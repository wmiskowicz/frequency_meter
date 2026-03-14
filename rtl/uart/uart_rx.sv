module uart_rx#(
  parameter int CLK_FREQ = 100_000_000,
  parameter int BAUD_RATE = 115200
)(
  input wire clk,
  input wire rst,
  input wire rx,

  output logic [7:0] data_out,
  output logic read_valid
);

localparam UART_PERIOD_CYCLES = CLK_FREQ / BAUD_RATE;
localparam UART_CTR_WIDTH = $clog2(UART_PERIOD_CYCLES);
localparam CTR_SAMPLE_VAL = UART_PERIOD_CYCLES >> 1;

typedef enum logic [3:0] {
  IDLE,
  START,
  SAMPLE,
  PARITY,
  STOP
} reciever_state_t;

// --- Local variables ---
reciever_state_t rx_state;
logic rx_q, rx_2q;
logic parity_bit_sampled;
logic [UART_CTR_WIDTH-1:0] uart_ctr;
logic [3:0] bit_ctr;
logic [7:0] data_reg;
wire negedge_rx;


always_ff @ (posedge clk) begin
  rx_q <= rx;
  rx_2q <= rx_q;
  data_out <= data_reg;
end

assign negedge_rx = (~rx_q && rx_2q);


always_ff @ (posedge clk) begin
  if (rst) begin
    read_valid <= 1'b0;
    rx_state <= IDLE;
    uart_ctr <= UART_CTR_WIDTH'(0);
    bit_ctr <= 4'd0;
    data_reg <= 8'd0;
  end
  else begin
    case (rx_state)

      IDLE: begin
        if (negedge_rx) begin
          rx_state <= START;
          uart_ctr <= UART_CTR_WIDTH'(0);
          bit_ctr <= 4'd0;
          read_valid <= 1'b0;
        end

      end

      START: begin
        if (uart_ctr == UART_PERIOD_CYCLES) begin
          rx_state <= SAMPLE;
          uart_ctr <= UART_CTR_WIDTH'(0);
          rx_state <= SAMPLE;
        end
        else begin
          uart_ctr <= uart_ctr + 1;
        end
      end

      SAMPLE: begin
        if (uart_ctr == CTR_SAMPLE_VAL) begin
          data_reg[bit_ctr] <= rx_2q;
          uart_ctr <= uart_ctr + 1;
        end
        else if (uart_ctr == UART_PERIOD_CYCLES) begin
          uart_ctr <= 0;
          bit_ctr <= bit_ctr + 4'd1;
          rx_state <= (bit_ctr == 4'd7) ? PARITY : SAMPLE;
        end
        else begin
          uart_ctr <= uart_ctr + 1;
        end
      end

      PARITY: begin
        if (uart_ctr == CTR_SAMPLE_VAL) begin
          parity_bit_sampled <= rx_2q;
          uart_ctr <= uart_ctr + 1;
        end
        else if (uart_ctr == UART_PERIOD_CYCLES) begin
          uart_ctr <= 0;
          rx_state <= STOP;
        end
        else begin
          uart_ctr <= uart_ctr + 1;
        end
      end

      STOP: begin
        read_valid <= (^data_reg == parity_bit_sampled);
        rx_state <= IDLE;
      end

      default:
        rx_state <= IDLE;

    endcase

  end
end



endmodule
