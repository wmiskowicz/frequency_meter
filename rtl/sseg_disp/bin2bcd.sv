module bin2bcd (
   input logic [31:0] bin,  
   
   output logic [3:0] bcd3, 
   output logic [3:0] bcd2, 
   output logic [3:0] bcd1, 
   output logic [3:0] bcd0  
);

   logic [31:0] binary;
   logic [3:0] thousands, hundreds, tens, ones;

   always_comb begin
       binary = bin;
       thousands = 4'd0;
       hundreds = 4'd0;
       tens = 4'd0;
       ones = 4'd0;

       for (int i = 31; i >= 0; i--) begin
           if (thousands >= 5)
               thousands = thousands + 3;
           if (hundreds >= 5)
               hundreds = hundreds + 3;
           if (tens >= 5)
               tens = tens + 3;
           if (ones >= 5)
               ones = ones + 3;

           thousands = thousands << 1;
           thousands[0] = hundreds[3];
           hundreds = hundreds << 1;
           hundreds[0] = tens[3];
           tens = tens << 1;
           tens[0] = ones[3];
           ones = ones << 1;
           ones[0] = binary[i];
       end
   end

   assign bcd3 = thousands;
   assign bcd2 = hundreds;
   assign bcd1 = tens;
   assign bcd0 = ones;

endmodule
