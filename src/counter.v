module counter(input isHalt, input clk, input [15:0]ret_val);

    reg [31:0] count = 0;

    always @(posedge clk) begin
        if (isHalt) begin
            $fdisplay(32'h8000_0002,"%d\n",count);
            $write("%c", ret_val[7:0]);
            $finish;
        end
        if (count == 500000) begin
            $display("ran for 500000 cycles");
            $finish;
        end
        count <= count + 1;
    end

endmodule
