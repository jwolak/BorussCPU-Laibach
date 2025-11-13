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
// Module: boruss_cpu_fsm
//==============================================================================
// Description:
//   Finite State Machine controller for the Boruss CPU core. This module 
//   manages the CPU execution pipeline states, instruction fetch cycles,
//   decode phases, execution control, and memory access coordination.
//   Implements the main control logic for CPU operation sequencing.
//==============================================================================
module boruss_cpu_fsm (
    input clk,
    input reset,
    input [7:0] instruction_data,           // instruction bus
    input alu_zero_flag,                    // set if execution result is zero
    input alu_carry_flag,                   // set if execution result caused a carry
    input alu_negative_flag,                // set if execution result is negative
    input [7:0] alu_result,                 // result from ALU (for write-back stage)
    
    output reg [2:0] current_state,         // current state of the FSM (FETCH, DECODE, EXECUTE, WRITEBACK, HALT)
    output reg [7:0] pc,                    // program counter
    output reg [7:0] instruction_addr,      // address to fetch the next instruction from memory
    output reg [7:0] current_instruction,   // currently decoded instruction
    output reg [6:0] opcode,                // opcode of the current instruction
    output reg [3:0] dest_reg,              // destination register for the current instruction
    output reg [3:0] src_reg,               // source register for the current instruction
    output reg execute_jump,                // signal to indicate a jump should be executed
    output reg update_registers,            // signal to indicate registers should be updated
    output reg update_flags,                // signal to indicate flags should be updated (zero, carry, negative)
    output reg [7:0] immediate_value_out,   // immediate value for instructions that require it
    output reg is_immediate_out             // flag indicating if the current instruction uses an immediate value
);

    // Definicje stanów
    localparam [2:0] FETCH      = 3'b000;   // Fetch the next instruction
    localparam [2:0] DECODE     = 3'b001;   // Decode the fetched instruction
    localparam [2:0] EXECUTE    = 3'b010;   // Execute the decoded instruction
    localparam [2:0] WRITEBACK  = 3'b011;   // Write back the result
    localparam [2:0] FETCH_IMM  = 3'b100;   // Fetch immediate value
    localparam [2:0] HALT       = 3'b101;   // Halt the CPU

    reg [2:0] next_state;                   // next state of the FSM
    reg [7:0] next_pc;                      // next value of the program counter
    reg [7:0] immediate_value;              // immediate value for instructions that require it
    reg is_immediate;                       // flag indicating if the current instruction uses an immediate value
    
    // CPU flags (preserved between instructions)
    reg zero_flag;                          // internal zero flag 
    reg carry_flag;                         // internal carry flag
    reg negative_flag;                      // internal negative flag

    // output assignments
    always @(*) begin
        immediate_value_out = immediate_value;
        is_immediate_out = is_immediate;
    end

    // state machine - sequential logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_state <= FETCH;
            pc <= 8'h00;
            zero_flag <= 1'b0;
            carry_flag <= 1'b0;
            negative_flag <= 1'b0;
            current_instruction <= 8'h00;
            opcode <= 7'h0;
            dest_reg <= 4'b0;
            src_reg <= 4'b0;
            immediate_value <= 8'h00;
            is_immediate <= 1'b0;
        end else begin
            current_state <= next_state;
            pc <= next_pc;
            
            // Update instruction in DECODE state
            if (current_state == DECODE) begin
                current_instruction <= instruction_data;
                
                // Check if immediate mode (bit 7 = 1)
                if (instruction_data[7] == 1'b1) begin
                    is_immediate <= 1'b1;
                    opcode <= instruction_data[6:0];      // Bity 6-0 to opcode
                    dest_reg <= instruction_data[3:0];    // Bity 3-0 to dest_reg (dla immediate)
                    src_reg <= 4'b0000;                   // src_reg nie używany w trybie immediate
                end else begin
                    is_immediate <= 1'b0;
                    opcode <= instruction_data[6:0];      // Bity 6-0 to opcode
                    dest_reg <= instruction_data[3:0];    // Dolne 4 bity dla dest_reg
                    src_reg <= instruction_data[7:4];     // Górne 4 bity dla src_reg (błąd: powinno być odwrotnie?)
                end
            end
            
            // Save immediate value in FETCH_IMM state
            if (current_state == FETCH_IMM) begin
                immediate_value <= instruction_data;
            end

            // Update flags in WRITEBACK state
            if (current_state == WRITEBACK && update_flags) begin
                zero_flag <= alu_zero_flag;
                carry_flag <= alu_carry_flag;
                negative_flag <= alu_negative_flag;
            end
        end
    end

        // state machine - combinational logic
    always @(*) begin
        next_state = current_state;
        next_pc = pc;
        instruction_addr = pc;
        execute_jump = 1'b0;
        update_registers = 1'b0;
        update_flags = 1'b0;
        
        case (current_state)
            FETCH: begin
                instruction_addr = pc;
                next_state = DECODE;
            end
            
            DECODE: begin
                // Check if this is a HALT instruction
                if (instruction_data[6:0] == 7'h7F) begin  // Zmienione z 8'hFF na 7'h7F
                    next_state = HALT;
                end else begin
                    // Sprawdź czy instrukcja wymaga immediate value
                    // Instrukcje ALU (0x00-0x07) lub JMP (0x08-0x0E) mogą mieć immediate
                    if (instruction_data[7] == 1'b1 || 
                        (instruction_data[6:0] >= 7'h08 && instruction_data[6:0] <= 7'h0E)) begin
                        next_state = FETCH_IMM;
                    end else begin
                        next_state = EXECUTE;
                    end
                end
            end

            // state for fetching immediate value or address
            FETCH_IMM: begin
                instruction_addr = pc + 1; // Get next byte
                next_state = EXECUTE;
            end
            
            EXECUTE: begin
                next_state = WRITEBACK;
            end
            
            WRITEBACK: begin
                // Handle jumps
                if (opcode >= 7'h08 && opcode <= 7'h0E) begin
                    update_flags = 1'b1;
                    
                    case (opcode)
                        7'h08: begin // JMP - unconditional
                            next_pc = immediate_value;
                            execute_jump = 1'b1;
                        end
                        7'h09: begin // JZ
                            if (zero_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        7'h0A: begin // JNZ
                            if (!zero_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        7'h0B: begin // JC
                            if (carry_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        7'h0C: begin // JNC
                            if (!carry_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        7'h0D: begin // JN
                            if (negative_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        7'h0E: begin // JP
                            if (!negative_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        default: begin
                            next_pc = pc + 2;
                        end
                    endcase
                // CMP instruction
                end else if (opcode == 7'h0F) begin
                    next_pc = pc + 1;  // CMP jest 1-bajtowa (bez immediate)
                    update_flags = 1'b1;
                    update_registers = 1'b0;
                // Instructions with immediate value
                end else if (is_immediate) begin
                    next_pc = pc + 2; // 2-byte instruction
                    update_registers = 1'b1;
                    update_flags = 1'b0; // Immediate does not change flags
                // Standard ALU instructions (register-register)
                end else begin
                    next_pc = pc + 1; // 1-byte instruction (nie ma immediate)
                    update_registers = 1'b1;
                    update_flags = 1'b1;
                end
                
                next_state = FETCH;
            end
            
            HALT: begin
                next_state = HALT;
            end
            
            default: begin
                next_state = FETCH;
            end
        endcase
    end

endmodule