# Clock constraints
create_clock -name clk -period 10 [get_ports clk]
set_clock_uncertainty 0.5 [get_clocks clk]
set_input_delay 2 -clock clk [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay 2 -clock clk [all_outputs]

# Input/output constraints
set_driving_cell -lib_cell INVX1 [all_inputs]
set_load 0.5 [all_outputs]

# Don't touch these
set_dont_touch [get_nets rst_n]