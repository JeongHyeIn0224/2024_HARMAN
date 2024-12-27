/*
 * UART.c
 *
 * Created: 2024-04-09 오후 4:58:09
 *  Author: user
 */ 
#include "UART.h"

void UART0_Init()    // UART 초기화
{
	// speed    9600bps
	UBRR0H = 0x00;
	UBRR0L = 207;
	// 비동기, 8bit, parity 없음, 1bit stop bit
	UCSR0A |= (1<<U2X0); // 2배속 모드

	UCSR0B |= (1<<RXEN0); // 수신 가능
	UCSR0B |= (1<<TXEN0); // 송신 가능

	// UCSR0C |= (1<<UCSZ01) | (1<<UCSZ00); // =0x06; // 8bit여서 손댈게 없음 그래서 생략가능
	UCSR0B |= (1<<RXCIE0); // 수신 UART0 인터럽트 인에이블 // 인에이블을 안주면 오류도 안뜨고 동작이 안됨
}

void UART0_Transmit(char data)
{
	while (!(UCSR0A & (1<<UDRE0))); // UDR이 비어있는지?
	// 송신준비가 되면 UCSR0A가 1이되서 and 연산 후 반전이 되면 0이 되서 빠져나갈수 있게 된다.
	UDR0 = data;
}

unsigned char UART0_Receive()
{
	while(!(UCSR0A & (1<<RXC0))); // 수신대기
	return UDR0;
}