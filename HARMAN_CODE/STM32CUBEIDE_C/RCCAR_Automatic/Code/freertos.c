/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * File Name          : freertos.c
  * Description        : Code for freertos applications
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Includes ------------------------------------------------------------------*/
#include "FreeRTOS.h"
#include "task.h"
#include "main.h"
#include "cmsis_os.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

#include "sonic.h"

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN Variables */

	extern uint8_t rxData[1];


/* USER CODE END Variables */
/* Definitions for auto_driving */
osThreadId_t auto_drivingHandle;
const osThreadAttr_t auto_driving_attributes = {
  .name = "auto_driving",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityLow,
};
/* Definitions for ultrasonic */
osThreadId_t ultrasonicHandle;
const osThreadAttr_t ultrasonic_attributes = {
  .name = "ultrasonic",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityLow,
};

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN FunctionPrototypes */

/* USER CODE END FunctionPrototypes */

void autodriving(void *argument);
void ultrasonic_(void *argument);

void MX_FREERTOS_Init(void); /* (MISRA C 2004 rule 8.1) */

/**
  * @brief  FreeRTOS initialization
  * @param  None
  * @retval None
  */
void MX_FREERTOS_Init(void) {
  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* USER CODE BEGIN RTOS_MUTEX */
  /* add mutexes, ... */
  /* USER CODE END RTOS_MUTEX */

  /* USER CODE BEGIN RTOS_SEMAPHORES */
  /* add semaphores, ... */
  /* USER CODE END RTOS_SEMAPHORES */

  /* USER CODE BEGIN RTOS_TIMERS */
  /* start timers, add new ones, ... */
  /* USER CODE END RTOS_TIMERS */

  /* USER CODE BEGIN RTOS_QUEUES */
  /* add queues, ... */
  /* USER CODE END RTOS_QUEUES */

  /* Create the thread(s) */
  /* creation of auto_driving */
  auto_drivingHandle = osThreadNew(autodriving, NULL, &auto_driving_attributes);

  /* creation of ultrasonic */
  ultrasonicHandle = osThreadNew(ultrasonic_, NULL, &ultrasonic_attributes);

  /* USER CODE BEGIN RTOS_THREADS */
  /* add threads, ... */
  /* USER CODE END RTOS_THREADS */

  /* USER CODE BEGIN RTOS_EVENTS */
  /* add events, ... */
  /* USER CODE END RTOS_EVENTS */

}

/* USER CODE BEGIN Header_autodriving */
/**
  * @brief  Function implementing the auto_driving thread.
  * @param  argument: Not used
  * @retval None
  */
/* USER CODE END Header_autodriving */
void autodriving(void *argument)
{
  /* USER CODE BEGIN autodriving */
  /* Infinite loop */
  for(;;)
  {
	if( rxData[0]== 'm')	//automatic_mode
	{
	 Automatic_mode();
	}
	else if(rxData[0] =='s')	//stop
	{
		stop(0,0);
	}
	else	//up , down , right, left -> manual_mode
	{
	 manual_mode();
	}
    osDelay(1);
  }
  /* USER CODE END autodriving */
}

/* USER CODE BEGIN Header_ultrasonic_ */
/**
* @brief Function implementing the ultrasonic thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_ultrasonic_ */
void ultrasonic_(void *argument)
{
  /* USER CODE BEGIN ultrasonic_ */
	extern uint16_t  distance;
	extern uint16_t  distance_R;
	extern uint16_t  distance_L;

	distance =0;
	distance_L =0;
	distance_R =0;
  /* Infinite loop */
  for(;;)
  {
	  HC_SR04();
//	  printf("distance = %d cm\n\r", distance);
//	  printf("distance_L = %d cm\n\r", distance_L);
//	  printf("distance_R = %d cm\n\r", distance_R);
	    osDelay(1);

  }

  /* USER CODE END ultrasonic_ */
}

/* Private application code --------------------------------------------------*/
/* USER CODE BEGIN Application */

/* USER CODE END Application */

