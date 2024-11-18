module axi_stream_master#(
  parameter int FRAME_SIZE = 4
)( 
  input  logic              clk, 
  input  logic              rst_n, 
   
  input  logic    [15:0]    data_in,
  input  logic              send_packet, 

  axi_if.master             axi
); 

typedef enum {IDLE, PAYLOAD} state_t;

localparam ID_SSEG = 8'h7F;

state_t state;
logic [7:0] data_buffer [FRAME_SIZE : 0];
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
          data_buffer[0] <= ID_SSEG; 
          data_buffer[1] <= data_in[7:0]; 
          data_buffer[2] <= data_in[15:8]; 
          data_buffer[3] <= '0;
          data_buffer[4] <= '0;
        end
        else
        begin
          state <= IDLE;
        end
        i <= 0;
      end
      PAYLOAD:
      begin
        if(i < FRAME_SIZE+1)
        begin
          axi.tdata <= data_buffer[i];
          i <= axi.tready ? i + 1 : i;

          axi.tvalid <= 1'b1;
          axi.tlast <= (i == FRAME_SIZE);
        end
        
        if(axi.tlast) 
        begin
          axi.tvalid <= 1'b0;
          axi.tlast  <= 1'b0;
          i <= 0;
          state <= IDLE;
        end
      end
      default: state <= IDLE;
    endcase
  end
end


endmodule 
