module REG_FILE #(parameter WIDTH = 8, DEPTH = 16, ADDR = 4)
(
input  wire                        CLK,
input  wire                        RST,
input  wire     [ADDR-1:0]         Address,
input  wire                        Wr_En,
input  wire                        Rd_En,
input  wire     [WIDTH-1:0]        Wr_Data,
output reg      [WIDTH-1:0]        Rd_Data,
output reg                         Rd_Data_Valid,
output wire     [WIDTH-1:0]        REG0,
output wire     [WIDTH-1:0]        REG1,
output wire     [WIDTH-1:0]        REG2,
output wire     [WIDTH-1:0]        REG3
);
 
 integer I;
//2D_array
 reg [WIDTH-1:0] Reg_File [DEPTH-1:0]; 

always @ (posedge CLK or negedge RST)
 begin
  if(!RST)
   begin
    Rd_Data <= 'b0;
	Rd_Data_Valid <= 'b0;
    for(I=0 ; I < DEPTH ;I = I+1)
	 begin 
	  if(I==2)
	   Reg_File [I] <= 'b100000_01;
	  else if(I==3)
	   Reg_File [I] <= 'b0010_0000;
	  else
	   Reg_File [I] <= 'b0;
	 end
   end
  else if(Wr_En && !Rd_En)
   begin
    Reg_File[Address] <= Wr_Data;
   end
  else if(!Wr_En && Rd_En)
   begin
    Rd_Data <= Reg_File[Address];
    Rd_Data_Valid <= 'b1;
   end
  else
   begin
    Rd_Data_Valid <= 'b0;
   end
 end
 
 assign REG0 = Reg_File[0];
 assign REG1 = Reg_File[1];
 assign REG2 = Reg_File[2];
 assign REG3 = Reg_File[3];
 
endmodule



