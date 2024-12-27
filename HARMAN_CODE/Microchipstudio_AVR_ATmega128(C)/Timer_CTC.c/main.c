/*
 * Timer_CTC.c //128분주 250Hz만듦 
 *
 * Created: 2024-04-04 오전 10:44:18
 * Author : user
 */ 
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
//CTC Mode: clear timer on compare match 

int main(void)
{
	DDRB = 0x10; //0b00010000 PB4출력//출력 설정 
	TCCR0 = 0x1D; //0b0001_1100 //데이터레지스터가지고 셋팅한 값 
	OCR0 = 249; //비교값 
    while (1) 
    {
		while ((TIFR & 0x02) ==0)
		{		 //0인지 아닌지 체크 
		};
		TIFR = 0x02; //다음 비교일치를 위해 해당 비트를 클리어 
		OCR0 =249; //새로 다시 시작 하는 거니까 재 셋팅 
		
    }
}
