//----------------기본 모듈 완성(불꽃 감지 시 fire caution출력, 높은 온도 감지시 high temp 출력 ----------------------------------------//
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


// 함수 프로토 타입 선언
void BTN_ISR(void *CallBackRef);
void Iic_LCD_write_byte(u8 tx_data, u8 rs);
void Iic_LCD_init(void);
void Iic_movecursor(u8 row, u8 col);	// 커서 이동
void LCD_write_string(char *string);		// 문자열은 배열이기 때문에 주소값을 받는다
void Fire_Extinguisher_Status(u32 btn_status);
void readTempADCFlame (int temperature, int adc_data);

XGpio btn_3_device;
XGpio buzz_device;
XIic iic_device;
XIntc intc;		//인터럽트 초기화를 위한 인스턴스
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

	//gpio초기화
    cfg_ptr = XGpio_LookupConfig(BTN_3_ID);
    XGpio_CfgInitialize(&btn_3_device, cfg_ptr, cfg_ptr ->BaseAddress);
    XGpio_SetDataDirection(&btn_3_device, BTN_3_CHANNEL, 0b111);

     cfg_ptr = XGpio_LookupConfig(BUZZ_ID);
     XGpio_CfgInitialize(&buzz_device, cfg_ptr, cfg_ptr ->BaseAddress);
     XGpio_SetDataDirection(&buzz_device, BUZZ_CHANNEL, 0);	//출력


     //인터럽트 초기화 및 버튼 인터럽트, flame 인터럽트 연결
     XIntc_Initialize(&intc, INTC_ID);
     XIntc_Connect(&intc, BTN_3_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_3_device);

     XIntc_Enable(&intc, BTN_3_VEC_ID);	//글로벌 인터럽트 인에이블 //요걸 하면 인터럽트 컨트롤러가 활성화가 됨
     XIntc_Start(&intc, XIN_REAL_MODE); //시작
     //실제 모드 (Real Mode): 이 모드는 실제 하드웨어 인터럽트를 처리하기 위해 사용됩니다.
     //시뮬레이션 모드 (Simulation Mode): 이 모드는 시뮬레이션 환경에서 사용되며, 하드웨어 없이 인터럽트 처리를 시뮬레이션할 수 있습니다.

     XGpio_InterruptEnable(&btn_3_device, BTN_3_CHANNEL);	//어떤 걸 인터럽트 활성화 시킬거냐? 개별인터럽트인에이블
     XGpio_InterruptGlobalEnable(&btn_3_device);

     Xil_ExceptionInit();
     Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
      		   (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //마이크로 블레이즈 익셉션 해준 인에이블

    Xil_ExceptionEnable();//마이크로 블레이즈 인에이블 시켜줌으로 써 실행할 수 있게됨

    //IIC 초기화
        XIic_Initialize(&iic_device, IIC_ID);	//초기화

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
    	Iic_LCD_write_byte(0b00101110, DATA);	//NO. 도트
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
    	// gpio의 data 읽기
    	 buzz_data = XGpio_DiscreteRead(&buzz_device, BUZZ_CHANNEL);
    	 btn_3_data = XGpio_DiscreteRead(&btn_3_device, BTN_3_CHANNEL);
    	// xil_pinrtf("debug1");

    	 adc_data = adc[0];
         temperature = dht11[1];

         //온도 값 , adc값 읽기 ( 값이 계속 바뀌기 때문에 while문 안에서 읽기 )
    	 readTempADCFlame(temperature, adc_data);
    	 MB_Sleep(1000);

    	 //comportmaster에서 값이 느리게 출력되도록 함
        cnt +=1;
        if(cnt >=5){
        	cnt =0;
        	xil_printf("ADC Data: %d\n\r", adc_data);
        	xil_printf("Temperature is : %d\n\r" , temperature);
        }
//        xil_pinrtf("debug2");

        		MB_Sleep(100); // 반복문 지연을 추가하여 CPU 과부하 방지
     }
    cleanup_platform();
    return 0;
}


void BTN_ISR(void *CallBackRef){

		XGpio *Gpio_ptr = (XGpio *)CallBackRef;		// CallBack주소값을 gpio 포인터로 받음
		btn_int_flag = 1;
		XGpio_InterruptClear(Gpio_ptr, BTN_3_CHANNEL);
		return;
	}


void Iic_LCD_write_byte(u8 tx_data, u8 rs){	//1byte = 16bit  //d7 d6 d5 d4 BL EN RW RS
	u8 data_t[4] = {0,}; 	//0으로 초기화

	data_t [0] = (tx_data & 0xf0) | (1 << BL) | (rs & 1)| (1 <<EN);
	data_t [1] = (tx_data & 0xf0) | (1 << BL) | (rs & 1) ;
	data_t [2] = (tx_data << 4) | (1 << BL) | (rs & 1)| (1 <<EN);
	data_t [3] = (tx_data << 4) | (1 << BL) | (rs & 1) ;
	XIic_Send(iic_device.BaseAddress, 0x27, &data_t, 4, XIIC_STOP);
	//data_t [0] = (tx_data & 0b11110000) | 0b0001000 | 0b00000000 | 0b00000000	| rs&0b00000001 ;
			//상위 4bit만 남김 , BL 1로 , en 0 , RW 0 , RS는 한 비트만 남김(마지막 비트만 사용하기 위해 &함 )
	return;
}

void Iic_LCD_init(void){
	MB_Sleep(15); 	//15ms
	Iic_LCD_write_byte(0x33, COMMAND);
	Iic_LCD_write_byte(0x32, COMMAND);
	Iic_LCD_write_byte(0x28, COMMAND);
	Iic_LCD_write_byte(0x0c, COMMAND); //08하면 display off니까 on으로 만들기 위해 0c를 주었음
	Iic_LCD_write_byte(0x01, COMMAND);
	Iic_LCD_write_byte(0x06, COMMAND);

	MB_Sleep(10);
	return;
}

void Iic_movecursor(u8 row, u8 col){
	row %= 2 ; //row = 1 or 0 row에 3이 들어오면 안됨 //row = row %2 ;
	col %=40 ; //나머지가 40까지만 나옴
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

//ADC,Temp 구동함수
void readTempADCFlame (int temperature, int adc_data){

	    	if(temperature >=57) {	//led주황
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
