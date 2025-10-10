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
// Module: boruss_memory_controller
// Description: Memory controller module for the Boruss CPU architecture.
//              Handles memory access operations, address decoding, and 
//              interfacing between the CPU and various memory subsystems.
//              Provides centralized control for memory read/write operations,
//              cache management, and memory mapped I/O access.
//
// Author: [Janusz Wolak]
// Date: [October 2025]
// Version: [1.0]
//
// Functionality:
//   - Memory address decoding and routing
//   - Read/write operation control
//   - Memory access arbitration
//   - Interface with cache subsystem
//   - Memory mapped I/O handling
//
// Notes:
//   - Part of the Boruss CPU Laibach implementation
//   - Ensure proper timing constraints for memory operations
//==============================================================================
module boruss_memory_controller (
    input clk,
    input reset,
    
    // CPU interface for instructions
    input [7:0] instruction_address,  // Address for instruction fetch
    output [7:0] instruction_data,    // Instruction data output
    
    // CPU interface for data
    input [7:0] data_address,        // Address for data access
    input [7:0] data_in,             // Data input for writes
    input data_write_enable,         // Write enable signal
    input data_read_enable,          // Read enable signal
    output [7:0] data_out,           // Data output
    
    // Memory mapping control
    input memory_map_select  // 0=ROM, 1=RAM
);

    // Internal signals for ROM
    wire [7:0] rom_data_out;    // Instruction data from ROM
    
    // Internal signals for RAM
    wire [7:0] ram_data_out;    // Data output from RAM
    reg ram_write_enable;       // RAM write enable
    reg ram_read_enable;        // RAM read enable

    // ROM instance (for instructions)
    boruss_rom rom_inst (
        .address(instruction_address),  // Address input
        .data_out(instruction_data)     // Data output
    );

    // RAM instance (for data)
    boruss_ram ram_inst (
        .clk(clk),
        .reset(reset),
        .address(data_address),          // Address input
        .data_in(data_in),               // Data input
        .write_enable(ram_write_enable), // Write enable
        .read_enable(ram_read_enable),   // Read enable
        .data_out(ram_data_out)          // Data output
    );
    
    // Memory mapping logic
    always @(*) begin
        // Default values
        ram_write_enable = 1'b0;        // Disable RAM write
        ram_read_enable = 1'b0;         // Disable RAM read

        if (memory_map_select) begin    // If RAM(1) is selected
            ram_write_enable = data_write_enable;   // Enable RAM write if CPU requests it
            ram_read_enable = data_read_enable;     // Enable RAM read if CPU requests it
        end
    end
    
    // Data output multiplexer
    assign data_out = memory_map_select ? ram_data_out : rom_data_out; // Select data from RAM or ROM based on mapping
endmodule