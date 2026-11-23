// mul_shift_add.sv
// Sequential 32x32 -> 64-bit unsigned shift-and-add multiplier.
//
// SCAFFOLDING: this block exists only to smoke-test the simulation and
// OpenLane flows before the real core exists. Replace it with your own
// block (e.g. your ALU or your own multiplier) before putting its numbers
// on a resume.
//
// Protocol: pulse `start` for one cycle with operands valid. `busy` stays
// high for 32 cycles, then `done` pulses for one cycle with `product` valid.
// Written in the Verilog-2005-compatible SystemVerilog subset that Yosys
// (used by OpenLane) handles reliably.

module mul_shift_add (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        start,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic        busy,
    output logic        done,
    output logic [63:0] product
);

    logic [63:0] multiplicand;
    logic [31:0] multiplier;
    logic [63:0] acc;
    logic [5:0]  count;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multiplicand <= 64'd0;
            multiplier   <= 32'd0;
            acc          <= 64'd0;
            count        <= 6'd0;
            busy         <= 1'b0;
            done         <= 1'b0;
            product      <= 64'd0;
        end else begin
            done <= 1'b0;
            if (start && !busy) begin
                multiplicand <= {32'd0, a};
                multiplier   <= b;
                acc          <= 64'd0;
                count        <= 6'd32;
                busy         <= 1'b1;
            end else if (busy) begin
                if (multiplier[0])
                    acc <= acc + multiplicand;
                multiplicand <= multiplicand << 1;
                multiplier   <= multiplier >> 1;
                count        <= count - 6'd1;
                if (count == 6'd1) begin
                    busy    <= 1'b0;
                    done    <= 1'b1;
                    product <= multiplier[0] ? acc + multiplicand : acc;
                end
            end
        end
    end

endmodule
