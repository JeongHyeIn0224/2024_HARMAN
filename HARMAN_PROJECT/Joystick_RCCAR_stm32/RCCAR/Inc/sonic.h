/*
 * sonic.h
 *
 *  Created on: Jun 18, 2024
 *      Author: user
 */
#include "stm32f4xx_hal.h"
#include "tim.h"

#ifndef INC_SONIC_H_
#define INC_SONIC_H_

////extern uint32_t  IC_Value1 ;
////extern uint32_t  IC_Value2 ;
////extern uint32_t  echoTime;
////extern uint16_t  captureFlag;
 extern uint16_t  distance;
 extern uint16_t  distance_2;


void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim);
void HC_SR04(void);

#endif /* INC_SONIC_H_ */
