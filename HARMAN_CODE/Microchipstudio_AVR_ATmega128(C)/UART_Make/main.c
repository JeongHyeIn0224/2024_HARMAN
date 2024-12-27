/*
 * UART_Make.c
 *
 * Created: 2024-04-08 오후 2:13:24
 * Author : user
 */ 

#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "UART_Make.h"
int main(void)
{
	uint8_t data = 0x01;
	UART0_Init();
	while (1)
	{
			data = UART0_Receive();
			UART0_Transmit(data); //받은 내용을 그대로 보낼 거임
		
		if(data=='a')
		{
			PORTA = 0xff;
		}
		
		else if(data=='b')
		{
			PORTA = 0x00;

		}
		else if(data=='c')
		{
			for(int i=0; i<8; i++)
			{
					PORTA |= 0b10000000 >> i;
					_delay_ms(100);
					PORTA = 0x00; 
			}
			PORTA = 0x00; 
			
		}
		else if(data=='d')
		{
			for(int i=0; i<8; i++)
			{
				PORTA |= 1<< i;
				_delay_ms(100);
				PORTA = 0x00;
			}
			PORTA = 0x00;


		}
		
	}
	
}

