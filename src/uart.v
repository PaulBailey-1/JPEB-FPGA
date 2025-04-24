`timescale 1ps/1ps

module uart(
    input clk, input baud_clk,
    input tx_en, input [7:0]tx_data,
    output tx
);

    wire [7:0]tx_buf_count;
    wire tx_send;
    wire [7:0]tx_bus;

    fifo tx_buf(
        .clk(clk), .wen(tx_en), .wdata(tx_data),
        .ren(tx_send), .rdata(tx_bus),
        .size(tx_buf_count)
    );

    reg tx_start = 0;
    wire tx_ready;

    uart_tx uart_tx(.clk(baud_clk), .tbus(tx_bus), .start(tx_start), .tx(tx), .ready(tx_ready));

    assign tx_send = tx_ready & (tx_buf_count > 0);

    always @(posedge clk) begin
        tx_start <= tx_send;
    end

endmodule

module fifo(
    input clk, input wen, input [7:0]wdata,
    input ren, output reg [7:0]rdata, 
    output wire [7:0]size
);

    reg [7:0]data[0:255];
    reg [7:0]read_ptr = 0;
    reg [7:0]write_ptr = 0;
    reg [7:0]count = 0;
    assign size = count;

    always @(posedge clk) begin
        if (wen) begin
            data[write_ptr] <= wdata;
            write_ptr <= write_ptr + 1;
            count <= count + 1;
        end
        if (ren) begin
            rdata <= data[read_ptr];
            read_ptr <= read_ptr + 1;
            count <= count - 1;
        end
    end

endmodule

// From demos
// https://github.com/Digilent/Basys-3-HW/blob/63134db53d58a894ba33ce24590ef38bb833772c/src/hdl/uart_tx.v

module uart_tx(
    input clk,
    input [7:0] tbus,
    input start,
    output tx,
    output ready 
);
    parameter CD_MAX=10416, CD_WIDTH=16;
    reg [CD_WIDTH-1:0] cd_count=0;
    reg [3:0] count=0;
    reg running=0;
    reg [10:0] shift=11'h7ff;
    always@(posedge clk) begin
        if (running == 1'b0) begin
            shift <= {2'b11, tbus, 1'b0};
            running <= start;
            cd_count <= 'b0;
            count <= 'b0;
        end else if (cd_count == CD_MAX) begin
            shift <= {1'b1, shift[10:1]};
            cd_count <= 'b0;
            if (count == 4'd10) begin
                running <= 1'b0;
                count <= 'b0;
            end
            else
                count <= count + 1'b1;
        end else
            cd_count <= cd_count + 1'b1;
    end
    assign tx = (running == 1'b1) ? shift[0] : 1'b1;
    assign ready = ((running == 1'b0 && start == 1'b0) || (cd_count == CD_MAX && count == 4'd10)) ? 1'b1 : 1'b0;
endmodule