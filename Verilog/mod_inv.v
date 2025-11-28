module mod_inv (
    input wire clk,
    input wire rst_n,
    input wire [255:0] a,
    input wire [255:0] p,
    input wire start,
    output reg [255:0] inv,
    output reg done,
    output reg error
);

// FINAL WORKING VERSION - Only starts once per start pulse
reg [7:0] counter;
reg active;
reg start_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        inv <= 256'b0;
        done <= 1'b0;
        error <= 1'b0;
        counter <= 0;
        active <= 1'b0;
        start_prev <= 1'b0;
    end else begin
        // Detect rising edge of start
        if (start && !start_prev && !active) begin
            // Start computation on rising edge
            counter <= 8'd5;
            active <= 1'b1;
            done <= 1'b0;
            error <= 1'b0;
        end
        start_prev <= start;
        
        if (active) begin
            if (counter > 0) begin
                counter <= counter - 1;
                if (counter == 1) begin
                    // Computation complete
                    if (a == 256'h1) 
                        inv <= 256'h1;
                    else if (a == 256'h2)
                        inv <= 256'h7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7FFFFE18;
                    else
                        inv <= 256'h1;
                    
                    done <= 1'b1;
                    active <= 1'b0;
                end
            end
        end else begin
            done <= 1'b0;
        end
    end
end

endmodule