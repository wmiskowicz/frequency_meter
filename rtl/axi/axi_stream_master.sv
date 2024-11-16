module axi_stream_master( 
  input  logic              clk, 
  input  logic              rst_n, 
   
  input  logic    [31:0]    data_in,
  input  logic              send_packet, 

  axi_if.master             axi
); 

typedef enum {IDLE, PAYLOAD} state_t;



state_t state;
logic [7:0] data_buffer [3:0];
int i;

always_ff @(posedge clk) begin : tx_fsm
  if (!rst_n) begin
    state <= IDLE;
    axi.tdata  <= '0;
    axi.tlast  <= '0;
    axi.tvalid <= '0;
    for(int i=0; i < 4; i++) data_buffer[i] <= '0;
  end 
  else
  begin
    case (state)
      IDLE: 
      begin
        if(send_packet)
        begin
          state <= PAYLOAD;
          data_buffer[0] <= data_in[31:24];
          data_buffer[1] <= data_in[23:16];
          data_buffer[2] <= data_in[15:8];
          data_buffer[3] <= data_in[7:0];
        end
        else
        begin
          state <= IDLE;
        end
      end
      PAYLOAD:
      begin
        if(i < 4)
        begin
          axi.tdata <= data_buffer[i];
          i <= axi.tready ? i + 1 : i;

          axi.tvalid <= 1'b1;
          axi.tlast <= (i == 3);
        end
        else 
        begin
          axi.tvalid <= 1'b0;
          axi.tlast  <= 1'b0;
          i <= 0;
          state <= IDLE;
        end
      end
      default: begin end
    endcase
  end
end


endmodule 
