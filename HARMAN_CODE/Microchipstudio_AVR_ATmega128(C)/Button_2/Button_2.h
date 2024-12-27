/*
 * Button_2.h
 *
 * Created: 2024-04-04 오전 8:39:41
 *  Author: user
 */ 
#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>

#define LED_DDR DDRA //출력
#define LED_PORT PORTA //입력
#define BUTTON_DDR DDRC //출력
#define BUTTON_PIN PINC //입력
#define BUTTON_ON		0
#define BUTTON_OFF		1
#define BUTTON_TOGGLE	2


enum{PUSHED, RELEASED }; // 0 , 1
enum{NO_ACT, ACT_PUSHED, ACT_RELEASED}; //0,1,2

typedef struct _button
{ //volatile -> 최적화하지마라
	volatile uint8_t *ddr;
	volatile uint8_t *pin;
	uint8_t btnPin; //버튼핀
	uint8_t prevState; //현재 누르는 버튼 핀의 상태 (이전상태, 현재상태 표현)
	
}Button;


void Button_Init(Button *button, volatile uint8_t *ddr, volatile uint8_t *pin, uint8_t pinNum);
uint8_t BUTTON_getState(Button *button);
