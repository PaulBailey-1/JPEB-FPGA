
module decode(input clk,
    input flush,

    input [15:0]mem_out_1, input bubble_in, input [15:0]pc_in, input [2:0]exec_tgt,

    input we, input [2:0]target, input [15:0]write_data,

    output [15:0]d_1, output [15:0]d_2, output reg [15:0]pc_out,
    output reg [2:0]opcode_out, output reg [2:0]s_1_out, output reg [2:0]s_2_out, output reg [2:0]tgt_out,
    output reg [3:0]alu_op_out,
    output reg bubble_out, output stall
  );

  wire [15:0]instr_in;
  assign instr_in = mem_out_1;

  wire [2:0]opcode = instr_in[15:13];

  wire [2:0]r_a = instr_in[12:10];
  wire [2:0]r_b = instr_in[9:7];
  wire [3:0]alu_op = instr_in[6:3];
  wire [2:0]r_c = instr_in[2:0];

  wire [2:0]s_1 = r_b;
  wire [2:0]s_2 = (opcode == 3'b100) ? r_a : r_c;

  assign stall = 
    ((exec_tgt == s_1 ||
      exec_tgt == s_2) &&
      exec_tgt != 3'b000 &&
      opcode_out == 3'b101 && // lw can cause stalls
      !bubble_in && !bubble_out);

  regfile regfile(clk,
        s_1, d_1,
        s_2, d_2,
        we, target, write_data, );

  initial begin
    bubble_out <= 1;
  end

  always @(posedge clk) begin
    opcode_out <= opcode;
    s_1_out <= s_1;
    s_2_out <= s_2;
    tgt_out <= (flush || bubble_in) ? 3'b000 : r_a;
    alu_op_out <= alu_op;
    bubble_out <= (flush || stall) ? 1 : bubble_in;
    pc_out <= pc_in;
  end

endmodule