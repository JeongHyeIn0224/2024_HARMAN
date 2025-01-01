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
  extern uint16_t  distance_R;

void forward(uint16_t Velocity_L, uint16_t Velocity_R) //forward
{
	TIM2->CCR1 = Velocity_L;
	TIM1->CCR2 = Velocity_R;
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
	HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
	HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);

	//light_led_off
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 0);
	HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 0);
}
void backward(uint16_t Velocity_L, uint16_t Velocity_R) //backward
{
	  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
	  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
	  HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
	  HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);
		TIM2->CCR1 = Velocity_L;
		TIM1->CCR2 = Velocity_R;

		//light_led_off
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 0);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 0);
}

void stop(uint16_t Velocity_L, uint16_t Velocity_R) 	//stop
{
	TIM2->CCR1 = Velocity_L;
	TIM1->CCR2 = Velocity_R;
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);

		//light_led_on
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 1);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 1);

}

void turn_right(uint16_t Velocity_L, uint16_t Velocity_R) 	//turn_right
{
		TIM2->CCR1 = Velocity_L;  //400
		TIM1->CCR2 = Velocity_R; //700
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 0);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 1);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 0);

		//light_led
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 1);

		//left_light_off
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 0);

}

void turn_left(uint16_t Velocity_L, uint16_t Velocity_R)	//turn_left
{
		TIM2->CCR1 = Velocity_L;
		TIM1->CCR2 = Velocity_R;
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_6, 1);
		HAL_GPIO_WritePin(GPIOA, GPIO_PIN_7, 0);
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_6, 0);
		HAL_GPIO_WritePin(GPIOC, GPIO_PIN_7, 1);

		//light_led
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_13, 1);

		//right_light_off
		HAL_GPIO_WritePin(GPIOB, GPIO_PIN_14, 0);


}


