/*
 *  Created on: 2025
 *      Author: Janusz Wolak
 */

/*-
 * BSD 3-Clause License
 *
 * Copyright (c) 2025, Janusz Wolak
 * All rights reserved.
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
    output reg update_flags
);

    // Definicje stanów
    localparam [2:0] FETCH    = 3'b000;
    localparam [2:0] DECODE   = 3'b001;
    localparam [2:0] EXECUTE  = 3'b010;
    localparam [2:0] WRITEBACK = 3'b011;
    localparam [2:0] HALT     = 3'b100;

    reg [2:0] next_state;
    reg [7:0] next_pc;
    
    // Flagi CPU (zachowane między instrukcjami)
    reg zero_flag;
    reg carry_flag;
    reg negative_flag;

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
        end else begin
            current_state <= next_state;
            pc <= next_pc;
            
            // Aktualizacja instrukcji w stanie DECODE
            if (current_state == DECODE) begin
                current_instruction <= instruction_data;
                opcode <= instruction_data[7:4];
                dest_reg <= instruction_data[3:2];
                src_reg <= instruction_data[1:0];
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
                end else begin
                    next_state = EXECUTE;
                end
            end
            
            EXECUTE: begin
                next_state = WRITEBACK;
            end
            
            WRITEBACK: begin
                update_flags = 1'b1;
                
                // Obsługa skoków
                case (opcode)
                    4'b1000: begin // JMP - bezwarunkowy
                        next_pc = alu_result;
                        execute_jump = 1'b1;
                    end
                    4'b1001: begin // JZ
                        if (zero_flag) begin
                            next_pc = alu_result;
                            execute_jump = 1'b1;
                        end else begin
                            next_pc = pc + 1;
                        end
                    end
                    4'b1010: begin // JNZ  
                        if (!zero_flag) begin
                            next_pc = alu_result;
                            execute_jump = 1'b1;
                        end else begin
                            next_pc = pc + 1;
                        end
                    end
                    4'b1011: begin // JC
                        if (carry_flag) begin
                            next_pc = alu_result;
                            execute_jump = 1'b1;
                        end else begin
                            next_pc = pc + 1;
                        end
                    end
                    4'b1100: begin // JNC
                        if (!carry_flag) begin
                            next_pc = alu_result;
                            execute_jump = 1'b1;
                        end else begin
                            next_pc = pc + 1;
                        end
                    end
                    4'b1101: begin // JN
                        if (negative_flag) begin
                            next_pc = alu_result;
                            execute_jump = 1'b1;
                        end else begin
                            next_pc = pc + 1;
                        end
                    end
                    4'b1110: begin // JP
                        if (!negative_flag) begin
                            next_pc = alu_result;
                            execute_jump = 1'b1;
                        end else begin
                            next_pc = pc + 1;
                        end
                    end
                    4'b1111: begin // CMP - tylko ustawia flagi
                        next_pc = pc + 1;
                    end
                    default: begin // Operacje arytmetyczno-logiczne
                        next_pc = pc + 1;
                        update_registers = 1'b1;
                    end
                endcase
                
                next_state = FETCH;
            end
            
            HALT: begin
                next_state = HALT; // Pozostań w stanie HALT
            end
            
            default: begin
                next_state = FETCH;
            end
        endcase
    end

endmodule