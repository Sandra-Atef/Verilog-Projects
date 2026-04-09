module DESERIALIZER (
input wire SAMPLED_BIT,
input wire DESER_EN,
input wire DATA_VALID,
input wire CLK,
input wire RST,
output wire [7:0] P_DATA
);

reg [7:0] shift_reg;
assign P_DATA = (DATA_VALID)? shift_reg : 8'b0;

always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    shift_reg <= 'b0;
   end
  else
   begin
    if(DESER_EN)
     begin
      //shift_reg [7] <= SAMPLED_BIT;
      //shift_reg <= shift_reg >> 1;
      shift_reg <= {SAMPLED_BIT, shift_reg[7:1]};
     end
   end
 end
endmodule