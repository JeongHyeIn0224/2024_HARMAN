void delay_count(unsigned int timeCount)
{
	for(;timeCount > 0; timeCount--);
}
int main()
{
	// GPIOA's clock setting
	(*(volatile unsigned *)0x40023830) |= 0x01;
	// (*(type change *)address) // less bit : +1
	// pointer's value |= 0x01;
	// GPIOA's mode setting output
	(*(volatile unsigned *)0x40020000) &= ~(0x3<<10);
	(*(volatile unsigned *)0x40020000) |= (0x1<<10);
	while(1)
	{
		// GPIOA's 5 ON
		(*(volatile unsigned *)0x40020014) |= (1<<5);
		//delay
		delay_count(0xffff);
		// GPIOA's 5 OFF
		(*(volatile unsigned *)0x40020014) &= ~(1<<5);
		delay_count(0xffff);
	}
}
