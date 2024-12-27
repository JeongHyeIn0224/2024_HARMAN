/*
 * Timer_Past_PWM.c
 *
 * Created: 2024-04-05 오전 10:39:52
 * Author : user
 */ 
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

int main(void)
{
	DDRB = (1<<PORTB4);//alt+g해서 보면 4임얘는 하나만//0x10 ; //0b00010000
	
	TCCR0 |= (1<<WGM00) | (1<<WGM01);
	TCCR0 |= (1<<COM01) | (1<<COM00);
	TCCR0 |= (1<<CS02) | (1<<CS01) |(0<<CS00);

	//TCCR0 = 0x6D;
	OCR0 =64;
    while (1) 
    {
		//for(int i=0; i<= 255; i++)
		//{
			//OCR0 = i;
			//_delay_ms(15);
		//}
		
    }
}

