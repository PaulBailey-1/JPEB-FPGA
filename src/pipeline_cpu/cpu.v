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

    wire [18:0]mispredict_counter;
    wire [18:0]branch_counter;

    //always @(posedge clk) begin
    //  if (halt) begin
    //    $fdisplay(32'h8000_0002,"mispredictions: %d\n",mispredict_counter);
    //    $fdisplay(32'h8000_0002,"branches: %d\n",branch_counter);
    //  end
    //end

    counter ctr(halt, clk);

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
    wire mem_halt;
    assign flush = branch || wb_halt;

    mem mem(clk, 
      fetch_addr[15:1], mem_out_1, 
      addr[15:1], mem_out_2,
      mem_we, exec_result_out[15:1], store_data);

    wire stall;
    wire [15:0]branch_tgt;
    wire [15:0]decode_pc_out;
    wire [15:0]fetch_a_pc_out;
    wire is_branch_instr;
    wire taken;
    wire fetch_a_bubble_out;

    fetch fetch(clk, stall, flush, branch, branch_tgt,
      fetch_addr, fetch_a_bubble_out, fetch_a_pc_out, mispredict_counter, branch_counter);

    wire fetch_b_bubble_out;
    wire [15:0]fetch_b_pc_out;

    fetch_b fetch_b(clk, stall, flush,
      fetch_a_bubble_out, fetch_a_pc_out, 
      fetch_b_bubble_out, fetch_b_pc_out);

    wire [15:0] decode_op1_out;
    wire [15:0] decode_op2_out;
    wire [15:0] decode_instr_out;
    wire decode_bubble_out;
    wire decode_was_pair;
    wire decode_was_was_pair;

    wire [3:0]reg_tgt;
    assign reg_tgt = mem_instr_out[3:0];

    decode decode(clk, flush,
      mem_out_1, fetch_bubble_out, fetch_b_pc_out,
      reg_we, reg_tgt, reg_write_data,
      decode_op1_out, decode_op2_out, decode_pc_out,
      decode_instr_out, decode_bubble_out, decode_was_pair, decode_was_was_pair,
      stall);

    wire [15:0]exec_instr_out;
    wire exec_bubble_out;

    wire [15:0]mem_instr_out;
    wire [15:0]mem_result_out;
    wire mem_bubble_out;
    
    execute execute(clk, decode_bubble_out, wb_halt, mem_halt, decode_was_pair, decode_was_was_pair,
      decode_instr_out, decode_op1_out, decode_op2_out, mem_instr_out, reg_write_data, mem_bubble_out,
      fetch_b_pc_out, decode_pc_out,
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
