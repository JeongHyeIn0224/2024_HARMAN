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

 uint32_t  IC_Value1 = 0;
 uint32_t  IC_Value2 = 0;
 uint32_t  echoTime = 0;
 uint16_t  captureFlag = 0;		//Check whether a capture is present.
 uint16_t  distance = 0;
 uint16_t pre_distance=0;

 uint32_t  IC_Value1_R = 0;
 uint32_t  IC_Value2_R = 0;
 uint32_t  echoTime_R = 0;
 uint16_t  captureFlag_R = 0;		//Check whether a capture is present.
 uint16_t  distance_R = 0;
 uint16_t pre_distance_R=0;


 uint32_t  IC_Value1_L = 0;
 uint32_t  IC_Value2_L = 0;
 uint32_t  echoTime_L = 0;
 uint16_t  captureFlag_L = 0;		//Check whether a capture is present.
 uint16_t  distance_L = 0;
 uint16_t pre_distance_L=0;

 uint16_t avg_dis[4], avg_dis_R[4], avg_dis_L[4];
 uint8_t i,j,k =0;


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
//			__HAL_TIM_SET_COMPARE(htim, TIM_CHANNEL_1 ,0); //timer restart

			if(IC_Value2 > IC_Value1)
			{
				echoTime = IC_Value2 - IC_Value1;
			}
			else if(IC_Value1 > IC_Value2)
			{
				echoTime = (0xffffffff - IC_Value1) +IC_Value2;
			}
//			distance = echoTime / 58;
			avg_dis[i%4] = echoTime / 58;
			i++;
			distance = (avg_dis[0] + avg_dis[1] + avg_dis[2] + avg_dis[3])/4;

			if(distance > 1000)
			{
				distance = pre_distance;
			}
			else
			{
				pre_distance = distance;
			}
			captureFlag =0;
			__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);
			__HAL_TIM_DISABLE_IT(htim, TIM_IT_CC1); //interrupt off
		}
	}

	//ultrasonic Right
	if(htim -> Channel == HAL_TIM_ACTIVE_CHANNEL_3)
		{
			if(captureFlag_R ==0)
			{
				IC_Value1_R = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3); //Being upcounting, value capture
				captureFlag_R =1;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_FALLING);
			}
			else if(captureFlag_R ==1) //done capture
			{
				IC_Value2_R = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3); //read and put
//				__HAL_TIM_SET_COMPARE(htim, TIM_CHANNEL_3 ,0); //timer restart

				if(IC_Value2_R > IC_Value1_R)
				{
					echoTime_R = IC_Value2_R - IC_Value1_R;
				}
				else if(IC_Value1_R > IC_Value2_R)
				{
					echoTime_R = (0xffffffff - IC_Value1_R) +IC_Value2_R;
				}
//				distance_R = echoTime_R / 58;
				avg_dis_R[j%4] = echoTime_R / 58;
				j++;
				distance_R = (avg_dis_R[0] + avg_dis_R[1] + avg_dis_R[2] + avg_dis_R[3])/4;

				if(distance_R > 1000)
				{
						distance_R = pre_distance_R;
				}
				else
				{
						pre_distance_R = distance_R;
				}

				captureFlag_R =0;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_RISING);
				__HAL_TIM_DISABLE_IT(htim, TIM_IT_CC3); //interrupt off
			}
		}

	//ultrasonic Left
	if(htim -> Channel == HAL_TIM_ACTIVE_CHANNEL_4)
		{
			if(captureFlag_L ==0)
			{
				IC_Value1_L = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_4); //Being upcounting, value capture
				captureFlag_L =1;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_4, TIM_INPUTCHANNELPOLARITY_FALLING);
			}
			else if(captureFlag_L ==1) //done capture
			{
				IC_Value2_L = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_4); //read and put
//				__HAL_TIM_SET_COMPARE(htim, TIM_CHANNEL_4 ,0); //timer restart //don't need

				if(IC_Value2_L > IC_Value1_L)
				{
					echoTime_L = IC_Value2_L - IC_Value1_L;
				}
				else if(IC_Value1_L > IC_Value2_L)
				{
					echoTime_L = (0xffffffff - IC_Value1_L) +IC_Value2_L;
				}
//				distance_L = (echoTime_L / 58)+5 ; //distance값 차이를 줄이기 위해 5를 더해줌
				avg_dis_L[k%4] = ( echoTime_L / 58 ) ;
				k++;
				distance_L = (avg_dis_L[0] + avg_dis_L[1] + avg_dis_L[2] + avg_dis_L[3])/4;

				if(distance_L > 1000)
				{
						distance_L = pre_distance_L;
				}
				else
				{
						pre_distance_L = distance_L;
				}

				captureFlag_L =0;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_4, TIM_INPUTCHANNELPOLARITY_RISING);
				__HAL_TIM_DISABLE_IT(htim, TIM_IT_CC4); //interrupt off
			}
		}
}


void HC_SR04(void)
{
	HAL_GPIO_WritePin(TRIG_PORT, TRIG_PIN, 1);
	delay_us(10);
	HAL_GPIO_WritePin(TRIG_PORT, TRIG_PIN, 0);

	__HAL_TIM_ENABLE_IT(&htim3, TIM_IT_CC1);
	__HAL_TIM_ENABLE_IT(&htim3, TIM_IT_CC3);
	__HAL_TIM_ENABLE_IT(&htim3, TIM_IT_CC4);


}


