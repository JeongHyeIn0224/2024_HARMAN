#include "LCD.h"
void LCD_Data(uint8_t data)
{
	LCD_DATA_PORT = data;
}
void LCD_WritePin()
{
	LCD_RW_PORT &= ~(1<<LCD_RW);	//RW핀을 LOW로 설정 -> 쓰기모드(핀 ASSIGNMENT)
}
void LCD_ReadPin()
{
	LCD_RW_PORT |= (1<<LCD_RW);		//RW핀을 HIGH로 설정 ->쓰기모드
}
void LCD_EnablePin()
{
	LCD_E_PORT &= ~(1<<LCD_E);		//E핀을 LOW로 설정
	LCD_E_PORT |= (1<<LCD_E);		//E핀을 HIGH로 설정
	LCD_E_PORT &= ~(1<<LCD_E);		//E핀을 LOW로 설정
	_delay_us(1600);				//일정시간 대기
}
void LCD_WriteCommand(uint8_t commandData)
{
	LCD_RS_PORT &= ~(1<<LCD_RS);	//RS핀을 LOW설정 -> 명령어모드(핀ASSIGNMENT봐)
	LCD_WritePin();				//데이터(명령어)를 쓸거야
	LCD_Data(commandData);		//명령어 데이터를 데이터핀에 전송
	LCD_EnablePin();
}
void LCD_WriteData(uint8_t charData)
{
	LCD_RS_PORT |= (1<<LCD_RS);	//RS 핀을 LOW로 설정->문자데이터 설정
	LCD_WritePin();					//데이터를(실제 문자) 쓸거야
	LCD_Data(charData);				//문자 데이터를 데이터핀에 전송
	LCD_EnablePin();				//LCD동작 신호 전송
}
void LCD_GotoXY(uint8_t row, uint8_t col)
{
	col %= 16;	//col 인덱스를 16으로 제한 (16개 열)
	row %= 2;	//row 인덱스를 2로 제한 (2행)
	uint8_t address = (0x40 * row) + col;	//주소계산
	uint8_t command = 0x80 + address;		//커맨드값 계산(주소설정)
	LCD_WriteCommand(command);				//주소설정 커맨드를 lcd전송
	
}
void LCD_WriteString(char *string)	//string은 c언어에서 배열로 인식
{
	for (uint8_t i = 0; string[i]; i++)
	{
		LCD_WriteData(string[i]);	//문자열의 각 문자를 출력
		
	}
}
void LCD_WriteStringXY(uint8_t row, uint8_t col, char *string)
{
	LCD_GotoXY(row,col);		//지정된 위치로 이동
	LCD_WriteString(string);	//문자열을 해당 위치부터 출력
}
void LCD_Init()
{
	LCD_DATA_DDR = 0xff;		// 데이터핀을 출력 설정
	LCD_RS_DDR |= (1<<LCD_RS);	// RS핀을 출력 설정
	LCD_RW_DDR |= (1<<LCD_RW);	// RW핀을 출력 설정
	LCD_E_DDR  |= (1<<LCD_E);	// E 핀을 출력 설정
	
	_delay_ms(20);				//15ms 이상 기다림
	LCD_WriteCommand(COMMAND_8_BIT_MODE);	//8bit 모드 설정0x38
	_delay_ms(5);				//4ms 이상 기다림
	LCD_WriteCommand(COMMAND_8_BIT_MODE);
	_delay_ms(5);				//100us 이상 기다림
	LCD_WriteCommand(COMMAND_8_BIT_MODE);		//8bit 모드 설정
	LCD_WriteCommand(COMMAND_8_BIT_MODE);		//8bit 모드 설정
	
	LCD_WriteCommand(COMMAND_DISPLAY_OFF);		//화면 켬
	LCD_WriteCommand(COMMAND_DISPLAY_CLEAR);	//화면클리어
	LCD_WriteCommand(COMMAND_DISPLAY_ON);		//화면 켬
	
	LCD_WriteCommand(COMMAND_ENTRY_MODE);		//엔트리모드
	
	
}