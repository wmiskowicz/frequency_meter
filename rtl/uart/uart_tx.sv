module uart_tx#(
  parameter int CLK_FREQ = 100_000_000,
  parameter int BAUD_RATE = 115200
)(
  input wire clk,
  input wire rst,
  input wire start_tx,
  input wire [7:0] tx_data,

  output logic tx
);

localparam UART_PERIOD_CYCLES = CLK_FREQ / BAUD_RATE;
localparam UART_CTR_WIDTH = $clog2(UART_PERIOD_CYCLES);

typedef enum bit [4:0] {
  IDLE,
  START,
  SEND,
  PARITY,
  STOP
} tx_state_t;

tx_state_t tx_state;

logic [7:0] tx_data_q;
logic [4:0] bit_ind;
logic tx_q;
logic [UART_CTR_WIDTH-1:0] uart_ctr;

always_ff @ (posedge clk) begin
  tx <= tx_q;
end


always_ff @ (posedge clk) begin
  if (rst) begin
    uart_ctr <= UART_CTR_WIDTH'(0);
    tx_state <= IDLE;
    bit_ind <= 4'd0;
    tx_q <= 1'b1;
  end
  else begin
    case (tx_state)

      IDLE: begin
        if (start_tx) begin
          tx_data_q <= tx_data;
          tx_state <= START;
          uart_ctr <= UART_CTR_WIDTH'(0);
        end
        bit_ind <= 4'd0;
        tx_q <= 1'b1;
      end

      START: begin
        if (uart_ctr == UART_PERIOD_CYCLES) begin
          tx_state <= SEND;
          uart_ctr <= UART_CTR_WIDTH'(0);
        end
        else begin
          uart_ctr <= uart_ctr + UART_CTR_WIDTH'(1);
        end

        tx_q <= 1'b0;
      end

      SEND: begin
        if (uart_ctr == UART_PERIOD_CYCLES) begin
          tx_state <= (bit_ind == 4'd7) ? PARITY : SEND;
          bit_ind <= bit_ind + 4'd1;
          uart_ctr <= UART_CTR_WIDTH'(0);
        end
        else begin
          uart_ctr <= uart_ctr + UART_CTR_WIDTH'(1);
        end

        tx_q <= tx_data_q[bit_ind];
      end

      PARITY: begin
        if (uart_ctr == UART_PERIOD_CYCLES) begin
          tx_state <= STOP;
          uart_ctr <= UART_CTR_WIDTH'(0);
        end
        else begin
          uart_ctr <= uart_ctr + UART_CTR_WIDTH'(1);
        end

        tx_q <= ^tx_data_q;
      end

      STOP: begin
        if (uart_ctr == UART_PERIOD_CYCLES) begin
          tx_state <= IDLE;
          uart_ctr <= UART_CTR_WIDTH'(0);
        end
        else begin
          uart_ctr <= uart_ctr + UART_CTR_WIDTH'(1);
        end

        tx_q <= 1'b1;
      end

      default:
        tx_state <= IDLE;

    endcase


  end
end



endmodule
