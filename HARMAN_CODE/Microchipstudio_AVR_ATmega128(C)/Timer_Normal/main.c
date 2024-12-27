/*
 * Timer_Normal.c
 * CTC Mode와 같은 의미인데 출력을 OCn의 핀으로 
 *출력하는 것이 아니라 내가 지정할 수 있다. 
 * Created: 2024-04-05 오전 9:32:05
 * Author : user
 */ 
#define F_CPU 16000000UL
#include <avr/io.h>


int main(void)
{
	DDRD = 0xff; 
	PORTD = 0x00; //Low로 시작해서 TOP만나면 토글 
	
	//0b00000101;
	TCCR0 = (1<<CS02); //1을 얘 이름만큼 밀거야 // (1<<2)
	TCCR0 = (1<< CS00); //(1<<0)
	//TCCR0 | = (1<<CS02) | (1<< CS00); 
	////TCCR0 = TCCR0 | (1<<CS02) | (1<< CS00);
	
    while (1) 
    {
    }
}

