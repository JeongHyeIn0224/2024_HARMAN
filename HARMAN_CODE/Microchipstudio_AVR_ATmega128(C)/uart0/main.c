/*
 * uart0.c
 *
 * Created: 2024-04-09 오후 2:03:50
 * Author : user
 */ 


#include <avr/io.h>
#include "uart0.h"


FILE OUTPUT = FDEV_SETUP_STREAM(USART0_Transmit, NULL, _FDEV_SETUP_WRITE);

//인터럽트가 발생하면 인터럽트를 해결하고
ISR(USART0_RX_vect)
{
	USART0_ISR_Process();
}
//인터럽트 해결된 후 진행됨
int main(void)
{

		UART0_init();
	stdout = &OUTPUT;  //출력스트림 설정
	while (1)
	{
		
	//	data = UART0_Receive();
	//	USART0_Transmit(data);
		
	
		UART0_execute(); //얘가 계속 반복될 거임
		
		
			
			if(ON=='N')
			{
				PORTA = 0xff;
			}
			
			else if(ON=='F')
			{
				PORTA = 0x00;

			}
			else if(data=='I')
			{
				for(int i=0; i<8; i++)
				{
					PORTA |= 0b10000000 >> i;
					_delay_ms(100);
					PORTA = 0x00;
				}
				PORTA = 0x00;
				
			}
			else if(data=='E')
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

