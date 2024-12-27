/*//혠코드 I2C_LCD.h
 * I2C_LCD.h
 *
 * Created: 2024-04-12 오전 10:55:45
 *  Author: user
 */ 
#ifndef I2C_LCD_H_
#define I2C_LCD_H_
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

#include "I2C.h"

#define LCD_RS			0
#define LCD_RW			1
#define LCD_E		    2
#define LCD_BACKLIGHT   3

#define LCD_DEV_ADDR	(0x27<<1) //LCD주소 

#define COMMAND_DISPLAY_CLEAR	0X01	//lcd명령어 요약
#define COMMAND_DISPLAY_ON		0X0C
#define COMMAND_DISPLAY_OFF		0X08
#define COMMAND_4_BIT_MODE		0X28
#define COMMAND_ENTRY_MODE		0X06

void LCD_Data4bit(uint8_t data);
void LCD_EnablePin();
void LCD_WriteCommand(uint8_t commandData);
void LCD_WriteData(uint8_t charData);
void LCD_BackLightOn();
void LCD_GotoXY(uint8_t row, uint8_t col);
void LCD_WriteString(char *string);
void LCD_WriteStringXY(uint8_t row, uint8_t col, char *string);
void LCD_Init();




#endif /*I2C_LCD_H_ */
