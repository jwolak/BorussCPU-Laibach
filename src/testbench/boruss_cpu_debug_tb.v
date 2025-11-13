`timescale 1ns / 1ps

module boruss_cpu_debug_tb;

    // Sygnały testowe
    reg clk;
    reg reset;
    wire [7:0] led_out;
    
    // Instancjacja modułu CPU
    boruss_cpu uut (
        .clk(clk),
        .reset(reset),
        .led_out(led_out)
    );

    // Generacja zegara (50 MHz, okres 20 ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Monitor z hierarchicznym dostępem do sygnałów
    initial begin
        $display("========================================");
        $display("  Boruss CPU Debug Testbench");
        $display("========================================");
        $display("");
        
        // Znajdź nazwy instancji wewnętrznych
        $display("Checking module hierarchy...");
        $display("CPU module instances:");
        
        // Inicjalizacja
        reset = 0;
        #25;
        
        $display("");
        $display("[%0t ns] Applying reset...", $time);
        reset = 1;
        #40;
        
        $display("[%0t ns] Reset released", $time);
        $display("");
        $display("========================================");
        $display("Monitoring first 20 clock cycles in detail:");
        $display("========================================");
        $display("");
        
        // Monitoruj szczegółowo pierwsze cykle
        repeat(20) begin
            @(posedge clk);
            #2;
            
            $display("Cycle %0d @ %0t ns:", ($time - 65) / 20, $time);
            $display("  LED Output: %b", led_out);
            
            // Próba dostępu do sygnałów - dostosuj ścieżki po sprawdzeniu hierarchii
            $display("  (Check waveform for internal signals)");
            $display("");
        end
        
        $display("========================================");
        $display("Running extended test (180 more cycles)...");
        $display("========================================");
        
        repeat(180) @(posedge clk);
        
        $display("");
        $display("Final LED state: %b", led_out);
        
        if (led_out == 8'h00) begin
            $display("");
            $display("DIAGNOSTIC STEPS:");
            $display("1. Open waveform viewer (Wave window)");
            $display("2. Expand 'uut' in the hierarchy");
            $display("3. Check these signals:");
            $display("   - Look for FSM state machine signals");
            $display("   - Look for program counter (PC)");
            $display("   - Look for instruction register");
            $display("   - Look for ROM data output");
            $display("4. Verify ROM is outputting 0x80, 0x01 at addresses 0x00, 0x01");
            $display("5. Check if FSM transitions through states");
        end
        
        #100;
        $finish;
    end
    
    // Dump kompletnej hierarchii do VCD
    initial begin
        $dumpfile("boruss_cpu_debug_tb.vcd");
        $dumpvars(0, boruss_cpu_debug_tb);
        
        // Dump wszystkich poziomów hierarchii
        $dumpvars(1, uut);
        $dumpvars(2, uut);
        $dumpvars(3, uut);
        $dumpvars(4, uut);
    end

endmodule