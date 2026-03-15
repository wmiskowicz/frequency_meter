module axi_stream_slave#(
    parameter int FRAME_SIZE = 4,
    parameter ID_VALID = 8'h7F
  )(
    input  logic        clk,
    input  logic        rst_n,
    output logic [(FRAME_SIZE*8)-1:0] rx_data, 
    output logic        select,
    output logic        data_valid,

    axi_if.slave        axi
  );

  typedef enum {IDLE, ID, PAYLOAD, RESULT, WAIT} state_t;


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
      data_valid  <= 1'b0;
    end
    else
    begin
      case (state)

        IDLE:
        begin
          if(axi.tvalid)
          begin
            state <= (axi.tdata == ID_VALID) ? PAYLOAD : IDLE;
            select <= (axi.tdata == ID_VALID);
          end
          else
          begin
            state <= IDLE;
          end
          i <= 0;
          data_valid <= 1'b0;
        end

        PAYLOAD:
        begin
          data_buffer[i] <= axi.tdata;
          state <= (axi.tlast) ? RESULT : PAYLOAD;
          select <= !(axi.tlast);
          i <= i + 1;
        end

        RESULT:
        begin 
          rx_data <= data_buffer;
          data_valid <= 1'b1;
          state <= IDLE;
          select <= 1'b0;
        end

        WAIT : state <= (axi.tlast) ? IDLE : WAIT;
        default: state <= IDLE;
      endcase
    end
  end


endmodule
