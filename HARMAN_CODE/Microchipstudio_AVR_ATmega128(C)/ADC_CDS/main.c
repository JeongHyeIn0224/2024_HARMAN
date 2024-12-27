/*
 * ADC_CDS.c
 *
 * Created: 2024-04-15 오전 10:14:48
 * Author : user
 */ 
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <stdio.h>
#include "UART.h"
#include "UART_LED.h"

FILE OUTPUT = FDEV_SETUP_STREAM(UART0_Transmit, NULL, _FDEV_SETUP_WRITE);

void ADC_Init()
{
	ADMUX |= (1<<REFS0); //기준전압 설정 
	ADCSRA |=(1<<ADPS2) | (1<<ADPS1) | (1<<ADPS0); //128분주 
	ADCSRA |= (1<<ADEN);	//인에이블  
	ADCSRA |= (1<<ADFR);	//러닝 모드?
}

int read_ADC(uint8_t channel) //읽어온 값 넘겨줄 거임 
{
	ADMUX =((ADMUX & 0xF0) | (channel & 0x0F)); //단일 입력 채널 선택
	ADCSRA |= (1<<ADSC);	//변환 시작 
	while(!(ADCSRA & (1<<ADIF)));	//변환 종료 대기 (변환마치고 데이터 들어옴 -> 데이터가 갱신되면 1로 set) -> 데이터 갱신은 종료의 의미
	
	return ADC;
}

//LED leds[8]=
//{
//{&PORTD, 0},
//{&PORTD, 1},
//{&PORTD, 2},
//{&PORTD, 3},
//{&PORTD, 4},
//{&PORTD, 5},
//{&PORTD, 6},
//{&PORTD, 7}
//};

int main(void)
{
	LED leds[8]=
	{
		{&PORTD, 0},
		{&PORTD, 1},
		{&PORTD, 2},
		{&PORTD, 3},
		{&PORTD, 4},
		{&PORTD, 5},
		{&PORTD, 6},
		{&PORTD, 7}
	};

	for(uint8_t i = 0; i < 8; i++)
	{
		ledInit(&leds[i]);
	}
	
	int read;
	 ADC_Init();
	 UART0_Init();
	stdout = &OUTPUT;
	
    while (1) 
    {
		read = read_ADC(0);
		printf("channel 0 : %d\n", read);
		_delay_ms(1000);
		
		if(0<=read && read<251)
		{
			for (uint8_t i = 0; i < 8 ; i++)
			{
				ledOn(&leds[i]);
			}
			printf("channel 0 : %d\n", read);
			_delay_ms(1000);
		}
		else if(251<=read && read<501)
		{
			for (uint8_t i = 0; i < 8 ; i++)
			{
				ledRight(&leds[i]);
			}
			printf("channel 0 : %d\n", read);
			//_delay_ms(1000);
		}
		else if(501<=read && read<751)
		{
			for (uint8_t i = 0; i < 8 ; i++)
			{
				ledLeft(&leds[i]);
			}
			printf("channel 0 : %d\n", read);
			//_delay_ms(1000);
		}
		else if(751<=read&& read<1024)
		{
			
			for (uint8_t i = 0; i < 8 ; i++)
			{
				ledOff(&leds[i]);
			}
			printf("channel 0 : %d\n", read);
			_delay_ms(1000);
		  }		
		
	}
}

