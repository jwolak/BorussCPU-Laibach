`timescale 1ns / 1ps

module boruss_rom_test_tb;

    reg [7:0] address;
    wire [7:0] data_out;
    
    // Instancjacja ROM
    boruss_rom uut (
        .address(address),
        .data_out(data_out)
    );
    
    initial begin
        $display("========================================");
        $display("  ROM Content Test");
        $display("========================================");
        $display("");
        $display("Addr\t| Data\t| Expected\t| Status");
        $display("--------|-------|---------------|----------");
        
        // Test kluczowych adresów z programu Knight Rider
        address = 8'h00; #10;
        $display("0x%h\t| 0x%h\t| 0x80\t\t| %s", 
                 address, data_out, (data_out == 8'h80) ? "PASS" : "FAIL");
        
        address = 8'h01; #10;
        $display("0x%h\t| 0x%h\t| 0x01\t\t| %s", 
                 address, data_out, (data_out == 8'h01) ? "PASS" : "FAIL");
        
        address = 8'h02; #10;
        $display("0x%h\t| 0x%h\t| 0x00\t\t| %s", 
                 address, data_out, (data_out == 8'h00) ? "PASS" : "FAIL");
        
        address = 8'h0E; #10;
        $display("0x%h\t| 0x%h\t| 0x08\t\t| %s", 
                 address, data_out, (data_out == 8'h08) ? "PASS" : "FAIL");
        
        address = 8'h0F; #10;
        $display("0x%h\t| 0x%h\t| 0x00\t\t| %s", 
                 address, data_out, (data_out == 8'h00) ? "PASS" : "FAIL");
        
        $display("");
        $display("========================================");
        
        // Sprawdź czy ROM w ogóle ma jakieś dane
        if (data_out == 8'h00) begin
            $display("WARNING: ROM appears to be all zeros!");
            $display("Check boruss_rom.v initialization block");
        end
        
        $finish;
    end

endmodule