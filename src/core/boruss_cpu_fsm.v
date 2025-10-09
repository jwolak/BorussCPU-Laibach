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

module boruss_cpu_fsm (
    input clk,
    input reset,
    input [7:0] instruction_data,
    input alu_zero_flag,
    input alu_carry_flag,
    input alu_negative_flag,
    input [7:0] alu_result,
    
    output reg [2:0] current_state,
    output reg [7:0] pc,
    output reg [7:0] instruction_addr,
    output reg [7:0] current_instruction,
    output reg [3:0] opcode,
    output reg [1:0] dest_reg,
    output reg [1:0] src_reg,
    output reg execute_jump,
    output reg update_registers,
    output reg update_flags,
    output reg [7:0] immediate_value_out,
    output reg is_immediate_out
);

    // Definicje stanów
    localparam [2:0] FETCH      = 3'b000;
    localparam [2:0] DECODE     = 3'b001;
    localparam [2:0] EXECUTE    = 3'b010;
    localparam [2:0] WRITEBACK  = 3'b011;
    localparam [2:0] FETCH_IMM  = 3'b100; // ZMIEŃ: Pobieranie wartości immediate
    localparam [2:0] HALT       = 3'b101;

    reg [2:0] next_state;
    reg [7:0] next_pc;
    reg [7:0] immediate_value;
    reg is_immediate;
    
    // Flagi CPU (zachowane między instrukcjami)
    reg zero_flag;
    reg carry_flag;
    reg negative_flag;

    // Przypisania wyjściowe
    always @(*) begin
        immediate_value_out = immediate_value;
        is_immediate_out = is_immediate;
    end

    // Maszyna stanów - logika sekwencyjna
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            current_state <= FETCH;
            pc <= 8'h00;
            zero_flag <= 1'b0;
            carry_flag <= 1'b0;
            negative_flag <= 1'b0;
            current_instruction <= 8'h00;
            opcode <= 4'h0;
            dest_reg <= 2'b00;
            src_reg <= 2'b00;
            immediate_value <= 8'h00;
            is_immediate <= 1'b0;
        end else begin
            current_state <= next_state;
            pc <= next_pc;
            
            // Aktualizacja instrukcji w stanie DECODE
            if (current_state == DECODE) begin
                current_instruction <= instruction_data;
                opcode <= instruction_data[7:4];
                dest_reg <= instruction_data[3:2]; 
                src_reg <= instruction_data[1:0];
                is_immediate <= 1'b0; // Reset flagi immediate
            end
            
            // Zapisz wartość immediate w stanie FETCH_IMM
            if (current_state == FETCH_IMM) begin
                immediate_value <= instruction_data;
                is_immediate <= 1'b1;
            end
            
            // Aktualizacja flag w stanie WRITEBACK
            if (current_state == WRITEBACK && update_flags) begin
                zero_flag <= alu_zero_flag;
                carry_flag <= alu_carry_flag;
                negative_flag <= alu_negative_flag;
            end
        end
    end

    // Maszyna stanów - logika kombinacyjna
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
                // Sprawdź czy to instrukcja HALT
                if (instruction_data == 8'hFF) begin
                    next_state = HALT;
                // Sprawdź czy instrukcja potrzebuje immediate value
                // Format: [4-bit opcode][4-bit modifier] - jeśli modifier != 0, to immediate
                end else if (instruction_data[3:0] != 4'b0000 && instruction_data[7:4] <= 4'b0111) begin
                    next_state = FETCH_IMM; // Pobierz wartość immediate
                // Instrukcje skoków zawsze 2-bajtowe
                end else if (instruction_data[7:4] >= 4'b1000 && instruction_data[7:4] <= 4'b1110) begin
                    next_state = FETCH_IMM; // Pobierz adres skoku
                end else begin
                    next_state = EXECUTE; // Standardowa instrukcja bez immediate
                end
            end

            // Stan pobierania wartości immediate lub adresu
            FETCH_IMM: begin
                instruction_addr = pc + 1; // Pobierz następny bajt
                next_state = EXECUTE;
            end
            
            EXECUTE: begin
                next_state = WRITEBACK;
            end
            
            WRITEBACK: begin
                // Obsługa skoków
                if (opcode >= 4'b1000 && opcode <= 4'b1110) begin
                    update_flags = 1'b1;
                    
                    case (opcode)
                        4'b1000: begin // JMP - bezwarunkowy
                            next_pc = immediate_value;
                            execute_jump = 1'b1;
                        end
                        4'b1001: begin // JZ
                            if (zero_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        4'b1010: begin // JNZ
                            if (!zero_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        4'b1011: begin // JC
                            if (carry_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        4'b1100: begin // JNC
                            if (!carry_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        4'b1101: begin // JN
                            if (negative_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        4'b1110: begin // JP
                            if (!negative_flag) begin
                                next_pc = immediate_value;
                                execute_jump = 1'b1;
                            end else begin
                                next_pc = pc + 2;
                            end
                        end
                        4'b1111: begin // CMP
                            next_pc = pc + 1;
                            update_flags = 1'b1;
                            update_registers = 1'b0;
                        end
                    endcase
                // Instrukcje z immediate value
                end else if (is_immediate) begin
                    next_pc = pc + 2; // Instrukcja 2-bajtowa
                    update_registers = 1'b1;
                    update_flags = 1'b0; // Immediate nie zmienia flag
                // Standardowe instrukcje ALU
                end else begin
                    next_pc = pc + 1; // Instrukcja 1-bajtowa
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