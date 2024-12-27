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
//iic_dht11
#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xiic.h"

#define IIC_ID XPAR_AXI_IIC_0_DEVICE_ID
#define DHT_BASEADDR XPAR_MYIP_DHT11_0_S00_AXI_BASEADDR


#define BL 3
#define EN 2
#define RW 1
#define RS 0

#define COMMAND 0 //0대신 command 주기 위함
#define DATA 1

#define LEFT 0
#define RIGHT 1
#define SHFIT 1
#define CURSOR 0
XIic iic_device;

void Iic_LCD_write_byte(u8 tx_data, u8 rs);
void Iic_LCD_init(void);
void Iic_gotoXY(u8 row, u8 col);
void LCD_write_string(char *string);
void LCD_display_shift( u8 RL );
int main()
{

	//dht11은 배열이 됨
	volatile unsigned int *dht11 = (volatile unsigned int *) DHT_BASEADDR;

	u8 data =0;
	u32 temperature =0;
	u32 humidity =0;

    init_platform();

    print("Start!! \n\r");

    XIic_Initialize(&iic_device, IIC_ID);	//초기화

    Iic_LCD_init( );
    LCD_write_string("Temperature:00");
    Iic_LCD_write_byte(0b11011111, DATA);
    Iic_LCD_write_byte('C', DATA);
    Iic_movecursor(1,0);
    LCD_write_string("Humidity:00%");

    char cnt =0, right_left_flag =0;

    while(1){
    	temperature = dht11[0];
    	Iic_movecursor(0,12);
    	Iic_LCD_write_byte('0'+ temperature/10%10, DATA);		//2 출력 원함
    	Iic_LCD_write_byte('0'+ temperature %10, DATA);	//2 출력 원함

    	humidity = dht11[1];
    	Iic_movecursor(1,9);
    	Iic_LCD_write_byte('0'+ humidity/10%10, DATA)	;//2 출력 원함
    	Iic_LCD_write_byte('0'+ humidity %10, DATA);	//2 출력 원함
    }

    cleanup_platform();
    return 0;
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


void LCD_display_shift( u8 RL ){

	Iic_LCD_write_byte(0x10 | 1<<3 | RL<<2, COMMAND);	//3 = SC

	return ;
}

