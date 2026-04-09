module EDGE_BIT_COUNTER (
 input wire [5:0] prescalar,
 input wire ENABLE,
 input wire CLK,
 input wire RST,
 output reg [3:0] BIT_CNT,
 output reg [4:0] EDGE_CNT
);


always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   EDGE_CNT <= 'b0;
  else 
   begin
    if(ENABLE)
     begin
      if(EDGE_CNT == prescalar-1)
       EDGE_CNT <= 'b0;
      else
       EDGE_CNT <= EDGE_CNT + 'b1;
     end
    else
     EDGE_CNT <= 'b0;
   end
 end

always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   BIT_CNT <= 'b0;
  else
   begin
    if(ENABLE)
     begin
      if(EDGE_CNT == prescalar-1)
       BIT_CNT <= BIT_CNT + 'b1;
     end
    else
     BIT_CNT <= 'b0;
   end
 end
 
endmodule
