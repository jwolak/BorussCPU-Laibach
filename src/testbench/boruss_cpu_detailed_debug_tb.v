`timescale 1ns / 1ps

module boruss_cpu_detailed_debug_tb;

    reg clk;
    reg reset;
    
    wire [7:0] pc;
    wire [7:0] instruction_addr;
    wire [2:0] cpu_state;
    wire [7:0] debug_reg_a, debug_reg_b, debug_reg_c, debug_reg_d;
    wire [7:0] led_out;
    
    boruss_cpu uut (
        .clk(clk),
        .reset(reset),
        .pc(pc),
        .instruction_addr(instruction_addr),
        .cpu_state(cpu_state),
        .debug_reg_a(debug_reg_a),
        .debug_reg_b(debug_reg_b),
        .debug_reg_c(debug_reg_c),
        .debug_reg_d(debug_reg_d),
        .led_out(led_out)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    function [63:0] state_name;
        input [2:0] state;
        begin
            case (state)
                3'b000: state_name = "FETCH   ";
                3'b001: state_name = "DECODE  ";
                3'b010: state_name = "EXECUTE ";
                3'b011: state_name = "WRITEBACK";
                3'b100: state_name = "FETCH_IMM";
                3'b101: state_name = "HALT    ";
                default: state_name = "UNKNOWN ";
            endcase
        end
    endfunction

    integer slow_clk_count = 0;

    initial begin
        $display("========================================");
        $display("  DETAILED CPU DEBUG");
        $display("========================================");
        
        reset = 0;
        #50;
        reset = 1;
        #100;
        
        $display("\nCHECKING CLOCK DIVIDER:");
        $display("clk_divider bit [5] period should be 2^6 = 64 system clocks");
        $display("Monitoring for 10 slow_clk cycles...\n");
        
        $display("Slow CLK | Time\t\t| State\t\t| PC | Addr | Instr | Opcode | Dest | Src | Is_Imm | Imm_Val | Update_Regs | Reg_A | ALU_Result | LED");
        $display("---------|---------------|---------------|----|----- |-------|--------|------|-----|--------|---------|-------------|-------|------------|-----");
        
        repeat(10) begin
            @(posedge uut.slow_clk);
            #2;
            slow_clk_count = slow_clk_count + 1;
            
            $display("%0d\t | %0t ns\t| %s\t| %h | %h   | %h    | %h     | %h   | %h  | %b      | %h      | %b           | %h    | %h         | %b",
                slow_clk_count,
                $time,
                state_name(cpu_state),
                pc,
                instruction_addr,
                uut.fsm_inst.current_instruction,
                uut.fsm_inst.opcode,
                uut.fsm_inst.dest_reg,
                uut.fsm_inst.src_reg,
                uut.fsm_inst.is_immediate,
                uut.fsm_inst.immediate_value,
                uut.update_registers,
                debug_reg_a,
                uut.alu_result,
                led_out
            );
            
            // Szczegółowa analiza w stanie WRITEBACK
            if (cpu_state == 3'b011) begin
                $display("    >>> WRITEBACK detected:");
                $display("        - update_registers = %b", uut.update_registers);
                $display("        - dest_reg = %h", uut.fsm_inst.dest_reg);
                $display("        - is_immediate = %b", uut.fsm_inst.is_immediate);
                $display("        - immediate_value = %h", uut.fsm_inst.immediate_value);
                $display("        - alu_result = %h", uut.alu_result);
                $display("        - ALU operand_a = %h", uut.alu_operand_a);
                $display("        - ALU operand_b = %h", uut.alu_operand_b);
                $display("        - ALU operation = %h", uut.alu_operation);
                
                if (uut.update_registers) begin
                    if (uut.fsm_inst.dest_reg == 4'h0) begin
                        if (uut.fsm_inst.is_immediate) begin
                            $display("        >>> Should write %h to reg_a (immediate)", uut.fsm_inst.immediate_value);
                        end else begin
                            $display("        >>> Should write %h to reg_a (ALU result)", uut.alu_result);
                        end
                    end
                end else begin
                    $display("        !!! update_registers is FALSE - registers won't update!");
                end
            end
        end
        
        $display("\n========================================");
        $display("FINAL STATE:");
        $display("========================================");
        $display("PC: %h", pc);
        $display("State: %s", state_name(cpu_state));
        $display("Reg_A: %h (LED: %b)", debug_reg_a, led_out);
        $display("Reg_B: %h", debug_reg_b);
        $display("Reg_C: %h", debug_reg_c);
        $display("Reg_D: %h", debug_reg_d);
        
        $display("\n========================================");
        $display("ANALYSIS:");
        $display("========================================");
        
        if (debug_reg_a == 8'h01) begin
            $display("SUCCESS! Reg_A = 0x01");
            $display("The instruction ADD R0, #1 executed correctly!");
        end else if (debug_reg_a == 8'h00) begin
            $display("FAILURE! Reg_A is still 0x00");
            $display("\nPossible causes:");
            $display("1. FSM not reaching WRITEBACK state");
            $display("2. update_registers signal not asserted");
            $display("3. is_immediate flag incorrect");
            $display("4. dest_reg not pointing to R0");
            $display("5. Register update logic not working");
            
            // Sprawdź ostatni stan FSM
            $display("\nLast FSM state details:");
            $display("  current_instruction: %h", uut.fsm_inst.current_instruction);
            $display("  opcode: %h (expected: 00)", uut.fsm_inst.opcode);
            $display("  dest_reg: %h (expected: 0)", uut.fsm_inst.dest_reg);
            $display("  is_immediate: %b (expected: 1)", uut.fsm_inst.is_immediate);
            $display("  immediate_value: %h (expected: 01)", uut.fsm_inst.immediate_value);
        end
        
        #100;
        $finish;
    end
    
    // Monitor każdej zmiany reg_a
    always @(posedge uut.slow_clk) begin
        if (debug_reg_a != 8'h00) begin
            $display("\n!!! REG_A CHANGED to %h at time %0t ns !!!\n", debug_reg_a, $time);
        end
    end
    
    initial begin
        $dumpfile("boruss_cpu_detailed_debug_tb.vcd");
        $dumpvars(0, boruss_cpu_detailed_debug_tb);
    end

endmodule