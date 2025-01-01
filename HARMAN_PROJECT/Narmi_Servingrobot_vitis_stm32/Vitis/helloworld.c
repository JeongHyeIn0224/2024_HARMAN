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

//최종
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xiic.h"
#include "xuartlite.h"

#define INTC_ID 		XPAR_INTC_0_DEVICE_ID
#define USB_UART_ID		XPAR_AXI_UARTLITE_0_DEVICE_ID
#define BT_UART_ID 	XPAR_AXI_UARTLITE_BT_DEVICE_ID
#define DC_IN_ID 		XPAR_GPIO_2_DEVICE_ID
#define IR_ID			XPAR_GPIO_4_DEVICE_ID
#define BTN_ID			XPAR_GPIO_0_DEVICE_ID
#define BUZZ_ID			XPAR_GPIO_1_DEVICE_ID
#define FND_ID			XPAR_GPIO_3_DEVICE_ID
#define pwm_servo_cntr_baseaddr XPAR_MYIP_PWM_SERVO_S00_AXI_BASEADDR


#define BTN_VEC_ID 		XPAR_INTC_0_GPIO_0_VEC_ID
#define UART_VEC_ID 	XPAR_INTC_0_UARTLITE_0_VEC_ID
#define BT_UART_VEC_ID XPAR_INTC_0_UARTLITE_1_VEC_ID

#define PWM_L_BASEADDR 	XPAR_MYIP_PWM_DC_L_S00_AXI_BASEADDR
#define PWM_R_BASEADDR 	XPAR_MYIP_PWM_DC_R_S00_AXI_BASEADDR
#define ultrasonic_baseaadr XPAR_MYIP_ULTRASONIC_0_S00_AXI_BASEADDR
#define dht_baseaddr XPAR_MYIP_DHT11_0_S00_AXI_BASEADDR
#define PWM_Servo_Duty PWM_SERVO[0]
#define PWM_Servo_Period PWM_SERVO[1]
#define DC_IN_CHANNEL 	1
#define IR_CHANNEL		1
#define BTN_CHANNEL  	1
#define GPIO_CHANNEL    1

#define IIC_ID XPAR_AXI_IIC_0_DEVICE_ID
#define BL 3
#define EN 2
#define RW 1
#define RS 0
#define COMMAND 0
#define DATA 1
#define RIGHT 1
#define LEFT 0

#define PWM_DUTY_L		pwm_l[0]
#define PWM_PERIOD_L	pwm_l[1]
#define PWM_ONOFF_L 	pwm_l[2]

#define PWM_DUTY_R		pwm_r[0]
#define PWM_PERIOD_R	pwm_r[1]
#define PWM_ONOFF_R		pwm_r[2]


XGpio IR;
XIic iic_device;

volatile char rxData[1];

// body없이 이름과 return값, 매개변수만 선언하는 함수 : 프로토 타입 선언 / 포로토 타입 선언을 해놓고 함수는 main문 아래에 작성 (코드 보기 편하라고 하는 짓)
void BTN_ISR(void *CallBackRef); //CallBackRef : 인터럽트가 발생된 디바이스
void SendHandler (void *CallBackRef, unsigned int EventData);
void RecvHandler (void *CallBackRef, unsigned int EventData);

void forward(void);
void backward(void);
void stop(void);
void turn_right(void);
void turn_left(void);
void line_trace();
void forward_3();
void Table(u8 rxData, u8 btn_status);
//void ServoMotor();
void ServoMotor(int wait, int table_status, int count);
XGpio dc_in_device;
XGpio ir_device;
XGpio btn_device;
XUartLite uart_device;
XUartLite bt_uart_device;

XIntc intc;		//인터럽트 초기화를 위한 인스턴스
XGpio buzz_device;



volatile unsigned int *pwm_l = (volatile unsigned int *) PWM_L_BASEADDR;
volatile unsigned int *pwm_r = (volatile unsigned int *) PWM_R_BASEADDR;
int ir_value_nk;
u8 DC_4bit;   // Debug 확인용
int count;
int turn;
int wait=0;
int lt=1; //line tracing

volatile u8 table_status;
volatile u8 pre_table_status;
volatile u8 exe_flag = 0;

void LCD_write_string(char *string);
void Iic_movecursor(u8 row, u8 col);
void Iic_LCD_init(void);
void Iic_LCD_write_byte(u8 tx_data, u8 rs) ;
void Ultrasonic_alert(u32 distance);


#define DOWN 0
#define UP 1


// Servo PWM
volatile unsigned int *PWM_SERVO = (volatile unsigned int)pwm_servo_cntr_baseaddr;



int main()
{
	XGpio_Config *cfg_ptr;
    init_platform();

    print("Start!!\n\r");

    XUartLite_Initialize(&uart_device, USB_UART_ID);
    XUartLite_Initialize(&bt_uart_device, BT_UART_ID);

    // I2C 초기화
        XIic_Initialize(&iic_device, IIC_ID);

	PWM_Servo_Period = 2000000;
	PWM_Servo_Duty = 50000;	// duty : 50000 ~ 250000


	//gpio dc 초기화
    cfg_ptr = XGpio_LookupConfig(DC_IN_ID); //config구조체
    XGpio_CfgInitialize(&dc_in_device, cfg_ptr, cfg_ptr ->BaseAddress); //이 함수가 구조체에 접근해서 값 읽고 씀
    XGpio_SetDataDirection(&dc_in_device, DC_IN_CHANNEL, 0b0000);	//dc_in_device에 1111을 줌 1이 입력 0이 출력

    XGpio_Initialize(&ir_device, IR_ID);
    XGpio_SetDataDirection(&ir_device, IR_CHANNEL, 0x7); // 3비트(0b111 = 0x7)를 입력으로 설정



    cfg_ptr = XGpio_LookupConfig(BTN_ID); //config구조체
    XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr ->BaseAddress); //이 함수가 구조체에 접근해서 값 읽고 씀
    XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);	//btn_device에 1111을 줌 1이 입력 0이 출력

    //Buzzer
    cfg_ptr = XGpio_LookupConfig(BUZZ_ID);
    	XGpio_CfgInitialize(&buzz_device, cfg_ptr, cfg_ptr->BaseAddress);
    	XGpio_SetDataDirection(&buzz_device, GPIO_CHANNEL, 0);	// buzz 채널을 출력으로 설정


    //인터럽트 컨트롤러 초기화
    XIntc_Initialize(&intc, INTC_ID);
    xil_printf("Check 1 \n\r");

    //어떤 함수가 실행될지 connect해줌 - 어떤 device에서 발생했을 때 어떤 함수 시행될지 connect 해줌
    XIntc_Connect(&intc, UART_VEC_ID, (XInterruptHandler)XUartLite_InterruptHandler, (void *)&uart_device);
    XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);
    XIntc_Connect(&intc, BT_UART_VEC_ID, (XInterruptHandler)XUartLite_InterruptHandler, (void *)&bt_uart_device);

    xil_printf("Check 2 \n\r");

    XUartLite_SetRecvHandler(&uart_device, RecvHandler, &uart_device);
    XUartLite_SetSendHandler(&uart_device, SendHandler, &uart_device);
    XUartLite_EnableInterrupt(&uart_device);
    XUartLite_SetRecvHandler(&bt_uart_device, RecvHandler, &bt_uart_device);
    XUartLite_SetSendHandler(&bt_uart_device, SendHandler, &bt_uart_device);
    XUartLite_EnableInterrupt(&bt_uart_device);
    xil_printf("Check 3 \n\r");

    //인터럽트 컨트롤러 활성화
    XIntc_Enable(&intc, BTN_VEC_ID);	// 버튼 인터럽트, 인터럽트 컨트롤러가 활성화가 됨
    XIntc_Enable(&intc, UART_VEC_ID);
    XIntc_Enable(&intc, BT_UART_VEC_ID);
    XIntc_Start(&intc, XIN_REAL_MODE); //시작
    xil_printf("Check 4 \n\r");

    //gpio btn 인터럽트 설정
	XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);	//어떤 걸 인터럽트 활성화 시킬거냐? 개별인터럽트인에이블
	XGpio_InterruptGlobalEnable(&btn_device);

    //마이크로블레이즈의 익셉션 인에이블 이 함수(XIntc_InterruptHandler)는 이미 만들어져 있음 초기화만 하면됨
    Xil_ExceptionInit(); //cpu입장에서의 예외처리micro blaze에 따로enable해줬던 것 //cpu(core)이기 때문에 주소가 따로 필요으없어
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //마이크로 블레이즈 익셉션 해준 인에이블
    Xil_ExceptionEnable();//마이크로 블레이즈 인에이블 시켜줌으로 써 실행할 수 있게됨
    xil_printf("Check 5 \n\r");

    // Ultrasonic
        volatile unsigned int *ULTRA_CNTR = (volatile unsigned int *)ultrasonic_baseaadr;
        u32 distance = 0;


        // DHT11
        volatile unsigned int *dht11 = (volatile unsigned int *)dht_baseaddr;	// 메모리가 32비트
        u32 temperature = 0;
        u32 humidity = 0;


    Iic_LCD_init();	// 함수 호출
	LCD_write_string("Nar-mi");
	Iic_movecursor(1, 0);
	LCD_write_string("No.  : ");


    while(1){
    	// Ultrasonic
		distance = ULTRA_CNTR[0];
		xil_printf("table_status is %d \n", table_status);
		xil_printf("wait is %d \n", wait);
		xil_printf("turn is %d \n", turn);
		xil_printf("count is %d \n\r", count);

		Ultrasonic_alert(distance);
		ServoMotor(wait, table_status, count);    // btn_status 값 나중에 수정

    	// LCD
		u8 btn_status = XGpio_DiscreteRead(&btn_device, BTN_CHANNEL);
//		u8 rec_data;
//		RecvHandler(&uart_device, &rec_data);


		Table(rxData,btn_status);

    	int control;
    	// 0 : 정지
    	// 1 : line tracing
    	// 2 : forward
    	// 3 : turn_left
    	// 4 : turn_right
    	// 5 : backward
    	ir_value_nk = XGpio_DiscreteRead(&ir_device, IR_CHANNEL);







    }
    cleanup_platform();
    return 0;
}


void forward_3(){
	XGpio_DiscreteWrite(&dc_in_device, 1, 0b0110);
	PWM_PERIOD_L = 1000;
	PWM_DUTY_L = 470;

	PWM_PERIOD_R = 1000;
	PWM_DUTY_R = 470;

	PWM_ONOFF_R=1;
	PWM_ONOFF_L=1;

	DC_4bit = XGpio_DiscreteRead(&dc_in_device, DC_IN_CHANNEL) & 0b1111;

}

void forward(){
	XGpio_DiscreteWrite(&dc_in_device, 1, 0b0110);
	PWM_PERIOD_L = 1000;
	PWM_DUTY_L = 450;

	PWM_PERIOD_R = 1000;
	PWM_DUTY_R = 450;

	PWM_ONOFF_R=1;
	PWM_ONOFF_L=1;

	DC_4bit = XGpio_DiscreteRead(&dc_in_device, DC_IN_CHANNEL) & 0b1111;

}

void backward(){
	XGpio_DiscreteWrite(&dc_in_device, 1, 0b1001);
	PWM_PERIOD_L = 1000;
	PWM_DUTY_L = 1000;
	PWM_ONOFF_R=1;
	PWM_ONOFF_L=1;
	PWM_PERIOD_R = 1000;
	PWM_DUTY_R = 1000;

	DC_4bit = XGpio_DiscreteRead(&dc_in_device, DC_IN_CHANNEL) & 0b1111;

}

void turn_left(){
	XGpio_DiscreteWrite(&dc_in_device, 1, 0b0101);
	PWM_PERIOD_L = 1000;
	PWM_DUTY_L = 493;
	PWM_ONOFF_R=1;
	PWM_ONOFF_L=1;
	PWM_PERIOD_R = 1000;
	PWM_DUTY_R = 475;

	DC_4bit = XGpio_DiscreteRead(&dc_in_device, DC_IN_CHANNEL) & 0b1111;

}

void turn_right(){
	XGpio_DiscreteWrite(&dc_in_device, 1, 0b1010);
	PWM_PERIOD_L = 1000;
	PWM_DUTY_L = 475;
	PWM_ONOFF_R=1;
	PWM_ONOFF_L=1;
	PWM_PERIOD_R = 1000;
	PWM_DUTY_R = 485;

	DC_4bit = XGpio_DiscreteRead(&dc_in_device, DC_IN_CHANNEL) & 0b1111;

}

void auto_turn_left(){
	XGpio_DiscreteWrite(&dc_in_device, 1, 0b0100);
	PWM_PERIOD_L = 1000;
	PWM_DUTY_L = 520;
	PWM_ONOFF_R=1;
	PWM_ONOFF_L=1;
	PWM_PERIOD_R = 1000;
	PWM_DUTY_R = 520;

	DC_4bit = XGpio_DiscreteRead(&dc_in_device, DC_IN_CHANNEL) & 0b1111;

}

void auto_turn_right(){
	XGpio_DiscreteWrite(&dc_in_device, 1, 0b0010);
	PWM_PERIOD_L = 1000;
	PWM_DUTY_L = 520;
	PWM_ONOFF_R=1;
	PWM_ONOFF_L=1;
	PWM_PERIOD_R = 1000;
	PWM_DUTY_R = 520;

	DC_4bit = XGpio_DiscreteRead(&dc_in_device, DC_IN_CHANNEL) & 0b1111;

}

void BTN_ISR(void *CallBackRef){
	XGpio *Gpio_ptr = (XGpio *)CallBackRef;  // GPIO의 주소로 받음 ;;


	    // 버튼 상태 확인: 두 번째 버튼이 눌렸는지 확인
	if(XGpio_DiscreteRead(Gpio_ptr, BTN_CHANNEL) & 0b0001){ //완료버튼 1번
		wait=0;
		count=count+1;
		xil_printf("button pushed!");
	}
	XGpio_InterruptClear(Gpio_ptr, BTN_CHANNEL); // 인터럽트 클리어

	return;
}
void stop(void){

	XGpio_DiscreteWrite(&dc_in_device, 1, 0b0000);

}

// UART 송신 완료 핸들러
void SendHandler(void *CallBackRef, unsigned int EventData){
    // 송신 완료 시 특별한 작업은 수행하지 않음


    return;
}

// UART 수신 완료 핸들러
void RecvHandler(void *CallBackRef, unsigned int EventData){
    u8 rxData;  // 수신된 데이터를 저장할 변수

//    XUartLite_Recv(&uart_device, &rxData, 1);  // 수신된 데이터를 읽어옴 (1바이트씩)
    XUartLite_Recv(&bt_uart_device, &rxData, 1);  // 수신된 데이터를 읽어옴 (1바이트씩)

    table_status=rxData; //
    return;
}


void line_trace(){
	if(!wait)
	{
		if(table_status == 49)
		{
			//tb1
			if(turn){
				if(count == 1){ //우회전
					auto_turn_right();
					print("table 1, turn 1, auto_turn_right, count 1\n");
					if(ir_value_nk == 2){ //010만나서 직진하기 전까지 turn_right 하라 //010까지
						turn =0;
					}
				}
				else if(count ==2){ //좌회전
					auto_turn_left();
					print("table 1, turn 1, auto_turn_left, count 2\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==3){ //정지
					print("Take your food and press the Finish button\n");
					stop();
					wait=1; //확인 버튼 누르면 wait=0;
				}
				else if(count ==4){ //180도 회전
					turn_left();
					print("table 1, turn 1, turn_right, count 4\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count == 5){
					auto_turn_right();
					print("table 1, turn 1, auto_turn_right, count 5\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count == 6){
					auto_turn_left();
					print("table 1, turn 1, auto_turn_left, count 6\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==7){ //좌회전
						stop();
						print("Arrived\n");
						table_status=0;
						pre_table_status=0;
						count=0;
						wait=0;
						turn=0;
				}
			}//turn
			else if(!turn){
				if(ir_value_nk == 7)//111 //교자로를 만나면!
				{   stop();
				print("crossway\n\r");
					MB_Sleep(500);
					count = count +1;
					turn=1;
				}
				else if(ir_value_nk == 4 || ir_value_nk == 3){ //100,110 //우회전
					auto_turn_right();
					print("Adjusting direction: auto_turn_right\n\r");
				}
				else if(ir_value_nk == 1 || ir_value_nk == 6){ //001,011 //좌회전
					auto_turn_left();
					print("Adjusting direction: auto_turn_left\n\r");
				}
				else if(ir_value_nk == 2){ //010 //직진
					forward();
					print("Adjusting direction: forward\n\r");
				}
				else{ //000, 101
					//하던거 유지
					print("Keep it\n\r");
				}
			}//!turn
	}//tb1
		else if(table_status == 50)
		{	//우,우, 좌
			if(turn){
				if(count == 1){ //우회전
					auto_turn_right();
					print("table 2, turn 1, auto_turn_right, count 1\n\r");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==2){ //우회전
					auto_turn_right();
					print("table 2, turn 1, auto_turn_right, count 2\n\r");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==3){ //좌회전
					auto_turn_left();
					print("table 2, turn 1, auto_turn_right, count 3\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==4){ //정지
					stop();
					print("Take your food and press the Finish button\n");
					wait=1; //확인 버튼 누르면 wait=0;
				}
				else if(count ==5){ //180도 회전
					turn_left();
					print("table 2, turn 1, turn_right, count 5\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count == 6){ //우
					auto_turn_right();
					print("table 2, turn 1, auto_turn_right, count 6\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count == 7){ //좌회전
					auto_turn_left();
					print("table 2, turn 1, auto_turn_left, count 7\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}

				else if(count == 8){//좌
					auto_turn_left();
					print("table 2, turn 1, auto_turn_left, count 8\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count == 9){//끝
					stop();
					print("Arrived\n");
					table_status=0;
					pre_table_status=0;
					count=0;
					turn=0;
					wait=0;
				}

			}
			else if(!turn){
				if(ir_value_nk == 7){ //111 //교자로를 만나면!
					stop();
					print("crossway\n");
					MB_Sleep(500);
					count = count +1;
					turn=1;
				}
				else if(ir_value_nk == 4 || ir_value_nk == 3){ //100,110 //우회전
					auto_turn_right();
					print("Adjusting direction: auto_turn_right\n");
				}
				else if(ir_value_nk == 1 || ir_value_nk == 6){ //001,011 //좌회전
					auto_turn_left();
					print("Adjusting direction: auto_turn_left\n");
				}
				else if(ir_value_nk == 2){ //010 //직진
					forward();
					print("Adjusting direction: forward\n");
				}
				else{ //000, 101
					//하던거 유지
					print("Keep it");
				}
			}

		}
		else if(table_status == 51)
		{
			if(turn){ //우우우, 좌좌좌
				if(count == 1){ //우회전
					auto_turn_right();
					print("table 3, turn 1, auto_turn_right, count 1\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==2){ //우회전
					auto_turn_right();
					print("table 3, turn 1, auto_turn_right, count 2\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==3){ //직진
					forward_3();
					print("table 3, turn 1, forward, count 3\n");
					MB_Sleep(500);
					turn =0;
				}
				else if(count ==4){ //우회전
					auto_turn_right();
					print("table 3, turn 1, auto_turn_right, count 4\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==5){ //정지
					stop();
					print("Take your food and press the Finish button\n");
					wait=1; //확인 버튼 누르면 wait=0;
				}
				else if(count ==6){ //180도 회전
					turn_left();
					print("table 3, turn 1, turn_right, count 6\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==7){ //좌회전
					auto_turn_left();
					print("table 3, turn 1, auto_turn_left, count 7\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count == 8){ //직진
					forward_3();
					print("table 3, turn 1, forward, count 8\n");
					MB_Sleep(500);
					turn =0;
				}
				else if(count == 9){ //좌
					auto_turn_left();
					print("table 3, turn 1, auto_turn_left, count 8\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count == 10){ //좌회전
					auto_turn_left();
					print("table 3, turn 1, auto_turn_left, count 9\n");
					if(ir_value_nk == 2){
						turn =0;
					}
				}
				else if(count ==11){//끝
					stop();
					print("Arrived\n");
					table_status=0;
					pre_table_status=0;
					count=0;
					turn=0;
					wait=0;
				}
			}
			else if(!turn){
				if(ir_value_nk == 7){ //111 //교자로를 만나면!
					stop();
					print("crossway\n");
					MB_Sleep(500);
					count = count +1;
					turn=1;
				}
				else if(ir_value_nk == 4 || ir_value_nk == 3){ //100,110 //우회전
					auto_turn_right();
					print("Adjusting direction: auto_turn_right\n");
				}
				else if(ir_value_nk == 1 || ir_value_nk == 6){ //001,011 //좌회전
					auto_turn_left();
					print("Adjusting direction: auto_turn_left\n");
				}
				else if(ir_value_nk == 2){ //010 //직진
					forward();
					print("Adjusting direction: forward\n");
				}
				else{ //000, 101
					//하던거 유지
					print("Keep it");
				}
			}
		}

		else {
			//유효한 테이블 넘버가 아닙니다. 출력하기
		}
	}
}//wait
//블루투스 새로운 신호가 들어올때마다 주차하기.

void Table(u8 rxData, u8 btn_status) {
	u8 btn_N = 0;

	if(rxData == 49 || rxData == 50 || rxData == 51) {
		if(rxData == 49) {
			table_status = 49;
		}
		if(rxData == 50) {
			table_status = 50;
		}
		if(rxData == 51) {
			table_status = 51;
		}
	}

	if(table_status != pre_table_status) {
		if(!exe_flag) {
			btn_N = 0;
			exe_flag = 1;
			pre_table_status = table_status;	// 다른 테이블 번호로 바뀌는 것을 막기 위해 넣은 코드

//			char message;
//			sprintf(message, "%d", pre_table_status);
			Iic_movecursor(1, 3);
			Iic_LCD_write_byte(pre_table_status, 1);   // 새로운 문구 출력
			Iic_movecursor(1, 8);
			LCD_write_string("Order ");
			//parking();
		}
	}

	if(btn_status == 0b0001) {
		btn_N = 1;
	}

	if(btn_N && exe_flag) {	// 서빙 완료
//		table_status = 0;	// 초기화
//		pre_table_status = 0;	// 초기화
		Iic_movecursor(1, 8);
		LCD_write_string("Served");
		exe_flag = 0;  // 처리 완료 표시
	}

}

void Iic_LCD_write_byte(u8 tx_data, u8 rs) {	// d7 d6 d5 d4 BL EN RW RS
	u8 data_t[4] = {0,};	// 배열 4개 0으로 초기화
	data_t[0] = (tx_data & 0Xf0) | (1 << BL) | (rs & 1) | (1 << EN);	// data는 상위 4bit	// rs가 1이면 최하위 비트가 1, 0이면 0	//	(tx_data & 0b11110000) | 0b00001000 | 0b00000000 | 0b00000000 | (rs & 0b00000001)
	data_t[1] = (tx_data & 0Xf0) | (1 << BL) | (rs & 1);
	data_t[2] = (tx_data << 4) | (1 << BL) | (rs & 1) | (1 << EN);	// 하위 4bit
	data_t[3] = (tx_data << 4) | (1 << BL) | (rs & 1);
	XIic_Send(iic_device.BaseAddress, 0x27, &data_t, 4, XIIC_STOP);
	return;
}

void Iic_LCD_init(void) {	// LCD 초기화
	MB_Sleep(15);
	Iic_LCD_write_byte(0x33, COMMAND);
	Iic_LCD_write_byte(0x32, COMMAND);
	Iic_LCD_write_byte(0x28, COMMAND);
	Iic_LCD_write_byte(0x0c, COMMAND);
	Iic_LCD_write_byte(0x01, COMMAND);
	Iic_LCD_write_byte(0x06, COMMAND);
	MB_Sleep(10);
	return;
}

void Iic_movecursor(u8 row, u8 col) {
	row %= 2; 	// 제한을 준다
	col %= 40;	// 제한을 준다
	Iic_LCD_write_byte(0x80 | (row << 6) | col, COMMAND);	// 0b10000000 커서 이동 명령
	return;
}

void LCD_write_string(char *string) {
	for(int i = 0;string[i];i++) {
		Iic_LCD_write_byte(string[i], DATA);
	}
	return;
}

void Ultrasonic_alert(u32 distance) {
	int ultra_flag;

	if(wait == 0) {
		if(distance <= 10) {
			stop();
			XGpio_DiscreteWrite(&buzz_device, GPIO_CHANNEL, 0);
			Iic_movecursor(0, 0);
			LCD_write_string("Watch Out!");
		}
		else {
			line_trace();
			XGpio_DiscreteWrite(&buzz_device, GPIO_CHANNEL, 1);
			Iic_movecursor(0, 0);
			LCD_write_string("Nar-mi       ");
		}
	}
	else if(wait==1){
		Iic_movecursor(0, 0);
		LCD_write_string("Nar-mi       ");
	}

}

//void ServoMotor() {
//
//	PWM_SERVO[1] = 2000000;	   // period
//
//	if(wait==0) {
//		PWM_Servo_Duty = 250000;
//}
//
//	else if(((table_status==1&&count==3)||(table_status==2&&count==4)||(table_status==1&&count==5))&&(wait==1)) {	// 도착 완료 신호
//
//		PWM_Servo_Duty = 50000; //열림
//	}
//}

void ServoMotor(int wait, int table_status, int count) {
	char up_down_flag = DOWN;


	if((table_status == 49 && count == 3) ||  (table_status == 50 && count == 4) || (table_status == 51 && count == 5)) {	// 도착 완료 신호
		up_down_flag = UP;
	}

	if(wait == 1) {
		if(up_down_flag == UP) {
			PWM_Servo_Duty = 230000;
			up_down_flag=DOWN;
			}
		}

	if(wait == 0) {
		if (up_down_flag == DOWN) {
			PWM_Servo_Duty = 70000; //열림
		}
	}
}

