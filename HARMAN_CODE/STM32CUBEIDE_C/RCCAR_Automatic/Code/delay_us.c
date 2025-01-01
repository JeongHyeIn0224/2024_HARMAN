/*
 * delay_us.c
 *
 *  Created on: Jun 18, 2024
 *      Author: user
 */
#include "delay_us.h"


void delay_us(uint16_t us)
{
	__HAL_TIM_SET_COUNTER(&htim11, 0);  //handler num 11-> 0 set
	while((__HAL_TIM_GET_COUNTER(&htim11)) < us); //Operate until it becomes smaller than us






}
