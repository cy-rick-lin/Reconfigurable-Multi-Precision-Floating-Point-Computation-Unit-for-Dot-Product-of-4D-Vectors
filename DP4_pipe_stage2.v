///////////////////////////////////////////////////////////
////////         Last edit: 2022/11/23 20:41        ///////
////////         Author: Rick Lin                   ///////
////////         Min time: 0.71 ns                  ///////
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "/EDA_Tools/Synopsys/synthesis/2018.06/dw/sim_ver/DW01_csa.v"

module DP4_pipe_stage2(
    mode, clk, reset,
    part_prod0_0_reg, part_prod0_1_reg, 
    part_prod1_0_reg, part_prod1_1_reg, 
    part_prod2_0_reg, part_prod2_1_reg, 
    part_prod3_0_reg, part_prod3_1_reg,
    sign_ab_reg, sign_cd_reg, sign_ef_reg, sign_gh_reg,
    exp_DP4_reg, shift_ab_reg, shift_cd_reg, shift_ef_reg, shift_gh_reg,
    exp_DP4_2_reg,
    carry1_1_reg, carry_pos_reg, sum_pos_reg, carry_Neg0_reg, sum_Neg0_reg, carry_Neg1_reg, sum_Neg1_reg
);

input mode, clk, reset;
input sign_ab_reg, sign_cd_reg, sign_ef_reg, sign_gh_reg;
input [7:0] exp_DP4_reg, shift_ab_reg, shift_cd_reg, shift_ef_reg, shift_gh_reg;
input signed [49:0] part_prod0_0_reg, part_prod0_1_reg, part_prod1_0_reg, part_prod1_1_reg, part_prod2_0_reg, part_prod2_1_reg, part_prod3_0_reg, part_prod3_1_reg;
output reg[7:0] exp_DP4_2_reg;
output reg signed [51:0] carry1_1_reg, carry_pos_reg, sum_pos_reg, carry_Neg0_reg, sum_Neg0_reg, carry_Neg1_reg, sum_Neg1_reg;

wire [7:0] exp_DP4_2;
wire signed [51:0] carry1_1, carry_pos, sum_pos, carry_Neg0, sum_Neg0, carry_Neg1, sum_Neg1;

wire signed [49:0] part_prodAB_0, part_prodAB_1, part_prodCD_0, part_prodCD_1, part_prodEF_0, part_prodEF_1, part_prodGH_0, part_prodGH_1;
wire signed [51:0] part_prod0, part_prod1, part_prod2, part_prod3, part_prod4, part_prod5, part_prod6, part_prod7;
wire signed [51:0] carry0_0, sum0_0, carry0_1, sum0_1, carry0_2, sum0_2, carry1_0, sum1_0, sum1_1;


assign exp_DP4_2 = exp_DP4_reg;

assign part_prodAB_0 = part_prod0_0_reg >>> shift_ab_reg;
assign part_prodAB_1 = part_prod0_1_reg >>> shift_ab_reg;
assign part_prodCD_0 = part_prod1_0_reg >>> shift_cd_reg;
assign part_prodCD_1 = part_prod1_1_reg >>> shift_cd_reg;
assign part_prodEF_0 = part_prod2_0_reg >>> shift_ef_reg;
assign part_prodEF_1 = part_prod2_1_reg >>> shift_ef_reg;
assign part_prodGH_0 = part_prod3_0_reg >>> shift_gh_reg;
assign part_prodGH_1 = part_prod3_1_reg >>> shift_gh_reg;

assign part_prod0 = {52{sign_ab_reg}} ^ {{2{part_prodAB_0[49]}}, part_prodAB_0};    // 1's complement to 52 bits
assign part_prod1 = {52{sign_ab_reg}} ^ {{2{part_prodAB_1[49]}}, part_prodAB_1};
assign part_prod2 = {52{sign_cd_reg}} ^ {{2{part_prodCD_0[49]}}, part_prodCD_0};
assign part_prod3 = {52{sign_cd_reg}} ^ {{2{part_prodCD_1[49]}}, part_prodCD_1};
assign part_prod4 = {52{sign_ef_reg}} ^ {{2{part_prodEF_0[49]}}, part_prodEF_0};
assign part_prod5 = {52{sign_ef_reg}} ^ {{2{part_prodEF_1[49]}}, part_prodEF_1};
assign part_prod6 = {52{sign_gh_reg}} ^ {{2{part_prodGH_0[49]}}, part_prodGH_0};
assign part_prod7 = {52{sign_gh_reg}} ^ {{2{part_prodGH_1[49]}}, part_prodGH_1};

// Level 1
DW01_csa #(52) U0_0(                                                  //     x|x x x x x    {sign_extend, x}
    .a(part_prod0), .b(part_prod1), .c(part_prod2), .ci(sign_ab_reg),     //     x|x x x x x
    .carry(carry0_0), .sum(sum0_0), .co(cout00)                       //     x|x x x x x
);                                                                    //     o o o o o o    sum 
                                                                      //   o|o o o o o 0    {cout, sign, carry}
DW01_csa #(52) U0_1(
    .a(part_prod3), .b(part_prod4), .c(part_prod5), .ci(sign_ab_reg), 
    .carry(carry0_1), .sum(sum0_1), .co(cout01)
);

DW01_csa #(52) U0_2(
    .a(part_prod6), .b(part_prod7), .c({50'b0, sign_cd_reg, 1'b0}), .ci(sign_ef_reg), 
    .carry(carry0_2), .sum(sum0_2), .co(cout02)
);

// Level 2
DW01_csa #(52) U1_0(
    .a(carry0_0), .b(sum0_0), .c(sum0_1), .ci(sign_ef_reg), 
    .carry(carry1_0), .sum(sum1_0), .co(cout10)
);

DW01_csa #(52) U1_1(
    .a(sum0_2), .b(carry0_1), .c(carry0_2), .ci(sign_gh_reg), 
    .carry(carry1_1), .sum(sum1_1), .co(cout11)
);

// Positive part
DW01_csa #(52) C0(
    .a(sum1_0), .b(carry1_0), .c(sum1_1), .ci(sign_gh_reg),
    .carry(carry_pos), .sum(sum_pos), .co(cout_pos)
);

// Negative part
DW01_csa #(52) Neg0_0(
    .a(~carry1_0), .b(~sum1_0), .c(~sum1_1), .ci(~sign_gh_reg),
    .carry(carry_Neg0), .sum(sum_Neg0), .co(_cout_Neg)
);

DW01_csa #(52) Neg0_1(
    .a(~carry1_1), .b(52'd4), .c(52'b0), .ci(1'b0),
    .carry(carry_Neg1), .sum(sum_Neg1), .co(cout_Neg1)
);

assign gclk = clk & mode;

always @(posedge gclk or posedge reset) begin
    if(reset) begin
        exp_DP4_2_reg[7:5] <= 0;
        carry1_1_reg[24:0] <= 0;
        carry_pos_reg[24:0] <= 0;
        sum_pos_reg[24:0] <= 0;
        carry_Neg0_reg[24:0] <= 0;
        sum_Neg0_reg[24:0] <= 0;
        carry_Neg1_reg[24:0] <= 0;
        sum_Neg1_reg[24:0] <= 0;
    end
    else begin
        exp_DP4_2_reg[7:5] <= exp_DP4_2[7:5];
        carry1_1_reg[24:0] <= carry1_1[24:0];
        carry_pos_reg[24:0] <= carry_pos[24:0];
        sum_pos_reg[24:0] <= sum_pos[24:0];
        carry_Neg0_reg[24:0] <= carry_Neg0[24:0];
        sum_Neg0_reg[24:0] <= sum_Neg0[24:0];
        carry_Neg1_reg[24:0] <= carry_Neg1[24:0];
        sum_Neg1_reg[24:0] <= sum_Neg1[24:0];
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        exp_DP4_2_reg[4:0] <= 0;
        carry1_1_reg[51:25] <= 0;
        carry_pos_reg[51:25] <= 0;
        sum_pos_reg[51:25] <= 0;
        carry_Neg0_reg[51:25] <= 0;
        sum_Neg0_reg[51:25] <= 0;
        carry_Neg1_reg[51:25] <= 0;
        sum_Neg1_reg[51:25] <= 0;
    end
    else begin
        exp_DP4_2_reg[4:0] <= exp_DP4_2[4:0];
        carry1_1_reg[51:25] <= carry1_1[51:25];
        carry_pos_reg[51:25] <= carry_pos[51:25];
        sum_pos_reg[51:25] <= sum_pos[51:25];
        carry_Neg0_reg[51:25] <= carry_Neg0[51:25];
        sum_Neg0_reg[51:25] <= sum_Neg0[51:25];
        carry_Neg1_reg[51:25] <= carry_Neg1[51:25];
        sum_Neg1_reg[51:25] <= sum_Neg1[51:25];
    end
end




endmodule