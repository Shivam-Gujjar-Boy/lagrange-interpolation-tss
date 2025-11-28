#!/bin/bash

echo "=== Starting Synthesis with Cadence Genus ==="

# Clean previous results
rm -rf outputs
rm -rf reports
mkdir -p ../Synthesis/RTL
mkdir -p ../Synthesis/Logs

# Run synthesis
Genus -files synthesis.tcl -log ../Synthesis/Logs/genus.log

if [ $? -eq 0 ]; then
    echo "✅ Synthesis completed successfully"
    
    # Copy reports
    cp area_report.log ../Synthesis/Logs/
    cp timing_report.log ../Synthesis/Logs/  
    cp power_report.log ../Synthesis/Logs/
    
    echo "Reports generated in Synthesis/Logs/"
else
    echo "❌ Synthesis failed"
    exit 1
fi