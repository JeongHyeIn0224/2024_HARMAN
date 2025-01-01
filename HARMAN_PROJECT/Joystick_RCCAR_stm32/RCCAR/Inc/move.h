/*
 * move.h
 *
 *  Created on: Jun 28, 2024
 *      Author: user
 */

#include "stm32f4xx_hal.h"
#include "tim.h"

#ifndef INC_MOVE_H_
#define INC_MOVE_H_

void forward(void); //forward
void backward(void); //backward
void stop(void); 	//stop
void turn_right(void); 	//turn_left
void turn_left(void);	//turn_right

#endif /* INC_MOVE_H_ */
