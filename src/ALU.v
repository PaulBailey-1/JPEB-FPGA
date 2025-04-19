
module ALU(input clk,
    input [3:0]op, input [15:0]s_1, input [15:0]s_2, 
    output [15:0]result);

  // O | S | Z | C
  reg [3:0]flags;

  wire [16:0]sum;
  assign sum = {1'b0, s_1} + {1'b0, s_2};
  wire [16:0]carry_sum;
  assign carry_sum = {1'b0, s_1} + {1'b0, s_2} + flags[0];

  wire [16:0]diff;
  assign diff = {1'b0, s_1} - {1'b0, s_2};
  wire [16:0]carry_diff;
  assign carry_diff = {1'b0, s_1} - {1'b0, s_2} - ~flags[0];

  assign result = 
    (op == 4'b0000) ? (~(s_1 & s_2)) : // nand
    (op == 4'b0001) ? (s_1 + s_2) : // add
    (op == 4'b0010) ? (s_1 + s_2 + flags[0]) : // addc
    (op == 4'b0011) ? (s_1 | s_2) : // or
    (op == 4'b0100) ? (s_1 - s_2 - ~flags[0]) : // subc
    (op == 4'b0101) ? (s_1 & s_2) : // and
    (op == 4'b0110) ? (s_1 - s_2) : // sub
    (op == 4'b0111) ? (s_1 ^ s_2) : // xor
    (op == 4'b1000) ? (~s_2) : // not
    (op == 4'b1001) ? ({s_2[14:0], 1'b0}) : // shl
    (op == 4'b1010) ? ({1'b0, s_2[15:1]}) : // shr
    (op == 4'b1011) ? ({s_2[14:0], s_2[15]}) : // rotl
    (op == 4'b1100) ? ({s_2[0], s_2[15:1]}) : // rotr
    (op == 4'b1101) ? ({s_2[15], s_2[15:1]}) : // sshr
    (op == 4'b1110) ? ({flags[0], s_2[15:1]}) : // shrc
    (op == 4'b1111) ? ({s_2[14:0], flags[0]}) : // shlc
    0;

  wire c;
  assign c = 
    (op == 4'b0000) ? 0 : // nand
    (op == 4'b0001) ? sum[16] : // add
    (op == 4'b0010) ? carry_sum[16] : // addc
    (op == 4'b0011) ? 0 : // or
    (op == 4'b0100) ? carry_diff[16] : // subc
    (op == 4'b0101) ? 0 : // and
    (op == 4'b0110) ? diff[16] : // sub
    (op == 4'b0111) ? 0 : // xor
    (op == 4'b1000) ? 0 : // not
    (op == 4'b1001) ? s_2[15] : // shl
    (op == 4'b1010) ? s_2[0] : // shr
    (op == 4'b1011) ? s_2[15] : // rotl
    (op == 4'b1100) ? s_2[0] : // rotr
    (op == 4'b1101) ? s_2[0] : // sshr
    (op == 4'b1110) ? s_2[0] : // shrc
    (op == 4'b1111) ? s_2[15] : // shlc
    0;

  wire z;
  assign z = (result == 0);

  wire s;
  assign s = result[15];

  wire o;
  assign o = (result[15] != s_1[15]) & (s_1[15] == s_2[15]);

  always @(posedge clk) begin
    flags <= {o, s, z, c};
  end

endmodule