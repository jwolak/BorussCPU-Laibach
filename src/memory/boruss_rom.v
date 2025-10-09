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
        
        // SHL reg_a (LED0 -> LED1)
        rom_memory[8'h02] = 8'b01100000; // SHL reg_a (opcode=0110, dest=00, src=00)
        
        // SHL reg_a (LED1 -> LED2)
        rom_memory[8'h02] = 8'b01100000; // SHL reg_a

        
        // SHL reg_a (LED2 -> LED3)
        rom_memory[8'h04] = 8'b01100000; // SHL reg_a

        
        // SHL reg_a (LED3 -> LED4)
        rom_memory[8'h05] = 8'b01100000; // SHL reg_a

        
        // SHL reg_a (LED4 -> LED5)
        rom_memory[8'h06] = 8'b01100000; // SHL reg_a
    
        
        // SHL reg_a (LED5 -> LED6)
        rom_memory[8'h07] = 8'b01100000; // SHL reg_a

        
        // SHL reg_a (LED6 -> LED7)
        rom_memory[8'h08] = 8'b01100000; // SHL reg_a
   
        
        // Bezwarunkowy skok do początku
        // Format: [opcode 1000][dest 00][src 00] + adres
        rom_memory[8'h09] = 8'b10000000; // JMP (opcode=1000, dest=00, src=00)
        rom_memory[8'h0A] = 8'h00;       // Adres skoku: 0x00 (początek programu)
        
        // Wypełnij resztę zerami (NOP)
        for (i = 8'h0B; i < 256; i = i + 1) begin
            rom_memory[i] = 8'b00000000; // NOP
        end
    end
    
    // Logika odczytu (kombinacyjna)
    always @(*) begin
        data_out = rom_memory[address];
    end

endmodule