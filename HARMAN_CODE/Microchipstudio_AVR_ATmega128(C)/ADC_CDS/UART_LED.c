/*
 * UART_LED.c
 *
 * Created: 2024-04-09 오전 10:51:50
 *  Author: user
 */ 
#include "UART_LED.h"


void ledInit(LED *led)
{
	*(led->port - 1) |= (1<<led->pin);
}

void ledOn(LED *led)
{
	// 해당핀을 high 설정
	*(led->port) |= (1 << led->pin);
}

void ledOff(LED *led)
{
	// 해당 핀을 Low 로 설정
	*(led->port) &= ~(1 << led->pin);
}

void ledRight(LED *led)
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

	for (uint8_t i = 0; i < 8 ; i++)
	{
		ledOn(&leds[i]);
		_delay_ms(1000);
		ledOff(&leds[i]);
		_delay_ms(1000);
	}
}

void ledLeft (LED * led)
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

	for (uint8_t i = 7; i < 8 ; i--)
	{
		ledOn(&leds[i]);
		_delay_ms(1000);
		ledOff(&leds[i]);
		_delay_ms(1000);
	}
}