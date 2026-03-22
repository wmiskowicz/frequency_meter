`timescale 1ns / 1ps
import component_id_pkg::*;

module axi_stream_dmux (
  input  logic        clk,
  input  logic        rst_n,

  // Interface from Master
  axi_if.slave        m_axis,

  // Interfaces to Slaves
  axi_if.master       sseg_axis,
  axi_if.master       mem_axis,
  axi_if.master       uart_tx_axis,
  axi_if.master       uart_rx_axis
);

typedef enum logic [1:0] { ROUTE_IDLE, ROUTE_ACTIVE } route_state_t;
route_state_t state;
logic [7:0] active_id;

// --- Routing Logic ---
assign sseg_axis.tvalid    = (m_axis.tvalid && active_id == SSEG_ID);
assign mem_axis.tvalid     = (m_axis.tvalid && active_id == MEMORY_ID);
assign uart_tx_axis.tvalid = (m_axis.tvalid && active_id == UART_TX_ID);
assign uart_rx_axis.tvalid = (m_axis.tvalid && active_id == UART_RX_ID);

assign {sseg_axis.tdata, mem_axis.tdata, uart_tx_axis.tdata, uart_rx_axis.tdata} = {4{m_axis.tdata}};
assign {sseg_axis.tlast, mem_axis.tlast, uart_tx_axis.tlast, uart_rx_axis.tlast} = {4{m_axis.tlast}};

// --- TREADY Multiplexer (The fix for your error) ---
always_comb begin
  case (active_id)
    SSEG_ID:    m_axis.tready = sseg_axis.tready;
    MEMORY_ID:  m_axis.tready = mem_axis.tready;
    UART_TX_ID: m_axis.tready = uart_tx_axis.tready;
    UART_RX_ID: m_axis.tready = uart_rx_axis.tready;
    default:    m_axis.tready = 1'b1;
  endcase
end

// --- ID Latching FSM ---
always_ff @(posedge clk) begin
  if (!rst_n) begin
    state <= ROUTE_IDLE;
    active_id <= 8'h00;
  end 
  else begin
    case (state)
      ROUTE_IDLE: begin
        if (m_axis.tvalid) begin
          active_id <= m_axis.tdata;
          state <= ROUTE_ACTIVE;
        end
      end

      ROUTE_ACTIVE: begin
        if (m_axis.tvalid && m_axis.tready && m_axis.tlast) begin
          state <= ROUTE_IDLE;
          active_id <= 8'h00;
        end
      end

    endcase
  end
end

endmodule