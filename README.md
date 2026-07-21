# BorussCPU "Laibach"
```
 /$$$$$$$                                                    /$$$$$$  /$$$$$$$  /$$   /$$
| $$__  $$                                                  /$$__  $$| $$__  $$| $$  | $$
| $$  \ $$  /$$$$$$   /$$$$$$  /$$   /$$  /$$$$$$$ /$$$$$$$| $$  \__/| $$  \ $$| $$  | $$
| $$$$$$$  /$$__  $$ /$$__  $$| $$  | $$ /$$_____//$$_____/| $$      | $$$$$$$/| $$  | $$
| $$__  $$| $$  \ $$| $$  \__/| $$  | $$|  $$$$$$|  $$$$$$ | $$      | $$____/ | $$  | $$
| $$  \ $$| $$  | $$| $$      | $$  | $$ \____  $$\____  $$| $$    $$| $$      | $$  | $$
| $$$$$$$/|  $$$$$$/| $$      |  $$$$$$/ /$$$$$$$//$$$$$$$/|  $$$$$$/| $$      |  $$$$$$/
|_______/  \______/ |__/       \______/ |_______/|_______/  \______/ |__/       \______/



```
```
"Boruss CPU" is an experimental 8 bits RISC CPU with code name "Laibach"
```

## Project description

```
BorussCPU "Laibach" is an experimental 8-bit RISC processor designed in Verilog.
The project aims to demonstrate the complete process of CPU design,
from architecture and implementation to verification with unit,
integration tests and a dedicated assembly compiler BorASM.
```
"BorASM" BorussCPU assembly compiler project link": [https://github.com/jwolak/BorASM](https://github.com/jwolak/BorASM)

### Key features
```
- 8-bit RISC architecture
- Four general-purpose 8-bit registers (reg_a, reg_b, reg_c, reg_d)
- ALU supporting arithmetic and logical operations:
  ADD, SUB, AND, OR, XOR, NOT, SHL, SHR, JMP, JZ, JNZ, JC, JNC, JN, JP, CMP
- Separate ROM (program) and RAM (data) memory blocks
- FSM-based control unit with states: FETCH, DECODE, EXECUTE, WRITEBACK, FETCH_IMM, HALT
- Flag system: zero (Z), carry (C), negative (N), overflow (O)
- Simple four-stage pipeline for instruction execution
- Testbenches for unit and integration testing (ModelSim compatible)
```

### Code structure
```
- src/core/ – Main CPU modules (ALU, FSM, register file, etc.)
- src/memory/ – ROM and RAM modules
- src/testbench/ – Unit and integration testbenches
- src/program/ - sources and .hex that can be loaded to ROM at start up (also built by BorASM)
```

### Dedicated assembly compiler "BorASM"

Visit: [https://github.com/jwolak/BorASM](https://github.com/jwolak/BorASM)

### Instruction format
```
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                                                                         │
    │  1-byte instructions:                                                   │
    │  [4-bit opcode][2-bit dest_reg][2-bit src_reg]                          │
    │                                                                         │
    │  2-byte instructions (with immediate):                                  │
    │  [4-bit opcode][4-bit modifier] [8-bit immediate/address]               │
    │                                                                         │
    │  Special:                                                               │
    │  HALT = 0xFF                                                            │
    └─────────────────────────────────────────────────────────────────────────┘
```

### Instruction encoding details

Bit layout for 1-byte register form:

| Bit range | Field | Meaning |
| --- | --- | --- |
| [7:4] | opcode | Operation code |
| [3:2] | dest_reg | Destination register |
| [1:0] | src_reg | Source register |

Register encoding:

| Reg bits | Register |
| --- | --- |
| 00 | R0 (reg_a) |
| 01 | R1 (reg_b) |
| 10 | R2 (reg_c) |
| 11 | R3 (reg_d) |

Immediate and jump encoding:

| Type | Byte 0 | Byte 1 |
| --- | --- | --- |
| ALU immediate (opcode 0x0-0x7) | [opcode][modifier != 0] | immediate value |
| Jump (opcode 0x8-0xE) | [opcode][modifier] | target address |

Examples:

| Bytes | Decoding |
| --- | --- |
| 0x60 | SHL, register form |
| 0x51 0x01 | Opcode 0x5 with immediate value 0x01 (MOV-style immediate load in current programs) |
| 0x80 0x02 | JMP 0x02 |
| 0xFF | HALT (special case, decoded before normal opcode handling) |

### Supported opcodes

| Opcode (bin) | Opcode (hex) | Mnemonic | Description |
| --- | --- | --- | --- |
| 0000 | 0x0 | ADD | Add source and destination registers |
| 0001 | 0x1 | SUB | Subtract source from destination |
| 0010 | 0x2 | AND | Bitwise AND |
| 0011 | 0x3 | OR | Bitwise OR |
| 0100 | 0x4 | XOR | Bitwise XOR |
| 0101 | 0x5 | NOT | Bitwise NOT |
| 0110 | 0x6 | SHL | Shift left |
| 0111 | 0x7 | SHR | Shift right |
| 1000 | 0x8 | JMP | Unconditional jump (2-byte instruction) |
| 1001 | 0x9 | JZ | Jump if zero flag is set (2-byte instruction) |
| 1010 | 0xA | JNZ | Jump if zero flag is clear (2-byte instruction) |
| 1011 | 0xB | JC | Jump if carry flag is set (2-byte instruction) |
| 1100 | 0xC | JNC | Jump if carry flag is clear (2-byte instruction) |
| 1101 | 0xD | JN | Jump if negative flag is set (2-byte instruction) |
| 1110 | 0xE | JP | Jump if negative flag is clear (2-byte instruction) |
| 1111 | 0xF | CMP | Compare values and update flags |

Special encoding:

| Byte value | Meaning |
| --- | --- |
| 0xFF | HALT |

Immediate mode note:

- For opcodes 0x0-0x7, when the low nibble is non-zero, the instruction is treated as a 2-byte immediate form and the second byte is written to the destination register.

## Example program in ROM

See: [`src/memory/boruss_rom.v`](src/memory/boruss_rom.v)

```sh
        // Always try to load from file
        $readmemh("src/program/knight_rider_two_way_borasm_LED1-LED4.hex", rom_memory);
        $display("Program loaded from src/program/knight_rider_two_way_borasm_LED1-LED4.hex");

        // Check if the first byte is != 0 (program loaded correctly)
        if (rom_memory[0] == 8'h00) begin
            $display("No program file found, using built-in Knight Rider");
            // Default program
            rom_memory[8'h00] = 8'b00000001; // LOAD immediate
            rom_memory[8'h01] = 8'h01;       // Value: 0x01
            rom_memory[8'h02] = 8'b01100000; // SHL
            rom_memory[8'h03] = 8'b01100000; // SHL
            rom_memory[8'h04] = 8'b01100000; // SHL
            rom_memory[8'h05] = 8'b01100000; // SHL
            rom_memory[8'h06] = 8'b01100000; // SHL
            rom_memory[8'h07] = 8'b01100000; // SHL
            rom_memory[8'h08] = 8'b01100000; // SHL
            rom_memory[8'h09] = 8'b10000000; // JMP
            rom_memory[8'h0A] = 8'h00;       // Address
        end else begin
            $display("Program loaded from src/program/knight_rider_two_way_borasm_LED1-LED4.hex");
        end
```
### Demo program (Terasic DE0-Nano Cyclone® IV EP4CE22F17C6N FPGA)

![BorussCPU Laibach DE0-Nano Demo](media/BorussCPU-Laibach-DE0Nano.gif)

[See source .asm file: `src/program/knight_rider_two_way_borasm_LED1-LED4.asm`](src/program/knight_rider_two_way_borasm_LED1-LED4.asm)

```
MOV R0, #1  ;LOAD immediate value 1 to R0
loop:
SHL R0      ;(LED0->LED1)
SHL R0      ;(LED1->LED2)
SHL R0      ;(LED2->LED3)
SHL R0      ;(LED3->LED4)
SHR R0      ;(LED4->LED3)
SHR R0      ;(LED3->LED2)
SHR R0      ;(LED2->LED1)
SHR R0      ;(LED1->LED0)
JMP loop
```

[See output BorASM .hex file: `src/program/knight_rider_two_way_borasm_LED1-LED4.hex`](src/program/knight_rider_two_way_borasm_LED1-LED4.hex)
```
51
01
60
60
60
60
70
70
70
70
80
02
```

[![SUB Operation Result](media/BorussCPU-Laibach-DE0NanoMini.PNG)](media/BorussCPU-Laibach-DE0Nano.mp4)

Link: [See BorussCPU Demo program](media/BorussCPU-Laibach-DE0Nano.mp4)

### Demo program (Terasic DE0-CV Cyclone V FPGA)

<img src="media/BorussCPU-Laibach-DE0-CV.JPEG" alt="BorussCPU Laibach DE0-CV board" width="420" />

![BorussCPU Laibach DE0-CV Demo](media/BorussCpu-DE0-CV.gif)

[See demo video](media/BorussCpu-DE0-CV.mp4)

UART (DE0-CV):
- TxD (uart_tx) is assigned to PIN_T17.

The loaded program is a Knight Rider variant for LED0-LED6. The assembly source is in [src/program/knight_rider_two_way_borasm_LED0-LED6.asm](src/program/knight_rider_two_way_borasm_LED0-LED6.asm), and the generated HEX file is in [src/program/knight_rider_de0_cv_LED0_LED6.hex](src/program/knight_rider_de0_cv_LED0_LED6.hex).

[See source .asm file: `src/program/knight_rider_two_way_borasm_LED0-LED6.asm`](src/program/knight_rider_two_way_borasm_LED0-LED6.asm)

```
MOV R0, #1  ;LOAD immediate value 1 to R0
loop:
SHL R0      ;(LED0->LED1)
SHL R0      ;(LED1->LED2)
SHL R0      ;(LED2->LED3)
SHL R0      ;(LED3->LED4)
SHL R0      ;(LED4->LED5)
SHL R0      ;(LED5->LED6)
SHR R0      ;(LED6->LED5)
SHR R0      ;(LED5->LED4)
SHR R0      ;(LED4->LED3)
SHR R0      ;(LED3->LED2)
SHR R0      ;(LED2->LED1)
SHR R0      ;(LED1->LED0)
JMP loop
```

[See output BorASM .hex file: `src/program/knight_rider_de0_cv_LED0_LED6.hex`](src/program/knight_rider_de0_cv_LED0_LED6.hex)
```
51
01
60
60
60
60
60
60
70
70
70
70
70
70
80
02
```

### Control signals
```
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                                                                         │
    │  FSM ──────────────────► CPU:                                           │
    │  • instruction_addr     • update_registers                              │
    │  • opcode               • memory_addr                                   │
    │  • dest_reg             • memory_data_in                                │
    │  • src_reg              • memory_write_enable                           │
    │  • is_immediate         • memory_read_enable                            │
    │  • immediate_value      • memory_map_select                             │
    │  • execute_jump         • alu_operation                                 │
    │                                                                         │
    │  CPU ◄──────────────────── ALU:                                         │
    │  • alu_result            • zero_flag                                    │
    │                          • carry_flag                                   │
    │                          • negative_flag                                │
    └─────────────────────────────────────────────────────────────────────────┘
```
### ALU flags
```
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                                                                         │
    │  • zero_flag (Z):      Result equals zero                               │
    │  • carry_flag (C):     Carry out from MSB or borrow in subtraction      │
    │  • negative_flag (N):  Result MSB = 1 (negative in 2's complement)      │
    │  • overflow_flag (O):  Signed arithmetic overflow occurred              │
    └─────────────────────────────────────────────────────────────────────────┘
```
### Execution pipeline
```
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                                                                         │
    │  FETCH ──► DECODE ──► EXECUTE ──► WRITEBACK                             │
    │     │          │                                                        │
    │     │          └──► FETCH_IMM ──┘                                       │
    │     │                                                                   │
    │     └──────────────► HALT                                               │
    └─────────────────────────────────────────────────────────────────────────┘
```
### Execution Pipeline – Timing Diagram
```
    Time:    0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
             │    │    │    │    │    │    │    │    │    │    │    │    │    │    │    │
    slow_clk ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐
             │    └────┘    └────┘    └────┘    └────┘    └────┘    └────┘    └────┘    └─

    CPU      │FETCH│DECODE│EXEC │WRITE│FETCH│DECODE│EXEC │WRITE│FETCH│DECODE│EXEC │WRITE│
    State    │  0  │  1   │  2  │  3  │  0  │  1   │  2  │  3  │  0  │  1   │  2  │  3  │

    PC       ├─ 00h ─────────────────────────┤ 01h ─────────────────────────┤ 02h ────────
             │                               │                              │
```

### Evironment
```
Software:
Quartus Prime 22.1std Build 915 10/25/2022 SC Lite Edition

Hardware:
DE0-Nano FPGA Development and Education Kit [https://www.terasic.com.tw/cgi-bin/page/archive.pl?No=593]
Cyclone® IV EP4CE22F17C6N FPGA
```

## License

**BSD 3-Clause License**
<br/>Copylefts 2025, Janusz Wolak
<br/>No rights reserved
