## Clock input (100 MHz oscillator on Basys3)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
#create_clock -add -name sys_clk -period 20.00 [get_ports clk]   # 50 MHz
create_clock -period 20.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

## Reset button (use BTNC as reset)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## Digit outputs mapped to LEDs (LD0–LD3)
set_property PACKAGE_PIN U16 [get_ports {digit_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_out[0]}]

set_property PACKAGE_PIN E19 [get_ports {digit_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_out[1]}]

set_property PACKAGE_PIN U19 [get_ports {digit_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_out[2]}]

set_property PACKAGE_PIN V19 [get_ports {digit_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_out[3]}]

## Valid output mapped to LED LD4
set_property PACKAGE_PIN W18 [get_ports valid_out]
set_property IOSTANDARD LVCMOS33 [get_ports valid_out]
