01  // LOAD immediate to reg_a
01  // Value: 0x01 (LED0)
60  // SHL reg_a (LED0->LED1)
60  // SHL reg_a (LED1->LED2)
60  // SHL reg_a (LED2->LED3)
60  // SHL reg_a (LED3->LED4)
60  // SHL reg_a (LED4->LED5)
60  // SHL reg_a (LED5->LED6)
60  // SHL reg_a (LED6->LED7)
70  // SHR reg_a (LED7->LED6)
70  // SHR reg_a (LED6->LED5)
70  // SHR reg_a (LED5->LED4)
70  // SHR reg_a (LED4->LED3)
70  // SHR reg_a (LED3->LED2)
70  // SHR reg_a (LED2->LED1)
70  // SHR reg_a (LED1->LED0)
80  // JMP instruction
00  // Jump address: 0x00