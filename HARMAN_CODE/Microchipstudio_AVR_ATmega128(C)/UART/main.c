/*
 * UART.c
 *
 * Created: 2024-04-08 오전 9:48:50
 * Author : user
 */ 

#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include "UART.h"
int main(void)
{
	UART0_Init();
    while (1) 
    {
		UART0_Transmit(UART0_Receive()); //받은 내용을 그대로 보낼 거임 
    }
}

