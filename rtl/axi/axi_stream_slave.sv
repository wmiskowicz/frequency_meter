module axi_stream_slave#(
    parameter int PCK_SIZE = 4,
    parameter ID_VALID = 8'h7F
  )(
    input  logic        clk,
    input  logic        rst_n,
    output logic [31:0] rx_data, 

    axi_if.slave        axi
  );

  typedef enum {IDLE, ID, PAYLOAD, WAIT} state_t;


  state_t state;
  logic [7:0] data_buffer [3:0];
  logic [7:0] id_buffer;
  int i;

  assign axi.tready = 1'b1;

  always_ff @(posedge clk)
  begin : rx_fsm
    if (!rst_n)
    begin
      state      <= IDLE;
      for(int i=0; i < PCK_SIZE; i++) data_buffer[i] <= '0;
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
        end
        ID:
        begin
          if(id_buffer == ID_VALID)
          begin
            state <= PAYLOAD;
            data_buffer[i] <= axi.tdata;
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
          if (axi.tlast) rx_data <= {data_buffer[3], data_buffer[2], data_buffer[1], data_buffer[0]};
          i <= i + 1;
        end
        WAIT : state <= (axi.tlast) ? IDLE : WAIT;
        default: state <= IDLE;
      endcase
    end
  end


endmodule
