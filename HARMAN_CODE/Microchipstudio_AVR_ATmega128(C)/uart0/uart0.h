/*
 * uart0.h
 *
 * Created: 2024-04-09 오후 2:04:31
 *  Author: user
 */ 


#ifndef UART0_H_
#define UART0_H_

#define F_CPU 16000000UL
#include <avr/io.h>
#include <util/delay.h>
#include <avr/interrupt.h>
#include <string.h>
#include <stdio.h>


void UART0_init();
uint8_t UART0_getRxFlag();
void UART0_clearRxFlag();
void UART0_setReadyRxFlag();
uint8_t *UART0_readRxBuff();
void USART0_Transmit( unsigned char data );
unsigned char USART0_Receive( void );
void UART0_print(char *str);
uint8_t UART0_Avail();
void USART0_ISR_Process();
void UART0_execute();



#endif /* UART0_H_ */