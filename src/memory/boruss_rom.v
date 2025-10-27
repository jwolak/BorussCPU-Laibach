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

module boruss_rom (
    input [7:0] address,
    output reg [7:0] data_out
);

    // ROM memory 256 bytes with LED Knight Rider program
    reg [7:0] rom_memory [255:0];
        
    // ROM initialization with Knight Rider program
    integer i;
    initial begin
        // Initialize memory with zeros
        for (i = 0; i < 256; i = i + 1) begin
            rom_memory[i] = 8'h00;
        end

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
    end

    // Read logic (combinational)
    always @(*) begin
        data_out = rom_memory[address];
    end

endmodule