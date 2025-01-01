/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.c
  * @brief          : Main program body
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
#include "main.h"
#include "cmsis_os.h"
#include "dma.h"
#include "tim.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */
#include "delay_us.h"
#include "sonic.h"
#include "move.h"
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

int _write(int file, unsigned char* p, int len) // send to uart2
{
    HAL_StatusTypeDef status = HAL_UART_Transmit(&huart6, p, len, 100);
    return (status == HAL_OK ? len : 0);
}

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */
	uint8_t rxData[1];
	uint8_t forward_flag, backward_flag, stop_flag, turn_left_flag, turn_right_flag;

	extern uint16_t  distance;
	extern uint16_t  distance_R;
	extern uint16_t  distance_L;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
void MX_FREERTOS_Init(void);
/* USER CODE BEGIN PFP */


void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart) //interrupt occur, come into this function
{
		HAL_UART_Receive_IT(&huart6, rxData, sizeof(rxData)); //enable
		HAL_UART_Receive_IT(&huart2, rxData, sizeof(rxData)); //enable
}





void Automatic_mode(void)
{
	forward(400,400);
	if(distance < 23 )
	{
		if(distance_R > distance_L )
		{
			turn_right(400,400); //small turn
		}
		else if(distance_L +5> distance_R  )
		{
			turn_left(400,400);
		}
	}
	else if (distance_L < 20)
	{
		turn_right(500,100); //left right large turn
	}
	else if(distance_R < 25)
	{
		turn_left(500,800); //large turn
	}
}

//void Automatic_mode(void)
//{
//	forward(500,500);
//	if (distance_L < 25)
//	{
//		turn_right(800,0);
//	}
//	if(distance_R < 20)
//	{
//		turn_left(0,800); //large turn
//	}
//
//	if(distance < 27 )
//	{
//		if(distance_R > distance_L )
//		{
//			turn_right(400,150); //small turn
//		}
//		else if(distance_L > distance_R + 5 )
//		{
//			turn_left(150,400);
//		}
//	}
//}


void manual_mode(void)
{
	  if(rxData[0] == 'a' || rxData[0] =='b' || rxData[0] == 'c' || rxData[0] == 'd' || rxData[0] == 'e')
	  {
		 switch (rxData[0])
		  {
				  case 'a':					//forward
					  forward(500 , 500);
					  break;
				  case 'b' :				//backward
					 backward(300,300);
					  break;
				  case 'c' :				//stop
					  stop(0,0);
					  break;
				  case 'd' :				//turn_right
					  turn_right(500,500);
						break;
				  case 'e' :				//turn_left
					  turn_left(500,500);
					  break;
				  default :

					  break;
		  }
	  }
}


/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

/**
  * @brief  The application entry point.
  * @retval int
  */
int main(void)
{

  /* USER CODE BEGIN 1 */


  /* USER CODE END 1 */

  /* MCU Configuration--------------------------------------------------------*/

  /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
  HAL_Init();

  /* USER CODE BEGIN Init */

  /* USER CODE END Init */

  /* Configure the system clock */
  SystemClock_Config();

  /* USER CODE BEGIN SysInit */

  /* USER CODE END SysInit */

  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_DMA_Init();
  MX_TIM2_Init();
  MX_USART2_UART_Init();
  MX_TIM1_Init();
  MX_USART6_UART_Init();
  MX_TIM3_Init();
  MX_TIM11_Init();
  MX_TIM4_Init();
  /* USER CODE BEGIN 2 */
  HAL_TIM_PWM_Start(&htim2,TIM_CHANNEL_1);
  HAL_TIM_PWM_Start(&htim1,TIM_CHANNEL_2);

  //connect interrupt
  HAL_UART_Receive_IT(&huart2, rxData, sizeof(rxData)); //enable
  HAL_UART_Receive_IT(&huart6, rxData, sizeof(rxData)); //enable

  //ultrasonic
  HAL_TIM_Base_Start(&htim11);	// for delay_us

  HAL_TIM_Base_Start(&htim3);	// for input capture
  HAL_TIM_IC_Start_IT(&htim3, TIM_CHANNEL_1); //ultrasonic1_echo
  HAL_TIM_IC_Start_IT(&htim3, TIM_CHANNEL_3); //ultrasonicR_echo
  HAL_TIM_IC_Start_IT(&htim3, TIM_CHANNEL_4); //ultrasonicL_echo

  //buzzer
  HAL_TIM_PWM_Start(&htim4, TIM_CHANNEL_2);


  /* USER CODE END 2 */

  /* Init scheduler */
  osKernelInitialize();

  /* Call init function for freertos objects (in cmsis_os2.c) */
  MX_FREERTOS_Init();

  /* Start scheduler */
  osKernelStart();

  /* We should never get here as control is now taken by the scheduler */

  /* Infinite loop */
  /* USER CODE BEGIN WHILE */
  while (1)
  {
    /* USER CODE END WHILE */

    /* USER CODE BEGIN 3 */
//		HC_SR04();
//
//		if( rxData[0]== 'm')	//automatic_mode
//		{
//		 Automatic_mode();
//		}
//		else if(rxData[0] =='s')	//stop
//		{
//			stop(0,0);
//		}
//		else	//up , down , right, left -> manual_mode
//		{
//		 manual_mode();
//		}
  }



  /* USER CODE END 3 */
}

/**
  * @brief System Clock Configuration
  * @retval None
  */
void SystemClock_Config(void)
{
  RCC_OscInitTypeDef RCC_OscInitStruct = {0};
  RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

  /** Configure the main internal regulator output voltage
  */
  __HAL_RCC_PWR_CLK_ENABLE();
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /** Initializes the RCC Oscillators according to the specified parameters
  * in the RCC_OscInitTypeDef structure.
  */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 4;
  RCC_OscInitStruct.PLL.PLLN = 100;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
  {
    Error_Handler();
  }

  /** Initializes the CPU, AHB and APB buses clocks
  */
  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK|RCC_CLOCKTYPE_SYSCLK
                              |RCC_CLOCKTYPE_PCLK1|RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

  if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_3) != HAL_OK)
  {
    Error_Handler();
  }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
  * @brief  Period elapsed callback in non blocking mode
  * @note   This function is called  when TIM10 interrupt took place, inside
  * HAL_TIM_IRQHandler(). It makes a direct call to HAL_IncTick() to increment
  * a global variable "uwTick" used as application time base.
  * @param  htim : TIM handle
  * @retval None
  */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  /* USER CODE BEGIN Callback 0 */

  /* USER CODE END Callback 0 */
  if (htim->Instance == TIM10) {
    HAL_IncTick();
  }
  /* USER CODE BEGIN Callback 1 */

  /* USER CODE END Callback 1 */
}

/**
  * @brief  This function is executed in case of error occurrence.
  * @retval None
  */
void Error_Handler(void)
{
  /* USER CODE BEGIN Error_Handler_Debug */
  /* User can add his own implementation to report the HAL error return state */
  __disable_irq();
  while (1)
  {
  }
  /* USER CODE END Error_Handler_Debug */
}

#ifdef  USE_FULL_ASSERT
/**
  * @brief  Reports the name of the source file and the source line number
  *         where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t *file, uint32_t line)
{
  /* USER CODE BEGIN 6 */
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
  /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */
