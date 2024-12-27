/*
 * Button_1.c
 *
 * Created: 2024-03-26 오후 2:37:26
 * Author : user
 */ 
//버튼 2개로 양쪽으로 옮겨가는 코드 
#define	F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
int main(void)
{
	DDRA = 0xff;	// LED연결 A포트는 모두 출력으로 사용하겠다. 
	//DDRC = 0x00; //DDRC 레지스터 전체를 버튼 입력으로 설정 //   1번째 
	
	//DDRC = DDRC & ~(1<<PINC0); //0번핀만 입력설정          //2번째방법
	//DDRC = DDRC & ~(1<<PINC1); //1번핀만 입력설정          //2번째방법	
	//DDRC = DDRC & ~(1<<PINC2); //2번핀만 입력설정 	         //2번째방법
	
	//DDRC의 0,1,2번 핀만... 입력 설정 연산자를 사용함 
	DDRC = DDRC & (~(1<<PINC0) | ~(1<<PINC1) | ~(1<<PINC2)); 
	//어느 포트를 입력으로 가져다가 쓴 지 알기 위해 표현해준 식 
	//8bit 모두 0이나와도 입력 or 출력 어느 것으로 쓰는지 알기 위해 꼭 써줘야함 
	//그러나 메모리가 부족한 경우에는 생략가능 
	
	
	//DDRC = DDRC & (~(1<<0) | ~(1<<1) | ~(1<<2)); //위에 놈과 같음 
	
	
	//DDRC = 0x00; //DDRC 레지스터 전체를 버튼 입력으로 설정
	
	uint8_t ledData = 0x01;
	uint8_t buttonData;	// 버튼 입력을 받을 변수 설정
	int flag = 0;	// ATmega128에서 int형은 2byte임
	PORTA = 0x00;	// LED 꺼진 상태로 출발
	
	while (1)
	{
		buttonData = PINC;
		if ((buttonData & (1<<0)) == 0) //0이랑 and하면 무조건 0 입력이 들어오면 pull up 때문에 0이됨  
		{								//버튼을 눌렀을 때 밑에 식을 실행한다. 	
			ledData = (ledData >> 7) | (ledData << 1);
			PORTA = ledData;
			_delay_ms(300);
		}
		if ((buttonData & (1<<1)) == 0)
		{
			ledData = (ledData >> 1) | (ledData << 7);
			PORTA = ledData;
			_delay_ms(300);
		}
		if (flag == 0) 
		{
			if ((buttonData & (1<<2)) == 0) //눌리면 실행 
			{
				flag = 1;
			}
			else
			{
				flag = 0;
			}
		}
		if (flag == 1)
		{
			for (uint8_t i = 0; i < 3; i++) //3번 실행 
			{
				PORTA = 0xff;
				_delay_ms(500);
				PORTA = 0x00;
				_delay_ms(500);
			}
			flag = 0;
		}
	}
}