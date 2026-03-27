module main_controller#(
  parameter MAIN_CONT_ID
)(
  input wire clk,
  input wire rst,

  input wire enable_toggle,
  
  axi_if.master sseg_axis,
  axi_if.master mem_axis,
  axi_if.slave  counter_axis,
  axi_if.master uart_tx_axis,
  axi_if.master uart_rx_axis
);

import component_id_pkg::*;

typedef enum {
  IDLE,
  SEND_SSEG,
  SEND_UART_TX
} main_state_t;

// ---- Local parameters ----
localparam FRAME_SIZE = 4;


// ---- Local variables ----
axi_if axim();
main_state_t main_state;

logic enable_toggle_q;
logic send_to_uart;

// --- FIFO ---
logic [39:0] fifo_data_in;
logic [39:0] fifo_data_out;
logic fifo_wr_en;
logic fifo_full;
logic fifo_empty;

// --- AXI ---
logic [FRAME_SIZE*8-1:0] rx_data;
logic [31:0] counter_val;
logic send_packet, send_packet_q;
logic counter_data_valid;
logic master_busy;

logic [3:0] uart_packet_ctr;
wire [3:0]  bcd3, bcd2, bcd1, bcd0;



// ---- Signal assignments ----
assign send_to_uart = (enable_toggle && !enable_toggle_q) || (!enable_toggle && enable_toggle_q);
assign master_busy = axim.tvalid;
assign send_packet = !fifo_empty && !master_busy;

// ---- Module logic ----
always_ff @ (posedge clk) begin
  if (rst) begin
    enable_toggle_q <= 1'b0;
    send_packet_q <= 1'b0;
  end
  else begin
    enable_toggle_q <= enable_toggle;
    send_packet_q <= send_packet;
  end
end


always_ff @ (posedge clk) begin
  if (rst) begin
    main_state <= IDLE;
    fifo_wr_en <= 1'b0;
    uart_packet_ctr <= 4'd0;
  end
  else begin
    case(main_state)
      
      IDLE: begin
        if (counter_data_valid) begin
          counter_val <= rx_data;
          main_state <= !enable_toggle ? SEND_UART_TX : SEND_SSEG;
        end
        else begin
          fifo_wr_en <= 1'b0;
        end
        uart_packet_ctr <= 4'd0;
      end

      SEND_SSEG: begin
        if (!fifo_full) begin
          fifo_data_in <= {SSEG_ID, 16'd0, counter_val[15:0]};
          fifo_wr_en <= 1'b1;
          main_state <= IDLE;
        end        
      end
      
      SEND_UART_TX: begin
        if (!fifo_full) begin
          case(uart_packet_ctr)
            4'd0: fifo_data_in <= {UART_TX_ID, "CTR "};
            4'd1: fifo_data_in <= {UART_TX_ID, "VAL "};
            4'd2: fifo_data_in <= {UART_TX_ID, 8'(bcd3 + 8'h30), 8'(bcd2 + 8'h30), 8'(bcd1 + 8'h30), 8'(bcd0 + 8'h30)};
            4'd3: fifo_data_in <= {UART_TX_ID, "  ", 8'hD, 8'hA};
            default: fifo_data_in <= {UART_TX_ID, "ERR "};
          endcase
          uart_packet_ctr <= uart_packet_ctr + 4'd1;
          fifo_wr_en <= 1'b1;
          main_state <= uart_packet_ctr == 4'd3 ? SEND_SSEG : SEND_UART_TX;
        end  
      end
      
      default: main_state <= IDLE;
    endcase 
  end
end



axi_stream_dmux u_axi_stream_dmux (
  .clk         (clk),
  .rst_n       (!rst),

  .m_axis      (axim),

  .mem_axis    (mem_axis),
  .sseg_axis   (sseg_axis),
  .uart_rx_axis(uart_rx_axis),
  .uart_tx_axis(uart_tx_axis)
);


axi_stream_master #(
  .FRAME_SIZE(4)
)
u_axi_stream_master (
  .clk        (clk),
  .rst_n      (!rst),
  .data_in    (fifo_data_out[31:0]),
  .id         (fifo_data_out[39:32]),
  .send_packet(send_packet),
  .axi        (axim)
);

fifo_generator_2 master_fifo (
  .clk(clk),   
  .srst(rst),  
  .din(fifo_data_in),   
  .wr_en(fifo_wr_en), 
  .rd_en(send_packet), 
  .dout(fifo_data_out),
  .full(fifo_full),
  .empty(fifo_empty)
);


axi_stream_slave #(
  .FRAME_SIZE(4)
)
u_axi_stream_slave (
  .clk         (clk),
  .rst_n       (!rst),

  .data_valid  (counter_data_valid),
  .module_ready(1'b1),
  .rx_data     (rx_data),
  .select      (),

  .axi         (counter_axis)
);

function [7:0] hex_to_ascii(input [3:0] nibble);
    hex_to_ascii = (nibble < 10) ? (nibble + 8'h30) : (nibble + 8'h37);
endfunction

bin2bcd u_bin2bcd (
    .bcd0(bcd0), 
    .bcd1(bcd1), 
    .bcd2(bcd2), 
    .bcd3(bcd3), 
    .bin (counter_val) 
);

endmodule
