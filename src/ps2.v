`timescale 1ps/1ps

module ps2(input ps2_clk, input ps2_data, input clk, input ren, output [15:0]data);

    reg [9:0]sr = 9'b0;
    reg [3:0]bit_count = 0;

    // Convert scan to ascii
    reg [7:0]lut[0:8'hff];
    initial begin
        $readmemh("scan_decode.hex", lut);
    end
    wire [7:0]decode_output = lut[sr[8:1]];

    // Buffer 3 scan codes
    reg [7:0]buff0 = 0;
    reg [7:0]buff1 = 0;
    reg [7:0]buff2 = 0;
    reg buff0_valid = 0;
    reg buff1_valid = 0;
    reg buff2_valid = 0;

    // Shift in ps/2 packet
    always @(negedge ps2_clk) begin
        sr <= {sr[8:0], ps2_data};
        bit_count <= bit_count + 1;
        if (bit_count == 10) begin
            buff0 <= decode_output;
            buff0_valid <= 1;
            bit_count <= 0;
        end
    end

    // Shift between buffers on sys clk
    always @(posedge clk) begin
        // Shift buff0 to buff1
        if (buff0_valid & ~buff1_valid & buff2_valid & ~ren) begin
            buff1 <= buff0;
            buff1_valid <= buff0_valid;
            buff0 <= 0;
            buff0_valid <= 0;
        end
        // Shift buff0 to buff2
        if (buff0_valid & (~buff2_valid | ren)) begin
            buff2 <= buff0;
            buff2_valid <= buff0_valid;
            buff0 <= 0;
            buff0_valid <= 0;
        end
        // Clear buff1
        if (ren) begin
            buff1 <= 0;
            buff1_valid <= 0;
        end
        // Clear buff2
        if (ren & ~buff0) begin
            buff2 <= 0;
            buff2_valid <= 0;
        end
    end

    // Read last 2 scan codes
    assign data = {buff1, buff2};

endmodule

module scan_to_ascii(input [7:0]addr, output [7:0]data);
    reg [7:0]lut[0:8'hff];
    initial begin
        $readmemh("scan_decode.hex", lut);
    end
    assign data = lut[addr];
endmodule