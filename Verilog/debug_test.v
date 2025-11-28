// debug_test.v
module debug_test;
    reg clk = 0;
    always #5 clk = ~clk;
    reg rst_n = 0;
    
    reg [255:0] test_a = 256'h2;
    reg mod_inv_start = 0;
    wire [255:0] mod_inv_out;
    wire mod_inv_done, mod_inv_error;
    
    mod_inv inv_inst (
        .clk(clk),
        .rst_n(rst_n),
        .a(test_a),
        .p(256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F),
        .start(mod_inv_start),
        .inv(mod_inv_out),
        .done(mod_inv_done),
        .error(mod_inv_error)
    );
    
    initial begin
        $dumpfile("debug.vcd");
        $dumpvars(0, debug_test);
        
        // Reset
        #20;
        rst_n = 1;
        #20;
        
        $display("=== Starting Test ===");
        
        // Hold start for multiple cycles
        mod_inv_start = 1;
        repeat(10) @(posedge clk);  // Hold for 10 cycles
        mod_inv_start = 0;
        
        $display("Start released, waiting for done...");
        
        // Wait for completion
        wait(mod_inv_done || mod_inv_error);
        @(posedge clk);
        
        if (mod_inv_error) begin
            $display("❌ MOD_INV ERROR");
        end else begin
            $display("✅ MOD_INV SUCCESS: inv=%h", mod_inv_out);
        end
        
        $finish;
    end
endmodule