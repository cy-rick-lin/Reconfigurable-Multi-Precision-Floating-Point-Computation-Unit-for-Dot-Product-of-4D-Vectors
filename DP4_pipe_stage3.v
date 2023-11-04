///////////////////////////////////////////////////////////
////////         Last edit: 2022/11/22 01:44        ///////
////////         Author: Rick Lin                   ///////
////////         Min time: 0.74 ns                  ///////
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
//`include "/EDA_Tools/Synopsys/synthesis/2018.06/dw/sim_ver/DW01_csa.v"

module DP4_pipe_stage3(
    mode, clk, reset,
    exp_DP4_2_reg,
    carry1_1_reg, carry_pos_reg, sum_pos_reg, carry_Neg0_reg, sum_Neg0_reg, carry_Neg1_reg, sum_Neg1_reg,
    sign_DP4_reg,
    exp_DP4_3_reg,
    mantissa_DP4_reg, 
    LOD_reg
);

input mode, clk, reset;
input [7:0] exp_DP4_2_reg;
input signed [51:0] carry1_1_reg, carry_pos_reg, sum_pos_reg, carry_Neg0_reg, sum_Neg0_reg, carry_Neg1_reg, sum_Neg1_reg;
output reg sign_DP4_reg;
output reg [7:0] exp_DP4_3_reg;
output reg [7:0] LOD_reg;
output reg [51:0] mantissa_DP4_reg;

wire [7:0] exp_DP4_3;
wire [7:0] LOD;
wire [51:0] mantissa_DP4;

wire signed [51:0] carry_f_pos, sum_f_pos, carry_Neg2, sum_Neg2, carry_f_Neg, sum_f_Neg, mantissa_DP4_pos, mantissa_DP4_neg;
integer i, j;
reg stop, stop2;
reg [7:0] LOD_pos, LOD_neg;

assign exp_DP4_3 = exp_DP4_2_reg;

// Positive part
DW01_csa #(52) C1(
    .a(carry1_1_reg), .b(carry_pos_reg), .c(sum_pos_reg), .ci(1'b0),
    .carry(carry_f_pos), .sum(sum_f_pos), .co(cout_f_pos)
);

// Negative part, 3 levels
DW01_csa #(52) Neg1_0(
    .a(carry_Neg0_reg), .b(sum_Neg0_reg), .c(carry_Neg1_reg), .ci(1'b0),
    .carry(carry_Neg2), .sum(sum_Neg2), .co(cout_Neg2)
);

DW01_csa #(52) Neg2(
    .a(sum_Neg1_reg), .b(carry_Neg2), .c(sum_Neg2), .ci(1'b0),
    .carry(carry_f_Neg), .sum(sum_f_Neg), .co(cout_f_Neg)
);


assign mantissa_DP4_pos = carry_f_pos + sum_f_pos;
assign mantissa_DP4_neg = carry_f_Neg + sum_f_Neg;
assign sign_DP4 = mantissa_DP4_pos[51];
assign mantissa_DP4 = (sign_DP4) ? mantissa_DP4_neg : mantissa_DP4_pos;

always @(*) begin
    stop = 0;
    LOD_pos = 0;

    for(i = 51; !stop & i>=0; i = i - 1) begin
        stop = mantissa_DP4_pos[i];
        LOD_pos = 51 - i;
    end
end

always @(*) begin
    stop2 = 0;
    LOD_neg = 0;

    for(j = 51; !stop2 & j>=0; j = j - 1) begin
        stop2 = mantissa_DP4_neg[j];
        LOD_neg = 51 - j;
    end
end

assign LOD = (sign_DP4) ? LOD_neg : LOD_pos;

assign gclk = clk & mode;

always @(posedge gclk or posedge reset) begin
    if(reset) begin
        exp_DP4_3_reg[7:5] <= 0;
        mantissa_DP4_reg[24:0] <= 0;
    end

    else begin
        exp_DP4_3_reg[7:5] <= exp_DP4_3[7:5];
        mantissa_DP4_reg[24:0] <= mantissa_DP4[24:0];
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        sign_DP4_reg <= 0;
        exp_DP4_3_reg[4:0] <= 0;
        mantissa_DP4_reg[51:25] <= 0;
        LOD_reg <= 0;
    end

    else begin
        sign_DP4_reg <= sign_DP4;
        exp_DP4_3_reg[4:0] <= exp_DP4_3[4:0];
        mantissa_DP4_reg[51:25] <= mantissa_DP4[51:25];
        LOD_reg <= LOD;
    end
end

endmodule