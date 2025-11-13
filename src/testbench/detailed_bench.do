vlib work
vlog ../core/boruss_alu.v
vlog ../memory/boruss_rom.v
vlog ../memory/boruss_ram.v
vlog ../memory/boruss_memory_controller.v
vlog ../core/boruss_cpu_fsm.v
vlog ../core/boruss_cpu.v
vlog boruss_cpu_detailed_debug_tb.v
vsim -c work.boruss_cpu_detailed_debug_tb -do "run -all; quit"