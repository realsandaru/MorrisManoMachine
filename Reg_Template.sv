module Reg_Template #(
    parameter int WIDTH = 16
)(
  	input logic [WIDTH-1:0] Data_In,
  	input logic [WIDTH-1:0] Initial_Reset_Data,
  	input logic Initial_Reset,
    output logic [WIDTH-1:0] Data_Out,
    input logic C_LD, C_INR, C_CLR, clk
);

    always_ff @(posedge clk) begin

      if (Initial_Reset) Data_Out <= Initial_Reset_Data;
      	if (C_CLR) Data_Out <= 'd0;
        else if (C_LD) Data_Out <= Data_In;
        else if (C_INR) Data_Out <= Data_Out + 1;
        
    end


endmodule