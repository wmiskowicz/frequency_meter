module axi_stream_slave#(
    parameter int FRAME_SIZE = 4,
    parameter ID_VALID = 8'h7F
  )(
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] rx_data, 
    output logic        select,

    axi_if.slave        axi
  );

  typedef enum {IDLE, ID, PAYLOAD, WAIT} state_t;


  state_t state;
  logic [FRAME_SIZE-1:0][7:0] data_buffer;
  logic [7:0] id_buffer;
  int i;

  assign axi.tready = 1'b1;

  always_ff @(posedge clk)
  begin : rx_fsm
    if (!rst_n)
    begin
      state       <= IDLE;
      data_buffer <= '0;
      select      <= '0;
    end
    else
    begin
      case (state)
        IDLE:
        begin
          if(axi.tvalid)
          begin
            state <= ID;
            id_buffer <= axi.tdata;
          end
          else
          begin
            state <= IDLE;
          end
          i <= 0;
          select <= '0;
        end
        ID:
        begin
          if(id_buffer == ID_VALID)
          begin
            state <= PAYLOAD;
            data_buffer[0] <= axi.tdata;
            select <= '1;
            i <= 1;
          end
          else
          begin
            state <= WAIT;
          end
        end
        PAYLOAD:
        begin
          data_buffer[i] <= axi.tdata;
          state <= (axi.tlast) ? IDLE : PAYLOAD;
          if (axi.tlast) rx_data <= data_buffer;
          i <= i + 1;
        end
        WAIT : state <= (axi.tlast) ? IDLE : WAIT;
        default: state <= IDLE;
      endcase
    end
  end


endmodule
