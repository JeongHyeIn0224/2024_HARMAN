/*
 * FND.c
 *
 * Created: 2024-03-27 오전 11:28:20
 * Author : user
 */ 
//FND하나짜리 
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>


int main(void)
{
    uint8_t FND_Number[]
	={0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x27, 0x7F, 0x67};
		
		
		int count =0;
		DDRA = 0xff; 
    while (1) 
    { //마이크로칩에서 int는 2byte -> 16bit 
		PORTA = FND_Number[count];
		count = (count + 1) % 10; //나머지를 다시 집어넣어줌 
		_delay_ms(500);
    }
}

