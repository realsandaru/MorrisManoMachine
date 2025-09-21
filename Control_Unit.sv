`include "Macros.sv"

module Control_Unit(
    input  logic clk,
    input  logic [15:0]IR,
    input  logic [15:0]DR,
    input  logic [15:0]AC,
    input  logic E,
    input  logic SS,
	input logic rst,
  	input logic input_read,
    output logic MEMORY_READ, MEMORY_WRITE,
    output logic AR_LD, AR_INR, AR_CLR,
    output logic PC_LD, PC_INR, PC_CLR,
    output logic DR_LD, DR_INR, DR_CLR,
    output logic AC_LD, AC_INR, AC_CLR,
    output logic TR_LD, TR_INR, TR_CLR,
    output logic E_LD_CO, A0_TO_E, A15_TO_E, E_CLR, E_INV,
    output logic [3:0]ALU_CTRL,
    output logic IR_LD,
    output logic OUTER_LD,
    output logic [2:0]S
);

    logic SC_CLR, SS_INTERNAL, IEN;
  	logic R = 0;
  	logic FGI = 0;
  	logic FGO = 1;
  	logic [2:0] T = 3'd0;


 
    always_ff @(posedge clk) begin
      if (SS && SS_INTERNAL) begin
        if(SC_CLR || rst) T <= 3'd0;
            else T <= T + 3'd1;
        end
    end

    always_ff @(posedge clk) begin
      if (input_read) FGI <= 1;
//       if there are data in the output buffer FGO <= 1;
      if (T > 2 && (FGO || FGI) && IEN) R <= 1;
      if (T == 3'd3 && IR == 16'hF080) IEN <= 1;
      if (T == 3'd3 && IR == 16'hF040) IEN <= 0;
      if (R && T == 3'd2) begin
        R <= 0;
        IEN <= 0;
      end
      if (T == 3'd3 && IR == 16'hF800) FGI <= 0;
      if (T == 3'd3 && IR == 16'hF400) FGO <= 0;
	end


    always_comb begin 
        
        MEMORY_READ = 0; MEMORY_WRITE = 0;
        AR_LD = 0; AR_INR = 0; AR_CLR = 0;
        PC_LD = 0; PC_INR = 0; PC_CLR = 0;
        DR_LD = 0; DR_INR = 0; DR_CLR = 0;
        AC_LD = 0; AC_INR = 0; AC_CLR = 0;
        TR_LD = 0; TR_INR = 0; TR_CLR = 0;
        E_LD_CO = 0; A0_TO_E = 0; A15_TO_E = 0; E_CLR = 0; E_INV = 0;
        ALU_CTRL = `ALU_NOP;
        IR_LD = 0;
        OUTER_LD = 0;
        S = 3'd0;
      
        SS_INTERNAL = 1;
        SC_CLR = 0;

        case ({R, T})

          {1'd0, 3'd0}: begin
                S = 3'd2; 
                AR_LD = 1; 
            end

          {1'd0, 3'd1}: begin
                MEMORY_READ = 1; 
                S = 3'd7; 
                IR_LD = 1; 
                PC_INR = 1; 
            end

          {1'd0, 3'd2}: begin
                S = 3'd5; 
                AR_LD = 1;  
                // I <= IR[15]; Place the MSB of the instruction into the I FlipFlop( Separately handled )
            end
          
          {1'd1, 3'd0}: begin
				AR_CLR = 1;
            	S = 3'd2;
            	TR_LD = 1;
            end

          {1'd1, 3'd1}: begin
				S = 3'd6;
            	MEMORY_WRITE = 1;
            	PC_CLR = 1;          	
            end

          {1'd1, 3'd2}: begin
				PC_INR = 1;
            	SC_CLR = 1;
//             ien <= 0 and r <= 0 handled separately
          end

            default: begin 

                casez (IR)

                    16'h0???: begin //AND (Direct memory)
                        if (T == 4) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            DR_LD = 1;                             
                        end
                        if (T == 5) begin
                            ALU_CTRL = `AC_AND_DR; 
                            AC_LD = 1; 
                            SC_CLR = 1; 
                        end
                    end

                    16'h1???: begin //ADD (Direct memory)
                        if (T == 4) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            DR_LD = 1;                            
                        end
                        if (T == 5) begin
                            ALU_CTRL = `AC_ADD_DR; 
                            E_LD_CO = 1; 
                          	AC_LD = 1;
                            SC_CLR = 1; 
                        end
                    end

                    16'h2???: begin //LDA (Direct memory)
                        if (T == 4) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            DR_LD = 1;                             
                        end
                        if (T == 5) begin
                            ALU_CTRL = `DR_TO_AC;
                            AC_LD = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h3???: begin //STA (Direct memory)
                        if (T == 4) begin
                            S = 3'd4;
                            MEMORY_WRITE = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h4???: begin //BUN (Direct memory)
                        if (T == 4) begin
                            S = 3'd1;
                            PC_LD = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h5???: begin //BSA (Direct memory)
                        if (T == 4) begin
                            MEMORY_WRITE = 1;
                            S = 3'd2;
                            AR_INR = 1;
                        end
                        if (T == 5) begin
                            S = 3'd1;
                            PC_LD = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h6???: begin //ISZ (Direct memory)
                        if (T == 4) begin
                          	MEMORY_READ = 1;
                            S = 3'd7;
                            DR_LD = 1;
                        end
                        if (T == 5) begin
                            DR_INR = 1;
                        end
                        if (T == 6) begin
                            MEMORY_WRITE = 1;
                            S = 3'd3;
                            SC_CLR = 1;
                            if (DR == 16'd0) PC_INR = 1;
                        end
                    end

                    16'h8???: begin //AND (Indirect memory)
                        if (T == 3) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            AR_LD = 1; 
                        end
                        if (T == 4) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            DR_LD = 1;                            
                        end
                        if (T == 5) begin
                            ALU_CTRL = `AC_AND_DR; 
                            AC_LD = 1; 
                            SC_CLR = 1; 
                        end
                    end

                    16'h9???: begin //ADD (Indirect memory)
                        if (T == 3) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            AR_LD = 1; 
                        end
                        if (T == 4) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            DR_LD = 1;                           
                        end
                        if (T == 5) begin
                            ALU_CTRL = `AC_ADD_DR; 
                            E_LD_CO = 1; 
                          	AC_LD = 1;
                            SC_CLR = 1; 
                        end
                    end

                    16'hA???: begin //LDA (Indirect memory)
                        if (T == 3) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            AR_LD = 1; 
                        end
                        if (T == 4) begin
                            MEMORY_READ = 1; 
                            S = 3'd7;
                            DR_LD = 1;                           
                        end
                        if (T == 5) begin
                            ALU_CTRL = `DR_TO_AC;
                            AC_LD = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'hB???: begin //STA (Indirect memory)
                        if (T == 3) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            AR_LD = 1; 
                        end
                        if (T == 4) begin
                            S = 3'd4;
                            MEMORY_WRITE = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'hC???: begin //BUN (Indirect memory)
                        if (T == 3) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            AR_LD = 1; 
                        end
                        if (T == 4) begin
                            S = 3'd1;
                            PC_LD = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'hD???: begin //BSA (Indirect memory)
                        if (T == 3) begin
                            MEMORY_READ = 1; 
                            S = 3'd7; 
                            AR_LD = 1; 
                        end
                        if (T == 4) begin
                            MEMORY_WRITE = 1;
                            S = 3'd2;
                            AR_INR = 1;
                        end
                        if (T == 5) begin
                            S = 3'd1;
                            PC_LD = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'hE???: begin //ISZ (Indirect memory)
                        if (T == 3) begin
                            MEMORY_READ = 1; 
                            S = 3'd7;
                            AR_LD = 1;
                        end
                        if (T == 4) begin
                          	MEMORY_READ = 1;
                            S = 3'd7;
                            DR_LD = 1;
                        end
                        if (T == 5) begin
                            DR_INR = 1;
                        end
                        if (T == 6) begin
                            MEMORY_WRITE = 1;
                            S = 3'd3;
                            SC_CLR = 1;
                            if (DR == 16'd0) PC_INR = 1;
                        end
                    end

                    16'h7800: begin //CLA
                        if (T == 3) begin
                            AC_CLR = 1;
                            SC_CLR = 1;
                        end
                    end                    

                    16'h7400: begin //CLE
                        if (T == 3) begin
                            E_CLR = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h7200: begin //CMA
                        if (T == 3) begin
                            ALU_CTRL = `INV_AC;
                            AC_LD = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h7100: begin //CME
                        if (T == 3) begin
                            E_INV = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h7080: begin //CIR
                        if (T == 3) begin
                            ALU_CTRL = `SHR_AC; // includes taking the bit from E
                            A0_TO_E = 1;
                            SC_CLR = 1; 
                          	AC_LD = 1;
                        end
                    end

                    16'h7040: begin //CIL
                        if (T == 3) begin
                            ALU_CTRL = `SHL_AC; // includes taking the bit from E
                            A15_TO_E = 1;
                            SC_CLR = 1;
                          	AC_LD = 1;
                        end
                    end

                    16'h7020: begin //INC
                        if (T == 3) begin
                            AC_INR = 1;
                            SC_CLR = 1;
                        end
                    end

                    16'h7010: begin //SPA
                        if (T == 3 && AC[15] == 0) begin
                            PC_INR = 1;
                            SC_CLR = 1;
                        end
                      	else SC_CLR = 1;
                    end

                    16'h7008: begin //SNA
                        if (T == 3 && AC[15] == 1) begin
                            PC_INR = 1;
                            SC_CLR = 1;
                        end
                      else SC_CLR = 1;
                    end


                    16'h7004: begin //SZA
                        if (T == 3 && AC == 16'd0) begin
                            PC_INR = 1;
                            SC_CLR = 1;
                        end
                        else SC_CLR = 1;
                    end

                    16'h7002: begin //SZE
                        if (T == 3 && E == 0) begin
                            PC_INR = 1;
                          	SC_CLR = 1;
                        end 
                      	else SC_CLR = 1;
                    end

                    16'h7001: begin //HLT
                        if (T == 3) begin
                          	SC_CLR = 1;
                            SS_INTERNAL = 0;                           
                        end
                    end

                    16'hF800: begin //INP
                        if (T == 3) begin
                            ALU_CTRL = `INPR_TO_AC;
                            // FGI <= 0; ( handled separately )
                            SC_CLR = 1;
                          	AC_LD = 1;
                        end
                    end

                    16'hF400: begin //OUT
                        if (T == 3) begin
                            S = 3'd4;
                            OUTER_LD = 1;
                            // FGO <= 0; ( handled separately )
                            SC_CLR = 1;
                        end
                    end

                    16'hF200: begin //SKI
                        if (T == 3 && FGI) begin
                            PC_INR = 1;                            
                        end
                      	SC_CLR = 1;
                    end

                    16'hF100: begin //SKO
                        if (T == 3 && FGO) begin
                            PC_INR = 1;                            
                        end
                      	SC_CLR = 1;
                    end

                    16'hF080: begin //ION
//                         IEN = 1; HANDLED
                      	SC_CLR = 1;
                    end

                    16'hF040: begin //IOF
//                         IEN = 0; HANDLED
                        SC_CLR = 1;
                    end 
	
						default: SC_CLR = 1;

                endcase
                
            end

        endcase            

    end
endmodule




