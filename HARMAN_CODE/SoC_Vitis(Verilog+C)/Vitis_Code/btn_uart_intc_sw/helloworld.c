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
//btn_uart
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xintc.h"
#include "xil_exception.h"
#include "xuartlite.h"

#define BTN_ID XPAR_AXI_GPIO_0_DEVICE_ID
#define UART_ID XPAR_UARTLITE_0_DEVICE_ID
#define INTC_ID XPAR_AXI_INTC_0_DEVICE_ID
#define BTN_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID
#define UART_VEC_ID XPAR_INTC_0_UARTLITE_0_VEC_ID

#define BTN_CHANNEL 1 //버튼 채널 1번

void BTN_ISR(void *CallBackRef);
void SendHandler (void *CallBackRef, unsigned int EventData);
void RecvHandler (void *CallBackRef, unsigned int EventData);

XGpio btn_device;	//버튼 초기화를 위한 인스턴스
XIntc intc;		//인터럽트 초기화를 위한 인스턴스
XUartLite uart_device;

int main()
{
	XGpio_Config *cfg_ptr;
    init_platform();

    print("Start!!\n\r");

    XUartLite_Initialize(&uart_device, UART_ID); //uart 초기화 ID주면 지가 주소값 찾아서 알아서함

    	//gpio초기화
       //SetDirectionn하기 위해 base add가서 하는 거
       cfg_ptr = XGpio_LookupConfig(BTN_ID); //config구조체
       XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr ->BaseAddress); //이 함수가 구조체에 접근해서 값 읽고 슴
       XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);	//btn_device에 1111을 줌 1이 입력 0이 출력

       //인터럽트 컨트롤러 초기화
       XIntc_Initialize(&intc, INTC_ID);

       //XUartLite_InterruptHandler-> 함수 이름 이것은 주소 UART의 연결
       XIntc_Connect(&intc, UART_VEC_ID, (XInterruptHandler)XUartLite_InterruptHandler,
    		   (void *)&uart_device);

       //유아트 수신완료 인터럽트-Rev발생, 송신완료 인터럽트 발생 -Send발생 //FuncPtr - 함수 이름
       XUartLite_SetRecvHandler(&uart_device, RecvHandler, &uart_device);
       XUartLite_SetSendHandler(&uart_device, SendHandler, &uart_device);
       XUartLite_EnableInterrupt(&uart_device);

       //버튼 gpio의 함수를 버튼벡터와 연결
       //어떤 함수가 실행될지 connect해줌 - 어떤 device에서 발생했을 때 어떤 함수 시행될지 connect 해줌
       XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);
       //(&intc, Id, Handler, CallBackRef)
       //어디서 발생했는지 알려줌 &btn_device

       //인터럽트 컨트롤러 활성화
       XIntc_Enable(&intc, BTN_VEC_ID);	//글로벌 인터럽트 인에이블 //요걸 하면 인터럽트 컨트롤러가 활성화가 됨
       XIntc_Enable(&intc, UART_VEC_ID);
       XIntc_Start(&intc, XIN_REAL_MODE); //시작

       //gpio인터럽트 설정
       XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);	//어떤 걸 인터럽트 활성화 시킬거냐? 개별인터럽트인에이블
       XGpio_InterruptGlobalEnable(&btn_device);

       //마이크로블레이즈의 익셉션 인에이블 이 함수(XIntc_InterruptHandler)는 이미 만들어져 있음 초기화만 하면됨
       Xil_ExceptionInit(); //micro blaze에 따로enable해줬던 것 //cpu(core)이기 때문에 주소가 따로 필요으없어
       Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
    		   (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //마이크로 블레이즈 익셉션 해준 인에이블

       Xil_ExceptionEnable();//마이크로 블레이즈 인에이블 시켜줌으로 써 실행할 수 있게됨
		while(1){

       }
    cleanup_platform();
    return 0;
}

void BTN_ISR(void *CallBackRef){	//CallBack주소값 -> int인지 버튼인지 모름 우리가 버튼인지 앎
	XGpio *Gpio_ptr = (XGpio *) CallBackRef;	//callback주소값을 gpio 포인터로 받음
	print("btn interrupt \n\r");

	if(XGpio_DiscreteRead(Gpio_ptr, BTN_CHANNEL)& 0b0010)	{//left버튼 활성화 나머지는 무시
		print("btn left pushed \n\r");
	}

	XGpio_InterruptClear(Gpio_ptr, BTN_CHANNEL);
	return;
}


void SendHandler (void *CallBackRef, unsigned int EventData){
	return;
}
void RecvHandler (void *CallBackRef, unsigned int EventData){
	u8 rxData; //unsigned 8bit = u8
	XUartLite_Recv(&uart_device, &rxData, 1); //1byte씩
	//수신된 값을 UDR에서 읽어서 rxData에 1byte를 저장한다.
	xil_printf("recv %c\n\r", rxData);

	return ;
}
