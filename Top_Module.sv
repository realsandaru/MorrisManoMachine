`include "Reg_Template.sv"
`include "RAM.sv"
`include "Control_Unit.sv"
`include "ALU.sv"

module Top_Module(
    input logic clk, SC_EN, rst,
    input logic prog_wr_en,
  	input logic [11:0] prog_addr,
  	input logic [15:0] prog_data,
  	input logic [7:0] input_data,
  	input logic input_read,
  	input logic [11:0]PC_Reset_Initial_Data,
  	input logic PC_Reset_Initial
);

  logic [15:0] Bus, Bus_DR, Bus_AC, Bus_IR, Bus_TR, Bus_MEMORY, ALU_Wire_Out;
    logic [7:0] INPR_Data_Out;
    logic [11:0]  Bus_AR, Bus_PC;
    logic E_Wire_Out;
    logic MEMORY_READ_Wire, MEMORY_WRITE_Wire,
    AR_LD_Wire, AR_INR_Wire, AR_CLR_Wire,
    PC_LD_Wire, PC_INR_Wire, PC_CLR_Wire,
    DR_LD_Wire, DR_INR_Wire, DR_CLR_Wire,
    AC_LD_Wire, AC_INR_Wire, AC_CLR_Wire,
    TR_LD_Wire, TR_INR_Wire, TR_CLR_Wire,
    E_LD_CO_Wire, A0_TO_E_Wire, A15_TO_E_Wire, E_CLR_Wire, E_INV_Wire,
    IR_LD_Wire,
    OUTER_LD_Wire;
    

    logic [3:0]ALU_CTRL_Wire;
    logic [2:0]S_Wire;


    always_comb begin
        case (S_Wire)
            3'd0: Bus = 16'd0;
            3'd1: Bus = {4'd0, Bus_AR};
            3'd2: Bus = {4'd0, Bus_PC};
            3'd3: Bus = Bus_DR;
            3'd4: Bus = Bus_AC;
            3'd5: Bus = Bus_IR;
            3'd6: Bus = Bus_TR;
            3'd7: Bus = Bus_MEMORY;
            default: Bus = 16'd0;
        endcase
    end

  Reg_Template #(.WIDTH(16)) DR (
        .Data_In(Bus),
        .Data_Out(Bus_DR),
    .Initial_Reset_Data(16'b0),
    .Initial_Reset(1'b0),
        .clk(clk),
        .C_LD(DR_LD_Wire),
        .C_INR(DR_INR_Wire),
    	.C_CLR(DR_CLR_Wire || rst)
    );

  Reg_Template #(.WIDTH(16)) TR (
        .Data_In(Bus),
        .Data_Out(Bus_TR),
    .Initial_Reset_Data(16'b0),
    .Initial_Reset(1'b0),
        .clk(clk),
        .C_LD(TR_LD_Wire),
        .C_INR(TR_INR_Wire),
    	.C_CLR(TR_CLR_Wire || rst)
    );

    Reg_Template #(.WIDTH(16)) AC (
        .Data_In(ALU_Wire_Out),
        .Data_Out(Bus_AC),
      .Initial_Reset_Data(16'b0),
      .Initial_Reset(1'b0),
        .clk(clk),
        .C_LD(AC_LD_Wire),
        .C_INR(AC_INR_Wire),
      	.C_CLR(AC_CLR_Wire || rst)
    );

    Reg_Template #(.WIDTH(16)) IR (
        .Data_In(Bus),
        .Data_Out(Bus_IR),
      .Initial_Reset_Data(16'b0),
      .Initial_Reset(1'b0),
        .clk(clk),
        .C_LD(IR_LD_Wire),
      	.C_INR(1'd0),
      	.C_CLR(1'd0 || rst)
    );

  	Reg_Template #(.WIDTH(8)) OUTER (
        .Data_In(Bus[7:0]),
        .Data_Out(),
      .Initial_Reset_Data(8'b0),
      .Initial_Reset(1'b0),
        .clk(clk),
        .C_LD(OUTER_LD_Wire),
        .C_INR(1'd0),
      	.C_CLR(1'd0 || rst)
    );

  	Reg_Template #(.WIDTH(8)) INPR (
      	.Data_In(input_data),
        .Data_Out(INPR_Data_Out),
      .Initial_Reset_Data(8'b0),
      .Initial_Reset(1'b0),
      	.clk(clk),
      	.C_LD(input_read),
        .C_INR(1'd0),
      	.C_CLR(1'd0 || rst)
    );

  Reg_Template #(.WIDTH(12)) PC (
        .Data_In(Bus[11:0]),
        .Data_Out(Bus_PC),
        .Initial_Reset_Data(PC_Reset_Initial_Data),
    .Initial_Reset(PC_Reset_Initial),
        .clk(clk),
        .C_LD(PC_LD_Wire),
        .C_INR(PC_INR_Wire),
      	.C_CLR(PC_CLR_Wire || rst)
    );

  	Reg_Template #(.WIDTH(12)) AR (
        .Data_In(Bus[11:0]),
        .Data_Out(Bus_AR),
      .Initial_Reset_Data(12'b0),
      .Initial_Reset(1'b0),
        .clk(clk),
        .C_LD(AR_LD_Wire),
        .C_INR(AR_INR_Wire),
      	.C_CLR(AR_CLR_Wire || rst)
    );

    ALU ALU_1(
        .clk(clk),
        .INPR_Data_In(INPR_Data_Out),
        .DR_Data_In(Bus_DR),
        .AC_Data_In(Bus_AC),
        .ALU_CTRL(ALU_CTRL_Wire),
        .E_LD_CO(E_LD_CO_Wire),
        .A0_TO_E(A0_TO_E_Wire), 
        .A15_TO_E(A15_TO_E_Wire), 
      	.E_CLR(E_CLR_Wire || rst), 
        .E_INV(E_INV_Wire),
        .E_Out(E_Wire_Out),
        .ALU_Data_Out(ALU_Wire_Out)
    );

    Control_Unit CU(
        .clk(clk),
        .IR(Bus_IR),
        .DR(Bus_DR),
        .AC(Bus_AC),
        .E(E_Wire_Out),
        .SS(SC_EN),
      	.input_read(input_read),
        .MEMORY_READ(MEMORY_READ_Wire), .MEMORY_WRITE(MEMORY_WRITE_Wire),
        .AR_LD(AR_LD_Wire), .AR_INR(AR_INR_Wire), .AR_CLR(AR_CLR_Wire),
        .PC_LD(PC_LD_Wire), .PC_INR(PC_INR_Wire), .PC_CLR(PC_CLR_Wire),
        .DR_LD(DR_LD_Wire), .DR_INR(DR_INR_Wire), .DR_CLR(DR_CLR_Wire),
        .AC_LD(AC_LD_Wire), .AC_INR(AC_INR_Wire), .AC_CLR(AC_CLR_Wire),
        .TR_LD(TR_LD_Wire), .TR_INR(TR_INR_Wire), .TR_CLR(TR_CLR_Wire),
        .E_LD_CO(E_LD_CO_Wire), .A0_TO_E(A0_TO_E_Wire), .A15_TO_E(A15_TO_E_Wire), .E_CLR(E_CLR_Wire), .E_INV(E_INV_Wire),
        .ALU_CTRL(ALU_CTRL_Wire),
        .IR_LD(IR_LD_Wire),
        .OUTER_LD(OUTER_LD_Wire),
      .S(S_Wire),
      .rst(rst)
    );

    RAM RAM_1 (
        .clk(clk),
        .Address(ram_addr),
        .Data_In(ram_data),
        .Write(ram_write),
        .Read(MEMORY_READ_Wire),
        .Data_Out(Bus_MEMORY)
    );

    logic [11:0] ram_addr;
    logic [15:0] ram_data;
    logic ram_write;

    assign ram_addr  = prog_wr_en ? prog_addr : Bus_AR;
    assign ram_data  = prog_wr_en ? prog_data : Bus;
    assign ram_write = MEMORY_WRITE_Wire | prog_wr_en;

endmodule

