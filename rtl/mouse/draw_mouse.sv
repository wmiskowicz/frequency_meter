`timescale 1 ns / 1 ps
//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   draw mouse
 Author:        Wojciech Miskowicz
 Last modified: 2023-06-18
 Description:  connects module Mouse Display
 */
//////////////////////////////////////////////////////////////////////////////
module draw_mouse (
    input  logic clk,
    input  logic rst,
    input wire [11:0] mouse_x_pos,
    input wire [11:0] mouse_y_pos,
    vga_if.in in,
    vga_if.out out
);
wire [11:0] rgb_nxt;

wire blank = (in.hblnk || in.vblnk);

always_ff @(posedge clk) begin : mouse_ff_blk
    if (rst) begin
        out.vcount <= '0;
        out.vsync <= '0;
        out.vblnk <= '0;
        out.hcount <= '0;
        out.hsync <= '0;
        out.hblnk <= '0;
        out.rgb <= 12'b0;
    end else begin
        out.vcount <= in.vcount;
        out.vsync <= in.vsync;
        out.vblnk <= in.vblnk;
        out.hcount <= in.hcount;
        out.hsync <= in.hsync;
        out.hblnk <= in.hblnk;
        out.rgb <= rgb_nxt;
    end
end


MouseDisplay u_MouseDisplay(
    .pixel_clk(clk),
    .xpos(mouse_x_pos),
    .ypos(mouse_y_pos),
    .hcount(out.hcount),
    .vcount(out.vcount),
    .rgb_in(in.rgb),
    .rgb_out(rgb_nxt),
    .blank(blank),
    .enable_mouse_display_out()
);


endmodule