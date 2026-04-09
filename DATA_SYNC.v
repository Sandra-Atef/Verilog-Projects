module DATA_SYNC #(parameter BUS_WIDTH = 8)(
input    wire                      CLK,
input    wire                      RST,
input    wire    [BUS_WIDTH-1:0]   unsync_bus,
input    wire                      bus_enable,
output   reg                       enable_pulse,
output   reg     [BUS_WIDTH-1:0]   sync_bus
);

reg meta_flop, sync_flop, enable_flop;
wire enable_pulse_c;
wire [BUS_WIDTH-1:0] sync_bus_c;

always@(posedge CLK or negedge RST)
 begin
  if(!RST)
   begin 
    meta_flop <= 1'b0;
    sync_flop <= 1'b0;
   end
  else
   begin
    meta_flop <= bus_enable;
    sync_flop <= meta_flop;
   end
 end

always@(posedge CLK or negedge RST)
 begin
  if(!RST)
   begin 
    enable_flop <= 1'b0;
   end
  else
   begin
    enable_flop <= sync_flop;
   end
 end

assign enable_pulse_c = sync_flop && !enable_flop;
assign sync_bus_c = enable_pulse_c ? unsync_bus : sync_bus;

always@(posedge CLK or negedge RST)
 begin
  if(!RST)
   begin 
    enable_pulse <= 1'b0;
   end
  else
   begin 
    enable_pulse <= enable_pulse_c;
   end
 end

always@(posedge CLK or negedge RST)
 begin
  if(!RST)
   begin 
     sync_bus <= 1'b0;
   end
  else
   begin 
     sync_bus <=  sync_bus_c;
   end
 end

endmodule
