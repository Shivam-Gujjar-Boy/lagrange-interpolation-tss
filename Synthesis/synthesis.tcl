# Simple synthesis flow - avoid advanced features
set_db init_lib_search_path {/vlsi/pdk/course_pdk_2025/tsmc_gp_65_stdio/tcbn65gplus_200a/TSMCHOME/digital/Front_End/timing_power_noise/CCS/tcbn65gplus_200a}

# Load technology library
read_libs {tcbn65gpluswc_ccs.lib}

# Read design files
read_hdl -v2001 ../Verilog/lagrange_interp.v
read_hdl -v2001 ../Verilog/mod_add.v  
read_hdl -v2001 ../Verilog/mod_sub.v
read_hdl -v2001 ../Verilog/mod_mul.v
read_hdl -v2001 ../Verilog/mod_inv.v

# Set top module
elaborate lagrange_interp

# Apply constraints
read_sdc constraints.sdc

# Use only basic synthesis - no advanced optimizations
syn_generic

# Generate reports
report area > area_report.log
report timing > timing_report.log

# Save netlist
write_hdl > ../Synthesis/RTL/post_synthesis_netlist.v

echo "Basic synthesis completed successfully!"
quit
