/*
 * move.c
 *
 *  Created on: Jun 28, 2024
 *      Author: user
 */

#include "delay_us.h"
#include "move.h"



  extern uint16_t  distance;
  extern uint16_t  distance_R;

void forward(uint16_t Velocity_L, uint16_t Velocity_R) //forward
{
	TIM2->CCR1 = Velocity_L;
	TIM1->CCR2 = Velocity_R;
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);

}
void backward(uint16_t Velocity_L, uint16_t Velocity_R) //backward
{
	  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
	  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
	  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
	  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
		TIM2->CCR1 = Velocity_L;
		TIM1->CCR2 = Velocity_R;

}

void stop(uint16_t Velocity_L, uint16_t Velocity_R) 	//stop
{
	TIM2->CCR1 = Velocity_L;
	TIM1->CCR2 = Velocity_R;
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
}

void turn_right(uint16_t Velocity_L, uint16_t Velocity_R) 	//turn_right
{
		TIM2->CCR1 = Velocity_L;  //400
		TIM1->CCR2 = Velocity_R; //700
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);
}

void turn_left(uint16_t Velocity_L, uint16_t Velocity_R)	//turn_left
{
		TIM2->CCR1 = Velocity_L;
		TIM1->CCR2 = Velocity_R;
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
}


