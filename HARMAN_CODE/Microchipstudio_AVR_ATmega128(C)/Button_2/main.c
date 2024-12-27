/*
 * Button_2.c
 *
 * Created: 2024-03-27 오전 9:05:44
 * Author : user
 */ 


#include "Button.h"



int main(void)
{
    LED_DDR = 0xff;
	Button btnOn;
	Button btnOff;
	Button btnToggle; 
	
	Button_Init(&btnOn, &BUTTON_DDR, &BUTTON_PIN, BUTTON_ON); //BUTTON_ON은 0번핀
	Button_Init(&btnOff, &BUTTON_DDR, &BUTTON_PIN, BUTTON_OFF); //BUTTON_ON은 0번핀
	Button_Init(&btnToggle, &BUTTON_DDR, &BUTTON_PIN, BUTTON_TOGGLE);

///////////main함수에서 초기화 시켰음 
    while (1) 
    {
		if(BUTTON_getState(&btnOn) == ACT_RELEASED) //버튼 읽어왔는데 released 상태라면 불켜라
		{	//버튼을 띄었을 때 
			LED_PORT = 0xff;
		}
		if (BUTTON_getState(&btnOff)== ACT_RELEASED)
		{
			LED_PORT = 0x00;
		}
		if (BUTTON_getState(&btnToggle)== ACT_RELEASED)
		{
			LED_PORT ^= 0xff;
		}
    }
	//만일 어디에도 만족이 안되면 그냥 그 상태 그대로 계속 돈다. 
	//led가 on상태에서 계속 
}

