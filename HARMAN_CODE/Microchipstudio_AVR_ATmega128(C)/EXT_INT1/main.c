/*
 * EXT_INT1.c
 *
 * Created: 2024-03-27 오후 3:40:07
 * Author : user
 */ 
#define F_CPU 16000000UL //항상 맨 위에 
#include <avr/io.h>
#include <avr/interrupt.h> //인터럽트 쓰기 위한 헤더파일 
#include <util/delay.h>

ISR(INT4_vect)//외부인터럽트 4번에 어떤 이벤트가 발생이 되면 얘를 실행해라 함수임
{
	PORTA =0xff; //0번포트 사용 
}

ISR(INT5_vect)
{
	PORTA =0x00; //1번포트 사용 
}

int main(void)
{
		DDRA = 0xff; //LED 출력
		
	//외부 인터럽트 INT4(PE4), INT5(PE5) 사용 
	//INT4 EICRa,b falling일 때 
	//00000010
	EICRB |= (1<<ISC41) | (0<<ISC40); 
	//INT5 EICRb, Rising 일 때 
	//00001100
	EICRB |=(1<< ISC51) | (1 << ISC50);
	EIMSK |=(1<<INT5) | (1<<INT4); //1로 세팅해야 작동됨 
	
	DDRE &= ~(1<<DDRE4) | ~(1<<DDRE5); //버튼  0번핀 1번핀 

	sei();
	
    while (1) 
    {
    }
}

