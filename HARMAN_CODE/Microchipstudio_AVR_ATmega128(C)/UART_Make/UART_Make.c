/*
 * UART_Make.c
 *
 * Created: 2024-04-08 오후 2:55:06
 *  Author: user
 */ 
#include "UART_Make.h"

void UART0_Init() //초기화 함수
{
	//speed 9600bps
	UBRR0H = 0x00;
	UBRR0L = 207;
	//비동기, 8bit, 패리티없음, 1비트 stop
	UCSR0A |= (1<<U2X0); //2배속 모드
	
	// UCSR0C |= (1<<UCSZ01) |(1<< UCSZ00) //=0x06;
	UCSR0B |= (1<<RXEN0); //수신 가능
	UCSR0B |= (1<<TXEN0); //송신가능
	
	DDRA=0xff;
	PORTA=0xff;
}

void UART0_Transmit(char data)
{
	while (!(UCSR0A & (1<<UDRE0))); //UDR이 비어 있는지?
	UDR0 =  data;
	
}

unsigned char UART0_Receive ()
{
	while(!(UCSR0A & (1<<RXC0)));//수신 대기
	return UDR0; //UCR0이라는 레지스터뭔가 들어오면 보내고, 안받았으면 그냥 보낼거임
}


