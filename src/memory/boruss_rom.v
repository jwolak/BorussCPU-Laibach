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
        // Program Knight Rider - z bezpośrednim resetem
        
        // Sekwencja dla LED0 (0x01)
        rom_memory[8'h00] = 8'h01;       // LOAD immediate 0x01 -> reg_a
        rom_memory[8'h01] = 8'b00000000; // NOP (delay)
        rom_memory[8'h02] = 8'b00000000; // NOP (delay)
        
        // Sekwencja dla LED1 (0x02) 
        rom_memory[8'h03] = 8'h02;       // LOAD immediate 0x02 -> reg_a
        rom_memory[8'h04] = 8'b00000000; // NOP (delay)
        rom_memory[8'h05] = 8'b00000000; // NOP (delay)
        
        // Sekwencja dla LED2 (0x04)
        rom_memory[8'h06] = 8'h04;       // LOAD immediate 0x04 -> reg_a
        rom_memory[8'h07] = 8'b00000000; // NOP (delay) 
        rom_memory[8'h08] = 8'b00000000; // NOP (delay)
        
        // Sekwencja dla LED3 (0x08)
        rom_memory[8'h09] = 8'h08;       // LOAD immediate 0x08 -> reg_a
        rom_memory[8'h0A] = 8'b00000000; // NOP (delay)
        rom_memory[8'h0B] = 8'b00000000; // NOP (delay)
        
        // Sekwencja dla LED4 (0x10)
        rom_memory[8'h0C] = 8'h10;       // LOAD immediate 0x10 -> reg_a
        rom_memory[8'h0D] = 8'b00000000; // NOP (delay)
        rom_memory[8'h0E] = 8'b00000000; // NOP (delay)
        
        // Sekwencja dla LED5 (0x20)
        rom_memory[8'h0F] = 8'h20;       // LOAD immediate 0x20 -> reg_a
        rom_memory[8'h10] = 8'b00000000; // NOP (delay)
        rom_memory[8'h11] = 8'b00000000; // NOP (delay)
        
        // Sekwencja dla LED6 (0x40)
        rom_memory[8'h12] = 8'h40;       // LOAD immediate 0x40 -> reg_a
        rom_memory[8'h13] = 8'b00000000; // NOP (delay)
        rom_memory[8'h14] = 8'b00000000; // NOP (delay)
        
        // Sekwencja dla LED7 (0x80)
        rom_memory[8'h15] = 8'h80;       // LOAD immediate 0x80 -> reg_a
        rom_memory[8'h16] = 8'b00000000; // NOP (delay)
        rom_memory[8'h17] = 8'b00000000; // NOP (delay)
        
        // Skok bezwarunkowy do początku
        rom_memory[8'h18] = 8'b10000000; // JMP
        rom_memory[8'h19] = 8'h00;       // Adres skoku (0x00)
        
        // Wypełnij resztę zerami
        for (i = 8'h1A; i < 256; i = i + 1) begin
            rom_memory[i] = 8'b00000000; // NOP
        end
    end
    
    // Logika odczytu (kombinacyjna)
    always @(*) begin
        data_out = rom_memory[address];
    end

endmodule