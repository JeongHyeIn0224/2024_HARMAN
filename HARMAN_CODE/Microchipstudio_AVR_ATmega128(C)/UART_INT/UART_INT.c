#include "UART.h"

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