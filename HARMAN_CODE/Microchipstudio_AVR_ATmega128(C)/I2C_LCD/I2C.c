/*//혠코드 I2C.c
 * I2C.c
 *
 * Created: 2024-04-12 오전 10:26:17
 *  Author: user
 */ 

#include "I2C.h"

void I2c_Init()
{
	I2C_DDR |= (1<<I2C_SCL) | (1<<I2C_SDA); //출력 설정 1인 부분 만들기 
	TWBR = 72;	//100kHz
	//TWBR = 32;	//200Khz
	//TWBR = 12;	//400KHz 
}

void I2C_Start()
{
	TWCR = (1<<TWINT) | (1 <<TWSTA) | (1<<TWEN);
	//TWINT에 1을 셋트하여 인터럽트를 발생시키는 것 같지만
	//소프트웨어적으로 1을 셋트하여 플래그를 클리어 하는것임!! 
	while (!(TWCR & (1<<TWINT))); //하드웨어적으로 TWINT를 클리어 함 
	//시작완료 대기 
}

void I2C_Stop()
{
	TWCR = (1<<TWINT) |(1<<TWEN) |(1<<TWSTO); //stop bit설정 
}

void I2C_TxData(uint8_t data) //1byte
{
	TWDR = data;	//data받아서 TWDR에 넣으면 저장이 된 것임 
	TWCR = (1<<TWINT) | (1<<TWEN);
	while(!(TWCR & (1<<TWINT)));
}

void I2C_TxByte(uint8_t devAddRW, uint8_t data)
{
	I2C_Start();
	I2C_TxData(devAddRW); //0x27 -주소보내는 순간 slave여러개 달리고 ack 날림 
	I2C_TxData(data);
	I2C_Stop();
}
