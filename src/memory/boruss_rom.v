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

    // Pamięć ROM 256 bajtów z przykładowym programem
    reg [7:0] rom_memory [255:0];
    
    // Inicjalizacja ROM z przykładowym programem
    initial begin
        // Przykładowy program demonstracyjny
        rom_memory[8'h00] = 8'b00000000; // ADD reg_a, reg_a (NOP - dodaj 0+0)
        rom_memory[8'h01] = 8'b00010001; // ADD reg_b, reg_b 
        rom_memory[8'h02] = 8'b00100010; // ADD reg_c, reg_c
        rom_memory[8'h03] = 8'b00110011; // ADD reg_d, reg_d
        
        // Test operacji arytmetycznych
        rom_memory[8'h04] = 8'b00000001; // SUB reg_a, reg_a
        rom_memory[8'h05] = 8'b00010000; // ADD reg_b, reg_a
        rom_memory[8'h06] = 8'b11110000; // CMP reg_a, reg_a (porównanie)
        
        // Test skoku bezwarunkowego
        rom_memory[8'h07] = 8'b10000000; // JMP to address in reg_a (skok do adresu 0)
        
        // Test skoków warunkowych
        rom_memory[8'h08] = 8'b10010000; // JZ - skok jeśli zero_flag=1
        rom_memory[8'h09] = 8'b10100000; // JNZ - skok jeśli zero_flag=0
        rom_memory[8'h0A] = 8'b10110000; // JC - skok jeśli carry_flag=1
        rom_memory[8'h0B] = 8'b11000000; // JNC - skok jeśli carry_flag=0
        
        // Test operacji logicznych
        rom_memory[8'h0C] = 8'b00100001; // AND reg_a, reg_b
        rom_memory[8'h0D] = 8'b00110001; // OR reg_a, reg_b
        rom_memory[8'h0E] = 8'b01000001; // XOR reg_a, reg_b
        rom_memory[8'h0F] = 8'b01010000; // NOT reg_a
        
        // Test przesunięć
        rom_memory[8'h10] = 8'b01100000; // SHL reg_a
        rom_memory[8'h11] = 8'b01110000; // SHR reg_a
        
        // Pętla nieskończona (dla demonstracji)
        rom_memory[8'h12] = 8'b10000000; // JMP to address 0x00
        
        // Wypełnij resztę pamięci zerami
        integer i;
        for (i = 8'h13; i < 256; i = i + 1) begin
            rom_memory[i] = 8'h00;
        end
        
        // Instrukcja HALT na końcu
        rom_memory[8'hFF] = 8'hFF; // HALT
    end
    
    // Logika odczytu (kombinacyjna)
    always @(*) begin
        data_out = rom_memory[address];
    end

endmodule