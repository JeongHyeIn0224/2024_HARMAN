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
#include "tim.h"
#include "usart.h"
#include "gpio.h"
#include "delay.h"
#include <stdio.h>

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */
int _write(int file, unsigned char* p, int len)
{
    HAL_StatusTypeDef status = HAL_UART_Transmit(&huart6, p, len, 100);
    return (status == HAL_OK ? len : 0);
}
/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/
/* USER CODE BEGIN Variables */

/* USER CODE END Variables */
/* Definitions for defaultTask */
osThreadId_t defaultTaskHandle;
const osThreadAttr_t defaultTask_attributes = {
  .name = "defaultTask",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityNormal,
};
/* Definitions for autodriving */
osThreadId_t autodrivingHandle;
const osThreadAttr_t autodriving_attributes = {
  .name = "autodriving",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityLow,
};
/* Definitions for ultrasonic1 */
osThreadId_t ultrasonic1Handle;
const osThreadAttr_t ultrasonic1_attributes = {
  .name = "ultrasonic1",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityLow,
};
/* Definitions for ultrasonic2 */
osThreadId_t ultrasonic2Handle;
const osThreadAttr_t ultrasonic2_attributes = {
  .name = "ultrasonic2",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityLow,
};
/* Definitions for ultrasonic3 */
osThreadId_t ultrasonic3Handle;
const osThreadAttr_t ultrasonic3_attributes = {
  .name = "ultrasonic3",
  .stack_size = 128 * 4,
  .priority = (osPriority_t) osPriorityLow,
};

/* Private function prototypes -----------------------------------------------*/
/* USER CODE BEGIN FunctionPrototypes */

/* USER CODE END FunctionPrototypes */

void StartDefaultTask(void *argument);
void auto_driving(void *argument);
void ultrasonic_1(void *argument);
void ultrasonic_2(void *argument);
void ultrasonic_3(void *argument);

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
  /* creation of defaultTask */
  defaultTaskHandle = osThreadNew(StartDefaultTask, NULL, &defaultTask_attributes);

  /* creation of autodriving */
  autodrivingHandle = osThreadNew(auto_driving, NULL, &autodriving_attributes);

  /* creation of ultrasonic1 */
  ultrasonic1Handle = osThreadNew(ultrasonic_1, NULL, &ultrasonic1_attributes);

  /* creation of ultrasonic2 */
  ultrasonic2Handle = osThreadNew(ultrasonic_2, NULL, &ultrasonic2_attributes);

  /* creation of ultrasonic3 */
  ultrasonic3Handle = osThreadNew(ultrasonic_3, NULL, &ultrasonic3_attributes);

  /* USER CODE BEGIN RTOS_THREADS */
  /* add threads, ... */
  /* USER CODE END RTOS_THREADS */

  /* USER CODE BEGIN RTOS_EVENTS */
  /* add events, ... */
  /* USER CODE END RTOS_EVENTS */

}

/* USER CODE BEGIN Header_StartDefaultTask */
/**
  * @brief  Function implementing the defaultTask thread.
  * @param  argument: Not used
  * @retval None
  */
/* USER CODE END Header_StartDefaultTask */
void StartDefaultTask(void *argument)
{
  /* USER CODE BEGIN StartDefaultTask */
  /* Infinite loop */
  for(;;)
  {
    osDelay(1);
  }
  /* USER CODE END StartDefaultTask */
}

/* USER CODE BEGIN Header_auto_driving */
/**
* @brief Function implementing the autodriving thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_auto_driving */
void auto_driving(void *argument)
{
  /* USER CODE BEGIN auto_driving */
  /* Infinite loop */


	extern uint16_t U1_distance;
	extern uint16_t U2_distance;
	extern uint16_t U3_distance;
	extern uint8_t btn_flag;

	void EXTI_Button();

  for(;;)
  {
	  if(btn_flag == 1){
		  if(U2_distance > 30)
		  {
			  go();
			  if(U1_distance < 18)
			  {
				  left();
			  }
			  else if((U3_distance < 18))
			  {
			  		right();
			  }
			  else if(U3_distance == U2_distance)
			  {
				  go();
			  }
		  }
		  else if(U2_distance <= 30)
		  {
			  slow();
			if(U1_distance < 30)
			{
				left();
			}
			else if(U3_distance < 30) //&& ((U3_distance - U1_distance)<60000))
			{
				right();
			}
			else if(U3_distance < 30)
			{
				right();
			}
			else if(U3_distance < 30) //&& ((U3_distance - U1_distance)<60000))
			{
				right();
			}
			else if(U3_distance == U1_distance)
			{
				back();
			}
		  }
	  }
	  else
	  {
		  stop();
	  }

    osDelay(1);
  }
  /* USER CODE END auto_driving */
}

/* USER CODE BEGIN Header_ultrasonic_1 */
/**
* @brief Function implementing the ultrasonic1 thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_ultrasonic_1 */
void ultrasonic_1(void *argument)
{
  /* USER CODE BEGIN ultrasonic_1 */
	extern uint16_t U1_distance;
	U1_distance = 0;
  /* Infinite loop */
  for(;;)
  {
	U1_HC_SR04();
	printf("U1 : %d cm\r\n", U1_distance);
	//osDelay(50);
	osDelay(50);
    osDelay(1);
  }
  /* USER CODE END ultrasonic_1 */
}

/* USER CODE BEGIN Header_ultrasonic_2 */
/**
* @brief Function implementing the ultrasonic2 thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_ultrasonic_2 */
void ultrasonic_2(void *argument)
{
  /* USER CODE BEGIN ultrasonic_2 */
  /* Infinite loop */

  extern uint16_t U2_distance;
  U2_distance = 0;
  for(;;)
  {
	U2_HC_SR04();
	printf("U2 : %d cm\r\n", U2_distance);
	osDelay(50);

    osDelay(1);
  }
  /* USER CODE END ultrasonic_2 */
}

/* USER CODE BEGIN Header_ultrasonic_3 */
/**
* @brief Function implementing the ultrasonic3 thread.
* @param argument: Not used
* @retval None
*/
/* USER CODE END Header_ultrasonic_3 */
void ultrasonic_3(void *argument)
{
  /* USER CODE BEGIN ultrasonic_3 */
	extern uint16_t U3_distance;
	U3_distance = 0;
  /* Infinite loop */
  for(;;)
  {
	U3_HC_SR04();
	printf("U3 : %d cm\r\n", U3_distance);
	osDelay(50);
    osDelay(1);
  }
  /* USER CODE END ultrasonic_3 */
}

/* Private application code --------------------------------------------------*/
/* USER CODE BEGIN Application */

/* USER CODE END Application */

