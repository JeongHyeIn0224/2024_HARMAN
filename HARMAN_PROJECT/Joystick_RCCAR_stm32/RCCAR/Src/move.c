/*
 * move.c
 *
 *  Created on: Jun 28, 2024
 *      Author: user
 */

#include "delay_us.h"
#include "move.h"
#include "sonic.h"

#define Sol 255
#define Ra 	227
#define qNote 300
#define qNote_Short 100
  uint16_t song[] = {Sol, Ra};
  uint16_t time[] = {qNote, qNote};
  uint16_t time_delay[] = {qNote_Short,qNote_Short};

  extern uint8_t forward_flag,backward_flag,stop_flag,turn_left_flag,turn_right_flag;

  extern uint16_t  distance;
  extern uint16_t  distance_2;

void forward(void) //forward
{
	TIM2->CCR1 = 300;
	TIM1->CCR2 = 300;
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);

	if(distance < 30)
	{
		stop();
	}
}
void backward(void) //backward
{
	  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
	  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
	  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
	  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
	  TIM2->CCR1 = 300;
	  TIM1->CCR2 = 300;


   if((40 <distance_2) && (distance_2 <= 60))
	  {
		  TIM2->CCR1 = 200;
		  TIM1->CCR2 = 200;

		  for(int i =0; i< 2; i++)
			{
			  TIM4->PSC = song[i];
//			  HAL_Delay(100);
			  TIM4->CCR2 =500;
			}
		  TIM4->CCR2 =0;
		  backward_flag =0;

	  }

  else if( ( 20<distance_2 )&&(distance_2 <=40)  )
	  {
		  TIM2->CCR1 = 100;
		  TIM1->CCR2 = 100;
		  for(int i =0; i< 2; i++)
			{
			  TIM4->PSC = song[i];
//				  HAL_Delay(20);
			  TIM4->CCR2 =500;
			}
		  TIM4->CCR2 =0;
		  backward_flag =0;

	  }

  else if( distance_2<=20   )
	  {
		  stop();
		  TIM2->CCR1 = 0;
		  TIM1->CCR2 = 0;
		  for(int i =0; i< 2; i++)
			{
			  TIM4->PSC = song[i];
			  TIM4->CCR2 =500;
			}
		  TIM4->CCR2 =0;
		  backward_flag =0;

	  }
}

void stop(void) 	//stop
{
		TIM2->CCR1 = 0;
		TIM1->CCR2 = 0;
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
}

void turn_right(void) 	//turn_right
{
		TIM2->CCR1 = 400;
		TIM1->CCR2 = 700;
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);
}

void turn_left(void)	//turn_left
{
		TIM2->CCR1 = 700;
		TIM1->CCR2 = 400;
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
}

//void diag_up_r(void) 	//diagonal_up_right
//{
//		TIM2->CCR1 = 400;
//		TIM1->CCR2 = 500;
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
//		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
//		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);
//}
//void diag_up_l(void)	//diagonal_up_left
//{
//		TIM2->CCR1 = 500;
//		TIM1->CCR2 = 400;
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
//		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
//		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
//}
//
//void diag_down_l(void) 	//diagonal_down_left
//{
//		TIM2->CCR1 = 400;
//		TIM1->CCR2 = 500;
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
//		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
//		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);
//}
//
//void diag_down_r(void) 	//diagonal_down_right
//{
//		TIM2->CCR1 = 500;
//		TIM1->CCR2 = 400;
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
//		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
//		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
//		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
//}
