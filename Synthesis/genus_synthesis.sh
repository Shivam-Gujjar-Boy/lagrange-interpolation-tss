#!/bin/bash

echo "=== Starting Lagrange Interpolation Synthesis ==="
echo "Date: $(date)"
echo "Working directory: $(pwd)"

# Clean previous results
rm -f *.log
rm -f ../Synthesis/RTL/post_synthesis_netlist.v
rm -f ../Synthesis/RTL/post_synthesis.sdf

# Create directories if they don't exist
mkdir -p ../Synthesis/RTL
mkdir -p ../Synthesis/Logs

# Run Genus synthesis
echo "Starting Cadence Genus synthesis..."
/vlsi/cad/cadence/GENUS211/tools.lnx86/bin/genus -files synthesis.tcl -log ../Synthesis/Logs/genus_synthesis.log

# Check if synthesis was successful
if [ $? -eq 0 ] && [ -f ../Synthesis/RTL/post_synthesis_netlist.v ]; then
    echo "✅ Synthesis completed successfully!"
    
    # Copy reports
    if [ -f area_report.log ]; then
        cp area_report.log ../Synthesis/Logs/
        echo "Area report: Synthesis/Logs/area_report.log"
    fi
    
    if [ -f timing_report.log ]; then
        cp timing_report.log ../Synthesis/Logs/
        echo "Timing report: Synthesis/Logs/timing_report.log"
    fi
    
    if [ -f power_report.log ]; then
        cp power_report.log ../Synthesis/Logs/
        echo "Power report: Synthesis/Logs/power_report.log"
    fi
    
    if [ -f gates_report.log ]; then
        cp gates_report.log ../Synthesis/Logs/
        echo "Gates report: Synthesis/Logs/gates_report.log"
    fi
    
    echo "Post-synthesis netlist: Synthesis/RTL/post_synthesis_netlist.v"
    
else
    echo "❌ Synthesis failed!"
    echo "Check the log file: Synthesis/Logs/genus_synthesis.log"
    exit 1
fi

echo "=== Synthesis Complete ==="
