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
      // Program Knight Rider - poprawny format instrukcji
        
        // LOAD immediate 0x01 do reg_a (LED0)
        // Format: [opcode 0000][dest_reg 00][src 0001] + immediate value
        rom_memory[8'h00] = 8'b00000001; // LOAD immediate do reg_a
        rom_memory[8'h01] = 8'h01;       // Wartość immediate: 0x01 (LED0)
        
        // NOP dla delay
        rom_memory[8'h02] = 8'b00000000; // NOP
        rom_memory[8'h03] = 8'b00000000; // NOP
        
        // SHL reg_a (LED0 -> LED1)
        rom_memory[8'h04] = 8'b01100000; // SHL reg_a (opcode=0110, dest=00, src=00)
        rom_memory[8'h05] = 8'b00000000; // NOP
        rom_memory[8'h06] = 8'b00000000; // NOP
        
        // SHL reg_a (LED1 -> LED2)
        rom_memory[8'h07] = 8'b01100000; // SHL reg_a
        rom_memory[8'h08] = 8'b00000000; // NOP
        rom_memory[8'h09] = 8'b00000000; // NOP
        
        // SHL reg_a (LED2 -> LED3)
        rom_memory[8'h0A] = 8'b01100000; // SHL reg_a
        rom_memory[8'h0B] = 8'b00000000; // NOP
        rom_memory[8'h0C] = 8'b00000000; // NOP
        
        // SHL reg_a (LED3 -> LED4)
        rom_memory[8'h0D] = 8'b01100000; // SHL reg_a
        rom_memory[8'h0E] = 8'b00000000; // NOP
        rom_memory[8'h0F] = 8'b00000000; // NOP
        
        // SHL reg_a (LED4 -> LED5)
        rom_memory[8'h10] = 8'b01100000; // SHL reg_a
        rom_memory[8'h11] = 8'b00000000; // NOP
        rom_memory[8'h12] = 8'b00000000; // NOP
        
        // SHL reg_a (LED5 -> LED6)
        rom_memory[8'h13] = 8'b01100000; // SHL reg_a
        rom_memory[8'h14] = 8'b00000000; // NOP
        rom_memory[8'h15] = 8'b00000000; // NOP
        
        // SHL reg_a (LED6 -> LED7)
        rom_memory[8'h16] = 8'b01100000; // SHL reg_a
        rom_memory[8'h17] = 8'b00000000; // NOP
        rom_memory[8'h18] = 8'b00000000; // NOP
        
        // Bezwarunkowy skok do początku
        // Format: [opcode 1000][dest 00][src 00] + adres
        rom_memory[8'h19] = 8'b10000000; // JMP (opcode=1000, dest=00, src=00)
        rom_memory[8'h1A] = 8'h00;       // Adres skoku: 0x00 (początek programu)
        
        // Wypełnij resztę zerami (NOP)
        for (i = 8'h1B; i < 256; i = i + 1) begin
            rom_memory[i] = 8'b00000000; // NOP
        end
    end
    
    // Logika odczytu (kombinacyjna)
    always @(*) begin
        data_out = rom_memory[address];
    end

endmodule