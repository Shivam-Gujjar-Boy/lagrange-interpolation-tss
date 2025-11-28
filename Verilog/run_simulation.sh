#!/bin/bash

echo "=== Lagrange Interpolation Pre-Synthesis Simulation ==="

# Clean previous files
rm -f waveforms.vcd
rm -f simulation.log

# Compile all Verilog files
iverilog -o sim_output \
    mod_add.v \
    mod_sub.v \
    mod_mul.v \
    mod_inv.v \
    lagrange_interp.v \
    tb_lagrange_interp.v

# Check if compilation was successful
if [ $? -eq 0 ]; then
    echo "✅ Compilation successful"
    
    # Run simulation
    echo "Starting simulation..."
    vvp sim_output
    
    # Check simulation result
    if [ $? -eq 0 ]; then
        echo "✅ Simulation completed successfully"
        
        # Open waveform viewer if available
        if command -v gtkwave &> /dev/null; then
            echo "Opening GTKWave..."
            gtkwave waveforms.vcd &
        else
            echo "GTKWave not found. Waveform file: waveforms.vcd"
        fi
    else
        echo "❌ Simulation failed"
        exit 1
    fi
else
    echo "❌ Compilation failed"
    exit 1
fi

echo "=== Simulation Complete ==="