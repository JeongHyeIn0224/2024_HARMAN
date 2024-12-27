/*
 * uart0.c
 *
 * Created: 2024-04-09 오후 2:04:52
 *  Author: user
 */ 

#include "uart0.h"

uint8_t uart0RxBuff [100];
uint8_t uart0RxCFlag;

void UART0_init()
{
	
	UCSR0B |= (1 << RXEN0) | (1 << TXEN0); // Enable Rx and Rx
	UCSR0A |= (1 << U2X0); // Double the speed of internal clock
	UBRR0L = 207; // 16: 115200bps, 207: 9600 bps
	UCSR0B |= (1 << RXCIE0); // Enable Receiver interrupt
	
	DDRA=0xff;
	PORTA=0xff;
	sei();
}

uint8_t UART0_getRxFlag() //플래그의 현재상태가져옴
{
	return uart0RxCFlag;
}

void UART0_clearRxFlag()
{
	uart0RxCFlag = 0;  //그 플래그의 상태가 clear가있고
}

void UART0_setReadyRxFlag()
{
	uart0RxCFlag = 1; //플래그의 상태가 set이 있음
}

uint8_t *UART0_readRxBuff()
{
	return uart0RxBuff;
}

void USART0_Transmit( unsigned char data )
{
	while ( !( UCSR0A & (1 << UDRE0)));
	UDR0 = data;
}

unsigned char UART0_Receive( void )
{
	while ( !(UCSR0A & (1 << RXC0)));
	return UDR0;
}

void UART0_print(char *str)
{
	for (int i = 0; str[i]; i++)
	{
		USART0_Transmit(str[i]);
	}
	USART0_Transmit('\n');
}

uint8_t UART0_Avail()
{
	// If there is RxData, return 0. Otherwise, return 1.
	if ( !(UCSR0A & (1 << RXC0)) )
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

//인터럽트 발생 시 하나씩 쌓아올림
//\n가 들어오면 그 때 데이터 들어오게 한다.
void USART0_ISR_Process()
{
	uint8_t rx0Data = UDR0;
	static uint8_t uart0RxTail = 0;
	// Insert null (\0) at the end of corresponding string and initialize a tail to 0 when \n detected
	if (rx0Data == '\n')
	{
		uart0RxBuff[uart0RxTail] = rx0Data;
		uart0RxTail++;
		uart0RxBuff[uart0RxTail] = '\0'; //배열의 문자 끝을 알림
		uart0RxTail = 0;
		UART0_setReadyRxFlag();
	}
	else //인터럽스 발생 시 아직 문자열 안 끝남
	{
		uart0RxBuff[uart0RxTail] = rx0Data; //배열의 0번인덱스에다가 rxData를 집어넣음
		uart0RxTail++; //배열의 인덱스를 1로 만듦
	}
}

void UART0_execute() //플래그의 현재 상태를 가져왔더니 0or1임
{
	if (UART0_getRxFlag()) //플래그의 현재 상태가 1인 경우 if문 참되서 실행
	{
		UART0_clearRxFlag();
		uint8_t *rxString = UART0_readRxBuff(); //버퍼라는 곳에 있는 애를 스트링이라는 포인터변수에 집어넣음
		//uint8_t가 없으면 rxString에 UART0_read의 값을 넣겠다는 의미
		//하지만 있으니까 rxString 포인터 변수 선언
		//UART0_readRxBuff 호출하면 uart0RxBuff를 항상 리턴
		//uart0RxBuff는 배열값임
		printf(rxString);
	}
	_delay_ms(300); //플래그의 현재 상태가 0인 경우
}