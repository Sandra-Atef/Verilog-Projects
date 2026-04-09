onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group TB_SIGNALS /SYS_TOP_TB/REF_CLK_tb
add wave -noupdate -expand -group TB_SIGNALS /SYS_TOP_TB/RST_N_tb
add wave -noupdate -expand -group TB_SIGNALS /SYS_TOP_TB/UART_CLK_tb
add wave -noupdate -expand -group TB_SIGNALS /SYS_TOP_TB/UART_RX_IN_tb
add wave -noupdate -expand -group TB_SIGNALS -color {Medium Violet Red} /SYS_TOP_TB/UART_TX_O_tb
add wave -noupdate -expand -group TB_SIGNALS /SYS_TOP_TB/framing_error_tb
add wave -noupdate -expand -group TB_SIGNALS /SYS_TOP_TB/parity_error_tb
add wave -noupdate -expand -group SYS_CTRL_SIGNALS -color {Medium Aquamarine} -itemcolor {Medium Aquamarine} -radix hexadecimal /SYS_TOP_TB/DUT/U0_SYS_CTRL/current_state
add wave -noupdate -expand -group SYS_CTRL_SIGNALS -color Orange -radix hexadecimal /SYS_TOP_TB/DUT/U0_SYS_CTRL/RX_P_DATA
add wave -noupdate -expand -group SYS_CTRL_SIGNALS -color Orange /SYS_TOP_TB/DUT/U0_SYS_CTRL/RX_D_VLD
add wave -noupdate -expand -group SYS_CTRL_SIGNALS -color Magenta /SYS_TOP_TB/DUT/U0_SYS_CTRL/FIFO_WR_DATA
add wave -noupdate -expand -group SYS_CTRL_SIGNALS -color Magenta /SYS_TOP_TB/DUT/U0_SYS_CTRL/FIFO_WR_INC
add wave -noupdate -expand -group ALU_SIGNALS -radix hexadecimal /SYS_TOP_TB/DUT/U0_ALU/ALU_OUT
add wave -noupdate -expand -group ALU_SIGNALS /SYS_TOP_TB/DUT/U0_ALU/OUT_VALID
add wave -noupdate -expand -group REG_FILE_SIGNALS -radix hexadecimal /SYS_TOP_TB/DUT/U0_RegFile/Reg_File
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1292612269 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 74
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {3203650800 ps}
