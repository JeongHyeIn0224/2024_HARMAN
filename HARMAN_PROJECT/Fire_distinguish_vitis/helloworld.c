/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

//----------------�⺻ ��� �ϼ�(�Ҳ� ���� �� fire caution���, ���� �µ� ������ high temp ��� ----------------------------------------//
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xiic.h"
#include "xuartlite.h"

#define INTC_ID XPAR_AXI_INTC_0_DEVICE_ID
#define UART_ID XPAR_AXI_UARTLITE_0_DEVICE_ID
#define BTN_3_ID XPAR_BTN_3_DEVICE_ID
#define BUZZ_ID XPAR_BUZZ_DEVICE_ID
#define IIC_STATE_ID XPAR_AXI_IIC_STATE_DEVICE_ID
#define IIC_CNTR_ID XPAR_AXI_IIC_CNTR_DEVICE_ID

#define BTN_3_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID
#define UART_VEC_ID XPAR_INTC_0_UARTLITE_0_VEC_ID

#define RGB_BASEADDR XPAR_MYIP_LED_33_0_S00_AXI_BASEADDR
#define DHT_BASEADDR XPAR_MYIP_DHT11_0_S00_AXI_BASEADDR
#define ADC_BASEADDR XPAR_MYIP_ADC_0_S00_AXI_BASEADDR

#define BTN_3_CHANNEL 1
#define BUZZ_CHANNEL  1

#define BL 3
#define EN 2
#define RW 1
#define RS 0

#define COMMAND 0
#define DATA 1


// �Լ� ������ Ÿ�� ����
void BTN_ISR(void *CallBackRef);
//void Iic_LCD_write_byte(u8 tx_data, u8 rs);
//void Iic_LCD_init(void);
//void Iic_movecursor(u8 row, u8 col);	// Ŀ�� �̵�
//void LCD_write_string(char *string);		// ���ڿ��� �迭�̱� ������ �ּҰ��� �޴´�

void Iic_LCD_cntr_write_byte(u8 tx_data, u8 rs);
void Iic_LCD_cntr_init(void);
void Iic_cntr_movecursor(u8 row, u8 col);
void LCD_cntr_write_string(char *string);

void Fire_Extinguisher_Status(u32 btn_status);
void readTempADCFlame (int temperature, int adc_data);
void SendHandler (void *CallBackRef, unsigned int EventData);
void RecvHandler (void *CallBackRef, unsigned int EventData);
void PrintHighTemp(void);

XGpio btn_3_device;
XGpio buzz_device;
XIic iic_state_device;
XIic iic_cntr_device;
XIntc intc;		//���ͷ�Ʈ �ʱ�ȭ�� ���� �ν��Ͻ�
XUartLite uart_device;

volatile char btn_int_flag;
  u8	buzz_data =0;
  u8	btn_3_data =0 ;

  int temperature ;
  int adc_data =0;
  int cnt;


volatile unsigned int *dht11 = (volatile unsigned int *) DHT_BASEADDR;
volatile unsigned int *rgb_led = (volatile unsigned int *) RGB_BASEADDR;
volatile unsigned int *adc = (volatile unsigned int *) ADC_BASEADDR;

int main()
{
	XGpio_Config *cfg_ptr;
    init_platform();

    print("Start!! \n\r");

    XUartLite_Initialize(&uart_device, UART_ID);

	//gpio�ʱ�ȭ
    cfg_ptr = XGpio_LookupConfig(BTN_3_ID);
    XGpio_CfgInitialize(&btn_3_device, cfg_ptr, cfg_ptr ->BaseAddress);
    XGpio_SetDataDirection(&btn_3_device, BTN_3_CHANNEL, 0b111);

     cfg_ptr = XGpio_LookupConfig(BUZZ_ID);
     XGpio_CfgInitialize(&buzz_device, cfg_ptr, cfg_ptr ->BaseAddress);
     XGpio_SetDataDirection(&buzz_device, BUZZ_CHANNEL, 0);	//���

     XIntc_Initialize(&intc, INTC_ID);

     XIntc_Connect(&intc, UART_VEC_ID, (XInterruptHandler)XUartLite_InterruptHandler,
              		   (void *)&uart_device);
     XIntc_Connect(&intc, BTN_3_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_3_device);

     //����Ʈ ���ſϷ� ���ͷ�Ʈ-Rev�߻�, �۽ſϷ� ���ͷ�Ʈ �߻� -Send�߻� //FuncPtr - �Լ� �̸�
     XUartLite_SetRecvHandler(&uart_device, RecvHandler, &uart_device);
     XUartLite_SetSendHandler(&uart_device, SendHandler, &uart_device);
     XUartLite_EnableInterrupt(&uart_device);

     //�ʱ�ȭ IIC_ID
     XIic_Initialize(&iic_cntr_device, IIC_CNTR_ID);
     XIic_Initialize(&iic_state_device, IIC_STATE_ID);

     XIntc_Enable(&intc, BTN_3_VEC_ID);	//�۷ι� ���ͷ�Ʈ �ο��̺� //��� �ϸ� ���ͷ�Ʈ ��Ʈ�ѷ��� Ȱ��ȭ�� ��
     XIntc_Enable(&intc, UART_VEC_ID);
     XIntc_Start(&intc, XIN_REAL_MODE); //����
     //���� ��� (Real Mode): �� ���� ���� �ϵ���� ���ͷ�Ʈ�� ó���ϱ� ���� ���˴ϴ�.
     //�ùķ��̼� ��� (Simulation Mode): �� ���� �ùķ��̼� ȯ�濡�� ���Ǹ�, �ϵ���� ���� ���ͷ�Ʈ ó���� �ùķ��̼��� �� �ֽ��ϴ�.

     XGpio_InterruptEnable(&btn_3_device, BTN_3_CHANNEL);	//� �� ���ͷ�Ʈ Ȱ��ȭ ��ų�ų�? �������ͷ�Ʈ�ο��̺�
     XGpio_InterruptGlobalEnable(&btn_3_device);

     Xil_ExceptionInit();
     Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
      		   (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //����ũ�� ������ �ͼ��� ���� �ο��̺�

    Xil_ExceptionEnable();//����ũ�� ������ �ο��̺� ���������� �� ������ �� �ְԵ�

       Iic_LCD_init(&iic_state_device);
       Iic_LCD_init(&iic_cntr_device);

     rgb_led[0] =0;	//led_r
     rgb_led[1] =0;	//led_g
     rgb_led[2] =1;	//led_b

    while(1){

    	u32 btn_status = XGpio_DiscreteRead(&btn_3_device, BTN_3_CHANNEL);

    	Iic_movecursor(&iic_state_device,0,2);
    	LCD_write_string(&iic_state_device,"1:");
//    	Iic_LCD_write_byte(&iic_state_device,'1st', DATA);	//NO. ��Ʈ
    	LCD_write_string(&iic_state_device,"X ");//(0,6)

    	LCD_write_string(&iic_state_device,"2:");
//    	Iic_LCD_write_byte(&iic_state_device,'', DATA);
    	LCD_write_string(&iic_state_device,"X ");//(0,12)

//    	Iic_movecursor(&iic_state_device,1,0);

    	LCD_write_string(&iic_state_device,"3:");
//    	Iic_LCD_write_byte(&iic_state_device, ':', DATA);
    	LCD_write_string(&iic_state_device,"X");//(1,6)



    	if(btn_int_flag){
    		Fire_Extinguisher_Status(btn_status);
    				//btn_int_flag = 0;
    	}
    	// gpio�� data �б�
    	 buzz_data = XGpio_DiscreteRead(&buzz_device, BUZZ_CHANNEL);
    	 btn_3_data = XGpio_DiscreteRead(&btn_3_device, BTN_3_CHANNEL);

         //�µ� �� , adc�� �б� ( ���� ��� �ٲ�� ������ while�� �ȿ��� �б� )
    	 readTempADCFlame(temperature, adc_data);
    	 MB_Sleep(10);

    	 //comportmaster���� ���� ������ ��µǵ��� ��
        cnt +=1;
        if(cnt >=10){
        	cnt =0;
        	xil_printf("Flame Sensor degree is: %d\n\r", adc_data);
        	xil_printf("Temperature is : %d\n\r" , temperature);
        }
        		MB_Sleep(100); // �ݺ��� ������ �߰��Ͽ� CPU ������ ����
     }
    cleanup_platform();
    return 0;
}


void BTN_ISR(void *CallBackRef){

		XGpio *Gpio_ptr = (XGpio *)CallBackRef;		// CallBack�ּҰ��� gpio �����ͷ� ����
		btn_int_flag = 1;
		XGpio_InterruptClear(Gpio_ptr, BTN_3_CHANNEL);
		return;
	}

///////////////////////////////////////////////////////////////////////////////////////////////////////////
//iic_state�� �Լ�
void Iic_LCD_write_byte(XIic *iic_device, u8 tx_data, u8 rs){	//1byte = 16bit  //d7 d6 d5 d4 BL EN RW RS
	u8 data_t[4] = {0,}; 	//0���� �ʱ�ȭ

	data_t [0] = (tx_data & 0xf0) | (1 << BL) | (rs & 1)| (1 <<EN);
	data_t [1] = (tx_data & 0xf0) | (1 << BL) | (rs & 1) ;
	data_t [2] = (tx_data << 4) | (1 << BL) | (rs & 1)| (1 <<EN);
	data_t [3] = (tx_data << 4) | (1 << BL) | (rs & 1) ;
	XIic_Send(iic_device->BaseAddress, 0x27, &data_t, 4, XIIC_STOP);
	//data_t [0] = (tx_data & 0b11110000) | 0b0001000 | 0b00000000 | 0b00000000	| rs&0b00000001 ;
			//���� 4bit�� ���� , BL 1�� , en 0 , RW 0 , RS�� �� ��Ʈ�� ����(������ ��Ʈ�� ����ϱ� ���� &�� )
	return;
}

void Iic_LCD_init(XIic *iic_device){
	MB_Sleep(15); 	//15ms
	Iic_LCD_write_byte(iic_device,0x33, COMMAND);
	Iic_LCD_write_byte(iic_device,0x32, COMMAND);
	Iic_LCD_write_byte(iic_device,0x28, COMMAND);
	Iic_LCD_write_byte(iic_device,0x0c, COMMAND); //08�ϸ� display off�ϱ� on���� ����� ���� 0c�� �־���
	Iic_LCD_write_byte(iic_device,0x01, COMMAND);
	Iic_LCD_write_byte(iic_device,0x06, COMMAND);

	MB_Sleep(10);
	return;
}

void Iic_movecursor(XIic *iic_device, u8 row, u8 col){
	row %= 2 ; //row = 1 or 0 row�� 3�� ������ �ȵ� //row = row %2 ;
	col %=40 ; //�������� 40������ ����
	Iic_LCD_write_byte(iic_device, 0x80 | (row <<6) | col, COMMAND);
	return;
}
void LCD_write_string(XIic *iic_device, char *string){
	for (int i =0; string[i]; i++){
		   if (i == 16) {
		    Iic_movecursor(iic_device ,1, 0);
		   }
		Iic_LCD_write_byte(iic_device, string[i], DATA);
	}
	return ;
}



void Fire_Extinguisher_Status(u32 btn_status) {
    switch (btn_status & 0b111) {
        case 0b001:
            printf("No.1 fire extinguisher is present\n\r");
            Iic_movecursor(&iic_state_device,0, 4);
            Iic_LCD_write_byte(&iic_state_device, 0b01001111, DATA); // 'O'
            break;

        case 0b010:
            printf("No.2 fire extinguisher is present\n\r");
            Iic_movecursor(&iic_state_device,0, 8);
            Iic_LCD_write_byte(&iic_state_device, 0b01001111, DATA);
            break;

        case 0b100:
            printf("No.3 fire extinguisher is present\n\r");
            Iic_movecursor(&iic_state_device,0, 12);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            break;

        case 0b011:
            printf("No.1, No.2 fire extinguishers are present\n\r");
            Iic_movecursor(&iic_state_device,0, 4);
            Iic_LCD_write_byte(&iic_state_device, 0b01001111, DATA);
            Iic_movecursor(&iic_state_device,0, 8);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            break;

        case 0b101:
            printf("No.1, No.3 fire extinguishers are present\n\r");
            Iic_movecursor(&iic_state_device,0, 4);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            Iic_movecursor(&iic_state_device,0, 12);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            break;

        case 0b110:
            printf("No.2, No.3 fire extinguishers are present\n\r");
            Iic_movecursor(&iic_state_device,0, 8);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            Iic_movecursor(&iic_state_device,0, 12);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            break;

        case 0b111:
            printf("All fire extinguishers are present\n\r");
            Iic_movecursor(&iic_state_device,0, 4);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            Iic_movecursor(&iic_state_device,0, 12);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            Iic_movecursor(&iic_state_device,0, 8);
            Iic_LCD_write_byte(&iic_state_device,0b01001111, DATA);
            break;

        default:
            // Handle unexpected cases or errors
            printf("Unknown fire extinguisher status\n\r");
            break;

    }

    MB_Sleep(500);
}

//ADC,Temp �����Լ�
void readTempADCFlame (int temperature, int adc_data){
	while(1){
			adc_data = adc[0];
			temperature = dht11[1];
		if (adc_data >= 500 && temperature >=57 ) { //temp < 57 && adc_data >=1000
					rgb_led[0] = 120;  // led_r
					rgb_led[1] = 0;  // led_g
					rgb_led[2] = 0;  // led_b
					XGpio_DiscreteWrite(&buzz_device, BUZZ_CHANNEL, 1);
					xil_printf("Fire detected, be cautious!!\n\r ");
					 PrintFiredetect();

			}
			else {
				if(temperature >=57 && adc_data < 1000 || temperature <57 && adc_data >= 1000) {	//led��Ȳ
				rgb_led[0] = 120;	//led_r
				rgb_led[1] =100 ;	//led_g
				rgb_led[2] =0 ;	//led_b
				XGpio_DiscreteWrite(&buzz_device, BUZZ_CHANNEL, 1);
				xil_printf("Warning,  be cautious!!\n\r ");
				PrintHighTemp();

				}
				else { //temp < 57 && adc_data <1000
					rgb_led[2] = 120;  // led_b
					rgb_led[0] = 0;
					rgb_led[1] = 0;
					XGpio_DiscreteWrite(&buzz_device, BUZZ_CHANNEL, 0);
					PrintSafe();
					return;
				}
		}
	}
}

void SendHandler (void *CallBackRef, unsigned int EventData){
	return;
}
void RecvHandler (void *CallBackRef, unsigned int EventData){
	u8 rxData;
	XUartLite_Recv(&uart_device, &rxData, 1);	// 1byte��
	// ���ŵ� ���� UDR���� �о rxData�� 1byte�� �����Ѵ�.
//	uart_flag = 1;
	if(rxData == '1') {
		Iic_movecursor(&iic_state_device,1, 0);  // Ŀ���� ù ��° ��, ù ��° ���� �̵�
		LCD_write_string(&iic_state_device,  "No");		// ������ ����
		Iic_LCD_write_byte(&iic_state_device, '.', DATA);
		LCD_write_string(&iic_state_device,  "1 Repair need");
	}
	if(rxData == '2') {
		Iic_movecursor(&iic_state_device,  1, 0);  // Ŀ���� ù ��° ��, ù ��° ���� �̵�
		LCD_write_string(&iic_state_device, "No");		// ������ ����
		Iic_LCD_write_byte(&iic_state_device,  0b00101110, DATA);
		LCD_write_string(&iic_state_device,  "2 Repair need");
	}
	if(rxData == '3') {
		Iic_movecursor(&iic_state_device,  1, 0);  // Ŀ���� ù ��° ��, ù ��° ���� �̵�
		LCD_write_string(&iic_state_device,  "No");		// ������ ����
		Iic_LCD_write_byte(&iic_state_device,  0b00101110, DATA);
		LCD_write_string(&iic_state_device,  "3 Repair need");
	}
	if(rxData == 'o') {	// ���� �Ϸ� �� LCD clear
		Iic_movecursor(&iic_state_device, 1, 9);  // Ŀ���� ù ��° ��, ù ��° ���� �̵�
		Iic_LCD_init(&iic_state_device);
	}

	xil_printf("%c \n\r", rxData);
	return;

}


void Printrepair (void){
	Iic_LCD_write_byte(&iic_cntr_device,0x01, COMMAND);
	MB_Sleep(10);
	Iic_movecursor(&iic_cntr_device,0,0);
    LCD_write_string(&iic_cntr_device,"    Device is    ");
	Iic_movecursor(&iic_cntr_device,1,0);
    LCD_write_string(&iic_cntr_device,"  being repaired ");
    return;

}

//LCD�� hightemp�߰� �ϱ� ���� �Լ�
void PrintHighTemp (void){
	Iic_LCD_write_byte(&iic_cntr_device,0x01, COMMAND);
	MB_Sleep(10);
	Iic_movecursor(&iic_cntr_device,0,0);
    LCD_write_string(&iic_cntr_device,"      Warning    ");
	Iic_movecursor(&iic_cntr_device,1,0);
    LCD_write_string(&iic_cntr_device,"  be cautious!!  ");

    return;
}

void PrintSafe(void){
Iic_movecursor(&iic_cntr_device,0,0);
LCD_write_string(&iic_cntr_device,"    Safe Now     ");
Iic_movecursor(&iic_cntr_device,1,0);
LCD_write_string(&iic_cntr_device,"   Don't Worry   ");

return;
}


//LCD�� Firedetected �߰� �ϱ� ���� �Լ�
void PrintFiredetect (void){
	Iic_movecursor(&iic_cntr_device,0,0);
    LCD_write_string(&iic_cntr_device," Fire detected  ");
	Iic_movecursor(&iic_cntr_device,1,0);
    LCD_write_string(&iic_cntr_device,"  sprinkler!!   ");

    return;
}
