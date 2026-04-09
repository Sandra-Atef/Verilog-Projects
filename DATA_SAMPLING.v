module DATA_SAMPLING (
input wire [5:0] prescalar,
input wire RX_IN,
input wire DAT_SAMP_EN,
input wire [4:0] EDGE_CNT,
input wire CLK,
input wire RST,
output reg SAMPLED_BIT
);
 
 wire [5:0] middle = (prescalar>>1)-1;
 wire [5:0] before = middle - 1;
 wire [5:0] after = middle + 1;
 
 reg val_middle, val_before, val_after;
  

always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    SAMPLED_BIT <= 1'b1;
    val_before  <= 1'b1;
    val_middle  <= 1'b1;
    val_after   <= 1'b1;
   end
  else
   begin
    if (DAT_SAMP_EN)
     begin
      if(EDGE_CNT == before)
       val_before <= RX_IN;
      else if(EDGE_CNT == middle)
       val_middle <= RX_IN;
      else if(EDGE_CNT == after)
       val_after <= RX_IN;
      else if(EDGE_CNT == after+1)
       begin
        SAMPLED_BIT <= (val_before + val_middle + val_after >= 2);
       end
     end
   end
 end

 endmodule
