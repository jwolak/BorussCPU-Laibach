MOV R0, #1  ;LOAD immediate value 1 to R0
loop:
SHL R0      ;(LED0->LED1)
SHL R0      ;(LED1->LED2)
SHL R0      ;(LED2->LED3)
SHL R0      ;(LED3->LED4)
SHL R0      ;(LED4->LED5)
SHL R0      ;(LED5->LED6)
SHL R0      ;(LED6->LED7)
SHR R0      ;(LED7->LED6)
SHR R0      ;(LED6->LED5)
SHR R0      ;(LED5->LED4)
SHR R0      ;(LED4->LED3)
SHR R0      ;(LED3->LED2)
SHR R0      ;(LED2->LED1)
SHR R0      ;(LED1->LED0)
JMP loop