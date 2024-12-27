/*
 * Timer_16_PWM.c
 * 64 prescaler , 100Hz 
 * Created: 2024-04-05 오후 12:37:15
 * Author : user
 */ 

#include <avr/io.h>
#define F_CPU 16000000
#include <avr/io.h>
#include <util/delay.h>

//64분주기 100hz 
//int main(void)
//{
	//DDRB = (1<<PORTB5); //0b0010000
	//TCCR1A |= (1<< COM1A1) | (1<<WGM11);
	//TCCR1B |= (1<<WGM13) |(1<<WGM12) |(1<<CS11) |(1<<CS10);
	//
	//OCR1A = 625; //duty 비 //2499*0.25
	//ICR1 = 2499; //top값
	//while (1)
	//{
	//}
//}



////64분주기 50hz, top값 4999, OCR:1249,  
//int main(void)
//{
	//DDRB = (1<<PORTB5); //0b0010000
	//TCCR1A |= (1<< COM1A1) | (1<<WGM11);
	//TCCR1B |= (1<<WGM13) |(1<<WGM12) |(1<<CS11) |(1<<CS10);
	//
	//OCR1A = 1249; //duty 비 //4999*0.25
	//ICR1 = 4999; //top값 
    //while (1) 
    //{
    //}
//}

//64분주기 50hz 만들기  듀티비 40% 
int main(void)
{
	DDRB = (1<<PORTB5); //0b0010000
	TCCR1A |= (1<< COM1A1) | (1<<WGM11);
	TCCR1B |= (1<<WGM13) |(1<<WGM12) |(1<<CS11) |(1<<CS10);
	
	//OCR1A = 2499; //duty 비 //4999*0.50
	ICR1 = 4999; //top값 최대 62xxx만 안넘으면 됨 
	while (1)
	{
		OCR1A = 570;
		_delay_ms(500);
		OCR1A= 105;
		_delay_ms(500);
	}
}
