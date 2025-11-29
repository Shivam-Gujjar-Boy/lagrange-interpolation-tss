# Create clock - 100MHz frequency
create_clock -name clk -period 10 [get_ports clk]

# Clock uncertainty
set_clock_uncertainty 0.2 [get_clocks clk]

# Input delays
set_input_delay 1.5 -clock clk [all_inputs]

# Output delays  
set_output_delay 1.5 -clock clk [all_outputs]

# Don't optimize reset network
set_dont_touch_network [get_ports rst_n]

# Set driving cells
set_driving_cell -lib_cell INVX4 [all_inputs]

# Set load capacitance
set_load 0.05 [all_outputs]
