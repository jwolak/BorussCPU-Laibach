# BorussCPU "Laibach"
```
"Boruss" is an experimental 8 bits RISC CPU here with code name "Laibach"
```

## Project Description

```
BorussCPU "Laibach" is an experimental 8-bit RISC processor designed in Verilog. The project aims to demonstrate the complete process of CPU design, from architecture and implementation to verification with unit, integration tests and a dedicated assembly compiler ([BorASM](https://github.com/jwolak/BorASM)).
```

### Key Features
```
- **8-bit RISC architecture** with a simple instruction set
- **Four general-purpose 8-bit registers** (reg_a, reg_b, reg_c, reg_d)
- **ALU** supporting arithmetic and logical operations: ADD, SUB, AND, OR, XOR, NOT, SHL, SHR, JMP, JZ, JNZ, JC, JNC, JN, JP, CMP
- **Separate ROM (program) and RAM (data) memory blocks**
- **FSM-based control unit** with states: FETCH, DECODE, EXECUTE, WRITEBACK, FETCH_IMM, HALT
- **Flag system**: zero (Z), carry (C), negative (N), overflow (O)
- **Simple four-stage pipeline** for instruction execution
- **Testbenches** for unit and integration testing (ModelSim compatible)
```

### Project Structure
```
- `src/core/` – Main CPU modules (ALU, FSM, register file, etc.)
- `src/memory/` – ROM and RAM modules
- `src/testbench/` – Unit and integration testbenches
```

### Dedicated ssembly compiler "BorASM"
```
https://github.com/jwolak/BorASM
```
---

                    BORUSS CPU "LAIBACH" - BLOCK DIAGRAM
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                              BORUSS CPU                                 │
    │                                                                         │
    │  ┌──────────────┐     ┌─────────────────┐     ┌─────────────────────┐   │
    │  │              │     │                 │     │                     │   │
    │  │ CLOCK DIVIDER│────>|   FSM CONTROL   │────>│   REGISTER FILE     │   │
    │  │              │     │                 │     │                     │   │
    │  │ clk ÷ 2^20   │     │ • FETCH         │     │ • reg_a (R0)        │   │
    │  │    ~24Hz     │     │ • DECODE        │     │ • reg_b (R1)        │   │
    │  │              │     │ • EXECUTE       │     │ • reg_c (R2)        │   │
    │  └──────────────┘     │ • WRITEBACK     │     │ • reg_d (R3)        │   │
    │                       │ • FETCH_IMM     │     │                     │   │
    │  ┌──────────────┐     │ • HALT          │     └─────────┬───────────┘   │
    │  │    RESET     │     │                 │               │               │
    │  │ (active low) │────>│ PC: 8-bit       │               |               │
    │  └──────────────┘     │ Flags: Z,C,N,O  │               │               │
    │                       │                 │               │               │
    │                       └───────────┬─────┘               │               │
    │                                   │                     │               │
    │                                   │                     ▼               │
    │  ┌─────────────────────────────┐  │        ┌───────────────────────────┐│
    │  │                             │  │        │                           ││
    │  │          ALU                │  │        │    OPERAND SELECTION      ││
    │  │                             │  │        │                           ││
    │  │ Operations:                 │  │        │ • operand_a <── src_reg   ││
    │  │ • ADD  (0x00)               │  │        │ • operand_b <── dest_reg/ ││
    │  │ • SUB  (0x01)               │  │        │                 immediate ││
    │  │ • AND  (0x02)               │  │        │                           ││
    │  │ • OR   (0x03)               │  │        └────────────┬──────────────┘│
    │  │ • XOR  (0x04)               │  │                     │               │
    │  │ • NOT  (0x05)               │  │                     │               │
    │  │ • SHL  (0x06)               │◄───────────────────────┘               │
    │  │ • SHR  (0x07)               │  │                                     │
    │  │ • JMP  (0x08)               │  │                                     │
    │  │ • JZ   (0x09)               │  │                                     │
    │  │ • JNZ  (0x0A)               │  │                                     │
    │  │ • JC   (0x0B)               │  │                                     │
    │  │ • JNC  (0x0C)               │  │                                     │
    │  │ • JN   (0x0D)               │  │                                     │
    │  │ • JP   (0x0E)               │  │                                     │
    │  │ • CMP  (0x0F)               │  │                                     │
    │  │                             │  │                                     │
    │  │ Outputs: result, Z, C, N, O │  │                                     │
    │  └─────────────────────────────┘  │                                     │
    │                                   │                                     │
    │                                   |                                     │
    │                                   |                                     │
    │                                   |                                     │
    │                                   |                                     │
    └───────────────────────────────────|─────────────────────────────────────┘
                                        │
                                        ▼
    ┌─────────────────────────────────────────────────────────────────────────┐
    │                      MEMORY CONTROLLER                                  │
    │                                                                         │
    │  ┌─────────────────┐        ┌─────────────────────┐                     │
    │  │     ROM         │        │        RAM          │                     │
    │  │  (Instructions) │        │      (Data)         │                     │
    │  │                 │        │                     │                     │
    │  │ • Program Code  │        │ • Variables         │                     │
    │  │ • Immediate     │        │ • Stack             │                     │
    │  │   Values        │        │ • Buffers           │                     │
    │  │                 │        │                     │                     │
    │  │ Address: 8-bit  │        │ Address: 8-bit      │                     │
    │  │ Data: 8-bit     │        │ Data: 8-bit         │                     │
    │  └─────────────────┘        └─────────────────────┘                     │
    │           ▲                            ▲                                │
    │           │                            │                                │
    │  ┌────────┴────────────────────────────┴────────────────────────────┐   │
    │  │                 MEMORY MAPPING                                   │   │
    │  │                                                                  │   │
    │  │ memory_map_select:                                               │   │
    │  │ • 0 = ROM (instruction fetch)                                    │   │
    │  │ • 1 = RAM (data access)                                          │   │
    │  │                                                                  │   │
    │  │ Instruction Interface:        Data Interface:                    │   │
    │  │ • instruction_address         • data_address                     │   │
    │  │ • instruction_data            • data_in/data_out                 │   │
    │  │                               • data_write_enable                │   │
    │  │                               • data_read_enable                 │   │
    │  └──────────────────────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────────┐
    │                         CONTROL SIGNALS                                 │
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

    ┌─────────────────────────────────────────────────────────────────────────┐
    │                      INSTRUCTION FORMAT                                 │
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

    ┌─────────────────────────────────────────────────────────────────────────┐
    │                           ALU FLAGS                                     │
    │                                                                         │
    │  • zero_flag (Z):      Result equals zero                               │
    │  • carry_flag (C):     Carry out from MSB or borrow in subtraction      │
    │  • negative_flag (N):  Result MSB = 1 (negative in 2's complement)      │
    │  • overflow_flag (O):  Signed arithmetic overflow occurred              │
    └─────────────────────────────────────────────────────────────────────────┘

    ┌─────────────────────────────────────────────────────────────────────────┐
    │                     EXECUTION PIPELINE                                  │
    │                                                                         │
    │  FETCH ──► DECODE ──► EXECUTE ──► WRITEBACK                             │
    │     │          │                                                        │
    │     │          └──► FETCH_IMM ──┘                                       │
    │     │                                                                   │
    │     └──────────────► HALT                                               │
    └─────────────────────────────────────────────────────────────────────────┘

    ## BORUSS CPU Execution Pipeline – Timing Diagram
    
    Time:    0    1    2    3    4    5    6    7    8    9   10   11   12   13   14   15
             │    │    │    │    │    │    │    │    │    │    │    │    │    │    │    │
    slow_clk ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐    ┌────┐
             │    └────┘    └────┘    └────┘    └────┘    └────┘    └────┘    └────┘    └─

    CPU      │FETCH│DECODE│EXEC │WRITE│FETCH│DECODE│EXEC │WRITE│FETCH│DECODE│EXEC │WRITE│
    State    │  0  │  1   │  2  │  3  │  0  │  1   │  2  │  3  │  0  │  1   │  2  │  3  │

    PC       ├─ 00h ─────────────────────────┤ 01h ─────────────────────────┤ 02h ────────
             │                               │                              │
