module axi_stream_slave#(
    parameter int FRAME_SIZE = 4,
    parameter ID_VALID = 8'h7F
  )(
    input  logic        clk,
    input  logic        rst_n,
    input  logic        module_ready,
    output logic [(FRAME_SIZE*8)-1:0] rx_data, 
    output logic        select,
    output logic        data_valid,

    axi_if.slave        axi
  );

  typedef enum {IDLE, ID, PAYLOAD, RESULT, WAIT} state_t;


  state_t state;
  logic [FRAME_SIZE-1:0][7:0] data_buffer;
  int i;

  assign axi.tready = module_ready;

  always_ff @(posedge clk)
  begin : rx_fsm
    if (!rst_n)
    begin
      state       <= IDLE;
      data_buffer <= '0;
      select      <= '0;
      data_valid  <= 1'b0;
      rx_data     <= FRAME_SIZE'(0);
    end
    else
    begin
      case (state)

        IDLE:
        begin
          if(axi.tvalid)
          begin
            state <= PAYLOAD;
            select <= 1'b1;
            data_buffer[FRAME_SIZE-1] <= axi.tdata;
          end
          else
          begin
            state <= IDLE;
          end
          i <= FRAME_SIZE-2;
          data_valid <= 1'b0;
        end

        PAYLOAD:
        begin
          data_buffer[i] <= axi.tdata;
          state <= (axi.tlast) ? RESULT : PAYLOAD;
          select <= !(axi.tlast);
          i <= i > 0 ? i - 1 : 0;
        end

        RESULT:
        begin 
          rx_data <= data_buffer;
          data_valid <= 1'b1;
          state <= IDLE;
          select <= 1'b0;
          i <= FRAME_SIZE-1;
        end

        WAIT : state <= (axi.tlast) ? IDLE : WAIT;
        default: state <= IDLE;
      endcase
    end
  end


endmodule
