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

module boruss_rom (
    input [7:0] address,
    output reg [7:0] data_out
);

    // Pamięć ROM 256 bajtów z programem LED Knight Rider
    reg [7:0] rom_memory [255:0];
    
    // Inicjalizacja ROM z programem Knight Rider
    integer i;
    initial begin
   // Inicjalizuj pamięć zerami
        for (i = 0; i < 256; i = i + 1) begin
            rom_memory[i] = 8'h00;
        end

        // Zawsze próbuj załadować z pliku
        $readmemh("program/knight_rider.mem", rom_memory);
        $display("Program loaded from program/knight_rider.mem");
        
        // Sprawdź czy pierwszy bajt jest != 0 (program załadowany)
        if (rom_memory[0] == 8'h00) begin
            $display("No program file found, using built-in Knight Rider");
            // Domyślny program
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
            $display("Program loaded from program/knight_rider.mem");
        end
    end
    
    // Logika odczytu (kombinacyjna)
    always @(*) begin
        data_out = rom_memory[address];
    end

endmodule