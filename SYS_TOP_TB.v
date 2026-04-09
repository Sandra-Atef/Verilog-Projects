`timescale 1ns/1ps

module SYS_TOP_TB;

  // Parameters
  parameter DATA_WIDTH       = 8;
  parameter RF_ADDR          = 4;
  parameter REF_CLK_PERIOD   = 20;
  parameter UART_CLK_PERIOD  = 271;     
  parameter BIT_PERIOD       = 32*UART_CLK_PERIOD; // one UART bit time = 8672 ns 

  // TB internal signals
  reg                   RST_N_tb;
  reg                   UART_CLK_tb;
  reg                   REF_CLK_tb;
  reg                   UART_RX_IN_tb;
  wire                  UART_TX_O_tb;
  wire                  parity_error_tb;
  wire                  framing_error_tb;

  // Instantiate DUT 
  SYS_TOP #(
      .DATA_WIDTH(DATA_WIDTH),
      .RF_ADDR   (RF_ADDR)
  ) DUT (
      .RST_N        (RST_N_tb),
      .UART_CLK     (UART_CLK_tb),
      .REF_CLK      (REF_CLK_tb),
      .UART_RX_IN   (UART_RX_IN_tb),
      .UART_TX_O    (UART_TX_O_tb),
      .parity_error (parity_error_tb),
      .framing_error(framing_error_tb)
  );

  // Clock Generation
  always #(UART_CLK_PERIOD/2) UART_CLK_tb = ~UART_CLK_tb;
  always #(REF_CLK_PERIOD/2)  REF_CLK_tb  = ~REF_CLK_tb;

  // Initialization
  task initialize;
    begin
      UART_CLK_tb   = 0;
      REF_CLK_tb    = 0;
      UART_RX_IN_tb = 1;
      RST_N_tb      = 0;
    end
  endtask

  // Reset
  initial begin
    initialize();
    $display("[INFO] Applying reset @ %0t", $time);
    #1000;
    RST_N_tb = 1;
    $display("[INFO] Reset deasserted @ %0t", $time);
  end

  // ---------------- UART WRITE TASK ----------------
  task UART_WRITE_BYTE;
    input [7:0] data;
    integer i;
    begin
      UART_RX_IN_tb = 1;
      #(BIT_PERIOD*2);

      // Start bit
      UART_RX_IN_tb = 0;
      #(BIT_PERIOD);

      // Data bits
      for (i = 0; i < 8; i = i+1) begin
        #(BIT_PERIOD/4);
        UART_RX_IN_tb = data[i];
        #(3*BIT_PERIOD/4);
      end

      // Stop bit
      UART_RX_IN_tb = 1;
      #(BIT_PERIOD*2);

      $display("[TX] Sent: 0x%0h @ %0t", data, $time);
    end
  endtask

  // ---------------- TX Monitor Task ----------------
  task MONITOR_TX_BYTE;
    integer i;
    reg [7:0] rx_shift;
    begin
      @(negedge UART_TX_O_tb);
      #(BIT_PERIOD + BIT_PERIOD/2);

      for (i = 0; i < 8; i = i+1) begin
        rx_shift[i] = UART_TX_O_tb;
        #(BIT_PERIOD);
      end

      #(BIT_PERIOD/2);
      $display("[RX] Captured: 0x%0h @ %0t", rx_shift, $time);
    end
  endtask

  // Continuous TX monitor
  initial begin
    forever begin
      MONITOR_TX_BYTE();
    end
  end

  // ---------------- Stimulus ----------------
  initial begin
    @(posedge RST_N_tb);
    #10000;

    $display("[TEST] Case 1: RegFile Write");
    UART_WRITE_BYTE(8'hAA);
    UART_WRITE_BYTE(8'h05);
    UART_WRITE_BYTE(8'hA5);
    #200000;

    $display("[TEST] Case 2: ALU With Operands");
    UART_WRITE_BYTE(8'hCC);
    UART_WRITE_BYTE(8'h12);
    UART_WRITE_BYTE(8'h34);
    UART_WRITE_BYTE(8'h02);
    #200000;

    $display("[TEST] Case 3: RegFile Read");
    UART_WRITE_BYTE(8'hBB);
    UART_WRITE_BYTE(8'h05);
    #200000;

    $display("[TEST] Case 4: ALU No Operands");
    UART_WRITE_BYTE(8'hDD);
    UART_WRITE_BYTE(8'h07);
    #200000;

    $display("[INFO] All test cases completed @ %0t", $time);
    #1000000;
    $stop;
  end

endmodule
