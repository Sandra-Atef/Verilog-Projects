module RST_SYNC #(parameter NUM_OF_STAGES = 2)
(
 input wire CLK,
 input wire RST,
 output reg SYNC_RST
);

 reg [NUM_OF_STAGES-1:0] SYNC_REG ;


always @ (posedge CLK or negedge RST)
 begin 
  if(!RST)      // active low
   begin
    SYNC_REG <= 'b0 ;
   end
  else
   begin
    SYNC_REG <= {SYNC_REG[NUM_OF_STAGES-2:0],1'b1};
   end
 end

always @ (*)
 begin 
  SYNC_RST <= SYNC_REG[NUM_OF_STAGES-1];
 end

endmodule
