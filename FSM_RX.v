module FSM_RX (
 input wire [5:0] prescalar,
 input wire RX_IN,
 input wire PAR_EN,
 input wire [3:0] BIT_CNT,
 input wire [4:0] EDGE_CNT,
 input wire PAR_ERR,
 input wire STP_ERR,
 input wire STRT_GLITCH,
 input wire CLK,
 input wire RST,
 output reg DAT_SAMP_EN,
 output reg EDGE_BIT_CNT_EN,
 output reg DESER_EN,
 output reg DATA_VALID,
 output reg PAR_CHK_EN,
 output reg STRT_CHK_EN,
 output reg STP_CHK_EN
);


// state encoding

localparam IDEL = 3'b000;
localparam START = 3'b001;
localparam DATA = 3'b011;
localparam PARITY = 3'b010;
localparam STOP = 3'b110;
localparam DATA_CHK = 3'b111;


reg [2:0] current_state, next_state;

//transition state
always @ (posedge CLK or negedge RST)
 begin
 if(!RST)
  current_state <= IDEL;
 else
  current_state <= next_state;
 end

 // output block
 always @ (*)
 begin
  //default values
  DAT_SAMP_EN = 1'b0;
  EDGE_BIT_CNT_EN = 1'b0;
  DESER_EN = 1'b0;
  PAR_CHK_EN = 1'b0;
  STRT_CHK_EN = 1'b0;
  STP_CHK_EN = 1'b0;
  DATA_VALID = 1'b0;
  
  case (current_state)
   IDEL : begin
           DAT_SAMP_EN = 1'b0;
           EDGE_BIT_CNT_EN = 1'b0;
           DESER_EN = 1'b0;
           PAR_CHK_EN = 1'b0;
           STRT_CHK_EN = 1'b0;
           STP_CHK_EN = 1'b0;
           DATA_VALID = 1'b0;
          end

   START : begin
            DAT_SAMP_EN = 1'b1;
            EDGE_BIT_CNT_EN = 1'b1;
            if(EDGE_CNT == prescalar-1)
              STRT_CHK_EN = 1'b1;
            else
              STRT_CHK_EN = 1'b0;
           end

   DATA : begin
           DAT_SAMP_EN = 1'b1;
           EDGE_BIT_CNT_EN = 1'b1;
           DESER_EN = (EDGE_CNT == prescalar - 1); //kant bwa7ed bt5li elstart hia eli td5ol
          end

   PARITY : begin
             DAT_SAMP_EN = 1'b1;
             EDGE_BIT_CNT_EN = 1'b1;
             if(EDGE_CNT == prescalar)
               PAR_CHK_EN = 1'b1;
             else
               PAR_CHK_EN = 1'b0;
            end

    STOP : begin
            DAT_SAMP_EN = 1'b1;
            EDGE_BIT_CNT_EN = 1'b1;
            if(EDGE_CNT == prescalar-2)
              STP_CHK_EN = 1'b1;
            else
              STP_CHK_EN = 1'b0;
            end

    DATA_CHK: begin
               
               if(EDGE_CNT == prescalar-1)
                begin
                 if(!PAR_ERR && !STP_ERR)
                  DATA_VALID = 1'b1;
                 else
                  DATA_VALID = 1'b0;
                end
               else
                DATA_VALID = 1'b0;
              end


    default: begin
              DAT_SAMP_EN = 1'b0;
              EDGE_BIT_CNT_EN = 1'b0;
              DESER_EN = 1'b0;
              PAR_CHK_EN = 1'b0;
              STRT_CHK_EN = 1'b0;
              STP_CHK_EN = 1'b0;
              DATA_VALID = 1'b0;
             end
   endcase
 end


 always @ (*)
 begin
  case(current_state)
   IDEL: begin
          if(!RX_IN)    
           next_state = START;
          else
           next_state = IDEL; 
         end

   START: begin
           if (EDGE_CNT == prescalar-1)
            begin
             if(STRT_GLITCH)
              next_state = IDEL;
             else 
              next_state = DATA;
            end
           else
            next_state = START;
          end

   DATA: begin
            if ((EDGE_CNT == prescalar-1) && (BIT_CNT == 4'b1000)) 
             begin
              case(PAR_EN)
               1'b0: next_state = STOP;
               1'b1: next_state = PARITY;
              endcase
             end
            else
             next_state = DATA;
         end

   PARITY: begin
            if (EDGE_CNT == prescalar-1)
             begin
              if(PAR_ERR)
               next_state = IDEL;
              else
               next_state = STOP;
             end
            else
             next_state = PARITY;
           end

   STOP:   begin
            if (EDGE_CNT == prescalar-2)
             begin
              if(STP_ERR)
               next_state = IDEL;
              else
               next_state = DATA_CHK;
             end
            else
             next_state = STOP;
           end

   DATA_CHK: begin
              if (!RX_IN)
               next_state = START;
              else
               next_state = IDEL;
             end

   default: begin
             next_state = IDEL;
            end
  endcase  
 end
endmodule
