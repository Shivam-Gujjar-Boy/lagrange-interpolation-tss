# Set library paths
set LIB_PATH /path/to/your/libs
set_target_library "$LIB_PATH/slow.db"
set_link_library "* $LIB_PATH/slow.db"

# Read design
read_verilog ../Verilog/lagrange_interp.v
read_verilog ../Verilog/mod_add.v
read_verilog ../Verilog/mod_sub.v
read_verilog ../Verilog/mod_mul.v
read_verilog ../Verilog/mod_inv.v

# Set top module
current_design lagrange_interp

# Apply constraints
read_sdc constraints.sdc

# Synthesis
compile_ultra

# Generate reports
report_area > area_report.log
report_timing > timing_report.log
report_power > power_report.log

# Save netlist
write -format verilog -hierarchy -output ../Synthesis/RTL/post_synthesis_netlist.v

# Exit
exit