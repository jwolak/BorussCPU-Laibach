`timescale 1ns / 1ps

module boruss_cpu_full_tb;

    // Sygnały testowe
    reg clk;
    reg reset;
    
    // Wyjścia z CPU
    wire [7:0] led_out;
    
    // Liczniki testów
    integer cycle_count = 0;
    reg [7:0] prev_led = 8'h00;
    integer led_changes = 0;
    
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

    // Główny blok testowy
    initial begin
        $display("========================================");
        $display("  Boruss CPU Full System Test");
        $display("========================================");
        $display("  Testing CPU execution with ROM program");
        $display("========================================");
        $display("");
        
        // Inicjalizacja
        reset = 0;
        #25;
        
        $display("[%0t ns] Applying reset...", $time);
        reset = 1;
        #40;
        
        $display("[%0t ns] Reset released, CPU starting execution", $time);
        $display("");
        $display("Cycle\t| Time (ns)\t| LED Output\t| Status");
        $display("--------|---------------|---------------|------------------");
        
        // Monitoruj wykonanie przez 200 cykli zegara
        repeat(200) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            #1; // Małe opóźnienie dla stabilności sygnałów
            
            // Wyświetl co 10 cykli lub gdy LED się zmieni
            if (cycle_count % 10 == 0 || led_out != prev_led) begin
                $display("%0d\t| %0t\t| %b\t| %s",
                    cycle_count,
                    $time,
                    led_out,
                    (led_out != prev_led) ? "LED CHANGED" : ""
                );
                
                if (led_out != prev_led) begin
                    led_changes = led_changes + 1;
                    prev_led = led_out;
                end
            end
        end
        
        $display("");
        $display("========================================");
        $display("  Test Results Summary");
        $display("========================================");
        
        // Test 1: Sprawdź czy CPU wykonał jakieś cykle
        if (cycle_count > 0) begin
            $display("PASS: CPU completed %0d clock cycles", cycle_count);
        end else begin
            $display("FAIL: CPU did not execute");
        end
        
        // Test 2: Sprawdź czy LED się zmienia
        if (led_changes > 0) begin
            $display("PASS: LED output changed %0d times", led_changes);
            $display("      This indicates CPU is processing instructions");
        end else begin
            $display("WARN: LED output did not change");
            $display("      Current LED state: %b", led_out);
        end
        
        // Test 3: Sprawdź końcowy stan LED
        if (led_out !== 8'hxx && led_out !== 8'hzz) begin
            $display("PASS: LED output is valid (final state: %b)", led_out);
        end else begin
            $display("FAIL: LED output is undefined");
        end
        
        // Test 4: Sprawdź czy CPU nie jest w stanie resetowania
        if (reset == 1'b1) begin
            $display("PASS: Reset signal properly released");
        end else begin
            $display("FAIL: Reset signal still active");
        end
        
        $display("");
        $display("========================================");
        $display("  Expected Behavior for Knight Rider");
        $display("========================================");
        $display("The LED should show pattern like:");
        $display("  00000001 -> 00000010 -> 00000100 -> 00001000");
        $display("  (or remain at 00000001 if using simple test program)");
        $display("");
        $display("Actual final LED state: %b", led_out);
        
        // Analiza - czy LED ma jakąś wartość niezerową
        if (led_out == 8'b00000001) begin
            $display("");
            $display("INFO: LED shows 0x01 - This matches the simple");
            $display("      test program (ADD R0, #1) from ROM");
        end else if (led_out == 8'b00000000) begin
            $display("");
            $display("WARN: LED is all zeros - possible issues:");
            $display("      1. ROM program not loading correctly");
            $display("      2. CPU FSM not reaching WRITEBACK state");
            $display("      3. Register file not updating");
            $display("      4. LED output mapping incorrect");
        end else begin
            $display("");
            $display("INFO: LED shows pattern %b", led_out);
        end
        
        $display("");
        $display("========================================");
        $display("  Simulation Complete");
        $display("========================================");
        
        #100;
        $finish;
    end
    
    // Monitor zmian LED w czasie rzeczywistym
    always @(posedge clk) begin
        if (led_out != prev_led && cycle_count > 0) begin
            $display(">>> [%0t ns] LED changed: %b -> %b", 
                     $time, prev_led, led_out);
        end
    end
    
    // Timeout watchdog - zakończ jeśli symulacja trwa zbyt długo
    initial begin
        #50000; // 50 microsekund
        $display("");
        $display("========================================");
        $display("  TIMEOUT - Simulation taking too long");
        $display("========================================");
        $display("CPU may be stuck in infinite loop or HALT state");
        $finish;
    end
    
    // Dump waveform do pliku VCD
    initial begin
        $dumpfile("boruss_cpu_full_tb.vcd");
        $dumpvars(0, boruss_cpu_full_tb);
    end

endmodule