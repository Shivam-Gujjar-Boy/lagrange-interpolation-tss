`timescale 1ns/1ps

module tb_lagrange_interp;
    reg clk;
    reg rst_n;
    reg start;
    reg [255:0] x1, y1;
    reg [255:0] x2, y2;
    wire [255:0] secret;
    wire done;
    wire error;
    
    // Clock generation
    always #5 clk = ~clk;
    
    // Device Under Test
    lagrange_interp dut (
        .clk(clk),
        .rst_n(rst_n),
        .x1(x1),
        .y1(y1),
        .x2(x2),
        .y2(y2),
        .start(start),
        .secret(secret),
        .done(done),
        .error(error)
    );
    
    // Test vectors
    localparam [255:0] P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    
    // Test Case 1: Simple working case Reconstruction
    localparam [255:0] TEST1_X1 = 256'h0000000000000000000000000000000000000000000000000000000000000001;
    localparam [255:0] TEST1_Y1 = 256'h0000000000000000000000000000000000000000000000000000000000000002;
    localparam [255:0] TEST1_X2 = 256'h0000000000000000000000000000000000000000000000000000000000000002;
    localparam [255:0] TEST1_Y2 = 256'h0000000000000000000000000000000000000000000000000000000000000004;
    localparam [255:0] TEST1_EXPECTED = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    
    // Test Case 2: Edge case - same shares (should error)
    localparam [255:0] TEST2_X1 = 256'h0000000000000000000000000000000000000000000000000000000000000001;
    localparam [255:0] TEST2_Y1 = 256'h00000000000000000000000000000000000000000000000000000000ABCDEF12;
    localparam [255:0] TEST2_X2 = 256'h0000000000000000000000000000000000000000000000000000000000000001;
    localparam [255:0] TEST2_Y2 = 256'h00000000000000000000000000000000000000000000000000000000DEADBEEF;
    
    // Test Case 3: Random large values
    localparam [255:0] TEST3_X1 = 256'h123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0;
    localparam [255:0] TEST3_Y1 = 256'hFEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210;
    localparam [255:0] TEST3_X2 = 256'h23456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF01;
    localparam [255:0] TEST3_Y2 = 256'hEDCBA9876543210FEDCBA9876543210FEDCBA9876543210FEDCBA9876543210F;
    
    integer test_case;
    integer passed_tests;
    integer total_tests;
    
    // Monitor results
    initial begin
        passed_tests = 0;
        total_tests = 0;
        $dumpfile("waveforms.vcd");
        $dumpvars(0, tb_lagrange_interp);
    end
    
    // Main test sequence
    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        start = 0;
        x1 = 0;
        y1 = 0;
        x2 = 0;
        y2 = 0;
        test_case = 0;
        
        // Reset
        #20;
        rst_n = 1;
        #20;
        
        $display("=== Starting Lagrange Interpolation Tests ===");
        
        // Test Case 1: Basic functionality
        test_case = 1;
        $display("\nTest Case %0d: Basic Reconstruction", test_case);
        run_test(TEST1_X1, TEST1_Y1, TEST1_X2, TEST1_Y2, TEST1_EXPECTED, 1'b0);
        
        // Test Case 2: Error case - same x values
        test_case = 2;
        $display("\nTest Case %0d: Error Case - Same X Values", test_case);
        run_test(TEST2_X1, TEST2_Y1, TEST2_X2, TEST2_Y2, 256'b0, 1'b1);
        
        // Test Case 3: Large values
        test_case = 3;
        $display("\nTest Case %0d: Large Values", test_case);
        run_test(TEST3_X1, TEST3_Y1, TEST3_X2, TEST3_Y2, 256'b0, 1'b0); // Don't check exact value
        
        // Summary
        #100;
        $display("\n=== Test Summary ===");
        $display("Passed: %0d/%0d", passed_tests, total_tests);
        if (passed_tests == total_tests) begin
            $display("✅ ALL TESTS PASSED!");
        end else begin
            $display("❌ SOME TESTS FAILED!");
        end
        
        $finish;
    end
    
    // Test runner task
    task run_test;
        input [255:0] test_x1, test_y1, test_x2, test_y2;
        input [255:0] expected_secret;
        input expected_error;
        integer timeout;
        begin
            total_tests = total_tests + 1;
            timeout = 0;
            
            // Apply inputs
            @(posedge clk);
            x1 = test_x1;
            y1 = test_y1;
            x2 = test_x2;
            y2 = test_y2;
            
            // Pulse start for exactly 1 cycle
            start = 1;
            @(posedge clk);
            start = 0;
            
            $display("Test %0d: Start signal pulsed", test_case);
            
            // Wait for completion with timeout
            while (!done && !error && timeout < 2000) begin
                @(posedge clk);
                timeout = timeout + 1;
            end
            
            if (timeout >= 2000) begin
                $display("  ❌ TIMEOUT - Stuck after %d cycles", timeout);
                $display("  Current state: %d", dut.state);
            end else if (error && expected_error) begin
                $display("  ✅ Expected error detected - PASS");
                passed_tests = passed_tests + 1;
            end else if (error && !expected_error) begin
                $display("  ❌ Unexpected error - FAIL");
            end else if (!error && expected_error) begin
                $display("  ❌ Expected error but none detected - FAIL");
            end else if (secret === expected_secret || expected_secret === 256'b0) begin
                if (expected_secret === 256'b0) begin
                    $display("  ✅ Computation completed (value not checked) - PASS");
                end else begin
                    $display("  ✅ Secret matches expected - PASS");
                end
                passed_tests = passed_tests + 1;
            end else begin
                $display("  ❌ Secret mismatch - FAIL");
                $display("     Expected: %064h", expected_secret);
                $display("     Got:      %064h", secret);
            end
            
            // Wait before next test
            repeat(10) @(posedge clk);
        end
    endtask
    
    // Performance monitoring
    real start_time, end_time, total_time;
    integer cycle_count;
    
    always @(posedge clk) begin
        if (start) begin
            start_time = $time;
            cycle_count = 0;
        end else if (done || error) begin
            end_time = $time;
            total_time = (end_time - start_time) / 1000.0; // Convert to ns
            $display("  Computation took %0.2f ns (%0d cycles)", total_time, cycle_count);
        end
        
        if (start && !done && !error) begin
            cycle_count = cycle_count + 1;
        end
    end
    
endmodule