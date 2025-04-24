`timescale 1ps/1ps

module ps2(input ps2_clk, input ps2_data, input clk, input ren, output [15:0]data);

    reg [9:0]sr = 10'b0;
    reg [3:0]bit_count = 0;

    // Convert scan to ascii
    reg [7:0]scan_decode[0:8'hff];
`ifdef SIMULATION
    reg [255:0] filepath;
    initial begin
        if (!$value$plusargs("DATAPATH=%s", filepath)) begin
            filepath = "./data/"; // Default
        end
    end
    initial begin
        $readmemh({filepath, "/scan_decode.hex"}, scan_decode); // Parameter
    end
`else
  initial begin
        $readmemh("../data/scan_decode.hex", scan_decode); // Sythesis
  end
`endif

    wire [7:0]decode_output = scan_decode[sr[8:1]];
    // wire [7:0]decode_output = sr[8:1];
    reg [7:0]key_buff = 0;

    // Shift in ps/2 packet
    always @(negedge ps2_clk) begin
        if (~ps2_clk) begin
            sr <= {ps2_data, sr[9:1]};
            bit_count <= bit_count + 1;
            if (bit_count == 10) begin
                key_buff <= decode_output;
                bit_count <= 0;
            end
        end
    end

    // always @(posedge clk) begin
    //     if (ren) begin
    //       key_buff <= 0;
    //     end
    // end

    assign data = {8'h00, key_buff};

endmodule