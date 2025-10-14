# test_alu.do
# Utwórz bibliotekę
vlib work

# Kompiluj pliki
vlog ../../core/boruss_alu.v
vlog test_boruss_alu.v

# Uruchom symulację
vsim test_boruss_alu

# Dodaj sygnały do wave
add wave -radix hex /test_boruss_alu/operand_a
add wave -radix hex /test_boruss_alu/operand_b
add wave -radix hex /test_boruss_alu/operation_code
add wave -radix hex /test_boruss_alu/result
add wave /test_boruss_alu/zero_flag
add wave /test_boruss_alu/carry_flag
add wave /test_boruss_alu/negative_flag

# Uruchom test
run -all

# Przybliż widok
wave zoom full