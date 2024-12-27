/*
 * Button.c.c
 *
 * Created: 2024-03-26 오후 12:12:12
 * Author : user
 */ 
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>


int main(void)
{
	DDRA = 0xff; //포트 A를 출력 설정 
	DDRD  =DDRD & ~(1<<1); //입력을 받기위해 1번 핀 설정(다른 건 모름). 
	
	 //DDRD & = ~(1<<1); 
    /* Replace with your application code */
    while (1) 
    {
		if(PIND & (1<<1)) //버튼이 안눌리면 (1)이어서 밑에 문장 실행 
		{ //0x11 & 0x02 
			PORTA = 0x00; }
		
		else { PORTA |= 1<<4;}
		
    }
}

