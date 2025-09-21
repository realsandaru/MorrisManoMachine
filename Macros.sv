`define ALU_NOP    4'h0
`define AC_AND_DR  4'h1
`define AC_ADD_DR  4'h2
`define DR_TO_AC   4'h3
`define INPR_TO_AC 4'h4
`define INV_AC     4'h5
`define SHR_AC     4'h6 //take bit from E automatically in to A15
`define SHL_AC     4'h8 // '' A0
`define CLR_AC     4'h9