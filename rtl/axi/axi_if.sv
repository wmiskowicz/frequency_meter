interface axi_if;

  logic [7:0] tdata;
  logic       tvalid;
  logic       tlast;
  logic       tready;

  modport master (
      output tdata,
      output tvalid,
      output tlast,
      input  tready
  );

  modport slave (
      input  tdata,
      input  tvalid,
      input  tlast,
      output tready
  );

endinterface : axi_if
