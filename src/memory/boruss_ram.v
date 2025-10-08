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

module boruss_ram (
    input clk,
    input reset,
    input [7:0] address,
    input [7:0] data_in,
    input write_enable,
    input read_enable,
    output reg [7:0] data_out
);

    // Pamięć RAM 256 bajtów (8-bitowe adresy)
    reg [7:0] memory [255:0];
    
    // Inicjalizacja pamięci
    integer i;
    always @(posedge reset) begin
        if (reset) begin
            for (i = 0; i < 256; i = i + 1) begin
                memory[i] <= 8'h00;
            end
            data_out <= 8'h00;
        end
    end
    
    // Logika odczytu/zapisu
    always @(posedge clk) begin
        if (!reset) begin
            if (write_enable && !read_enable) begin
                // Zapis do pamięci
                memory[address] <= data_in;
            end else if (read_enable && !write_enable) begin
                // Odczyt z pamięci
                data_out <= memory[address];
            end
        end
    end

endmodule