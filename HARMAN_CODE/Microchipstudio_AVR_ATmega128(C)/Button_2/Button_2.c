/*
 * Button_2.c
 *
 * Created: 2024-04-04 오전 8:38:51
 *  Author: user
 */ 
#include "Button.h"



//Init함수 : 초기화 시키는 함수라고 정의
void Button_Init(Button *button, volatile uint8_t *ddr1, volatile uint8_t *pin, uint8_t pinNum)
{
	button->ddr = ddr1; //버튼이라고 만든 ddr의 주소값에다가 //0x10
	button->pin = pin;  //0x09
	button->btnPin=pinNum;
	button->prevState=RELEASED; //현재 상태를 표시하는 것으로, 초기화로 아무것도 안누른 상태
	*button->ddr &= ~(1<< button ->btnPin); //0이 나오는 자리를 입력설정
}

//버튼의 ddr과 pin의 주소를 받기 위해
uint8_t BUTTON_getState(Button *button) //현재값과 과거값을 비교하여 과거값을 바꾸고 현재값을 받아오기
{
	//이 함수 실행시키면 curState가져다가 button의 pin에다가 넣고
	uint8_t curState = *button->pin &( 1 << button ->btnPin); //and연산을 통해 현재 상태를 읽어옴
	//현재 눌려있으면 curState가 0 안눌려있으면 1
	
	if((curState ==PUSHED) && (button->prevState==RELEASED)) //안누른 상태에서 누르면 //enum에서 PUSHED는 0 임
	//입력 0일 때 curState는 1됨 PUSHED는 0이니까 실행안됨		//아직 안누른 상태니까 prevState가 RELEASED로 초기화되어 있음 그리고 curState로 누르면
	{
		_delay_ms(50);
		button->prevState= PUSHED; //버튼의 상태를 누른 상태로 변환 // 이미 눌렀으니 과거의 상태 prevState가 PUSHEd로 바뀜
		return ACT_PUSHED; //버튼이 눌렸음을 리턴함
	}
	else if((curState != PUSHED) &&(button ->prevState==PUSHED)) //버튼이 눌러진 상태에서 떼면
	{
		_delay_ms(50);
		button->prevState = RELEASED; //버튼을 뗀 상태로 변환
		return ACT_RELEASED; //버튼이 떨어졌음을 반환
	}
	
	return NO_ACT;
	
}