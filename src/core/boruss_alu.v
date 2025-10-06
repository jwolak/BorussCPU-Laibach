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

module boruss_alu (
    input [7:0] operand_a,
    input [7:0] operand_b,
    input [7:0] operation_code,
    output reg [7:0] result,
    output reg zero_flag,
    output reg carry_flag,
    output reg negative_flag
);
    always @(*) begin
        zero_flag = 1'b0;
        carry_flag = 1'b0;
        negative_flag = 1'b0;
        
        case (operation_code)
            8'b00000000: begin // ADD
                {carry_flag, result} = operand_a + operand_b;
            end
            8'b00000001: begin // SUB
                {carry_flag, result} = operand_a - operand_b;
            end

            8'b00000010: result = operand_a & operand_b; // AND
            8'b00000011: result = operand_a | operand_b; // OR
            8'b00000100: result = operand_a ^ operand_b; // XOR
            8'b00000101: result = ~operand_a;            // NOT

            8'b00000110: begin // SHL
                {carry_flag, result} = {operand_a, 1'b0};
            end
            8'b00000111: begin // SHR
                {result, carry_flag} = {1'b0, operand_a};
            end
            
            // Operacje skoków
            8'b00001000: result = operand_b;             // JMP - Unconditional jump
            8'b00001001: result = operand_b;             // JZ - Jump if zero
            8'b00001010: result = operand_b;             // JNZ - Jump if not zero
            8'b00001011: result = operand_b;             // JC - Jump if carry
            8'b00001100: result = operand_b;             // JNC - Jump if no carry
            8'b00001101: result = operand_b;             // JN - Jump if negative
            8'b00001110: result = operand_b;             // JP - Jump if positive
            8'b00001111: begin                           // CMP - Comparison (sets flags)
                {carry_flag, result} = operand_a - operand_b;
            end

            default: result = 8'b00000000;               // NOP
        endcase
        
        // flag update based on result
        zero_flag = (result == 8'b00000000);
        negative_flag = result[7];
    end
endmodule