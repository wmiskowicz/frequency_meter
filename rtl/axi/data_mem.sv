module data_mem #(
  parameter COMPONENT_ID = 8'h7A
)(
  // clocks and resets 
  input  logic  clk, 
  input  logic  rst,

  axi_if.slave     axi
);

localparam int ADDR_WIDTH = 4;  
localparam int DATA_WIDTH = 16;
localparam int MEM_SIZE   = 30;

logic [MEM_SIZE-1:0][DATA_WIDTH-1:0] data_mem;
logic [DATA_WIDTH-1:0]     wr_data;  
logic [ADDR_WIDTH-1:0]     wr_addr;  
logic                      wr_enabl; 

logic [DATA_WIDTH-1:0]     rd_data;
logic [ADDR_WIDTH-1:0]     rd_addr;
logic                      rd_enabl;

logic [31:0] data;
logic select;



assign wr_enabl = select && axi.tlast;

axi_stream_slave #(
  .FRAME_SIZE(4),
  .ID_VALID(COMPONENT_ID)
)
u_axi_stream_slave (
  .clk  (clk),
  .rst_n(!rst),
  .rx_data(data),
  .select(select),
  .axi  (axi)
);

always_ff @(clk) 
begin : addr_blk
  if(rst)
  begin
    wr_addr <= '0;
  end
  else if(wr_enabl)
  begin
    wr_addr <= (wr_addr + 1) % MEM_SIZE;
  end
end


always_ff @(posedge clk)
  begin : DATA_MEM_BLK
    if(rst)
    begin
      data_mem  <= '0;
      rd_data   <= '0;
    end
    else
    begin
      // WRITE
      if (wr_enabl) data_mem[wr_addr] <= data[15:0];
      // READ
      if (rd_enabl) rd_data   <= data_mem[rd_addr];
    end
end

endmodule