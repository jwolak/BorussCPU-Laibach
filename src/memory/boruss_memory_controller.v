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

module boruss_memory_controller (
    input clk,
    input reset,
    
    // Interfejs CPU dla instrukcji
    input [7:0] instruction_address,
    output [7:0] instruction_data,
    
    // Interfejs CPU dla danych
    input [7:0] data_address,
    input [7:0] data_in,
    input data_write_enable,
    input data_read_enable,
    output [7:0] data_out,
    
    // Sygnały kontrolne
    input memory_map_select  // 0=ROM, 1=RAM dla obszaru danych
);

    // Sygnały wewnętrzne dla ROM
    wire [7:0] rom_data_out;
    
    // Sygnały wewnętrzne dla RAM
    wire [7:0] ram_data_out;
    reg ram_write_enable;
    reg ram_read_enable;
    
    // Instancja ROM (dla instrukcji)
    boruss_rom rom_inst (
        .address(instruction_address),
        .data_out(instruction_data)
    );
    
    // Instancja RAM (dla danych)
    boruss_ram ram_inst (
        .clk(clk),
        .reset(reset),
        .address(data_address),
        .data_in(data_in),
        .write_enable(ram_write_enable),
        .read_enable(ram_read_enable),
        .data_out(ram_data_out)
    );
    
    // Logika mapowania pamięci
    always @(*) begin
        // Domyślne wartości
        ram_write_enable = 1'b0;
        ram_read_enable = 1'b0;
        
        if (memory_map_select) begin
            // Dostęp do RAM
            ram_write_enable = data_write_enable;
            ram_read_enable = data_read_enable;
        end
    end
    
    // Multiplekser wyjścia danych
    assign data_out = memory_map_select ? ram_data_out : rom_data_out;

endmodule