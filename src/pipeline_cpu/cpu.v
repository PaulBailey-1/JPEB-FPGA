`timescale 1ps/1ps

module main();

    initial begin
        $dumpfile("cpu.vcd");
        $dumpvars(0,main);
    end

    // clock 
    wire clk;
    clock c0(clk);

    reg halt = 0;

    wire [15:0] ret_val;
    counter ctr(halt, clk, ret_val);

    // read from memory
    wire [15:0]fetch_instr_out;
    wire [15:0]mem_out_1;
    wire [15:0]fetch_addr;
    wire [15:0]mem_out_2;

    wire mem_we;
    wire [15:0]exec_result_out;
    wire [15:0]addr;
    wire [15:0]store_data;

    wire [15:0]reg_write_data;
    wire reg_we;

    wire branch;
    wire flush;
    wire wb_halt;
    assign flush = branch || wb_halt;

    mem mem(clk, 
      fetch_addr, mem_out_1, 
      addr, mem_out_2,
      mem_we, exec_result_out, store_data);

    wire stall;
    wire [15:0]branch_tgt;
    wire [15:0]decode_pc_out;
    wire [15:0]fetch_pc_out;
    wire fetch_bubble_out;

    fetch fetch(clk, stall, flush, branch, branch_tgt,
      fetch_addr, fetch_pc_out, fetch_bubble_out);

    wire [15:0] decode_op1_out;
    wire [15:0] decode_op2_out;

    wire [2:0] decode_opcode_out;
    wire [2:0] decode_s_1_out;
    wire [2:0] decode_s_2_out;
    wire [2:0] decode_tgt_out;
    wire [3:0] decode_alu_op_out;
    wire [15:0] decode_imm_out;
    wire [5:0] decode_branch_code_out;
    
    wire decode_bubble_out;
    wire decode_halt_out;
    wire [3:0]reg_tgt;

    decode decode(clk, flush,
      mem_out_1, fetch_bubble_out, fetch_pc_out,
      reg_we, reg_tgt, reg_write_data,
      decode_op1_out, decode_op2_out, decode_pc_out,
      decode_opcode_out, decode_s_1_out, decode_s_2_out, decode_tgt_out,
      decode_alu_op_out, decode_imm_out, decode_branch_code_out,
      decode_bubble_out, stall, decode_halt_out, ret_val);

    wire [15:0]exec_instr_out;
    wire exec_bubble_out;

    wire [15:0]mem_instr_out;
    wire [15:0]mem_result_out;
    wire mem_bubble_out;
    wire wb_halt;
    wire wb_tgt;
    wire [15:0]wb_result_out;
    wire mem_tgt;
    
    execute execute(clk, decode_bubble_out, wb_halt, 
      decode_opcode_out, decode_s_1_out, decode_s_2_out, decode_tgt_out,
      decode_alu_op_out, decode_imm_out, decode_branch_code_out,
      wb_tgt, decode_op1_out, decode_op2_out, wb_result_out, decode_pc_out,
      decode_halt_out, 

      exec_result_out, addr, store_data, exec_instr_out, exec_bubble_out, 
      branch, branch_tgt, is_branch_instr, taken);

    memory memory(clk, exec_bubble_out, wb_halt, exec_instr_out, exec_result_out,
      mem_instr_out, mem_result_out, mem_we, mem_bubble_out, mem_halt);

    writeback writeback(clk, mem_bubble_out, mem_instr_out, mem_result_out, mem_out_2,
      reg_write_data, reg_we, wb_halt);

    always @(posedge clk) begin
      halt <= wb_halt;
    end

endmodule
