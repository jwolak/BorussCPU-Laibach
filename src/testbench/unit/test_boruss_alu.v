`timescale 1ns/1ps

module test_boruss_alu;
    // test signals
    reg [7:0] operand_a;
    reg [7:0] operand_b;
    reg [7:0] operation_code;
    
    wire [7:0] result;
    wire zero_flag;
    wire carry_flag;
    wire negative_flag;
    
    // ALU instantiation to be tested
    boruss_alu tested_boruss_alu_dut (
        .operand_a(operand_a),
        .operand_b(operand_b),
        .operation_code(operation_code),
        .result(result),
        .zero_flag(zero_flag),
        .carry_flag(carry_flag),
        .negative_flag(negative_flag)
    );

    // Test counters
    integer test_count = 0;
    integer pass_count = 0;
    integer fail_count = 0;

    // Task for displaying results
    task display_result;
        input [7:0] expected_result;
        input expected_zero;
        input expected_carry;
        input expected_negative;
        input [31:0] test_name;
        begin
            test_count = test_count + 1;
            
            $display("=== %s ===", test_name);
            $display("A=%d (0x%02h), B=%d (0x%02h), Op=0x%02h", 
                     operand_a, operand_a, operand_b, operand_b, operation_code);
            $display("Result: %d (0x%02h), Expected: %d (0x%02h)", 
                     result, result, expected_result, expected_result);
            $display("Flags - Z:%b C:%b N:%b | Expected - Z:%b C:%b N:%b", 
                     zero_flag, carry_flag, negative_flag,
                     expected_zero, expected_carry, expected_negative);
            
            if (result == expected_result && 
                zero_flag == expected_zero && 
                carry_flag == expected_carry && 
                negative_flag == expected_negative) begin
                $display("PASS");
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL");
                fail_count = fail_count + 1;

                 // Detailed error information
                if (result != expected_result)
                    $display("  ERROR: Result mismatch - got %h, expected %h", result, expected_result);
                if (zero_flag != expected_zero)
                    $display("  ERROR: Zero flag mismatch - got %b, expected %b", zero_flag, expected_zero);
                if (carry_flag != expected_carry)
                    $display("  ERROR: Carry flag mismatch - got %b, expected %b", carry_flag, expected_carry);
                if (negative_flag != expected_negative)
                    $display("  ERROR: Negative flag mismatch - got %b, expected %b", negative_flag, expected_negative);
            end
            $display("");
            #10; // Delay between tests
        end
    endtask
    
    initial begin
        $display("=== BORUSS ALU TESTBENCH ===");
        $display("Starting ALU tests...\n");
        
        // ========================
        // ARITHMETIC OPERATIONS
        // ========================
        
        // Test 1: ADD -> 10 + 5 = 15
        operand_a = 8'd10;
        operand_b = 8'd5;
        operation_code = 8'h00; // ADD
        #5;
        display_result(8'd15, 1'b0, 1'b0, 1'b0, "ADD 10+5");
        
        // Test 2: ADD -> 255 + 1 = 0 (carry flag set to 1)
        operand_a = 8'd255;
        operand_b = 8'd1;
        operation_code = 8'h00; // ADD
        #5;
        display_result(8'd0, 1'b1, 1'b1, 1'b0, "ADD 255+1 (carry)");
        
        // Test 3: SUB -> 10 - 5 = 5
        operand_a = 8'd10;
        operand_b = 8'd5;
        operation_code = 8'h01; // SUB
        #5;
        display_result(8'd5, 1'b0, 1'b0, 1'b0, "SUB 10-5");
        
        // Test 4: SUB -> 5 - 5 = 0 (zero flag set to 1)
        operand_a = 8'd5;
        operand_b = 8'd5;
        operation_code = 8'h01; // SUB
        #5;
        display_result(8'd0, 1'b1, 1'b0, 1'b0, "SUB 5-5 (zero)");
        
        // Test 5: SUB -> 5 - 10 = 251 (negative result, carry flag set to 1)
        operand_a = 8'd5;
        operand_b = 8'd10;
        operation_code = 8'h01; // SUB
        #5;
        display_result(8'd251, 1'b0, 1'b1, 1'b1, "SUB 5-10 (negative)");
        
        // ========================
        // LOGICAL OPERATIONS
        // ========================
        
        // Test 6: AND
        operand_a = 8'b11110000;
        operand_b = 8'b10101010;
        operation_code = 8'h02; // AND
        #5;
        display_result(8'b10100000, 1'b0, 1'b0, 1'b1, "AND 0xF0 & 0xAA");
        
        // Test 7: OR
        operand_a = 8'b11110000;
        operand_b = 8'b00001111;
        operation_code = 8'h03; // OR
        #5;
        display_result(8'b11111111, 1'b0, 1'b0, 1'b1, "OR 0xF0 | 0x0F");
        
        // Test 8: XOR
        operand_a = 8'b11111111;
        operand_b = 8'b10101010;
        operation_code = 8'h04; // XOR
        #5;
        display_result(8'b01010101, 1'b0, 1'b0, 1'b0, "XOR 0xFF ^ 0xAA");
        
        // Test 9: NOT
        operand_a = 8'b10101010;
        operand_b = 8'b00000000; // not used
        operation_code = 8'h05; // NOT
        #5;
        display_result(8'b01010101, 1'b0, 1'b0, 1'b0, "NOT ~0xAA");
        
        // ========================
        // SHIFT OPERATIONS
        // ========================
        
        // Test 10: SHL (Shift Left)
        operand_a = 8'b01010101;
        operand_b = 8'b00000000;
        operation_code = 8'h06; // SHL
        #5;
        display_result(8'b10101010, 1'b0, 1'b0, 1'b1, "SHL 0x55<<1");
        
        // Test 11: SHL (carry set to 1)
        operand_a = 8'b10000000;
        operand_b = 8'b00000000;
        operation_code = 8'h06; // SHL
        #5;
        display_result(8'b00000000, 1'b1, 1'b1, 1'b0, "SHL 0x80<<1 (carry)");
        
        // Test 12: SHR (Shift Right)
        operand_a = 8'b10101010;
        operand_b = 8'b00000000;
        operation_code = 8'h07; // SHR
        #5;
        display_result(8'b01010101, 1'b0, 1'b0, 1'b0, "SHR 0xAA>>1");
        
        // Test 13: SHR (carry set to 1)
        operand_a = 8'b00000001;
        operand_b = 8'b00000000;
        operation_code = 8'h07; // SHR
        #5;
        display_result(8'b00000000, 1'b1, 1'b1, 1'b0, "SHR 0x01>>1 (carry)");
        
        // ========================
        // JUMP OPERATIONS
        // ========================
        
        // Test 14: JMP (Jump Unconditional) - operand_b contains jump address
        operand_a = 8'd0;
        operand_b = 8'h40; // Jump address
        operation_code = 8'h08; // JMP
        #5;
        display_result(8'h40, 1'b0, 1'b0, 1'b0, "JMP to 0x40");
        
        // Test 15: JZ (Jump if Zero) - return jump address
        operand_a = 8'd0;
        operand_b = 8'h50; // Jump address
        operation_code = 8'h09; // JZ
        #5;
        display_result(8'h50, 1'b0, 1'b0, 1'b0, "JZ to 0x50");
        
        // Test 16: JNZ (Jump if Not Zero) - return jump address
        operand_a = 8'd0;
        operand_b = 8'h60; // Jump address
        operation_code = 8'h0A; // JNZ
        #5;
        display_result(8'h60, 1'b0, 1'b0, 1'b0, "JNZ to 0x60");
        
        // Test 17: JC (Jump if Carry) - return jump address
        operand_a = 8'd0;
        operand_b = 8'h70; // Jump address
        operation_code = 8'h0B; // JC
        #5;
        display_result(8'h70, 1'b0, 1'b0, 1'b0, "JC to 0x70");
        
        // Test 18: JNC (Jump if Not Carry) - return jump address
        operand_a = 8'd0;
        operand_b = 8'h80; // Jump address
        operation_code = 8'h0C; // JNC
        #5;
        display_result(8'h80, 1'b0, 1'b0, 1'b1, "JNC to 0x80");
        
        // Test 19: JN (Jump if Negative) - return jump address
        operand_a = 8'd0;
        operand_b = 8'h90; // Jump address
        operation_code = 8'h0D; // JN
        #5;
        display_result(8'h90, 1'b0, 1'b0, 1'b1, "JN to 0x90");
        
        // Test 20: JNN (Jump if Not Negative) - return jump address
        operand_a = 8'd0;
        operand_b = 8'hA0; // Jump address
        operation_code = 8'h0E; // JNN
        #5;
        display_result(8'hA0, 1'b0, 1'b0, 1'b1, "JNN to 0xA0");
        
        // ========================
        // COMPARISON OPERATIONS
        // ========================
        
        // Test 21: CMP - equal values -> 10 == 10
        operand_a = 8'd10;
        operand_b = 8'd10;
        operation_code = 8'h0F; // CMP
        #5;
        display_result(8'd0, 1'b1, 1'b0, 1'b0, "CMP 10-10 (equal)");
        
        // Test 22: CMP -> A > B
        operand_a = 8'd15;
        operand_b = 8'd10;
        operation_code = 8'h0F; // CMP
        #5;
        display_result(8'd5, 1'b0, 1'b0, 1'b0, "CMP 15-10 (greater)");
        
        // Test 23: CMP -> A < B (negative result)
        operand_a = 8'd5;
        operand_b = 8'd15;
        operation_code = 8'h0F; // CMP
        #5;
        display_result(8'd246, 1'b0, 1'b1, 1'b1, "CMP 5-15 (less)");
        
        // ========================
        // EDGE CASES AND SPECIAL TESTS
        // ========================
        
        // Test 24: ADD with zero operands
        operand_a = 8'd0;
        operand_b = 8'd0;
        operation_code = 8'h00; // ADD
        #5;
        display_result(8'd0, 1'b1, 1'b0, 1'b0, "ADD 0+0");
        
        // Test 25: SUB with zero result from non-zero operands
        operand_a = 8'd128;
        operand_b = 8'd128;
        operation_code = 8'h01; // SUB
        #5;
        display_result(8'd0, 1'b1, 1'b0, 1'b0, "SUB 128-128");
        
        // Test 26: AND with zero result
        operand_a = 8'b11110000;
        operand_b = 8'b00001111;
        operation_code = 8'h02; // AND
        #5;
        display_result(8'b00000000, 1'b1, 1'b0, 1'b0, "AND 0xF0 & 0x0F (zero)");
        
        // Test 27: XOR with same operands (should give zero)
        operand_a = 8'b10101010;
        operand_b = 8'b10101010;
        operation_code = 8'h04; // XOR
        #5;
        display_result(8'b00000000, 1'b1, 1'b0, 1'b0, "XOR 0xAA ^ 0xAA (zero)");
        
        // Test 28: SHL with zero operand
        operand_a = 8'b00000000;
        operand_b = 8'b00000000;
        operation_code = 8'h06; // SHL
        #5;
        display_result(8'b00000000, 1'b1, 1'b0, 1'b0, "SHL 0x00<<1");
        
        // Test 29: SHR with zero operand
        operand_a = 8'b00000000;
        operand_b = 8'b00000000;
        operation_code = 8'h07; // SHR
        #5;
        display_result(8'b00000000, 1'b1, 1'b0, 1'b0, "SHR 0x00>>1");
        
        // Test 30: Jump with zero address
        operand_a = 8'd0;
        operand_b = 8'h00; // Jump to address 0
        operation_code = 8'h08; // JMP
        #5;
        display_result(8'h00, 1'b1, 1'b0, 1'b0, "JMP to 0x00");
        
        // Test 31: Jump with maximum address
        operand_a = 8'd0;
        operand_b = 8'hFF; // Jump to address 255
        operation_code = 8'h09; // JZ
        #5;
        display_result(8'hFF, 1'b0, 1'b0, 1'b1, "JZ to 0xFF");
        
        // Test 32: Unknown operation (default case)
        operand_a = 8'd10;
        operand_b = 8'd5;
        operation_code = 8'hFF; // Unknown operation
        #5;
        display_result(8'd0, 1'b1, 1'b0, 1'b0, "Unknown operation");
        
        // Test 33: Another unknown operation
        operand_a = 8'd42;
        operand_b = 8'd24;
        operation_code = 8'h10; // Invalid opcode
        #5;
        display_result(8'd0, 1'b1, 1'b0, 1'b0, "Invalid opcode 0x10");
        
        $display("=== ALL TESTS COMPLETED ===\n");

        $display("=== TEST SUMMARY ===");
        $display("Total tests: %0d", test_count);
        $display("Passed: %0d", pass_count);
        $display("Failed: %0d", fail_count);
        $display("Success rate: %0.1f%%", (pass_count * 100.0) / test_count);
        
        if (fail_count == 0) begin
            $display("ALL TESTS PASSED! 🎉");
        end else begin
            $display("%0d TESTS FAILED!", fail_count);
            $finish(1); // Finish with error code
        end

        $stop;
    end
    
    // Monitor changes in signals
    initial begin
        $monitor("Time: %0t | A=%h B=%h Op=%h | Result=%h Z=%b C=%b N=%b", 
                 $time, operand_a, operand_b, operation_code, 
                 result, zero_flag, carry_flag, negative_flag);
    end
    
endmodule