module RAM(
    input logic clk,
  	input logic [11:0] Address,
    input logic [15:0]Data_In,
    input logic Write, Read,
    output logic [15:0]Data_Out
);

    logic [15:0] mem [0:4095];

    always_ff @(posedge clk) begin
        if (Write) mem[Address] <= Data_In;
    end


    always_comb begin
        if (Read) Data_Out = mem[Address];
        else Data_Out = 16'd0;
    end

endmodule
