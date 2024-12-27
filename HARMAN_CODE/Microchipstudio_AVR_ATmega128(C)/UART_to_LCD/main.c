/*
 * UART_to_LCD.c
 *
 * Created: 2024-04-12 오후 3:02:03
 * Author : user
 */ 

#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <stdio.h>
#include "UART.h"
#include "I2C_LCD.h"

// 출력 스트림 설정 <stdio.h>에 있는 표준 입출력
FILE OUTPUT = FDEV_SETUP_STREAM(UART0_Transmit, NULL, _FDEV_SETUP_WRITE);

uint8_t indexMotion;

char rxBuff[100] = {0}; // 수신 버퍼 설정, 0으로 초기화
uint8_t rxFlag = 0; // 수신 완료 플래그설정

ISR(USART0_RX_vect) // UART 수신 인터럽트 핸들러
{
	static uint8_t rxHead = 0; // 수신된 데이터의 인덱스
	uint8_t rxData = UDR0; // 수신된 데이터
	
	if (rxData == '\n' || rxData == '\r') // '\n' 개행문자나, '\r' 리턴, 이면..
	{
		//rxBuff[rxHead] = rxData;
		//rxHead++;
		rxBuff[rxHead] = '\0'; // 수신된 문자열의 마지막에 NULL(0) 추가
		
		indexMotion = rxHead;
		
		rxHead = 0; // 인덱스를 초기화하고
		rxFlag = 1; // 문자열 수신 플래그를 set clear
	}
	else // 그렇지 않으면 계속 문자를 받음
	{
		rxBuff [rxHead] = rxData; // 버퍼에 수신된 데이터 추가
		rxHead++; // 인덱스를 증가시킨다.
	} //
}

int main(void)
{
	LCD_Init();
	UART0_Init();
	uint8_t rxData; // 데이터 수신
	stdout = &OUTPUT; // 출력스트림 저장
	 sei(); 
	while(1)
	{
		if(rxFlag==1)
		{
			rxFlag ==0;
			LCD_WriteCommand(COMMAND_DISPLAY_CLEAR);
			LCD_WriteStringXY(0, 0, rxBuff);
			_delay_ms(100);
			indexMotion = 0;
		}
		  
		 // 전역 인터럽트 활성화
		  // cli(); // 전역 인터럽트 비활성화
	}
	return 0;
}