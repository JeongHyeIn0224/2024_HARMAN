/*
 * LCD_8bit.c
 *
 * Created: 2024-04-11 오후 12:26:16
 * Author : user
 */ 

//#define F_CPU 16000000UL
//#include <avr/io.h>
//#include <avr/delay.h>
#include <stdio.h>
#include "LCD.h"
int main(void)
{
	LCD_Init();
	LCD_GotoXY(0,0);
	//LCD_WriteString("hello lcd");
	//LCD_GotoXY(1,0);
	//LCD_WriteString("hello avr");
	
	char buff[30];
	LCD_Init();
	sprintf(buff, "hello avr");
	LCD_WriteStringXY(0,0,buff);
	int count =0;
	
	
	while (1)
	{
		sprintf(buff,"count : %d", count++);
		LCD_WriteStringXY(1,0,buff);
		_delay_ms(200);

	}
}