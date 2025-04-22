
module decode(input clk,
    input flush,

    input [15:0]mem_out_1, input bubble_in, input [15:0]pc_in,

    input we, input [2:0]target, input [15:0]write_data,

    output [15:0]d_1, output [15:0]d_2, output reg [15:0]pc_out,
    output reg [2:0]opcode_out, output reg [2:0]s_1_out, output reg [2:0]s_2_out, output reg [2:0]tgt_out,
    output reg [3:0]alu_op_out, output reg [15:0]imm_out, output reg [5:0]branch_code_out,
    output reg bubble_out, output stall, output reg halt_out, output [15:0]ret_val
  );

  wire [15:0]instr_in;
  assign instr_in = mem_out_1;

  wire [2:0]opcode = instr_in[15:13];

  wire [2:0]r_a = instr_in[12:10];
  wire [2:0]r_b = instr_in[9:7];
  wire [3:0]alu_op = instr_in[6:3];
  wire [2:0]r_c = instr_in[2:0];

  wire [5:0]branch_code = instr_in[12:7];

  wire [2:0]s_1 = r_b;
  wire [2:0]s_2 = (opcode == 3'b100) ? r_a : r_c;

  assign stall = 
    ((tgt_out == s_1 ||
      tgt_out == s_2) &&
      tgt_out != 3'b000 &&
      opcode_out == 3'b101 && // lw can cause stalls
      !bubble_in);

  regfile regfile(clk,
        s_1, d_1,
        s_2, d_2,
        we, target, write_data, ret_val);

  wire [6:0]imm7;
  assign imm7 = instr_in[6:0];

  wire [9:0]imm10;
  assign imm10 = instr_in[9:0];

  wire [15:0]sign_ext_7;
  assign sign_ext_7 = {{9{imm7[6]}}, imm7};

  wire [15:0]left_shift_6;
  assign left_shift_6 = {imm10, 6'b0};

  wire mux_imm = (opcode == 3'b011);
  assign imm = mux_imm ? left_shift_6 : sign_ext_7;


  initial begin
    bubble_out <= 1;
  end

  always @(posedge clk) begin
    opcode_out <= opcode;
    s_1_out <= s_1;
    s_2_out <= s_2;
    tgt_out <= (flush || bubble_in || (opcode == 3'b100 || opcode == 3'b110)) ? 3'b000 : r_a;
    imm_out <= imm;
    branch_code_out <= branch_code;
    alu_op_out <= alu_op;
    bubble_out <= (flush || stall) ? 1 : bubble_in;
    pc_out <= pc_in;
    halt_out <= (opcode == 3'b111) && (imm7 != 0);
  end

endmodule