//////////////////////////////////////////////////////////////////////////////
/*
 Module name:   top_mouse
 Author:        Wojciech Miskowicz
 Last modified: 2023-06-25
 Description:  Top module for mouse signals
 */
//////////////////////////////////////////////////////////////////////////////

 `timescale 1 ns / 1 ps

 module top_mouse (
     input  wire         clk,
     input  wire         rst,
     
     inout               ps2_clk,
     inout               ps2_data,

     output logic [11:0] xpos,
     output logic        right,
     output logic        left
 );


 MouseCtl u_MouseCtl(
    .clk(clk),
    .rst,
    .xpos(xpos),
    .ypos(),
    .ps2_clk,
    .ps2_data,
    .zpos(),
    .left(left),
    .middle(),
    .right(right),
    .new_event(),
    .value(),
    .setx(),
    .sety(),
    .setmax_x('0),
    .setmax_y('0)
 );

 endmodule