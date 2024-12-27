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
#define IIC_ID XPAR_AXI_IIC_0_DEVICE_ID
#define BTN_3_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID

#define RGB_BASEADDR XPAR_MYIP_LED_33_0_S00_AXI_BASEADDR
#define ULTRA_BASEADDR XPAR_MYIP_ULTRAOSNIC_0_S00_AXI_BASEADDR
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
void Iic_LCD_write_byte(u8 tx_data, u8 rs);
void Iic_LCD_init(void);
void Iic_movecursor(u8 row, u8 col);	// Ŀ�� �̵�
void LCD_write_string(char *string);		// ���ڿ��� �迭�̱� ������ �ּҰ��� �޴´�
void Fire_Extinguisher_Status(u32 btn_status);
void readTempADCFlame (int temperature, int adc_data);

XGpio btn_3_device;
XGpio buzz_device;
XIic iic_device;
XIntc intc;		//���ͷ�Ʈ �ʱ�ȭ�� ���� �ν��Ͻ�
XUartLite uart_device;

volatile char btn_int_flag;
  u8	buzz_data =0;
  u8	btn_3_data =0 ;

  int temperature ;
  int adc_data =0;
  int cnt;


volatile unsigned int *dht11 = (volatile unsigned int *) DHT_BASEADDR;
volatile unsigned int *ultrasonic = (volatile unsigned int *) ULTRA_BASEADDR;
volatile unsigned int *rgb_led = (volatile unsigned int *) RGB_BASEADDR;
volatile unsigned int *adc = (volatile unsigned int *) ADC_BASEADDR;

int main()
{
	XGpio_Config *cfg_ptr;
    init_platform();

    print("Start!! \n\r");

	//gpio�ʱ�ȭ
    cfg_ptr = XGpio_LookupConfig(BTN_3_ID);
    XGpio_CfgInitialize(&btn_3_device, cfg_ptr, cfg_ptr ->BaseAddress);
    XGpio_SetDataDirection(&btn_3_device, BTN_3_CHANNEL, 0b111);

     cfg_ptr = XGpio_LookupConfig(BUZZ_ID);
     XGpio_CfgInitialize(&buzz_device, cfg_ptr, cfg_ptr ->BaseAddress);
     XGpio_SetDataDirection(&buzz_device, BUZZ_CHANNEL, 0);	//���


     //���ͷ�Ʈ �ʱ�ȭ �� ��ư ���ͷ�Ʈ, flame ���ͷ�Ʈ ����
     XIntc_Initialize(&intc, INTC_ID);
     XIntc_Connect(&intc, BTN_3_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_3_device);

     XIntc_Enable(&intc, BTN_3_VEC_ID);	//�۷ι� ���ͷ�Ʈ �ο��̺� //��� �ϸ� ���ͷ�Ʈ ��Ʈ�ѷ��� Ȱ��ȭ�� ��
     XIntc_Start(&intc, XIN_REAL_MODE); //����
     //���� ��� (Real Mode): �� ���� ���� �ϵ���� ���ͷ�Ʈ�� ó���ϱ� ���� ���˴ϴ�.
     //�ùķ��̼� ��� (Simulation Mode): �� ���� �ùķ��̼� ȯ�濡�� ���Ǹ�, �ϵ���� ���� ���ͷ�Ʈ ó���� �ùķ��̼��� �� �ֽ��ϴ�.

     XGpio_InterruptEnable(&btn_3_device, BTN_3_CHANNEL);	//� �� ���ͷ�Ʈ Ȱ��ȭ ��ų�ų�? �������ͷ�Ʈ�ο��̺�
     XGpio_InterruptGlobalEnable(&btn_3_device);

     Xil_ExceptionInit();
     Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
      		   (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //����ũ�� ������ �ͼ��� ���� �ο��̺�

    Xil_ExceptionEnable();//����ũ�� ������ �ο��̺� ���������� �� ������ �� �ְԵ�

    //IIC �ʱ�ȭ
        XIic_Initialize(&iic_device, IIC_ID);	//�ʱ�ȭ

       Iic_LCD_init();

     rgb_led[0] =0;	//led_r
     rgb_led[1] =0;	//led_g
     rgb_led[2] =1;	//led_b

    while(1){

    	u32 btn_status = XGpio_DiscreteRead(&btn_3_device, BTN_3_CHANNEL);

    //	xil_pinrtf("debug");
//    	Iic_movecursor(1, 0);
//    	LCD_write_string("use:(0)(0)(0)");


    	Iic_movecursor(0,0);
    	LCD_write_string("NO");
    	Iic_LCD_write_byte(0b00101110, DATA);	//NO. ��Ʈ
    	LCD_write_string("1: X ");//(0,6)

    	LCD_write_string("No");
    	Iic_LCD_write_byte(0b00101110, DATA);
    	LCD_write_string("2: X ");//(0,12)

    	Iic_movecursor(1,0);

    	LCD_write_string("No");
    	Iic_LCD_write_byte(0b00101110, DATA);
    	LCD_write_string("3: X ");//(1,6)

    	if(btn_int_flag){
    		Fire_Extinguisher_Status(btn_status);
    				//btn_int_flag = 0;
    	}
    	// gpio�� data �б�
    	 buzz_data = XGpio_DiscreteRead(&buzz_device, BUZZ_CHANNEL);
    	 btn_3_data = XGpio_DiscreteRead(&btn_3_device, BTN_3_CHANNEL);
    	// xil_pinrtf("debug1");

    	 adc_data = adc[0];
         temperature = dht11[1];

         //�µ� �� , adc�� �б� ( ���� ��� �ٲ�� ������ while�� �ȿ��� �б� )
    	 readTempADCFlame(temperature, adc_data);
    	 MB_Sleep(1000);

    	 //comportmaster���� ���� ������ ��µǵ��� ��
        cnt +=1;
        if(cnt >=5){
        	cnt =0;
        	xil_printf("ADC Data: %d\n\r", adc_data);
        	xil_printf("Temperature is : %d\n\r" , temperature);
        }
//        xil_pinrtf("debug2");

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


void Iic_LCD_write_byte(u8 tx_data, u8 rs){	//1byte = 16bit  //d7 d6 d5 d4 BL EN RW RS
	u8 data_t[4] = {0,}; 	//0���� �ʱ�ȭ

	data_t [0] = (tx_data & 0xf0) | (1 << BL) | (rs & 1)| (1 <<EN);
	data_t [1] = (tx_data & 0xf0) | (1 << BL) | (rs & 1) ;
	data_t [2] = (tx_data << 4) | (1 << BL) | (rs & 1)| (1 <<EN);
	data_t [3] = (tx_data << 4) | (1 << BL) | (rs & 1) ;
	XIic_Send(iic_device.BaseAddress, 0x27, &data_t, 4, XIIC_STOP);
	//data_t [0] = (tx_data & 0b11110000) | 0b0001000 | 0b00000000 | 0b00000000	| rs&0b00000001 ;
			//���� 4bit�� ���� , BL 1�� , en 0 , RW 0 , RS�� �� ��Ʈ�� ����(������ ��Ʈ�� ����ϱ� ���� &�� )
	return;
}

void Iic_LCD_init(void){
	MB_Sleep(15); 	//15ms
	Iic_LCD_write_byte(0x33, COMMAND);
	Iic_LCD_write_byte(0x32, COMMAND);
	Iic_LCD_write_byte(0x28, COMMAND);
	Iic_LCD_write_byte(0x0c, COMMAND); //08�ϸ� display off�ϱ� on���� ����� ���� 0c�� �־���
	Iic_LCD_write_byte(0x01, COMMAND);
	Iic_LCD_write_byte(0x06, COMMAND);

	MB_Sleep(10);
	return;
}

void Iic_movecursor(u8 row, u8 col){
	row %= 2 ; //row = 1 or 0 row�� 3�� ������ �ȵ� //row = row %2 ;
	col %=40 ; //�������� 40������ ����
	Iic_LCD_write_byte(0x80 | (row <<6) | col, COMMAND);
	return;
}
void LCD_write_string(char *string){
	for (int i =0; string[i]; i++){
		Iic_LCD_write_byte(string[i], DATA);
	}
	return ;
}

void Fire_Extinguisher_Status(u32 btn_status) {
//	xil_pinrtf("debug3");

	   if (btn_status & 0b001) {
 		      printf("No.1 fire extinguisher is here\n\r");
 		      Iic_movecursor(0, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA); //o
 		   }
 		   if (btn_status & 0b010) {
 		      printf("No.2 fire extinguisher is here\n\r");
 		      Iic_movecursor(0, 14);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		   }
 		   if (btn_status & 0b100) {
 		      printf("No.3 fire extinguisher is here \n\r");
 		      Iic_movecursor(1, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		   }
 		   if ((btn_status & 0b011) == 0b011) {
// 		      printf("No.1, No.2 fire extinguisher in use\n\r");
 		      Iic_movecursor(0, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		      Iic_movecursor(0, 14);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		   }
 		   if ((btn_status & 0b101) == 0b101) {
// 		      printf("No.1, No.3 fire extinguisher in use\n\r");
 		      Iic_movecursor(0, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		      Iic_movecursor(1, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		   }
 		   if ((btn_status & 0b110) == 0b110) {
// 		      printf("No.2, No.3 fire extinguisher in use\n\r");
 		      Iic_movecursor(0, 14);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		      Iic_movecursor(1, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		    }
 		   if ((btn_status & 0b111) == 0b111) {
// 		      printf("All fire extinguisher in use\n\r");
 		      Iic_movecursor(0, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		      Iic_movecursor(0, 14);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		      Iic_movecursor(1, 6);
 		      Iic_LCD_write_byte(0b01001111, DATA);
 		    }
    MB_Sleep(100);
    return;
}

//ADC,Temp �����Լ�
void readTempADCFlame (int temperature, int adc_data){

	    	if(temperature >=57) {	//led��Ȳ
	    		rgb_led[0] = 1;	//led_r
	    		rgb_led[1] =0.65 ;	//led_g
	    		rgb_led[2] =0 ;	//led_b
	            XGpio_DiscreteWrite(&buzz_device, BUZZ_CHANNEL, 1);
	        	xil_printf("High temperature, be cautious!!\n\r ");

	    	}
	    	else {
						if (adc_data >= 1000) { //temp < 57 && adc_data >=1000
							rgb_led[0] = 120;  // led_r
							rgb_led[1] = 0;  // led_g
							rgb_led[2] = 0;  // led_b
							XGpio_DiscreteWrite(&buzz_device, BUZZ_CHANNEL, 1);
				        	xil_printf("Fire detected, be cautious!!\n\r ");

						}
						else if(adc_data < 1000){ //temp < 57 && adc_data <1000
							rgb_led[2] = 120;  // led_b
							rgb_led[0] = 0;
							rgb_led[1] = 0;
							XGpio_DiscreteWrite(&buzz_device, BUZZ_CHANNEL, 0);
						}
	    	}
	    	  return;

}
