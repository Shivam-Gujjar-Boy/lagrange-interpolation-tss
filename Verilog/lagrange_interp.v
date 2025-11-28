module lagrange_interp (
    input wire clk,
    input wire rst_n,
    input wire [255:0] x1, y1,
    input wire [255:0] x2, y2,
    input wire start,
    output reg [255:0] secret,
    output reg done,
    output reg error
);

localparam [255:0] P = 256'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

// FSM states
localparam [3:0] IDLE            = 4'd0;
localparam [3:0] CALC_DENOMS     = 4'd1;
localparam [3:0] CALC_NUMERATORS = 4'd2;
localparam [3:0] MOD_INV_1       = 4'd3;
localparam [3:0] CALC_L1         = 4'd4;
localparam [3:0] MOD_INV_2       = 4'd5;
localparam [3:0] CALC_L2         = 4'd6;
localparam [3:0] CALC_TERM1      = 4'd7;
localparam [3:0] CALC_TERM2      = 4'd8;
localparam [3:0] FINAL_ADD       = 4'd9;
localparam [3:0] DONE            = 4'd10;

reg [3:0] state, next_state;
reg [15:0] state_counter;

// Internal registers
reg [255:0] denominator, numerator1, numerator2;
reg [255:0] lagrange1, lagrange2;
reg [255:0] term1, term2;
reg [255:0] mod_inv_input;
reg mod_inv_start;
wire mod_inv_done;
wire [255:0] mod_inv_output;
wire mod_inv_error;

// Operation results
wire [255:0] sub_denom, sub_num1, sub_num2;
wire [255:0] add_final;

// Submodule instances
mod_sub sub_denom_inst (.a(x1), .b(x2), .p(P), .diff(sub_denom));
mod_sub sub_num1_inst  (.a(256'b0), .b(x2), .p(P), .diff(sub_num1));
mod_sub sub_num2_inst  (.a(256'b0), .b(x1), .p(P), .diff(sub_num2));
mod_add add_final_inst (.a(term1), .b(term2), .p(P), .sum(add_final));

mod_inv mod_inv_inst (
    .clk(clk), .rst_n(rst_n),
    .a(mod_inv_input), .p(P),
    .start(mod_inv_start),
    .inv(mod_inv_output),
    .done(mod_inv_done),
    .error(mod_inv_error)
);

// Manual multiplication (avoid mod_mul for now)
function [255:0] manual_mul;
    input [255:0] a, b;
    begin
        manual_mul = (a * b) % P;
        $display("MANUAL_MUL: %h * %h = %h", a, b, manual_mul);
    end
endfunction

// FSM State Register
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        state <= IDLE;
        state_counter <= 0;
    end else begin
        state <= next_state;
        if (state != next_state) begin
            state_counter <= 0;
        end else begin
            state_counter <= state_counter + 1;
        end
    end
end

// FSM Next State Logic
always @(*) begin
    next_state = state;
    case (state)
        IDLE:           if (start) next_state = CALC_DENOMS;
        CALC_DENOMS:    next_state = CALC_NUMERATORS;
        CALC_NUMERATORS:next_state = MOD_INV_1;
        MOD_INV_1:      if (state_counter > 10) next_state = CALC_L1;
        CALC_L1:        next_state = MOD_INV_2;
        MOD_INV_2:      if (state_counter > 10) next_state = CALC_L2;
        CALC_L2:        next_state = CALC_TERM1;
        CALC_TERM1:     next_state = CALC_TERM2;
        CALC_TERM2:     next_state = FINAL_ADD;
        FINAL_ADD:      next_state = DONE;
        DONE:           next_state = IDLE;
        default:        next_state = IDLE;
    endcase
end

// FSM Output Logic
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        denominator <= 256'b0; numerator1 <= 256'b0; numerator2 <= 256'b0;
        lagrange1 <= 256'b0; lagrange2 <= 256'b0; term1 <= 256'b0; term2 <= 256'b0;
        secret <= 256'b0; done <= 1'b0; error <= 1'b0; mod_inv_input <= 256'b0; mod_inv_start <= 1'b0;
    end else begin
        done <= 1'b0; error <= 1'b0; mod_inv_start <= 1'b0;
        
        case (state)
            CALC_DENOMS: begin
                denominator <= sub_denom;
                $display("=== STARTING COMPUTATION ===");
                $display("x1=%h, y1=%h", x1, y1);
                $display("x2=%h, y2=%h", x2, y2);
                $display("denominator = (x1 - x2) = %h", sub_denom);
            end
            
            CALC_NUMERATORS: begin
                numerator1 <= sub_num1;
                numerator2 <= sub_num2;
                $display("numerator1 = (-x2) = %h", sub_num1);
                $display("numerator2 = (-x1) = %h", sub_num2);
            end
            
            MOD_INV_1: begin
                if (state_counter == 0) begin
                    mod_inv_input <= denominator;
                    mod_inv_start <= 1'b1;
                    $display("MOD_INV_1: computing inverse of %h", denominator);
                end
                if (mod_inv_done) begin
                    $display("MOD_INV_1: result = %h", mod_inv_output);
                end
            end
            
            CALC_L1: begin
                lagrange1 <= manual_mul(numerator1, mod_inv_output);
                $display("L1 = numerator1 * inv(denominator) = %h", lagrange1);
            end
            
            MOD_INV_2: begin
                if (state_counter == 0) begin
                    mod_inv_input <= denominator;
                    mod_inv_start <= 1'b1;
                    $display("MOD_INV_2: computing inverse of %h", denominator);
                end
                if (mod_inv_done) begin
                    $display("MOD_INV_2: result = %h", mod_inv_output);
                end
            end
            
            CALC_L2: begin
                lagrange2 <= manual_mul(numerator2, mod_inv_output);
                $display("L2 = numerator2 * inv(denominator) = %h", lagrange2);
            end
            
            CALC_TERM1: begin
                term1 <= manual_mul(y1, lagrange1);
                $display("term1 = y1 * L1 = %h", term1);
            end
            
            CALC_TERM2: begin
                term2 <= manual_mul(y2, lagrange2);
                $display("term2 = y2 * L2 = %h", term2);
            end
            
            FINAL_ADD: begin
                secret <= add_final;
                $display("secret = term1 + term2 = %h", add_final);
            end
            
            DONE: begin
                done <= 1'b1;
                error <= (denominator == 256'b0);
                $display("=== COMPUTATION COMPLETE ===");
                $display("Final secret = %h", secret);
            end
        endcase
    end
end

endmodule