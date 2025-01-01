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
#include "tim.h"
#include "usart.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

#define TRIG_PORT_1 GPIOC
#define TRIG_PIN_1 GPIO_PIN_0
#define TRIG_PORT_2 GPIOC
#define TRIG_PIN_2 GPIO_PIN_1
#define TRIG_PORT_3 GPIOB
#define TRIG_PIN_3 GPIO_PIN_0

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */


/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

GPIO_TypeDef *gpio_in[4] = {GPIOA, GPIOB, GPIOB, GPIOB};
uint16_t in_gpio_pin[4]= {GPIO_PIN_10, GPIO_PIN_3, GPIO_PIN_5, GPIO_PIN_4};

uint16_t U1_IC_Value1 = 0;
uint16_t U1_IC_Value2 = 0;
uint16_t U2_IC_Value1 = 0;
uint16_t U2_IC_Value2 = 0;
uint16_t U3_IC_Value1 = 0;
uint16_t U3_IC_Value2 = 0;

uint16_t U1_echoTime = 0;
uint16_t U2_echoTime = 0;
uint16_t U3_echoTime = 0;

uint16_t U1_captureFlag = 0;
uint16_t U2_captureFlag = 0;
uint16_t U3_captureFlag = 0;

uint16_t U1_distance = 0;
uint16_t U2_distance = 0;
uint16_t U3_distance = 0;

uint16_t U1_pre_distance = 0;
uint16_t U2_pre_distance = 0;
uint16_t U3_pre_distance = 0;

uint8_t btn_flag = 0;

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
void MX_FREERTOS_Init(void);
/* USER CODE BEGIN PFP */


void go()
{
	 TIM3->CCR1 = 900;
	 TIM3->CCR2 = 900;
	 HAL_GPIO_WritePin(gpio_in[0], in_gpio_pin[0], 1);
	 HAL_GPIO_WritePin(gpio_in[1], in_gpio_pin[1], 0);
	 HAL_GPIO_WritePin(gpio_in[2], in_gpio_pin[2], 0);
	 HAL_GPIO_WritePin(gpio_in[3], in_gpio_pin[3], 1);
}

void back()
{
	 TIM3->CCR1 = 300;
	 TIM3->CCR2 = 300;
	 HAL_GPIO_WritePin(gpio_in[0], in_gpio_pin[0], 0);
	 HAL_GPIO_WritePin(gpio_in[1], in_gpio_pin[1], 1);
	 HAL_GPIO_WritePin(gpio_in[2], in_gpio_pin[2], 1);
	 HAL_GPIO_WritePin(gpio_in[3], in_gpio_pin[3], 0);
}

void slow()
{
	 TIM3->CCR1 = 300;
	 TIM3->CCR2 = 300;
	 HAL_GPIO_WritePin(gpio_in[0], in_gpio_pin[0], 1);
	 HAL_GPIO_WritePin(gpio_in[1], in_gpio_pin[1], 0);
	 HAL_GPIO_WritePin(gpio_in[2], in_gpio_pin[2], 0);
	 HAL_GPIO_WritePin(gpio_in[3], in_gpio_pin[3], 1);
}



void stop()
{
	 TIM3->CCR1 = 0;
	 TIM3->CCR2 = 0;
	 HAL_GPIO_WritePin(gpio_in[0], in_gpio_pin[0], 0);
	 HAL_GPIO_WritePin(gpio_in[1], in_gpio_pin[1], 0);
	 HAL_GPIO_WritePin(gpio_in[2], in_gpio_pin[2], 0);
	 HAL_GPIO_WritePin(gpio_in[3], in_gpio_pin[3], 0);
}


void right()
{
	 TIM3->CCR1 = 500;
	 TIM3->CCR2 = 300;
	 HAL_GPIO_WritePin(gpio_in[0], in_gpio_pin[0], 1);
	 HAL_GPIO_WritePin(gpio_in[1], in_gpio_pin[1], 0);
	 HAL_GPIO_WritePin(gpio_in[2], in_gpio_pin[2], 1);
	 HAL_GPIO_WritePin(gpio_in[3], in_gpio_pin[3], 0);
}

void left()
{
	 TIM3->CCR1 = 300;
	 TIM3->CCR2 = 500;
	 HAL_GPIO_WritePin(gpio_in[0], in_gpio_pin[0], 0);
	 HAL_GPIO_WritePin(gpio_in[1], in_gpio_pin[1], 1);
	 HAL_GPIO_WritePin(gpio_in[2], in_gpio_pin[2], 0);
	 HAL_GPIO_WritePin(gpio_in[3], in_gpio_pin[3], 1);
}


void EXTI_Button(void)
{
	HAL_GPIO_EXTI_IRQHandler(GPIO_PIN_13);
}


void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
	btn_flag = !btn_flag;
}


void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
	if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_1)
	{
		if(U1_captureFlag == 0)
		{
			U1_IC_Value1 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);
			U1_captureFlag = 1;
			__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_FALLING); //echo falling capture set
		}
		else if(U1_captureFlag == 1)
		{
			U1_IC_Value2 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_1);


			if(U1_IC_Value2 > U1_IC_Value1)
			{
				U1_echoTime = U1_IC_Value2 - U1_IC_Value1;
			}
			else if(U1_IC_Value1 > U1_IC_Value2)
			{
				U1_echoTime = (0xffff - U1_IC_Value1) + U1_IC_Value2;
			}
			U1_distance = U1_echoTime / 58;

			if(U1_distance > 1000)
			{
				U1_distance = U1_pre_distance;
			}
			else
			{
				U1_pre_distance = U1_distance;
			}

			U1_captureFlag = 0;
			__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_1, TIM_INPUTCHANNELPOLARITY_RISING);	//ehco rising capture set
			__HAL_TIM_DISABLE_IT(&htim4, TIM_IT_CC1);
		}
	}
	else if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_2)
		{
			if(U2_captureFlag == 0)
			{
				U2_IC_Value1 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_2);
				U2_captureFlag = 1;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_2, TIM_INPUTCHANNELPOLARITY_FALLING); //echo falling capture set
			}
			else if(U2_captureFlag == 1)
			{
				U2_IC_Value2 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_2);


				if(U2_IC_Value2 > U2_IC_Value1)
				{
					U2_echoTime = U2_IC_Value2 - U2_IC_Value1;
				}
				else if(U2_IC_Value1 > U2_IC_Value2)
				{
					U2_echoTime = (0xffff - U2_IC_Value1) + U2_IC_Value2;
				}
				U2_distance = U2_echoTime / 58;

				if(U2_distance > 1000)
				{
					U2_distance = U2_pre_distance;
				}
				else
				{
					U2_pre_distance = U2_distance;
				}

				U2_captureFlag = 0;
				__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_2, TIM_INPUTCHANNELPOLARITY_RISING);	//ehco rising capture set
				__HAL_TIM_DISABLE_IT(&htim4, TIM_IT_CC2);
			}
		}
	else if(htim->Channel == HAL_TIM_ACTIVE_CHANNEL_3)
			{
				if(U3_captureFlag == 0)
				{
					U3_IC_Value1 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3);
					U3_captureFlag = 1;
					__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_FALLING); //echo falling capture set
				}
				else if(U3_captureFlag == 1)
				{
					U3_IC_Value2 = HAL_TIM_ReadCapturedValue(htim, TIM_CHANNEL_3);

					if(U3_IC_Value2 > U3_IC_Value1)
					{
						U3_echoTime = U3_IC_Value2 - U3_IC_Value1;
					}
					else if(U3_IC_Value1 > U3_IC_Value2)
					{
						U3_echoTime = (0xffff - U3_IC_Value1) + U3_IC_Value2;
					}
					U3_distance = U3_echoTime / 58;


					if(U3_distance > 1000)
					{
						U3_distance = U3_pre_distance;
					}
					else
					{
						U3_pre_distance = U3_distance;
					}
					U3_captureFlag = 0;
					__HAL_TIM_SET_CAPTUREPOLARITY(htim, TIM_CHANNEL_3, TIM_INPUTCHANNELPOLARITY_RISING);	//ehco rising capture set
					__HAL_TIM_DISABLE_IT(&htim4, TIM_IT_CC3);
				}
			}
}

void U1_HC_SR04(void)
{
	HAL_GPIO_WritePin(TRIG_PORT_1, TRIG_PIN_1, GPIO_PIN_SET);
	delay_us(10);
	HAL_GPIO_WritePin(TRIG_PORT_1, TRIG_PIN_1, GPIO_PIN_RESET);

	__HAL_TIM_ENABLE_IT(&htim4, TIM_IT_CC1);
}

void U2_HC_SR04(void)
{
	HAL_GPIO_WritePin(TRIG_PORT_2, TRIG_PIN_2, GPIO_PIN_SET);
	delay_us(10);
	HAL_GPIO_WritePin(TRIG_PORT_2, TRIG_PIN_2, GPIO_PIN_RESET);

	__HAL_TIM_ENABLE_IT(&htim4, TIM_IT_CC2);
}

void U3_HC_SR04(void)
{
	HAL_GPIO_WritePin(TRIG_PORT_3, TRIG_PIN_3, GPIO_PIN_SET);
	delay_us(10);
	HAL_GPIO_WritePin(TRIG_PORT_3, TRIG_PIN_3, GPIO_PIN_RESET);

	__HAL_TIM_ENABLE_IT(&htim4, TIM_IT_CC3);
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
  MX_TIM3_Init();
  MX_TIM4_Init();
  MX_TIM10_Init();
  MX_USART2_UART_Init();
  MX_USART6_UART_Init();
  /* USER CODE BEGIN 2 */
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);
  HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_2);

  HAL_TIM_Base_Start(&htim10);	// for delay
  HAL_TIM_Base_Start(&htim4);	//for input capture

  HAL_TIM_IC_Start_IT(&htim4, TIM_CHANNEL_1);	//function starts the input capture feature with interrupts.
  HAL_TIM_IC_Start_IT(&htim4, TIM_CHANNEL_2);
  HAL_TIM_IC_Start_IT(&htim4, TIM_CHANNEL_3);


  TIM3->CCR1 = 1000;
  TIM3->CCR2 = 1000;
  HAL_GPIO_WritePin(gpio_in[0], in_gpio_pin[0], 0);
  HAL_GPIO_WritePin(gpio_in[1], in_gpio_pin[1], 0);
  HAL_GPIO_WritePin(gpio_in[2], in_gpio_pin[2], 0);
  HAL_GPIO_WritePin(gpio_in[3], in_gpio_pin[3], 0);


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
  * @note   This function is called  when TIM11 interrupt took place, inside
  * HAL_TIM_IRQHandler(). It makes a direct call to HAL_IncTick() to increment
  * a global variable "uwTick" used as application time base.
  * @param  htim : TIM handle
  * @retval None
  */
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
  /* USER CODE BEGIN Callback 0 */

  /* USER CODE END Callback 0 */
  if (htim->Instance == TIM11) {
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
