﻿/*
 * UART.h
 *
 * Created: 2024-04-08 오전 10:01:03
 *  Author: user
 */ 

#ifndef UART_H_
#define UART_H_
#include <avr/io.h>

void UART0_Init() ;//초기화 함수
void UART0_Transmit(char data);
unsigned char UART0_Receive ();

#endif 