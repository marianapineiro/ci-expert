`timescale 1ns / 1ps

module tb_alu;

// Inputs
reg [7:0] A, B;
reg [3:0] ALU_Sel;

// Outputs
wire [7:0] ALU_Out;
wire CarryOut;

integer i;

// Instantiate ALU
alu test_unit (
    A,
    B,
    ALU_Sel,
    ALU_Out,
    CarryOut
);

// Dump waveform
initial begin
    $fsdbDumpfile("alu.fsdb");
    $fsdbDumpvars(0, tb_alu);
end

// Stimulus
initial begin

    A = 8'h0A;
    B = 8'h02;
    ALU_Sel = 4'h0;

    for (i = 0; i <= 15; i = i + 1)
    begin
        #10;
        ALU_Sel = ALU_Sel + 4'h1;
    end

    A = 8'hF6;
    B = 8'h0A;

    #20;

    $finish;
end

endmodule