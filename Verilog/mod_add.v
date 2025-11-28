module mod_add (
    input wire [255:0] a,
    input wire [255:0] b,
    input wire [255:0] p,  // modulus
    output reg [255:0] sum
);

wire [256:0] temp_sum;

// Compute a + b (needs 257 bits to detect overflow)
assign temp_sum = a + b;

// If result >= p, subtract p, else keep as is
always @(*) begin
    if (temp_sum >= p) begin
        sum = temp_sum - p;
    end else begin
        sum = temp_sum[255:0];
    end
end

endmodule