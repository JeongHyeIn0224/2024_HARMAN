/*
 * LCD_4bit.c
 *
 * Created: 2024-04-11 오후 3:17:09
 *  Author: user
 */ 
//#include <util/delay.h>
#include "LCD_4bit.h"

void LCD_Data(uint8_t data)
{
	LCD_DATA_PORT = data; // 데이터를 LCD 데이터 핀에 출력
}

void LCD_Data4bit(uint8_t data) //data보낼 때 스는 거 
//상위비트와 하위비트를 둘 다 표시해준 것 
//8비트의 데이터를 보내주기 위한 함수 
{
	LCD_DATA_PORT = (LCD_DATA_PORT & 0x0f) | (data & 0xf0); // 상위 4비트를 LCD 데이터 핀에 출력
	LCD_EnablePin(); // LCD 동작 신호 전송
	LCD_DATA_PORT = (LCD_DATA_PORT & 0x0f) | ((data & 0x0f) << 4); // 하위 4비트를 LCD 데이터 핀에 출력
	LCD_EnablePin(); // LCD 동작 신호 전송
}

//상위비트만 표시해주는 것 
//상위비트만 빼서 보여주기 위한 함수 즉, 상위 4비트를 뽑아서 command를 보내는 함수 
void LCD_Data4bitInit(uint8_t data)// write command보낼 대 스는 거 
{
	LCD_DATA_PORT = (LCD_DATA_PORT & 0x0f) | (data & 0xf0); // 상위 4비트를 LCD 데이터 핀에 출력
	LCD_EnablePin(); // LCD 동작 신호 전송
}


void LCD_WriteMode()
{
	LCD_RW_PORT &= ~(1<<LCD_RW); // RW 핀을 LOW로 정하여 쓰기 모드로 설정
}


void LCD_EnablePin()
{
	LCD_E_PORT &= ~(1<<LCD_E); // E 핀을 LOW로 설정
	LCD_E_PORT |= (1<<LCD_E); // E 핀을 HIGH로 설정하여 동작 신호 전송
	LCD_E_PORT &= ~(1<<LCD_E); // E 핀을 다시 LOW로 설정
	_delay_us(1800); // 일정 시간동안 대기 (맞춤 시간, 실제 딜레이 값은 상황에 따라 조정 가능)
}

void LCD_WriteCommand(uint8_t commandData)
{
	LCD_RS_PORT &= ~(1<<LCD_RS); // RS 핀을 LOW로 설정하여 명령어 모드로 설정 요자리만 무조건 0->명령어 모드 
	LCD_WriteMode(); // 쓰기 모드로 설정
	LCD_Data4bit(commandData); // 명령어 데이터를 LCD 데이터 핀에 출력
}

void LCD_WriteCommandInit(uint8_t commandData)
{
	LCD_RS_PORT &= ~(1<<LCD_RS); // RS 핀을 LOW로 설정하여 명령어 모드로 설정
	LCD_WriteMode(); // 쓰기 모드로 설정
	LCD_Data4bitInit(commandData); // 초기화 과정에서 명령어 데이터를 LCD 데이터 핀에 출력
}

void LCD_WriteData(uint8_t charData)
{
	LCD_RS_PORT |= (1<<LCD_RS); // RS 핀을 HIGH로 설정하여 문자 데이터 모드로 설정
	LCD_WriteMode(); // 쓰기 모드로 설정
	LCD_Data4bit(charData); // 문자 데이터를 LCD 데이터 핀에 출력
}

void LCD_GotoXY(uint8_t row, uint8_t col)
{
	col %= 16; // 열 인덱스를 0부터 15까지로 제한 (16개의 열)
	row %= 2; // 행 인덱스를 0 또는 1로 제한 (2개의 행)

	uint8_t address = (0x40 * row) + col; // 주소 계산
	uint8_t command = 0x80 + address; // 커맨드 값 계산 (주소 설정)
	LCD_WriteCommand(command); // 주소 설정 커맨드를 LCD에 전송
}

void LCD_WriteString(char *string)
{
	for (uint8_t i=0; string[i]; i++)
	{
		LCD_WriteData(string[i]); // 문자열의 각 문자를 LCD에 출력
	}
}

void LCD_WriteStringXY(uint8_t row, uint8_t col, char *string)
{
	LCD_GotoXY(row, col); // 지정된 위치로 커서 이동
	LCD_WriteString(string); // 문자열을 해당 위치부터 LCD에 출력
}

void LCD_Init()
{
	LCD_DATA_DDR = 0xff; // 데이터 핀을 출력으로 설정
	LCD_RS_DDR |= (1<<LCD_RS); // RS 핀을 출력으로 설정
	LCD_RW_DDR |= (1<<LCD_RW); // RW 핀을 출력으로 설정
	LCD_E_DDR |= (1<<LCD_E); // E 핀을 출력으로 설정

	_delay_ms(20); // 초기화 대기 시간 (충분한 대기 시간 필요)
	LCD_WriteCommand(0x03); // 4비트 모드로 설정
	_delay_ms(10); // 초기화 대기 시간
	LCD_WriteCommand(0x03); // 8비트 모드로 설정
	_delay_ms(1); // 초기화 대기 시간
	LCD_WriteCommand(0x03); // 8비트 모드로 설정
	LCD_WriteCommand(0x02); // 4비트 모드로 설정
	LCD_WriteCommand(COMMAND_4_BIT_MODE); // 4비트 모드로 LCD 설정
	LCD_WriteCommand(COMMAND_DISPLAY_OFF); // 화면 OFF
	LCD_WriteCommand(COMMAND_DISPLAY_CLEAR); // 화면 지우기
	LCD_WriteCommand(COMMAND_ENTRY_MODE); // 입력 모드 설정
	LCD_WriteCommand(COMMAND_DISPLAY_ON); // 화면 ON
}