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

//#include <stdio.h>
//#include "platform.h"
//#include "xil_printf.h"
//#include "xparameters.h"
//#include "xgpio.h"
//#include "xintc.h"
//#include "xil_exception.h"
//
//
//#define BTN_ID XPAR_GPIO_0_DEVICE_ID
//#define BTN_CHANNEL 1
//#define INTC_ID XPAR_INTC_0_DEVICE_ID
//#define BTN_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID
//#define STOPWATCH_BASEADDR XPAR_MYIP_STOPWATCH_0_S00_AXI_BASEADDR
//
//void BTN_ISR(void *CallBackRef);
//
//
//XGpio btn_device;	//버튼 초기화를 위한 인스턴스
//XIntc intc;
//volatile unsigned int * stopwatch ;
//char btn_int_flag; 	//flag 전역변수 선언
//
//int main()
//{
//	 u32 btn_value;
//	 init_platform();
//
//	print("Start!! \n\r");
//	XGpio_Config  *cfg_ptr;
//    XGpio btn_device;
//
//	 u16 data =0;
//
//	stopwatch = (volatile unsigned int *) STOPWATCH_BASEADDR;
//
//	 cfg_ptr = XGpio_LookupConfig(BTN_ID); //GPIO 설정정보 찾기
//	 XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr ->BaseAddress); //GPIO 장치 인스턴스 초기화
//	 XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);
//
//
//    //인터럽트 컨트롤러 초기화
//      XIntc_Initialize(&intc, INTC_ID);
//      XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);
//
//      XIntc_Enable(&intc, BTN_VEC_ID);	//글로벌 인터럽트 인에이블 //요걸 하면 인터럽트 컨트롤러가 활성화가 됨
//      XIntc_Start(&intc, XIN_REAL_MODE); //시작
//
//      XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);	//어떤 걸 인터럽트 활성화 시킬거냐? 개별인터럽트인에이블
//      XGpio_InterruptGlobalEnable(&btn_device);
//
//      Xil_ExceptionInit(); //micro blaze에 따로enable해줬던 것 //cpu(core)이기 때문에 주소가 따로 필요으없어
//      Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
//   		   (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //마이크로 블레이즈 익셉션 해준 인에이블
//
//      Xil_ExceptionEnable();//마이크로 블레이즈 인에이블 시켜줌으로 써 실행할 수 있게됨
//
//      while(1){
//    	  if(btn_int_flag){	//flag가 1일 때 동작하도록
//    		  btn_int_flag =0;
//    		  if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL)& 0b0001)	{//left버튼 활성화 나머지는 무시
//    		  		print("btn btn0 pushed \n\r");
//    		  		stopwatch[0] = 0b1;
//    		  		MB_Sleep(10);	//btn눌리는 시간 10msec
//    		  		stopwatch[0] = 0b0;
//    		  	}
//    		  	else if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL)& 0b0010)	{//left버튼 활성화 나머지는 무시
//    		  		print("btn btn1 pushed \n\r");
//    		  		stopwatch[0] = 0b10;
//    		  		MB_Sleep(10);
//    		  		stopwatch[0] = 0b0;
//    		  	}
//
//    		  	XGpio_InterruptClear(&btn_device, BTN_CHANNEL);
//    	  }
//      }
//
//    cleanup_platform();
//    return 0;
//}
//
//void BTN_ISR(void *CallBackRef){
//	btn_int_flag = 1; //flag 1만 셋팅
//	XGpio_InterruptClear(&btn_device, BTN_CHANNEL);
//
//	return;
//}

/////////////////////////////////////////////////////////////////////////////////////

//stopwatch
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xintc.h"
#include "xil_exception.h"


#define BTN_ID XPAR_GPIO_0_DEVICE_ID
#define BTN_CHANNEL 1
#define INTC_ID XPAR_INTC_0_DEVICE_ID
#define BTN_VEC_ID XPAR_INTC_0_GPIO_0_VEC_ID
#define STOPWATCH_BASEADDR XPAR_MYIP_STOPWATCH_0_S00_AXI_BASEADDR

void BTN_ISR(void *CallBackRef);


XGpio btn_device;	//버튼 초기화를 위한 인스턴스
XIntc intc;
volatile unsigned int * stopwatch ;
char btn_int_flag; 	//flag 전역변수 선언

int main()
{
	 u32 btn_value;
	 init_platform();

	print("Start!! \n\r");
	XGpio_Config  *cfg_ptr;

	 u16 data =0;

	stopwatch = (volatile unsigned int *) STOPWATCH_BASEADDR;

	 cfg_ptr = XGpio_LookupConfig(BTN_ID); //GPIO 설정정보 찾기
	 XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr ->BaseAddress); //GPIO 장치 인스턴스 초기화
	 XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);


    //인터럽트 컨트롤러 초기화
      XIntc_Initialize(&intc, INTC_ID);
      XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);

      XIntc_Enable(&intc, BTN_VEC_ID);	//글로벌 인터럽트 인에이블 //요걸 하면 인터럽트 컨트롤러가 활성화가 됨
      XIntc_Start(&intc, XIN_REAL_MODE); //시작

      XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);	//어떤 걸 인터럽트 활성화 시킬거냐? 개별인터럽트인에이블
      XGpio_InterruptGlobalEnable(&btn_device);

      Xil_ExceptionInit(); //micro blaze에 따로enable해줬던 것 //cpu(core)이기 때문에 주소가 따로 필요으없어
      Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
   		   (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //마이크로 블레이즈 익셉션 해준 인에이블

      Xil_ExceptionEnable();//마이크로 블레이즈 인에이블 시켜줌으로 써 실행할 수 있게됨

      while(1){
    	  if(btn_int_flag){	//flag가 1일 때 동작하도록
    		  btn_int_flag =0;
    		  print("if\n\r");
    		  MB_Sleep(1);	//채터링 제거를 위해 넣어줌
    		XGpio_InterruptEnable(&btn_device, BTN_CHANNEL );

    		  if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL)& 0b0001)	{//left버튼 활성화 나머지는 무시
    		  		print("btn btn0 pushed \n\r");
    		  		stopwatch[0] ^= 0b1;

    		  	}
    		  	else if(XGpio_DiscreteRead(&btn_device, BTN_CHANNEL)& 0b0010)	{//left버튼 활성화 나머지는 무시
    		  		print("btn btn1 pushed \n\r");
    		  		stopwatch[0] ^= 0b10;

    		  	}

    		  	XGpio_InterruptClear(&btn_device, BTN_CHANNEL);
    	  }
      }

    cleanup_platform();
    return 0;
}

void BTN_ISR(void *CallBackRef){
	btn_int_flag = 1; //flag 1만 셋팅
	XGpio_InterruptClear(&btn_device, BTN_CHANNEL);
	XGpio_InterruptDisable(&btn_device,BTN_CHANNEL );


	return;
}


