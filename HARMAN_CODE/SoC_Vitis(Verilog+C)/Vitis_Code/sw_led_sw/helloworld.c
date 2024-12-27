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

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xgpio.h"

#define LED_ID XPAR_GPIO_0_DEVICE_ID //xparameters.h 에 있음 우리가 만들 때 이름을 axi_gpio_sw_led로 만들었으니 sw가 2 led가 1인 것을 아는 거임 , 그리고 아이디를 줌
#define SW_ID XPAR_GPIO_0_DEVICE_ID
#define LED_CHANNEL 1
#define SW_CHANNEL 2

int main()
{
    init_platform();
    print("DEbug");
    print("Hello World\n\r");

    XGpio_Config *cfg_ptr;//구조체 주소를 하나 만들기 pointer ptr
    XGpio led_device, sw_device;

    u32 data =0; //32bit짜리 스위치 data선언
    cfg_ptr = XGpio_LookupConfig(LED_ID);	//ID가지고 GPIO찾음 LED_ID와 SW_ID같으니까 아무거나 줘도됨
    XGpio_CfgInitialize(&led_device, cfg_ptr, cfg_ptr->BaseAddress);
    //    XGpio_CfgInitialize(InstancePtr, Config, EffectiveAddr)

    XGpio_SetDataDirection(&led_device, LED_CHANNEL, 0); //led 는 출력 출력이면 0줘야하고 0이 16개면 0 되이ㅑ함   DirectionMast : 0
    //XGpio_SetDataDirection(InstancePtr, Channel, DirectionMask)

    XGpio_CfgInitialize(&sw_device,cfg_ptr,cfg_ptr ->BaseAddress);
    XGpio_SetDataDirection(&sw_device, SW_CHANNEL, 0xffff); //스위치는 출력이니까 1이 16개 ->ffff

    while(1){
    	data = XGpio_DiscreteRead(&sw_device, SW_CHANNEL);
    	XGpio_DiscreteWrite(&led_device, LED_CHANNEL, data);	//data읽어와서 led에서 출력
    	xil_printf("%x \n\r", data);
    	MB_Sleep(1000);
    }

    cleanup_platform();
    return 0;
}
