module SYS_CTRL (
input  wire        CLK,
input  wire        RST,
input  wire [15:0] ALU_OUT,
input  wire        ALU_OUT_VALID,
input  wire [7:0]  REGFILE_RdData,
input  wire        REGFILE_RdData_Valid,
input  wire [7:0]  RX_P_DATA,
input  wire        RX_D_VLD,
input  wire        FIFO_FULL,

output reg  [3:0]  ALU_FUN,
output reg         ALU_EN,
output reg         ALU_CLK_GATE_EN,
output reg  [3:0]  REGFILE_Address,
output reg         REGFILE_WrEN,
output reg         REGFILE_RdEN,
output reg  [7:0]  REGFILE_WrData,
output reg  [7:0]  FIFO_WR_DATA,
output reg         FIFO_WR_INC,
output reg         clk_div_en
);

// ---------------------------
// State Encoding
// ---------------------------
typedef enum logic [3:0] {
IDEAL           = 4'b0000,
WAIT_WR_ADDR    = 4'b0001,
WAIT_WR_DATA    = 4'b0011,
WAIT_RD_ADDR    = 4'b0110,
OUT_RD_DATA     = 4'b0100,
OPERAND_A       = 4'b1000,
OPERAND_B       = 4'b1001,
ALU_OPERATION   = 4'b1100,
ALU_OUT_STORE   = 4'b1110,
ALU_OUT1        = 4'b1111,
ALU_OUT2        = 4'b1101
} state_e;

// Command bytes
localparam CMD_WRITE  = 8'hAA;
localparam CMD_READ   = 8'hBB;
localparam CMD_ALU_OP = 8'hCC;
localparam CMD_ALU_NO = 8'hDD;

// ---------------------------
// Internal registers
// ---------------------------
state_e current_state, next_state;
reg [7:0] RF_ADDR_REG;
reg [15:0] ALU_OUT_REG;
reg RF_ADDR_SAVE, ALU_OUT_SAVE;

// ---------------------------
// State Transition
// ---------------------------
always @(posedge CLK or negedge RST) begin
  if (!RST)
    current_state <= IDEAL;
  else
    current_state <= next_state;
end

// ---------------------------
// Next State Logic
// ---------------------------
always @(*) begin
  case (current_state)
    IDEAL: begin
      if (RX_D_VLD) begin
        case (RX_P_DATA)
          CMD_WRITE:  next_state = WAIT_WR_ADDR;
          CMD_READ:   next_state = WAIT_RD_ADDR;
          CMD_ALU_OP: next_state = OPERAND_A;
          CMD_ALU_NO: next_state = ALU_OPERATION;
          default:    next_state = IDEAL;
        endcase
      end else next_state = IDEAL;
    end

    WAIT_WR_ADDR: next_state = (RX_D_VLD) ? WAIT_WR_DATA : WAIT_WR_ADDR;
    WAIT_WR_DATA: next_state = (RX_D_VLD) ? IDEAL : WAIT_WR_DATA;

    WAIT_RD_ADDR: next_state = (RX_D_VLD) ? OUT_RD_DATA : WAIT_RD_ADDR;
    OUT_RD_DATA:  next_state = (REGFILE_RdData_Valid) ? IDEAL : OUT_RD_DATA;

    OPERAND_A:    next_state = (RX_D_VLD) ? OPERAND_B : OPERAND_A;
    OPERAND_B:    next_state = (RX_D_VLD) ? ALU_OPERATION : OPERAND_B;

    ALU_OPERATION: next_state = (RX_D_VLD) ? ALU_OUT_STORE : ALU_OPERATION;
    ALU_OUT_STORE: next_state = (ALU_OUT_VALID) ? ALU_OUT1 : ALU_OUT_STORE;
    ALU_OUT1:      next_state = ALU_OUT2;
    ALU_OUT2:      next_state = IDEAL;

    default:       next_state = IDEAL;
  endcase
end

// ---------------------------
// Output Logic
// ---------------------------
always @(*) begin
  // default outputs
  ALU_FUN = 4'b0;
  ALU_EN = 0;
  ALU_CLK_GATE_EN = 0;
  REGFILE_Address = 0;
  REGFILE_WrEN = 0;
  REGFILE_RdEN = 0;
  REGFILE_WrData = 0;
  FIFO_WR_DATA = 0;
  FIFO_WR_INC = 0;
  clk_div_en = 1;
  ALU_OUT_SAVE = 0;
  RF_ADDR_SAVE = 0;

  case (current_state)
    IDEAL: begin
      clk_div_en = 1;
    end

    WAIT_WR_ADDR: begin
      if (RX_D_VLD) RF_ADDR_SAVE = 1;
    end

    WAIT_WR_DATA: begin
      if (RX_D_VLD) begin
        REGFILE_WrEN = 1;
        REGFILE_Address = RF_ADDR_REG[3:0];
        REGFILE_WrData = RX_P_DATA;
      end
    end

    WAIT_RD_ADDR: begin
      if (RX_D_VLD) begin
        REGFILE_RdEN = 1;
        REGFILE_Address = RX_P_DATA[3:0];
      end
    end

    OUT_RD_DATA: begin
      if (REGFILE_RdData_Valid && !FIFO_FULL) begin
        FIFO_WR_DATA = REGFILE_RdData;
        FIFO_WR_INC = 1;
      end
    end

    OPERAND_A: begin
      if (RX_D_VLD) begin
        REGFILE_WrEN = 1;
        REGFILE_Address = 4'd0;
        REGFILE_WrData = RX_P_DATA;
      end
    end

    OPERAND_B: begin
      if (RX_D_VLD) begin
        REGFILE_WrEN = 1;
        REGFILE_Address = 4'd1;
        REGFILE_WrData = RX_P_DATA;
      end
    end

    ALU_OPERATION: begin
      ALU_CLK_GATE_EN = 1;
      if (RX_D_VLD) begin
        ALU_EN = 1;
        ALU_FUN = RX_P_DATA[3:0];
      end
    end

    ALU_OUT_STORE: begin
      ALU_CLK_GATE_EN = 1;
      if (ALU_OUT_VALID)
        ALU_OUT_SAVE = 1;
    end

    ALU_OUT1: begin
      ALU_CLK_GATE_EN = 1;
      if (!FIFO_FULL) begin
        FIFO_WR_DATA = ALU_OUT_REG[7:0];
        FIFO_WR_INC = 1;
      end
    end

    ALU_OUT2: begin
      ALU_CLK_GATE_EN = 1;
      if (!FIFO_FULL) begin
        FIFO_WR_DATA = ALU_OUT_REG[15:8];
        FIFO_WR_INC = 1;
      end
    end
  endcase
end

// ---------------------------
// Register Saves
// ---------------------------
always @(posedge CLK or negedge RST) begin
  if (!RST)
    RF_ADDR_REG <= 8'b0;
  else if (RF_ADDR_SAVE)
    RF_ADDR_REG <= RX_P_DATA;
end

always @(posedge CLK or negedge RST) begin
  if (!RST)
    ALU_OUT_REG <= 16'b0;
  else if (ALU_OUT_SAVE)
    ALU_OUT_REG <= ALU_OUT;
end

endmodule

