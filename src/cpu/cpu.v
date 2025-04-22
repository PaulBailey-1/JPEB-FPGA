`timescale 1ps/1ps

module cpu(
  input clk, output mem_read_en,
  output [15:0]mem_read0_addr, input [15:0]mem_read0_data,
  output [15:0]mem_read1_addr, input [15:0]mem_read1_data,
  output mem_write_en, output [15:0]mem_write_addr, output [15:0]mem_write_data,
  output [15:0]ret_val
);

    reg halt = 0;

`ifdef SIMULATION
    counter ctr(halt, clk, ret_val);
`endif

    // PC
    reg [15:0]pc = 16'h0000;
    reg [15:0]fetch_pc = 16'h0000;

    reg fetch_valid = 0;

    wire [15:0]instr;

    wire [2:0]op;
    assign op = instr[15:13];

    wire [2:0]r_a;
    assign r_a = instr[12:10];

    wire [2:0]r_b;
    assign r_b = instr[9:7];

    wire [3:0]alu_op;
    assign alu_op = instr[6:3];

    wire [2:0]r_c;
    assign r_c = instr[2:0];

    wire [6:0]imm7;
    assign imm7 = instr[6:0];

    wire [9:0]imm10;
    assign imm10 = instr[9:0];

    wire [15:0]sign_ext_7;
    assign sign_ext_7 = {{9{imm7[6]}}, imm7};

    wire [15:0]left_shift_6;
    assign left_shift_6 = {imm10, 6'b0};

    wire [5:0]branch_code;
    assign branch_code = instr[12:7];

    wire taken;
    wire [3:0]flags; // flags: O | S | Z | C
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

    wire mux_rf = (op == 3'b100);
    wire mux_lhs = (op == 3'b011);
    wire mux_rhs = (op == 3'b001) || (op == 3'b100) || (op == 3'b101) || (op == 3'b101);
    wire [1:0]mux_tgt = (op == 3'b101) ? 2'b01 :
                        (op == 3'b111) ? 2'b00 :
                        2'b10;
    wire [1:0]mux_pc = (op == 3'b111) ? 2'b10 :
                        (op == 3'b110 && taken) ? 2'b01 :
                        2'b00;
    wire we_rf = (op == 3'b000) || (op == 3'b001) || (op == 3'b011) ||
                  (op == 3'b101) || (op == 3'b111);
    wire we_mem = (op == 3'b100);

    wire [2:0]s_1;
    assign s_1 = r_b;

    wire [2:0]s_2;
    assign s_2 = mux_rf ? r_a : r_c;

    wire [15:0]d_1;
    wire [15:0]d_2;
    wire [15:0]tgt;
    wire [15:0]rslt;
    wire [15:0]mem_out;

    reg _mem_read_en = 1;
    assign mem_read_en = _mem_read_en;
    assign mem_read0_addr = pc;
    assign instr = mem_read0_data;
    assign mem_read1_addr = rslt;
    assign mem_out = mem_read1_data;
    assign mem_write_en = we_mem;
    assign mem_write_addr = rslt;
    assign mem_write_data = d_2;

    regfile regfile(clk, s_1, d_1, s_2, d_2, we_rf, r_a, tgt, ret_val);

    wire [15:0]lhs;
    wire [15:0]rhs;

    assign lhs = mux_lhs ? left_shift_6 : d_1;
    assign rhs = mux_rhs ? sign_ext_7 : d_2;

    ALU ALU(clk, op, alu_op, lhs, rhs, rslt, flags);

    assign tgt = (mux_tgt == 2'b00) ? fetch_pc + 1 :
                 (mux_tgt == 2'b01) ? mem_out :
                 (mux_tgt == 2'b10) ? rslt : 
                 0;

    reg fetch_setup = 0;
    wire jumping = fetch_valid & ((mux_pc == 2'b01) || (mux_pc == 2'b10));

    always @(posedge clk) begin
      if (~halt) begin
        pc <= (mux_pc == 2'b00) || !fetch_valid ? pc + 1 : 
              (mux_pc == 2'b01) ? fetch_pc + sign_ext_7 + 1 :
              (mux_pc == 2'b10) ? rslt :
              0;
      end
      fetch_pc <= pc;
      fetch_setup <= 1;
      fetch_valid <= fetch_setup & ~jumping;
      halt <= ~halt ? 
            (fetch_valid ? (op == 3'b111 && imm7 != 7'b0) : 0) : 1;
    end

endmodule