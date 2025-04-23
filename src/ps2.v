`timescale 1ps/1ps

module ps2(input ps2_clk, input ps2_data, input clk, input ren, output [15:0]data);

    reg [9:0]sr = 10'b0;
    reg [3:0]bit_count = 0;

    // Convert scan to ascii
    reg [7:0]lut[0:8'hff];
`ifdef SIMULATION
    reg [255:0] filepath;
    initial begin
        if (!$value$plusargs("DATAPATH=%s", filepath)) begin
            filepath = "./data/"; // Default
        end
    end
    initial begin
        $readmemh({filepath, "/scan_decode.hex"}, lut); // Parameter
    end
`else
  initial begin
        $readmemh("../data/scan_decode.hex", lut); // Sythesis
  end
`endif

    wire [7:0]decode_output = lut[sr[8:1]];

    // Buffer 3 scan codes
    reg [7:0]buff0 = 0;
    reg [7:0]buff1 = 0;
    reg buff0_valid = 0;
    reg buff1_valid = 0;

    // Shift in ps/2 packet
    always @(negedge ps2_clk or posedge clk) begin
        if (~ps2_clk) begin
            sr <= {ps2_data, sr[9:1]};
            bit_count <= bit_count + 1;
            if (bit_count == 10) begin
                if (~buff0_valid) begin
                    buff0 <= decode_output;
                    buff0_valid <= 1;
                end else if (~buff1_valid) begin
                    buff1 <= decode_output;
                    buff1_valid <= 1;
                end
                bit_count <= 0;
            end
        end else if (ren) begin
          buff0 <= 0;
          buff0_valid <= 0;
          buff1 <= 0;
          buff1_valid <= 0;
        end
    end

    // Read last 2 scan codes
    assign data = {buff0, buff1};

endmodule