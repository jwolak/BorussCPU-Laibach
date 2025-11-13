/*
 *  Created on: 2025
 *      Author: Janusz Wolak
 */

/*-
 * BSD 3-Clause License
 *
 * Copyright (c) 2025, Janusz Wolak
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 */

//==============================================================================
// Module: boruss_cpu
// Description: Main CPU core module for the Boruss processor architecture.
//              Implements the central processing unit with instruction fetch,
//              decode, execute, and writeback stages. Handles instruction
//              execution, register file management, and memory interface
//              coordination.
//==============================================================================
module boruss_cpu (
    input clk,
    input reset,
    output [7:0] pc,                    // Program Counter - Current address of the instruction being executed
    output [7:0] instruction_addr,      // Instruction Address - Address used to fetch the current instruction from memory
    output [2:0] cpu_state,             // CPU State - 3-bit value indicating current processor state (fetch, decode, execute, etc.)
    output [7:0] debug_reg_a,           // Debug Register A - Contents of general purpose register A for debugging purposes
    output [7:0] debug_reg_b,           // Debug Register B - Contents of general purpose register B for debugging purposes
    output [7:0] debug_reg_c,           // Debug Register C - Contents of general purpose register C for debugging purposes
    output [7:0] debug_reg_d,           // Debug Register D - Contents of general purpose register D for debugging purposes
    
    // LED Output - Displays the value of register A on the LEDs for visual debugging
    output [7:0] led_out
);

    // Clock divider to slow down the clock for visible LED changes
    reg [25:0] clk_divider;
    reg slow_clk;
    
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            clk_divider <= 26'h0;
            slow_clk <= 1'b0;
        end else begin
            clk_divider <= clk_divider + 1;
            slow_clk <= clk_divider[20]; // Zmień na [5] dla symulacji testowej
        end
    end

    // CPU registers
    reg [7:0] reg_a, reg_b, reg_c, reg_d;

    // Memory signals
    wire [7:0] instruction_data;
    wire [7:0] memory_data_out;
    reg [7:0] memory_addr;
    reg [7:0] memory_data_in;
    reg memory_write_enable;
    reg memory_read_enable;
    reg memory_map_select;  // 0=ROM, 1=RAM

    // State machine signals
    wire [7:0] fsm_pc;
    wire [7:0] fsm_instruction_addr;
    wire [7:0] current_instruction;
    wire [6:0] opcode;
    wire [3:0] src_reg;
    wire [3:0] dest_reg;
    wire execute_jump, update_registers, update_flags;
    wire [2:0] current_state;
    wire [7:0] immediate_value;
    wire is_immediate;
    
    // ALU signals
    reg [7:0] alu_operand_a, alu_operand_b, alu_operation;
    wire [7:0] alu_result;
    wire alu_zero_flag, alu_carry_flag, alu_negative_flag;
    
    // Output assignments
    assign pc = fsm_pc;
    assign instruction_addr = fsm_instruction_addr;
    assign cpu_state = current_state;
    assign debug_reg_a = reg_a;
    assign debug_reg_b = reg_b;
    assign debug_reg_c = reg_c;
    assign debug_reg_d = reg_d;

    // LED Output - Displays the value of register A on the LEDs for visual debugging
    assign led_out = reg_a;//current_instruction;

    // memory controller instance
    boruss_memory_controller memory_ctrl (
        .clk(slow_clk),
        .reset(reset),
        .instruction_address(fsm_instruction_addr),
        .instruction_data(instruction_data),
        .data_address(memory_addr),
        .data_in(memory_data_in),
        .data_write_enable(memory_write_enable),
        .data_read_enable(memory_read_enable),
        .data_out(memory_data_out),
        .memory_map_select(memory_map_select)
    );
    
    // FSM instance
    boruss_cpu_fsm fsm_inst (
        .clk(slow_clk),
        .reset(reset),
        .instruction_data(instruction_data),
        .alu_zero_flag(alu_zero_flag),
        .alu_carry_flag(alu_carry_flag),
        .alu_negative_flag(alu_negative_flag),
        .alu_result(alu_result),
        .current_state(current_state),
        .pc(fsm_pc),
        .instruction_addr(fsm_instruction_addr),
        .current_instruction(current_instruction),
        .opcode(opcode),
        .dest_reg(dest_reg),
        .src_reg(src_reg),
        .execute_jump(execute_jump),
        .update_registers(update_registers),
        .update_flags(update_flags),
        .immediate_value_out(immediate_value),
        .is_immediate_out(is_immediate)       
    );

    // ALU instance
    boruss_alu alu_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .operation_code(alu_operation),
        .result(alu_result),
        .zero_flag(alu_zero_flag),
        .carry_flag(alu_carry_flag),
        .negative_flag(alu_negative_flag)
    );

    // ALU operand preparation logic
    always @(*) begin
        // Use ROM by default for instruction fetch
        memory_map_select = 1'b0;
        memory_addr = 8'h00;
        memory_data_in = 8'h00;
        memory_write_enable = 1'b0;
        memory_read_enable = 1'b0;

        // Select operand A (source register)
        case (dest_reg)
            4'b0000: alu_operand_a = reg_a;   // if dest_reg is 0 then use reg_a
            4'b0001: alu_operand_a = reg_b;   // if dest_reg is 1 then use reg_b
            4'b0010: alu_operand_a = reg_c;   // if dest_reg is 2 then use reg_c
            4'b0011: alu_operand_a = reg_d;   // if dest_reg is 3 then use reg_d
        endcase

        // Select operand B - immediate or register
        if (is_immediate) begin
            alu_operand_b = immediate_value; // use immediate value (instead to use value from register)
        end else begin
            case (src_reg) // For register-register operations
                4'b0000: alu_operand_b = reg_a;   // if src_reg is 0 then use reg_a
                4'b0001: alu_operand_b = reg_b;   // if src_reg is 1 then use reg_b
                4'b0010: alu_operand_b = reg_c;   // if src_reg is 2 then use reg_c
                4'b0011: alu_operand_b = reg_d;   // if src_reg is 3 then use reg_d
            endcase
        end

        // Map opcode to ALU operation code
        case (opcode)
            7'b00000000: alu_operation = 8'b00000000; // ADD
            7'b00000001: alu_operation = 8'b00000001; // SUB
            7'b00000010: alu_operation = 8'b00000010; // AND
            7'b00000011: alu_operation = 8'b00000011; // OR
            7'b00000100: alu_operation = 8'b00000100; // XOR
            7'b00000101: alu_operation = 8'b00000101; // NOT
            7'b00000110: alu_operation = 8'b00000110; // SHL
            7'b00000111: alu_operation = 8'b00000111; // SHR
            7'b00001000: alu_operation = 8'b00001000; // JMP
            7'b00001001: alu_operation = 8'b00001001; // JZ
            7'b00001010: alu_operation = 8'b00001010; // JNZ
            7'b00001011: alu_operation = 8'b00001011; // JC
            7'b00001100: alu_operation = 8'b00001100; // JNC
            7'b00001101: alu_operation = 8'b00001101; // JN
            7'b00001110: alu_operation = 8'b00001110; // JP
            7'b00001111: alu_operation = 8'b00001111; // CMP
            7'b00010000: alu_operation = 8'b00010000; // MUL
            default: alu_operation = 8'b00000000; // Default to ADD
        endcase
    end

    // Register update logic
    always @(posedge slow_clk or negedge reset) begin
        if (!reset) begin
            reg_a <= 8'h00; // reset all registers to 0
            reg_b <= 8'h00;
            reg_c <= 8'h00;
            reg_d <= 8'h00;
        end else begin
            if (update_registers) begin // Update registers if enabled
                case (dest_reg) // Select destination register
                    4'b0000: reg_a <= is_immediate ? immediate_value : alu_result;    // if immediate mode use immediate value else use ALU result
                    4'b0001: reg_b <= is_immediate ? immediate_value : alu_result;
                    4'b0010: reg_c <= is_immediate ? immediate_value : alu_result;
                    4'b0011: reg_d <= is_immediate ? immediate_value : alu_result;
                endcase
            end
        end
    end

endmodule