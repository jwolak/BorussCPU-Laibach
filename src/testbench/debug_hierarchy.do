# Kompilacja
quit -sim
vdel -lib work -all
vlib work

vlog -work work ../core/boruss_alu.v
vlog -work work ../memory/boruss_rom.v
vlog -work work ../memory/boruss_ram.v
vlog -work work ../memory/boruss_memory_controller.v
vlog -work work ../core/boruss_cpu_fsm.v
vlog -work work ../core/boruss_cpu.v
vlog -work work boruss_cpu_debug_tb.v

# Uruchom symulację
vsim -voptargs=+acc work.boruss_cpu_debug_tb

# Wyświetl hierarchię
echo ""
echo "========================================="
echo "MODULE HIERARCHY:"
echo "========================================="

# Pokaż strukturę modułu uut
describe /boruss_cpu_debug_tb/uut

echo ""
echo "========================================="
echo "Looking for submodules..."
echo "========================================="

# Spróbuj znaleźć instancje
if {[catch {examine /boruss_cpu_debug_tb/uut/*}]} {
    echo "Could not list submodules directly"
}

# Dodaj podstawowe sygnały
add wave -divider "Top Level"
add wave /boruss_cpu_debug_tb/clk
add wave /boruss_cpu_debug_tb/reset
add wave -radix binary /boruss_cpu_debug_tb/led_out

# Spróbuj dodać sygnały wewnętrzne (dostosuj ścieżki)
add wave -divider "Trying to find internal signals..."

# Szukaj typowych nazw instancji
foreach inst {cpu_fsm fsm cpu_state state_machine core} {
    if {![catch {add wave /boruss_cpu_debug_tb/uut/$inst/*}]} {
        echo "Found instance: $inst"
    }
}

foreach inst {rom memory program_rom instruction_rom} {
    if {![catch {add wave /boruss_cpu_debug_tb/uut/$inst/*}]} {
        echo "Found instance: $inst"
    }
}

foreach inst {alu arithmetic_unit} {
    if {![catch {add wave /boruss_cpu_debug_tb/uut/$inst/*}]} {
        echo "Found instance: $inst"
    }
}

# Uruchom krótką symulację
run 500ns

wave zoom full

echo ""
echo "========================================="
echo "Check the Wave window for signals"
echo "Expand 'uut' to see submodule instances"
echo "========================================="