
module execute(input clk,
    input bubble_in, input halt_in_wb,
    input [2:0]opcode, input [2:0]s_1, input [2:0]s_2, input [2:0]tgt, input [3:0]alu_op,
    input [15:0]reg_out_1, input [15:0]reg_out_2,
    input [15:0]mem_instr_out, input [15:0]wb_result_out, input mem_bubble_out,
    input [15:0]decode_pc_out,
    output reg [15:0]result, output [15:0]addr, output reg [15:0]store_data, output reg [15:0]instr_out,
    output reg bubble_out,
    output branch, output [15:0]branch_tgt
  );

  initial begin
    bubble_out <= 1;
  end

  wire [15:0]op1;
  wire [15:0]op2;

  assign op1 = 
    (mem_tgt == s_1 && s_1 != 3'b000) ? result :
    (wb_tgt == s_1 && s_1 != 3'b000) ? wb_result_out :
    reg_out_1;
  assign op2 = 
    (mem_tgt == s_2 && s_2 != 3'b000) ? result :
    (wb_tgt == s_2 && s_2 != 3'b000) ? wb_result_out :
    reg_out_2;

  wire [6:0]imm7;
  assign imm7 = instr[6:0];

  wire [9:0]imm10;
  assign imm10 = instr[9:0];

  wire [15:0]sign_ext_7;
  assign sign_ext_7 = {{9{imm7[6]}}, imm7};

  wire [15:0]left_shift_6;
  assign left_shift_6 = {imm10, 6'b0};

  wire mux_lhs = (opcode == 3'b011);
  wire mux_rhs = (opcode == 3'b001) || (opcode == 3'b100) || (opcode == 3'b101) || (opcode == 3'b101);

  assign lhs = mux_lhs ? left_shift_6 : d_1;
  assign rhs = mux_rhs ? sign_ext_7 : d_2;

  wire [3:0]flags;
  ALU ALU(clk, opcode, alu_op, lhs, rhs, addr, flags);

  always @(posedge clk) begin
    result <= addr;
    store_data <= op2;
    instr_out <= instr_in;
    bubble_out <= halt_in_wb ? 1 : bubble_in;
  end

  wire [5:0]branch_code;
  assign branch_code = instr[12:7];

  wire taken;
  assign taken = (branch_code == 6'b000000) ? flags[1] : // bz beq
                    (branch_code == 6'b000001) ? !flags[1] && !flags[2] : // bp
                    (branch_code == 6'b000010) ? flags[2] : // bn
                    (branch_code == 6'b000011) ? flags[0] : // bc
                    (branch_code == 6'b000100) ? flags[3] : // bo
                    (branch_code == 6'b000101) ? !flags[1] : // bne
                    (branch_code == 6'b000110) ? 1 : // jmp
                    (branch_code == 6'b000111) ? !flags[0] : // bnc
                    (branch_code == 6'b001000) ? !flags[1] && flags[2] == flags[3] : // bg
                    (branch_code == 6'b001001) ? flags[2] == flags[3] : // bae
                    (branch_code == 6'b001010) ? flags[2] != flags[3] && !flags[1] : // bl
                    (branch_code == 6'b001011) ? flags[2] != flags[3] || flags[1] : // ble
                    (branch_code == 6'b001100) ? !flags[1] && flags[0] : // ba
                    (branch_code == 6'b001101) ? flags[0] || flags[1] : // bae
                    (branch_code == 6'b001110) ? !flags[0] && !flags[1] : // bb
                    (branch_code == 6'b001111) ? !flags[0] || flags[1] : // bbe
                    (branch_code == 6'b010000) ? !flags[3] : // bno
                    0;

  assign branch = !bubble_in && !halt_in_wb && taken;
  wire [1:0]mux_pc = (op == 3'b111) ? 2'b10 :
                     (op == 3'b110 && branch) ? 2'b01 :
                     2'b00;
  
  assign branch_tgt = 
            (mux_pc == 2'b00) ? pc + 1 : 
            (mux_pc == 2'b01) ? pc + sign_ext_7 + 1 :
            (mux_pc == 2'b10) ? rslt :
            0;

endmodule