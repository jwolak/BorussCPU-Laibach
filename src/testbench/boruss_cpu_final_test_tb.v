`timescale 1ns / 1ps

module boruss_cpu_final_test_tb;

    reg clk;
    reg reset;
    
    wire [7:0] pc;
    wire [7:0] instruction_addr;
    wire [2:0] cpu_state;
    wire [7:0] debug_reg_a;
    wire [7:0] debug_reg_b;
    wire [7:0] debug_reg_c;
    wire [7:0] debug_reg_d;
    wire [7:0] led_out;
    
    // Liczniki
    integer slow_clk_cycles = 0;
    reg prev_slow_clk = 0;
    
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

    // Generacja zegara systemowego (50 MHz)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Nazwy stanów
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

    // Monitor slow_clk transitions
    always @(posedge clk) begin
        if (uut.slow_clk != prev_slow_clk) begin
            prev_slow_clk = uut.slow_clk;
            if (uut.slow_clk == 1'b1) begin
                slow_clk_cycles = slow_clk_cycles + 1;
            end
        end
    end

    initial begin
        $display("========================================");
        $display("  Boruss CPU Complete Test");
        $display("========================================");
        $display("");
        $display("IMPORTANT: CPU uses clock divider");
        $display("  System clock: 50 MHz (20ns period)");
        $display("  Slow clock: clk_divider[20] (~24Hz)");
        $display("  Need ~2^20 = 1,048,576 system clocks");
        $display("  for one slow_clk cycle!");
        $display("");
        $display("Running extended simulation...");
        $display("========================================");
        
        reset = 0;
        #25;
        reset = 1;
        #40;
        
        $display("Time\t\t| Slow CLK | State\t\t| PC\t| Instr\t| Reg_A\t| LED");
        $display("----------------|----------|---------------|-------|-------|-------|-------");
        
        // Potrzebujemy DUŻO więcej cykli dla clock dividera
        // Dla ~10 cykli slow_clk potrzebujemy: 10 * 2^20 = 10,485,760 cykli
        // To zbyt dużo dla symulacji, więc monitorujemy zmiany
        
        repeat(50) begin
            // Czekaj na zbocze slow_clk
            @(posedge uut.slow_clk);
            #2;
            
            $display("%0t ns\t| %0d\t   | %s\t| %h\t| %h\t| %h\t| %b",
                $time,
                slow_clk_cycles,
                state_name(cpu_state),
                pc,
                uut.current_instruction,
                debug_reg_a,
                led_out
            );
        end
        
        $display("");
        $display("========================================");
        $display("  Test Results");
        $display("========================================");
        $display("Slow clock cycles executed: %0d", slow_clk_cycles);
        $display("Final PC: 0x%h", pc);
        $display("Final State: %s", state_name(cpu_state));
        $display("Register A: 0x%h (LED: %b)", debug_reg_a, led_out);
        $display("Register B: 0x%h", debug_reg_b);
        $display("Register C: 0x%h", debug_reg_c);
        $display("Register D: 0x%h", debug_reg_d);
        
        $display("");
        if (debug_reg_a == 8'h01) begin
            $display("*** TEST PASSED ***");
            $display("Register A = 0x01 as expected from ADD R0, #1");
        end else if (debug_reg_a == 8'h00) begin
            $display("*** TEST FAILED ***");
            $display("Register A is still 0x00");
            $display("CPU may not be executing instructions correctly");
        end else begin
            $display("*** UNEXPECTED RESULT ***");
            $display("Register A = 0x%h", debug_reg_a);
        end
        
        #1000;
        $finish;
    end
    
    initial begin
        $dumpfile("boruss_cpu_final_test_tb.vcd");
        $dumpvars(0, boruss_cpu_final_test_tb);
    end

endmodule