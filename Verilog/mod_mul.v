module mod_mul (
    input wire clk,
    input wire rst_n,
    input wire [255:0] a,
    input wire [255:0] b,
    input wire [255:0] p,
    input wire start,
    output reg [255:0] product,
    output reg done
);

reg [3:0] counter;
reg active;
reg start_prev;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        product <= 256'b0;
        done <= 1'b0;
        counter <= 0;
        active <= 1'b0;
        start_prev <= 1'b0;
    end else begin
        // Detect rising edge of start
        if (start && !start_prev && !active) begin
            counter <= 4'd3;
            active <= 1'b1;
            done <= 1'b0;
            $display("MOD_MUL: Starting a=%h, b=%h", a, b);
        end
        start_prev <= start;
        
        if (active) begin
            if (counter > 0) begin
                counter <= counter - 1;
                if (counter == 1) begin
                    product <= (a * b) % p;
                    done <= 1'b1;
                    active <= 1'b0;
                    $display("MOD_MUL: Result product=%h", product);
                end
            end
        end else begin
            done <= 1'b0;
        end
    end
end

endmodule