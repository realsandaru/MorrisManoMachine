`include "Macros.sv"

module ALU(
    input logic clk,
    input logic [7:0]INPR_Data_In,
    input logic [15:0]DR_Data_In, AC_Data_In,
    input logic [3:0]ALU_CTRL,
    input logic E_LD_CO, A0_TO_E, A15_TO_E, E_CLR, E_INV,
    output logic E_Out,
    output logic [15:0]ALU_Data_Out
);
    logic E_Next;
    logic CO;

    always_ff @(posedge clk) begin
        if(A0_TO_E) E_Out <= AC_Data_In[0];
        else if(A15_TO_E) E_Out <= AC_Data_In[15];
        else if(E_CLR) E_Out <= 0;
        else if(E_INV) E_Out <= ~E_Out;
        else if(E_LD_CO) E_Out <= CO; 
        else E_Out <= E_Next;
    end 

    always_comb begin

        ALU_Data_Out = AC_Data_In;
        E_Next = E_Out;
        CO = 1'b0;
        

        case (ALU_CTRL) 

            `ALU_NOP: ALU_Data_Out = AC_Data_In; 
            `AC_AND_DR: ALU_Data_Out = AC_Data_In & DR_Data_In; 
            `AC_ADD_DR: {CO, ALU_Data_Out} = AC_Data_In + DR_Data_In;
            `DR_TO_AC: ALU_Data_Out = DR_Data_In;
          	`INPR_TO_AC:   ALU_Data_Out = {AC_Data_In[15:8], INPR_Data_In};
            `INV_AC: ALU_Data_Out = ~(AC_Data_In);
            `SHR_AC: begin
                ALU_Data_Out = {E_Out, AC_Data_In[15:1]};
                E_Next        = AC_Data_In[0];
            end
            `SHL_AC: begin
                ALU_Data_Out = {AC_Data_In[14:0], E_Out};
                E_Next        = AC_Data_In[15];
            end
            `CLR_AC: ALU_Data_Out = 16'd0;

            default: ALU_Data_Out = AC_Data_In; 
        
        endcase
    end
endmodule

