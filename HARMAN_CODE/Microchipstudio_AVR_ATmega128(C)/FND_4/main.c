/*
 * FND_4.c //FND 4개 표시 
 *
 * Created: 2024-03-27 오후 12:16:28
 * Author : user
 */ 
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

#define FND_DATA_DDR DDRA
#define FND_SELECT_DDR DDRC //digit select
#define FND_DATA_PORT PORTA
#define FND_SELECT_PORT PORTC 

//16bit쓰겠다. 1byte쓰면 255까지만 나타냄
void FND_Display(uint16_t data) //2자릿수 사용을 위한 2byte(16bit,16진수)
{
	static uint8_t position = 0; 
	uint8_t fndData[10] 
	={0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x27, 0x7F, 0x67};
		//segment(0~dp)표시하는 배열 
	
	switch(position) //출력할 자리(position)에 따라 해당 자리 출력 
	{
		case 0: 
		// 첫번째 자리 출력위해 , 0번핀 LOW, 1,2,3 HIGH  VCC를 칩과 연결해서 LOW되는 곳이 켜짐 
		FND_SELECT_PORT &= ~(1<<0); //0 digit ON 
		//0000_1110 & 1111 1110 -> 0의 자리만 0이 나옴 
		//캐소드 타입이라 gnd에 0이 들어가야 전류가 흐를 수 있음.  
		FND_SELECT_PORT |=(1<<1) | (1<<2) | (1<<3); //1,2,3 digit OFF
		//0000_1110
		//입력된 데이터의 천의 자리를 구해서 해당 FND 데이터 값 출력 
		FND_DATA_PORT = fndData[data/1000]; 
		break;
		
		case 1:
		FND_SELECT_PORT &= ~(1<<1); //0 digit ON
		
		FND_SELECT_PORT |=(1<<0) | (1<<2) | (1<<3); //1,2,3 digit OFF
	
		FND_DATA_PORT = fndData[data/100 % 10] ;
		break;
		
		case 2:
		FND_SELECT_PORT &= ~(1<<2); //0 digit ON
		
		FND_SELECT_PORT |=(1<<0) | (1<<1) | (1<<3); //1,2,3 digit OFF
		
		FND_DATA_PORT = fndData[data/10 %10] ;
		break;
		
		case 3:
		FND_SELECT_PORT &= ~(1<<3); //0 digit ON
		
		FND_SELECT_PORT |=(1<<0) | (1<<1) | (1<<2); //1,2,3 digit OFF
		
		FND_DATA_PORT = fndData[data % 10];
		break;
	}
	position++; //다음 자리 이동 
	position = position % 4; //숫자표시하는 것X, 위치 표시하는 것 
}



int main(void)
{
	FND_DATA_DDR =0xff;
	FND_SELECT_DDR =0xff;
	FND_SELECT_PORT=0x00;
	
	uint16_t count =0;
	uint16_t timeTick = 0;
	uint32_t prevTime =0; 

    while (1) 
    {
		FND_Display(count);
		if(timeTick - prevTime > 100)//100ms가 지날 때마다 count값을 1씩 증가시킬 거야
		{
			prevTime = timeTick;
			count++;
		}
		_delay_ms(1); //100바퀴 돈다 
		timeTick++;
		 
    }
}

