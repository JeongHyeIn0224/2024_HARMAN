/*
 * sonic.c
 *
 *  Created on: Jun 18, 2024
 *      Author: user
 */

#include "sonic.h"
#include "delay_us.h"

#define TRIG_PORT	GPIOB
#define TRIG_PIN	GPIO_PIN_5

#define TRIG_PORT_2	GPIOC
#define TRIG_PIN_2	GPIO_PIN_2

 uint32_t  IC_Value1 = 0;
 uint32_t  IC_Value2 = 0;
 uint32_t  echoTime = 0;
 uint16_t  captureFlag = 0;		//Check whether a capture is present.
 uint16_t  distance = 0;

 uint32_t  IC_Value1_2 = 0;
 uint32_t  IC_Value2_2 = 0;
 uint32_t  echoTime_2 = 0;
 uint16_t  captureFlag_2 = 0;		//Check whether a capture is present.
 uint16_t  distance_2 = 0;

void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)

{
	//ultrasonic front
	if(htim -> Channel == HAL_TIM_ACTIVE_CHANNEL_1)
	{
		if(captureFlag ==0)
		{
			IC_Value1 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1); //Being upcounting, value capture
			captureFlag =1;
			__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_FALLING);
		}
		else if(captureFlag ==1) //done capture
		{
			IC_Value2 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1); //read and put
			__HAL_TIM_SET_COMPARE(htim, TIM_CHANNEL_1 ,0); //timer restart

			if(IC_Value2 > IC_Value1)
			{
				echoTime = IC_Value2 - IC_Value1;
			}
			else if(IC_Value1 > IC_Value2)
			{
				echoTime = (0xffffffff - IC_Value1) +IC_Value2;
			}
			distance = echoTime / 58;
			captureFlag =0;
			__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);
			__HAL_TIM_DISABLE_IT(htim, TIM_IT_CC1); //interrupt off
		}
	}

	//ultrasonic back
	if(htim -> Channel == HAL_TIM_ACTIVE_CHANNEL_3)
		{
			if(captureFlag_2 ==0)
			{
				IC_Value1_2 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3); //Being upcounting, value capture
				captureFlag_2 =1;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_FALLING);
			}
			else if(captureFlag_2 ==1) //done capture
			{
				IC_Value2_2 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3); //read and put
				__HAL_TIM_SET_COMPARE(htim, TIM_CHANNEL_3 ,0); //timer restart

				if(IC_Value2_2 > IC_Value1_2)
				{
					echoTime_2 = IC_Value2_2 - IC_Value1_2;
				}
				else if(IC_Value1_2 > IC_Value2_2)
				{
					echoTime_2 = (0xffffffff - IC_Value1_2) +IC_Value2_2;
				}
				distance_2 = echoTime_2 / 58;
				captureFlag_2 =0;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_RISING);
				__HAL_TIM_DISABLE_IT(htim, TIM_IT_CC3); //interrupt off
			}
		}
}


void HC_SR04(void)
{
	HAL_GPIO_WritePin(TRIG_PORT, TRIG_PIN, 1);
	delay_us(10);
	HAL_GPIO_WritePin(TRIG_PORT, TRIG_PIN, 0);

	HAL_GPIO_WritePin(TRIG_PORT_2, TRIG_PIN_2, 1);
	delay_us(10);
	HAL_GPIO_WritePin(TRIG_PORT_2, TRIG_PIN_2, 0);

	__HAL_TIM_ENABLE_IT(&htim3, TIM_IT_CC1);
	__HAL_TIM_ENABLE_IT(&htim3, TIM_IT_CC3);

}


