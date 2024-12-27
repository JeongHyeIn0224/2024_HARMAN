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

#define BTN_CHANNEL 1 //��ư ä�� 1��

void BTN_ISR(void *CallBackRef);
void SendHandler (void *CallBackRef, unsigned int EventData);
void RecvHandler (void *CallBackRef, unsigned int EventData);

XGpio btn_device;	//��ư �ʱ�ȭ�� ���� �ν��Ͻ�
XIntc intc;		//���ͷ�Ʈ �ʱ�ȭ�� ���� �ν��Ͻ�
XUartLite uart_device;

int main()
{
	XGpio_Config *cfg_ptr;
    init_platform();

    print("Start!!\n\r");

    XUartLite_Initialize(&uart_device, UART_ID); //uart �ʱ�ȭ ID�ָ� ���� �ּҰ� ã�Ƽ� �˾Ƽ���

    	//gpio�ʱ�ȭ
       //SetDirectionn�ϱ� ���� base add���� �ϴ� ��
       cfg_ptr = XGpio_LookupConfig(BTN_ID); //config����ü
       XGpio_CfgInitialize(&btn_device, cfg_ptr, cfg_ptr ->BaseAddress); //�� �Լ��� ����ü�� �����ؼ� �� �а� ��
       XGpio_SetDataDirection(&btn_device, BTN_CHANNEL, 0b1111);	//btn_device�� 1111�� �� 1�� �Է� 0�� ���

       //���ͷ�Ʈ ��Ʈ�ѷ� �ʱ�ȭ
       XIntc_Initialize(&intc, INTC_ID);

       //XUartLite_InterruptHandler-> �Լ� �̸� �̰��� �ּ� UART�� ����
       XIntc_Connect(&intc, UART_VEC_ID, (XInterruptHandler)XUartLite_InterruptHandler,
    		   (void *)&uart_device);

       //����Ʈ ���ſϷ� ���ͷ�Ʈ-Rev�߻�, �۽ſϷ� ���ͷ�Ʈ �߻� -Send�߻� //FuncPtr - �Լ� �̸�
       XUartLite_SetRecvHandler(&uart_device, RecvHandler, &uart_device);
       XUartLite_SetSendHandler(&uart_device, SendHandler, &uart_device);
       XUartLite_EnableInterrupt(&uart_device);

       //��ư gpio�� �Լ��� ��ư���Ϳ� ����
       //� �Լ��� ������� connect���� - � device���� �߻����� �� � �Լ� ������� connect ����
       XIntc_Connect(&intc, BTN_VEC_ID, (XInterruptHandler)BTN_ISR, (void *)&btn_device);
       //(&intc, Id, Handler, CallBackRef)
       //��� �߻��ߴ��� �˷��� &btn_device

       //���ͷ�Ʈ ��Ʈ�ѷ� Ȱ��ȭ
       XIntc_Enable(&intc, BTN_VEC_ID);	//�۷ι� ���ͷ�Ʈ �ο��̺� //��� �ϸ� ���ͷ�Ʈ ��Ʈ�ѷ��� Ȱ��ȭ�� ��
       XIntc_Enable(&intc, UART_VEC_ID);
       XIntc_Start(&intc, XIN_REAL_MODE); //����

       //gpio���ͷ�Ʈ ����
       XGpio_InterruptEnable(&btn_device, BTN_CHANNEL);	//� �� ���ͷ�Ʈ Ȱ��ȭ ��ų�ų�? �������ͷ�Ʈ�ο��̺�
       XGpio_InterruptGlobalEnable(&btn_device);

       //����ũ�κ������� �ͼ��� �ο��̺� �� �Լ�(XIntc_InterruptHandler)�� �̹� ������� ���� �ʱ�ȭ�� �ϸ��
       Xil_ExceptionInit(); //micro blaze�� ����enable����� �� //cpu(core)�̱� ������ �ּҰ� ���� �ʿ�������
       Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
    		   (Xil_ExceptionHandler)XIntc_InterruptHandler, &intc); //����ũ�� ������ �ͼ��� ���� �ο��̺�

       Xil_ExceptionEnable();//����ũ�� ������ �ο��̺� ���������� �� ������ �� �ְԵ�
		while(1){

       }
    cleanup_platform();
    return 0;
}

void BTN_ISR(void *CallBackRef){	//CallBack�ּҰ� -> int���� ��ư���� �� �츮�� ��ư���� ��
	XGpio *Gpio_ptr = (XGpio *) CallBackRef;	//callback�ּҰ��� gpio �����ͷ� ����
	print("btn interrupt \n\r");

	if(XGpio_DiscreteRead(Gpio_ptr, BTN_CHANNEL)& 0b0010)	{//left��ư Ȱ��ȭ �������� ����
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
	XUartLite_Recv(&uart_device, &rxData, 1); //1byte��
	//���ŵ� ���� UDR���� �о rxData�� 1byte�� �����Ѵ�.
	xil_printf("recv %c\n\r", rxData);

	return ;
}
