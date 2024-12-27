/* //혠코드 I2C.h
 * I2C.h
 *
 * Created: 2024-04-12 오전 10:26:28
 *  Author: user
 */ 
#ifndef I2C_H_
#define I2C_H_

#include <avr/io.h>
//DDR의 포트 0번과 1번을 사용할거다. 
#define  I2C_DDR	DDRD
#define  I2C_SCL	PORTD0 //클럭 
#define  I2C_SDA	PORTD1	//데이터 

void I2c_Init();
void I2C_Start();
void I2C_Stop();
void I2C_TxData(uint8_t data); //1byte
void I2C_TxByte(uint8_t devAddRW, uint8_t data);





#endif	/*I2C_H_*/