module PARITY_CHECK (
input wire PAR_TYP,
input wire PAR_CHK_EN,
input wire SAMPLED_BIT,
input wire CLK,
input wire RST,
output reg PAR_ERR
);

always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   PAR_ERR <= 1'b0;
  else
   begin
    if(PAR_CHK_EN)
     begin
      if(PAR_TYP == SAMPLED_BIT)
       PAR_ERR <= 1'b0;
      else
       PAR_ERR <= 1'b1;
     end
    else
     PAR_ERR <= 1'b0;
   end
 end

endmodule


