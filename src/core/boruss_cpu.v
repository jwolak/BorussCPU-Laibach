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

module boruss_cpu (
    input clk,
    input reset,
    output [7:0] pc,
    output [7:0] instruction_addr,
    output [2:0] cpu_state,
    output [7:0] debug_reg_a,
    output [7:0] debug_reg_b,
    output [7:0] debug_reg_c,
    output [7:0] debug_reg_d,
    
    // Wyjście dla 8 LED-ów DE0-Nano
    output [7:0] led_out
);

    // Rejestry CPU
    reg [7:0] reg_a, reg_b, reg_c, reg_d;
    
    // Sygnały pamięci
    wire [7:0] instruction_data;
    wire [7:0] memory_data_out;
    reg [7:0] memory_addr;
    reg [7:0] memory_data_in;
    reg memory_write_enable;
    reg memory_read_enable;
    reg memory_map_select;  // 0=ROM, 1=RAM
    
    // Sygnały z maszyny stanów
    wire [7:0] fsm_pc;
    wire [7:0] fsm_instruction_addr;
    wire [7:0] current_instruction;
    wire [3:0] opcode;
    wire [1:0] dest_reg, src_reg;
    wire execute_jump, update_registers, update_flags;
    wire [2:0] current_state;
    
    // Sygnały ALU
    reg [7:0] alu_operand_a, alu_operand_b, alu_operation;
    wire [7:0] alu_result;
    wire alu_zero_flag, alu_carry_flag, alu_negative_flag;
    
    // Przypisania wyjściowe
    assign pc = fsm_pc;
    assign instruction_addr = fsm_instruction_addr;
    assign cpu_state = current_state;
    assign debug_reg_a = reg_a;
    assign debug_reg_b = reg_b;
    assign debug_reg_c = reg_c;
    assign debug_reg_d = reg_d;
    
    // Przypisanie LED-ów - wyświetla zawartość rejestru A
    assign led_out = reg_a;
    
    // Instancja kontrolera pamięci
    boruss_memory_controller memory_ctrl (
        .clk(clk),
        .reset(reset),
        .instruction_address(fsm_instruction_addr),
        .instruction_data(instruction_data),
        .data_address(memory_addr),
        .data_in(memory_data_in),
        .data_write_enable(memory_write_enable),
        .data_read_enable(memory_read_enable),
        .data_out(memory_data_out),
        .memory_map_select(memory_map_select)
    );
    
    // Instancja maszyny stanów
    boruss_cpu_fsm fsm_inst (
        .clk(clk),
        .reset(reset),
        .instruction_data(instruction_data),
        .alu_zero_flag(alu_zero_flag),
        .alu_carry_flag(alu_carry_flag),
        .alu_negative_flag(alu_negative_flag),
        .alu_result(alu_result),
        .current_state(current_state),
        .pc(fsm_pc),
        .instruction_addr(fsm_instruction_addr),
        .current_instruction(current_instruction),
        .opcode(opcode),
        .dest_reg(dest_reg),
        .src_reg(src_reg),
        .execute_jump(execute_jump),
        .update_registers(update_registers),
        .update_flags(update_flags)
    );
    
    // Instancja ALU
    boruss_alu alu_inst (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .operation_code(alu_operation),
        .result(alu_result),
        .zero_flag(alu_zero_flag),
        .carry_flag(alu_carry_flag),
        .negative_flag(alu_negative_flag)
    );
    
    // Logika przygotowania operandów ALU
    always @(*) begin
        // Domyślnie używaj RAM
        memory_map_select = 1'b1;
        memory_addr = 8'h00;
        memory_data_in = 8'h00;
        memory_write_enable = 1'b0;
        memory_read_enable = 1'b0;
        
        // Wybór operandu A
        case (src_reg)
            2'b00: alu_operand_a = reg_a;
            2'b01: alu_operand_a = reg_b;
            2'b10: alu_operand_a = reg_c;
            2'b11: alu_operand_a = reg_d;
        endcase
        
        // Wybór operandu B
        case (dest_reg)
            2'b00: alu_operand_b = reg_a;
            2'b01: alu_operand_b = reg_b;
            2'b10: alu_operand_b = reg_c;
            2'b11: alu_operand_b = reg_d;
        endcase
        
        // Mapowanie opcode na kod operacji ALU
        case (opcode)
            4'b0000: alu_operation = 8'b00000000; // ADD
            4'b0001: alu_operation = 8'b00000001; // SUB
            4'b0010: alu_operation = 8'b00000010; // AND
            4'b0011: alu_operation = 8'b00000011; // OR
            4'b0100: alu_operation = 8'b00000100; // XOR
            4'b0101: alu_operation = 8'b00000101; // NOT
            4'b0110: alu_operation = 8'b00000110; // SHL
            4'b0111: alu_operation = 8'b00000111; // SHR
            4'b1000: alu_operation = 8'b00001000; // JMP
            4'b1001: alu_operation = 8'b00001001; // JZ
            4'b1010: alu_operation = 8'b00001010; // JNZ
            4'b1011: alu_operation = 8'b00001011; // JC
            4'b1100: alu_operation = 8'b00001100; // JNC
            4'b1101: alu_operation = 8'b00001101; // JN
            4'b1110: alu_operation = 8'b00001110; // JP
            4'b1111: alu_operation = 8'b00001111; // CMP
            default: alu_operation = 8'b00000000;
        endcase
    end
    
    // Aktualizacja rejestrów
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            reg_a <= 8'h00;
            reg_b <= 8'h00;
            reg_c <= 8'h00;
            reg_d <= 8'h00;
        end else begin
            // Aktualizacja rejestrów po operacjach arytmetyczno-logicznych
            if (update_registers) begin
                case (dest_reg)
                    2'b00: reg_a <= alu_result;
                    2'b01: reg_b <= alu_result;
                    2'b10: reg_c <= alu_result;
                    2'b11: reg_d <= alu_result;
                endcase
            end
        end
    end

endmodule