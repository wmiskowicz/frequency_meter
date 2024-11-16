module data_mem #(
  parameter int ADDR_WIDTH = 4,  
  parameter int DATA_WIDTH = 16,
  parameter int MEM_SIZE   = 30 
)(
  // clocks and resets 
  input  logic                      clk, 
  input  logic                      rst
);

logic [MEM_SIZE-1:0][DATA_WIDTH-1:0] data_mem;
logic [DATA_WIDTH-1:0]     wr_data;  
logic [ADDR_WIDTH-1:0]     wr_addr;  
logic                      wr_enabl; 

logic [DATA_WIDTH-1:0]     rd_data;
logic [ADDR_WIDTH-1:0]     rd_addr;
logic                      rd_enabl;

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
      if (wr_enabl) data_mem[wr_addr] <= wr_data;
      // READ
      if (rd_enabl) rd_data   <= data_mem[rd_addr];
    end
end

endmodule