# Wyczyść poprzednie kompilacje
quit -sim
if {[file exists work]} {
    vdel -lib work -all
}

# Utwórz bibliotekę roboczą
vlib work

# Skompiluj wszystkie moduły w odpowiedniej kolejności
echo "========================================="
echo "Compiling Boruss CPU Modules..."
echo "========================================="

echo "1. Compiling ALU..."
if {[catch {vlog -work work ../core/boruss_alu.v}]} {
    echo "ERROR: Failed to compile ALU"
    quit -f
}

echo "2. Compiling ROM..."
if {[catch {vlog -work work ../memory/boruss_rom.v}]} {
    echo "ERROR: Failed to compile ROM"
    quit -f
}

echo "3. Compiling RAM..."
if {[catch {vlog -work work ../memory/boruss_ram.v}]} {
    echo "ERROR: Failed to compile RAM"
    quit -f
}

echo "4. Compiling Memory Controller..."
if {[catch {vlog -work work ../memory/boruss_memory_controller.v}]} {
    echo "ERROR: Failed to compile Memory Controller"
    quit -f
}

echo "5. Compiling CPU FSM..."
if {[catch {vlog -work work ../core/boruss_cpu_fsm.v}]} {
    echo "ERROR: Failed to compile CPU FSM"
    quit -f
}

echo "6. Compiling CPU top-level..."
if {[catch {vlog -work work ../core/boruss_cpu.v}]} {
    echo "ERROR: Failed to compile CPU"
    quit -f
}

echo "7. Compiling testbench..."
if {[catch {vlog -work work boruss_cpu_full_tb.v}]} {
    echo "ERROR: Failed to compile testbench"
    quit -f
}

echo ""
echo "========================================="
echo "All modules compiled successfully!"
echo "========================================="
echo ""

# Uruchom symulację
echo "Starting simulation..."
vsim -voptargs=+acc work.boruss_cpu_full_tb

# Dodaj sygnały do okna Wave (jeśli GUI jest aktywne)
if {[batch_mode] == 0} {
    add wave -divider "Clock and Reset"
    add wave /boruss_cpu_full_tb/clk
    add wave /boruss_cpu_full_tb/reset
    
    add wave -divider "Output"
    add wave -radix binary /boruss_cpu_full_tb/led_out
    
    add wave -divider "Test Counters"
    add wave -radix unsigned /boruss_cpu_full_tb/cycle_count
    add wave -radix unsigned /boruss_cpu_full_tb/led_changes
    
    # Uruchom symulację
    run 5000ns
    
    # Dopasuj widok
    wave zoom full
    
    echo ""
    echo "========================================="
    echo "Simulation running in GUI mode"
    echo "Check the waveform and transcript window"
    echo "========================================="
} else {
    # Tryb batch - uruchom i zakończ
    run -all
}