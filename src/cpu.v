`timescale 1ps/1ps

module cpu(
    input clk
    );

    reg halt = 0;
    wire [15:0]ret_val;

    `ifdef SIMULATION
      counter ctr(halt, clk, ret_val);
    `endif

    // PC
    reg [15:0]pc = 16'h0000;

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

    wire taken; // TODO: define this

    wire mux_rf = (op == 3'b100);
    wire mux_lhs = (op == 3'b001) || (op == 3'b100) || (op == 3'b101) || (op == 3'b101);
    wire mux_rhs = (op == 3'b011);
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

    regfile regfile(clk, s_1, d_1, s_2, d_2, we_rf, r_a, tgt, ret_val);

    simple_mem simple_mem(clk, pc, instr, rslt, mem_out, we_mem, rslt, d_2);

    wire [15:0]lhs;
    wire [15:0]rhs;
    wire [3:0]flags;

    assign lhs = mux_lhs ? sign_ext_7 : d_1;
    assign rhs = mux_rhs ? left_shift_6 : d_2;

    ALU ALU(clk, op, alu_op, lhs, rhs, rslt, flags);

    assign tgt = (mux_tgt == 2'b00) ? pc + 1 :
                 (mux_tgt == 2'b01) ? mem_out :
                 (mux_tgt == 2'b10) ? rslt : 
                 0;


    always @(posedge clk) begin
      pc <= (mux_pc == 2'b00) ? pc + 1 : 
            (mux_pc == 2'b01) ? pc + sign_ext_7 + 1 :
            (mux_pc == 2'b10) ? rslt :
            0;
    end

endmodule