`timescale 1ps/1ps

// experimental copy of memory with sprites
// seems to be broken right now

module mem2(input clk,
    input [15:0]raddr0, output reg [15:0]rdata0,
    input ren, input [15:0]raddr1, output reg [15:0]rdata1,
    input wen, input [15:0]waddr, input [15:0]wdata,
    output ps2_ren, input [15:0]ps2_data_in,
    input [9:0]pixel_x_in, input [9:0]pixel_y_in, output [11:0]pixel,
    output reg [7:0]uart_tx_data, output uart_tx_wen
);

    localparam TILEMAP_START = 16'hc000;
    localparam FRAMEBUFFER_START = 16'he000;
    localparam IO_START = 16'hf000;
    
    localparam SPRITE_0_START = 16'ha000;
    localparam SPRITE_1_START = 16'ha400;
    localparam SPRITE_2_START = 16'ha800;
    localparam SPRITE_3_START = 16'hac00;
    localparam SPRITE_4_START = 16'hb000;
    localparam SPRITE_5_START = 16'hb400;
    localparam SPRITE_6_START = 16'hb800;
    localparam SPRITE_7_START = 16'hbc00;
    
    localparam PS2_REG = 16'hffff;
    localparam VSCROLL_REG = 16'hfffe;
    localparam HSCROLL_REG = 16'hfffd;
    localparam SCALE_REG = 16'hfffc;
    localparam UART_TX_REG = 16'hf000;
    
    localparam SPRITE_0_X = 16'hffe0;
    localparam SPRITE_0_Y = 16'hffe1;
    localparam SPRITE_1_X = 16'hffe2;
    localparam SPRITE_1_Y = 16'hffe3;
    localparam SPRITE_2_X = 16'hffe4;
    localparam SPRITE_2_Y = 16'hffe5;
    localparam SPRITE_3_X = 16'hffe6;
    localparam SPRITE_3_Y = 16'hffe7;
    localparam SPRITE_4_X = 16'hffe8;
    localparam SPRITE_4_Y = 16'hffe9;
    localparam SPRITE_5_X = 16'hffea;
    localparam SPRITE_5_Y = 16'hffeb;
    localparam SPRITE_6_X = 16'hffec;
    localparam SPRITE_6_Y = 16'hffed;
    localparam SPRITE_7_X = 16'hffee;
    localparam SPRITE_7_Y = 16'hffef;

    (* ram_style = "block" *) reg [15:0]ram[0:16'h9fff]; // 768Kb (0x0000-0x9FFF)
    reg [15:0]sprite_0_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    reg [15:0]sprite_1_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    reg [15:0]sprite_2_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    reg [15:0]sprite_3_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    reg [15:0]sprite_4_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    reg [15:0]sprite_5_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    reg [15:0]sprite_6_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    reg [15:0]sprite_7_data[0:16'h3ff]; // ???Kb (0xA000-0xBFFF)
    (* ram_style = "block" *) reg [15:0]tile_map[0:16'h1fff]; // 128Kb (0xC000-0xDFFF)
    (* ram_style = "block" *) reg [15:0]frame_buffer[0:16'h0fff]; // 64Kb (0xE000-0xEFFF)

`ifdef SIMULATION
    reg [255:0] filepath;
    initial begin
        if (!$value$plusargs("DATAPATH=%s", filepath)) begin
            filepath = "./data/"; // Default
        end
    end
    initial begin
        // Parameter
        $readmemh({filepath, "/program.hex"},ram);
        $readmemh({filepath, "tilemap.hex"}, tile_map);
    end
`else
  initial begin
        // Sythesis
        $readmemh("program.mem",ram);
        $readmemh("tilemap.mem", tile_map);
  end
`endif

    reg [15:0]raddr0_buf;
    reg [15:0]raddr1_buf;
    reg [15:0]waddr_buf;

    reg ren_buf;
    reg wen_buf;

    reg [15:0]ram_data0_out;
    reg [15:0]ram_data1_out;
    reg [15:0]tilemap_data0_out;
    reg [15:0]tilemap_data1_out;
    reg [15:0]framebuffer_data0_out;
    reg [15:0]framebuffer_data1_out;
    
    reg [15:0]sprite_0_data0_out;
    reg [15:0]sprite_0_data1_out;
    reg [15:0]sprite_1_data0_out;
    reg [15:0]sprite_1_data1_out;
    reg [15:0]sprite_2_data0_out;
    reg [15:0]sprite_2_data1_out;
    reg [15:0]sprite_3_data0_out;
    reg [15:0]sprite_3_data1_out;
    reg [15:0]sprite_4_data0_out;
    reg [15:0]sprite_4_data1_out;
    reg [15:0]sprite_5_data0_out;
    reg [15:0]sprite_5_data1_out;
    reg [15:0]sprite_6_data0_out;
    reg [15:0]sprite_6_data1_out;
    reg [15:0]sprite_7_data0_out;
    reg [15:0]sprite_7_data1_out;

    wire [15:0]data0_out =  raddr0_buf;
    wire [15:0]data1_out =  raddr1_buf < SPRITE_0_START ? ram_data1_out :
                            raddr1_buf < SPRITE_1_START ? sprite_0_data1_out :
                            raddr1_buf < SPRITE_2_START ? sprite_1_data1_out :
                            raddr1_buf < SPRITE_3_START ? sprite_2_data1_out :
                            raddr1_buf < SPRITE_4_START ? sprite_3_data1_out :
                            raddr1_buf < SPRITE_5_START ? sprite_4_data1_out :
                            raddr1_buf < SPRITE_6_START ? sprite_5_data1_out :
                            raddr1_buf < SPRITE_7_START ? sprite_0_data1_out :
                            raddr1_buf < TILEMAP_START ? sprite_0_data1_out :
                            raddr1_buf < FRAMEBUFFER_START ? tilemap_data1_out :
                            raddr1_buf < IO_START ? framebuffer_data1_out :
                            raddr1_buf == SCALE_REG ? scale_reg :
                            raddr1_buf == HSCROLL_REG ? hscroll_reg :
                            raddr1_buf == VSCROLL_REG ? vscroll_reg :
                            raddr1_buf == PS2_REG ? ps2_data_in :
                            16'h0;

    assign ps2_ren = raddr1_buf == PS2_REG & ren_buf;
    assign uart_tx_wen = waddr_buf == UART_TX_REG & wen_buf;

    reg [15:0]display_framebuffer_out;
    reg display_odd_tile;
    reg [9:0]display_pixel_x;
    reg [9:0]display_pixel_y;
    reg [15:0]display_tilemap_out;

    reg [15:0]scale_reg = 0;
    reg [15:0]vscroll_reg = 0;
    reg [15:0]hscroll_reg = 0;
    
    reg [15:0]sprite_0_x = 0;
    reg [15:0]sprite_0_y = 0;
    reg [15:0]sprite_1_x = 0;
    reg [15:0]sprite_1_y = 0;
    reg [15:0]sprite_2_x = 10'h60;
    reg [15:0]sprite_2_y = 10'h60;
    reg [15:0]sprite_3_x = 0;
    reg [15:0]sprite_3_y = 0;
    reg [15:0]sprite_4_x = 0;
    reg [15:0]sprite_4_y = 0;
    reg [15:0]sprite_5_x = 0;
    reg [15:0]sprite_5_y = 0;
    reg [15:0]sprite_6_x = 0;
    reg [15:0]sprite_6_y = 0;
    reg [15:0]sprite_7_x = 10'h40;
    reg [15:0]sprite_7_y = 10'h40;

    reg use_sprite_0 = 0;
    reg use_sprite_1 = 0;
    reg use_sprite_2 = 0;
    reg use_sprite_3 = 0;
    reg use_sprite_4 = 0;
    reg use_sprite_5 = 0;
    reg use_sprite_6 = 0;                 
    reg use_sprite_7 = 0; 

    wire [9:0]pixel_x = (pixel_x_in >> scale_reg) - hscroll_reg;
    wire [9:0]pixel_y = (pixel_y_in >> scale_reg) - vscroll_reg;
    
    // Display pixel retrevial
    wire [15:0] display_frame_addr = ({9'b0, pixel_x[9:3]} + {2'b0, pixel_y[9:3], 7'b0}); // (x / 8 + y /8 * 128)
    wire [15:0] display_tile_addr_pair = display_framebuffer_out;
    wire [7:0] display_tile = ~display_odd_tile ? display_tile_addr_pair[7:0] : display_tile_addr_pair[15:8];
    wire [15:0] pixel_idx = {2'b0, display_tile, 6'b0} + {10'b0, display_pixel_y[2:0], 3'b0} + {13'b0, display_pixel_x[2:0]}; // tile_idx * 64 + py % 8 * 8 + px % 8
    
    reg [15:0]display_sprite_0_out;
    reg [15:0]display_sprite_1_out;
    reg [15:0]display_sprite_2_out;
    reg [15:0]display_sprite_3_out;
    reg [15:0]display_sprite_4_out;
    reg [15:0]display_sprite_5_out;
    reg [15:0]display_sprite_6_out;
    reg [15:0]display_sprite_7_out;
    
    wire [9:0]display_sprite_addr = {display_pixel_y[4:0], display_pixel_x[4:0]};
    wire not_transparent_0 = (display_sprite_0_out[15:12] == 4'b0000);
    wire not_transparent_1 = (display_sprite_1_out[15:12] == 4'b0000);
    wire not_transparent_2 = (display_sprite_2_out[15:12] == 4'b0000);
    wire not_transparent_3 = (display_sprite_3_out[15:12] == 4'b0000);
    wire not_transparent_4 = (display_sprite_4_out[15:12] == 4'b0000);
    wire not_transparent_5 = (display_sprite_5_out[15:12] == 4'b0000);
    wire not_transparent_6 = (display_sprite_6_out[15:12] == 4'b0000);
    wire not_transparent_7 = (display_sprite_7_out[15:12] == 4'b0000);
    
    reg use_sprite_0_out;
    reg use_sprite_1_out;
    reg use_sprite_2_out;
    reg use_sprite_3_out;
    reg use_sprite_4_out;
    reg use_sprite_5_out;
    reg use_sprite_6_out;
    reg use_sprite_7_out;
    
    wire sprite_0_onscreen = use_sprite_0_out & not_transparent_0;
    wire sprite_1_onscreen = use_sprite_1_out & not_transparent_1;
    wire sprite_2_onscreen = use_sprite_2_out & not_transparent_2;
    wire sprite_3_onscreen = use_sprite_3_out & not_transparent_3;
    wire sprite_4_onscreen = use_sprite_4_out & not_transparent_4;
    wire sprite_5_onscreen = use_sprite_5_out & not_transparent_5;
    wire sprite_6_onscreen = use_sprite_6_out & not_transparent_6;
    wire sprite_7_onscreen = use_sprite_7_out & not_transparent_7;
    
    assign pixel = //sprite_7_onscreen ? display_sprite_7_out : 
                   //sprite_6_onscreen ? display_sprite_6_out : 
                   //sprite_5_onscreen ? display_sprite_5_out : 
                   //sprite_4_onscreen ? display_sprite_4_out : 
                   //sprite_3_onscreen ? display_sprite_3_out : 
                   //sprite_2_onscreen ? display_sprite_2_out : 
                   //sprite_1_onscreen ? display_sprite_1_out : 
                   //sprite_0_onscreen ? display_sprite_0_out :
                   display_tilemap_out[11:0];

    always @(posedge clk) begin

        raddr0_buf <= raddr0;
        raddr1_buf <= raddr1;
        waddr_buf <= waddr;

        ren_buf <= ren;
        wen_buf <= wen;

        ram_data0_out <= ram[raddr0];
        ram_data1_out <= ram[raddr1];
        tilemap_data1_out <= tile_map[raddr1 - TILEMAP_START];
        framebuffer_data1_out <= frame_buffer[raddr1 - FRAMEBUFFER_START];

        rdata0 <= data0_out;
        rdata1 <= data1_out;
        
        sprite_0_data1_out <= sprite_0_data[raddr1];
        sprite_1_data1_out <= sprite_1_data[raddr1];
        sprite_2_data1_out <= sprite_2_data[raddr1];
        sprite_3_data1_out <= sprite_3_data[raddr1];
        sprite_4_data1_out <= sprite_4_data[raddr1];
        sprite_5_data1_out <= sprite_5_data[raddr1];
        sprite_6_data1_out <= sprite_6_data[raddr1];
        sprite_7_data1_out <= sprite_7_data[raddr1];

        display_framebuffer_out <= frame_buffer[display_frame_addr[15:1]];
        display_odd_tile <= display_frame_addr[0];
        display_pixel_x <= pixel_x;
        display_pixel_y <= pixel_y;
        
        display_sprite_0_out <= sprite_0_data[display_sprite_addr];
        display_sprite_1_out <= sprite_1_data[display_sprite_addr];
        display_sprite_2_out <= sprite_2_data[display_sprite_addr];
        display_sprite_3_out <= sprite_3_data[display_sprite_addr];
        display_sprite_4_out <= sprite_4_data[display_sprite_addr];
        display_sprite_5_out <= sprite_5_data[display_sprite_addr];
        display_sprite_6_out <= sprite_6_data[display_sprite_addr];
        display_sprite_7_out <= sprite_7_data[display_sprite_addr];

        display_tilemap_out <= tile_map[pixel_idx];
        
        use_sprite_0 <= (sprite_0_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_0_x) &
                       (sprite_0_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_0_y);
        use_sprite_1 <= (sprite_1_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_1_x) &
                       (sprite_1_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_1_y);
        use_sprite_2 <= (sprite_2_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_2_x) &
                       (sprite_2_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_2_y);
        use_sprite_3 <= (sprite_3_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_3_x) &
                       (sprite_3_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_3_y);
        use_sprite_4 <= (sprite_4_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_4_x) &
                       (sprite_4_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_4_y);
        use_sprite_5 <= (sprite_5_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_5_x) &
                       (sprite_5_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_5_y);
        use_sprite_6 <= (sprite_6_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_6_x) &
                       (sprite_6_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_6_y);
        use_sprite_7 <= (sprite_7_x - 10'h20 < pixel_x_in) & (pixel_x_in <= sprite_7_x) &
                       (sprite_7_y - 10'h20 < pixel_y_in) & (pixel_y_in <= sprite_7_y);
                       
        use_sprite_0_out <= use_sprite_0;
        use_sprite_1_out <= use_sprite_1;
        use_sprite_2_out <= use_sprite_2;
        use_sprite_3_out <= use_sprite_3;
        use_sprite_4_out <= use_sprite_4;
        use_sprite_5_out <= use_sprite_5;
        use_sprite_6_out <= use_sprite_6;
        use_sprite_7_out <= use_sprite_7;

        if (wen) begin
            if (waddr < TILEMAP_START) begin
                ram[waddr] <= wdata;
            end else if (waddr < FRAMEBUFFER_START) begin
                tile_map[waddr - TILEMAP_START] <= wdata;
            end else if (waddr < IO_START) begin
                frame_buffer[waddr - FRAMEBUFFER_START] <= wdata;
            end
            if (waddr == SPRITE_0_X) begin
                sprite_0_x <= wdata;
            end
            if (waddr == SPRITE_0_Y) begin
                sprite_0_y <= wdata;
            end
            if (waddr == SPRITE_1_X) begin
                sprite_1_x <= wdata;
            end
            if (waddr == SPRITE_1_Y) begin
                sprite_1_y <= wdata;
            end
            if (waddr == SPRITE_2_X) begin
                sprite_2_x <= wdata;
            end
            if (waddr == SPRITE_2_Y) begin
                sprite_2_y <= wdata;
            end
            if (waddr == SPRITE_3_X) begin
                sprite_3_x <= wdata;
            end
            if (waddr == SPRITE_3_Y) begin
                sprite_3_y <= wdata;
            end
            if (waddr == SPRITE_4_X) begin
                sprite_4_x <= wdata;
            end
            if (waddr == SPRITE_4_Y) begin
                sprite_4_y <= wdata;
            end
            if (waddr == SPRITE_5_X) begin
                sprite_5_x <= wdata;
            end
            if (waddr == SPRITE_5_Y) begin
                sprite_5_y <= wdata;
            end
            if (waddr == SPRITE_6_X) begin
                sprite_6_x <= wdata;
            end
            if (waddr == SPRITE_6_Y) begin
                sprite_6_y <= wdata;
            end
            if (waddr == SPRITE_7_X) begin
                sprite_7_x <= wdata;
            end
            if (waddr == SPRITE_7_Y) begin
                sprite_7_y <= wdata;
            end
            if (waddr == SCALE_REG) begin
                scale_reg <= wdata;
            end
            if (waddr == HSCROLL_REG) begin
                hscroll_reg <= wdata;
            end
            if (waddr == VSCROLL_REG) begin
                vscroll_reg <= wdata;
            end
            if (waddr == SCALE_REG) begin
                scale_reg <= wdata;
            end
            if (waddr == HSCROLL_REG) begin
                hscroll_reg <= wdata;
            end
            if (waddr == VSCROLL_REG) begin
                vscroll_reg <= wdata;
            end
            if (waddr == UART_TX_REG) begin
                uart_tx_data <= wdata[7:0];
            end
        end
    end

endmodule
