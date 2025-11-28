module mod_sub (
    input wire [255:0] a,
    input wire [255:0] b,
    input wire [255:0] p,  // modulus
    output reg [255:0] diff
);

wire [255:0] temp_diff;

// Compute a - b
assign temp_diff = a - b;

// If result is negative, add p, else keep as is
always @(*) begin
    if (a < b) begin
        diff = temp_diff + p;
    end else begin
        diff = temp_diff;
    end
end

endmodule