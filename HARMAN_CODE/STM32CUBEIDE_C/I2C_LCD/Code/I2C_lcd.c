/*
 * I2C_lcd.c
 *
 *  Created on: Jun 26, 2024
 *      Author: user
 */

#include "I2C_lcd.h"

extern I2C_HandleTypeDef hi2c1;



void lcd_command(uint8_t command)
{
	uint8_t high_nibble, low_nibble;
	uint8_t i2c_buffer[4];
	high_nibble = command & 0xf0; 	//extracting the high 4 bits
	low_nibble = (command << 4) & 0xf0; //extracting the lower 4 bits and shifting them left by 4 positions
	i2c_buffer[0] = high_nibble | 0x04 | 0x08; 	//en=1, rs=0 , rw=0 backlight=1
	i2c_buffer[1] = high_nibble | 0x00 | 0x08; 	//en=0, rs=0 , rw=0 backlight=1
	i2c_buffer[2] = low_nibble | 0x04 | 0x08;	//en=1, rs=0 , rw=0 backlight=1
	i2c_buffer[3] = low_nibble | 0x00 | 0x08;	//en=1, rs=0 , rw=0 backlight=1

	while(HAL_I2C_Master_Transmit(&hi2c1, I2C_LCD_ADDRESS, i2c_buffer, 4, 100) != HAL_OK)
										//,devie add, real data, 4bit,
	//while function role : holding until OK appears
	{

	}
}
void lcd_data(uint8_t data) //sending data
{
	uint8_t high_nibble, low_nibble;
	uint8_t i2c_buffer[4];
	high_nibble = data & 0xf0; 	//extracting the high 4 bits
	low_nibble = (data << 4) & 0xf0; //extracting the lower 4 bits and shifting them left by 4 positions
	i2c_buffer[0] = high_nibble | 0x05 | 0x08; 	//en=1, rs=0 , rw=0 backlight=1
	i2c_buffer[1] = high_nibble | 0x01 | 0x08; 	//en=0, rs=0 , rw=0 backlight=1
	i2c_buffer[2] = low_nibble | 0x05 | 0x08;	//en=1, rs=0 , rw=0 backlight=1
	i2c_buffer[3] = low_nibble 	| 0x01 | 0x08;

	while(HAL_I2C_Master_Transmit(&hi2c1, I2C_LCD_ADDRESS, i2c_buffer, 4, 100) ==! HAL_OK)
										//,devie add, real data, 4bit,
	//while function role : holding until OK appears
	{

	}

}
void i2c_lcd_init(void)
{
	HAL_Delay(50);
	lcd_command(0x33);
	HAL_Delay(5);
	lcd_command(0x32);
	HAL_Delay(5);
	lcd_command(0x28);
	HAL_Delay(5);
	lcd_command(DISPLAY_ON);
	HAL_Delay(5);
	lcd_command(0x06);
	HAL_Delay(5);
	lcd_command(CLEAR_DISPLAY);
	HAL_Delay(2);

}
void lcd_string(char *str)
{
	while(*str)lcd_data(*str++);
}
void move_cursor(uint8_t row, uint8_t col)
{
	lcd_command(0x80 | row << 6 | col);
}


/*
 * I2C_LCD.c
 *
 *  Created on: Jun 26, 2024
 *      Author: user
 */

//#include "I2C_LCD.h"
//
//extern I2C_HandleTypeDef hi2c1;
//
//void lcd_command(uint8_t command)
//{
//  uint8_t high_nibble, low_nibble;
//  uint8_t i2c_buffer[4];
//  high_nibble = command & 0xf0;       //high 4bit 추출
//  low_nibble = (command <<4) & 0xf0;  //low 4bit를 좌로 4칸 밀어서 추출
//  i2c_buffer[0] = high_nibble | 0x04 | 0x08; //en = 1, rs = 0, rw = 0, backlight = 1
//  i2c_buffer[1] = high_nibble | 0x00 | 0x08; //en = 0, rs = 0, rw = 0, backlight = 1
//  i2c_buffer[2] = low_nibble  | 0x04 | 0x08;  //en = 1, rs = 0, rw = 0, backlight = 1
//  i2c_buffer[3] = low_nibble  | 0x00 | 0x08;  //en = 0, rs = 0, rw = 0, backlight = 1
//
//  while(HAL_I2C_Master_Transmit(&hi2c1, I2C_LCD_ADDRESS, i2c_buffer, 4, 100) != HAL_OK)
//  {
//
//  }
//}
//
//// 1byte
//void lcd_data(uint8_t data)
//{
//  uint8_t high_nibble, low_nibble;
//  uint8_t i2c_buffer[4];
//  high_nibble = data & 0xf0;       //high 4bit 추출
//  low_nibble = (data <<4) & 0xf0;  //low 4bit를 좌로 4칸 밀어서 추출
//  i2c_buffer[0] = high_nibble | 0x05 | 0x08; //en = 1, rs = 1, rw = 0, backlight = 1
//  i2c_buffer[1] = high_nibble | 0x01 | 0x08; //en = 0, rs = 1, rw = 0, backlight = 1
//  i2c_buffer[2] = low_nibble  | 0x05 | 0x08;  //en = 1, rs = 1, rw = 0, backlight = 1
//  i2c_buffer[3] = low_nibble  | 0x01 | 0x08;  //en = 0, rs = 1, rw = 0, backlight = 1
//
//  while(HAL_I2C_Master_Transmit(&hi2c1, I2C_LCD_ADDRESS, i2c_buffer, 4, 100) != HAL_OK)
//    {
//
//    }
//}
//
//void i2c_lcd_init(void )
//{
//  HAL_Delay(50);
//  lcd_command(0x33);
//  HAL_Delay(5);
//  lcd_command(0x32);
//  HAL_Delay(5);
//  lcd_command(0x28);
//  HAL_Delay(5);
//  lcd_command(DISPLAY_ON);
//  HAL_Delay(5);
//  lcd_command(0x06);
//  HAL_Delay(5);
//  lcd_command(CLEAR_DISPLAY);
//  HAL_Delay(2);
//}
//
//void lcd_string(char *str)
//{
//  while(*str)lcd_data(*str++);
//}
//
//void move_cursor(uint8_t row, uint8_t col)
//{
//  lcd_command(0x80 | row << 6 | col);
//}
