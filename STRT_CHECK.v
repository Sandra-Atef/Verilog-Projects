module STRT_CHECK (
input wire STRT_CHK_EN,
input wire SAMPLED_BIT,
input wire CLK,
input wire RST,
output reg STRT_GLITCH
);

always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   STRT_GLITCH <= 1'b0;
  else
   begin
    if(STRT_CHK_EN)
     begin
      if(SAMPLED_BIT == 1'b0)
       STRT_GLITCH <= 1'b0;
      else
       STRT_GLITCH <= 1'b1;
     end
    else
     STRT_GLITCH <= 1'b0;
   end
 end

endmodule


