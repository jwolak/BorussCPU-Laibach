# test_alu.do
# create library
vlib work

# Compile files
vlog ../../core/boruss_alu.v
vlog test_boruss_alu.v

# Run simulation
vsim test_boruss_alu

# Add signals to wave
add wave -radix hex /test_boruss_alu/operand_a
add wave -radix hex /test_boruss_alu/operand_b
add wave -radix hex /test_boruss_alu/operation_code
add wave -radix hex /test_boruss_alu/result
add wave /test_boruss_alu/zero_flag
add wave /test_boruss_alu/carry_flag
add wave /test_boruss_alu/negative_flag

# Run test
run -all

# Zoom view
wave zoom full