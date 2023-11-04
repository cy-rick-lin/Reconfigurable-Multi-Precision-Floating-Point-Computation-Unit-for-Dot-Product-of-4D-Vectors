///////////////////////////////////////////////////////////
////////         Last edit: 2022/11/12 17:10        ///////
////////         Author: Rick Lin                   ///////
////////         Min time: 0.72 ns                  ///////
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "Dadda_tree.v"

module DP4_pipe_stage1(
    mode, clk, reset,
    a, b, c, d, e, f, g, h,
    part_prod0_0_reg, part_prod0_1_reg, 
    part_prod1_0_reg, part_prod1_1_reg, 
    part_prod2_0_reg, part_prod2_1_reg, 
    part_prod3_0_reg, part_prod3_1_reg,
    sign_ab_reg, sign_cd_reg, sign_ef_reg, sign_gh_reg,
    exp_DP4_reg, shift_ab_reg, shift_cd_reg, shift_ef_reg, shift_gh_reg
) ;

input mode, clk, reset;
input [31:0] a, b, c, d, e, f, g, h;
output reg sign_ab_reg, sign_cd_reg, sign_ef_reg, sign_gh_reg;
output reg [7:0] exp_DP4_reg, shift_ab_reg, shift_cd_reg, shift_ef_reg, shift_gh_reg;
output reg signed [49:0] part_prod0_0_reg, part_prod0_1_reg, part_prod1_0_reg, part_prod1_1_reg, part_prod2_0_reg, part_prod2_1_reg, part_prod3_0_reg, part_prod3_1_reg;

wire sign_ab, sign_cd, sign_ef, sign_gh;
reg [7:0] _exp_DP4, shift_ab, shift_cd, shift_ef, shift_gh;
wire signed [49:0] part_prod0_0, part_prod0_1, part_prod1_0, part_prod1_1, part_prod2_0, part_prod2_1, part_prod3_0, part_prod3_1;

wire [1:0] uns0_0, uns0_1, uns1_0, uns1_1, uns2_0, uns2_1, uns3_0, uns3_1;
wire [7:0] exp_ab, exp_cd, exp_ef, exp_gh;
wire [7:0] diff_ab_cd, diff_cd_ef, diff_ef_gh, diff_gh_ab, diff_ab_ef, diff_cd_gh;
wire signed [7:0] _diff_ab_cd, _diff_cd_ef, _diff_ef_gh, _diff_gh_ab, _diff_ab_ef, _diff_cd_gh;
wire signed [7:0] diff_ab_cd_, diff_cd_ef_, diff_ef_gh_, diff_gh_ab_, diff_ab_ef_, diff_cd_gh_;
wire [23:0] mantissa_A, mantissa_B, mantissa_C, mantissa_D, mantissa_E, mantissa_F, mantissa_G, mantissa_H;

wire [7:0] exp_DP4, _exp_DP4_;

assign mantissa_A = (mode) ? {1'b1, a[22:0]} : {1'b1, a[9:0], 13'b0};      // mode 1 for FLP32, 0 for FLP16, 24 bits
assign mantissa_B = (mode) ? {1'b1, b[22:0]} : {1'b1, b[9:0], 13'b0};
assign mantissa_C = (mode) ? {1'b1, c[22:0]} : {1'b1, c[9:0], 13'b0};
assign mantissa_D = (mode) ? {1'b1, d[22:0]} : {1'b1, d[9:0], 13'b0};
assign mantissa_E = (mode) ? {1'b1, e[22:0]} : {1'b1, e[9:0], 13'b0};
assign mantissa_F = (mode) ? {1'b1, f[22:0]} : {1'b1, f[9:0], 13'b0};
assign mantissa_G = (mode) ? {1'b1, g[22:0]} : {1'b1, g[9:0], 13'b0};
assign mantissa_H = (mode) ? {1'b1, h[22:0]} : {1'b1, h[9:0], 13'b0};

Dadda_tree D0(
    mantissa_A, mantissa_B, 
    part_prod0_0, part_prod0_1
);
Dadda_tree D1(
    mantissa_C, mantissa_D, 
    part_prod1_0, part_prod1_1
);
Dadda_tree D2(
    mantissa_E, mantissa_F, 
    part_prod2_0, part_prod2_1
);
Dadda_tree D3(
    mantissa_G, mantissa_H, 
    part_prod3_0, part_prod3_1
);



assign sign_ab = (mode) ? (a[31] ^ b[31]) : (a[15] ^ b[15]);
assign sign_cd = (mode) ? (c[31] ^ d[31]) : (c[15] ^ d[15]);
assign sign_ef = (mode) ? (e[31] ^ f[31]) : (e[15] ^ f[15]);
assign sign_gh = (mode) ? (g[31] ^ h[31]) : (g[15] ^ h[15]);

assign exp_ab = (mode) ? (a[30:23] + b[30:23] - 127) : (a[14:10] + b[14:10] - 15);
assign exp_cd = (mode) ? (c[30:23] + d[30:23] - 127) : (c[14:10] + d[14:10] - 15);
assign exp_ef = (mode) ? (e[30:23] + f[30:23] - 127) : (e[14:10] + f[14:10] - 15);
assign exp_gh = (mode) ? (g[30:23] + h[30:23] - 127) : (g[14:10] + h[14:10] - 15);

assign _diff_ab_cd = exp_ab - exp_cd;
assign diff_ab_cd_ = exp_cd - exp_ab;

assign _diff_cd_ef = exp_cd - exp_ef;
assign diff_cd_ef_ = exp_ef - exp_cd;

assign _diff_ef_gh = exp_ef - exp_gh;
assign diff_ef_gh_ = exp_gh - exp_ef;

assign _diff_gh_ab = exp_gh - exp_ab;
assign diff_gh_ab_ = exp_ab - exp_gh;

assign _diff_ab_ef = exp_ab - exp_ef;
assign diff_ab_ef_ = exp_ef - exp_ab;

assign _diff_cd_gh = exp_cd - exp_gh;
assign diff_cd_gh_ = exp_gh - exp_cd;

assign diff_ab_cd = (_diff_ab_cd[7]) ? diff_ab_cd_ : _diff_ab_cd;
assign diff_cd_ef = (_diff_cd_ef[7]) ? diff_cd_ef_ : _diff_cd_ef;
assign diff_ef_gh = (_diff_ef_gh[7]) ? diff_ef_gh_ : _diff_ef_gh;
assign diff_gh_ab = (_diff_gh_ab[7]) ? diff_gh_ab_ : _diff_gh_ab;
assign diff_ab_ef = (_diff_ab_ef[7]) ? diff_ab_ef_ : _diff_ab_ef;
assign diff_cd_gh = (_diff_cd_gh[7]) ? diff_cd_gh_ : _diff_cd_gh;

assign comp_ab_cd = (_diff_ab_cd >= 0) ? 1 : 0;
assign comp_cd_ef = (_diff_cd_ef >= 0) ? 1 : 0;
assign comp_ef_gh = (_diff_ef_gh >= 0) ? 1 : 0;
assign comp_gh_ab = (_diff_gh_ab >= 0) ? 1 : 0;
assign comp_ab_ef = (_diff_ab_ef >= 0) ? 1 : 0;
assign comp_cd_gh = (_diff_cd_gh >= 0) ? 1 : 0;

always @(*) begin
    casex({comp_ab_cd, comp_cd_ef, comp_ef_gh, comp_gh_ab, comp_ab_ef, comp_cd_gh})
        6'b0001_xx: _exp_DP4 <= exp_gh;
        6'b0010_xx: _exp_DP4 <= exp_ef;
        6'b0011_xx: _exp_DP4 <= exp_ef;
        6'b0100_xx: _exp_DP4 <= exp_cd;
        6'b0101_x0: _exp_DP4 <= exp_gh;
        6'b0101_x1: _exp_DP4 <= exp_cd;
        6'b0110_xx: _exp_DP4 <= exp_cd;
        6'b0111_xx: _exp_DP4 <= exp_cd;
        6'b1000_xx: _exp_DP4 <= exp_ab;
        6'b1001_xx: _exp_DP4 <= exp_gh;
        6'b1010_0x: _exp_DP4 <= exp_ef;
        6'b1010_1x: _exp_DP4 <= exp_ab;
        6'b1011_xx: _exp_DP4 <= exp_ef;
        6'b1100_xx: _exp_DP4 <= exp_ab;
        6'b1101_xx: _exp_DP4 <= exp_gh;
        6'b1110_xx: _exp_DP4 <= exp_ab;
        default: _exp_DP4 <= exp_ab;
    endcase
end
assign exp_DP4 = (mode) ? _exp_DP4 : {3'b0, _exp_DP4[4:0]};

always @(*) begin
    casex({comp_ab_cd, comp_cd_ef, comp_ef_gh, comp_gh_ab, comp_ab_ef, comp_cd_gh})
        6'b0001_xx: shift_ab <= diff_gh_ab;
        6'b0010_xx: shift_ab <= diff_ab_ef;
        6'b0011_xx: shift_ab <= diff_ab_ef;
        6'b0100_xx: shift_ab <= diff_ab_cd;
        6'b0101_x0: shift_ab <= diff_gh_ab;
        6'b0101_x1: shift_ab <= diff_ab_cd;
        6'b0110_xx: shift_ab <= diff_ab_cd;
        6'b0111_xx: shift_ab <= diff_ab_cd;
        6'b1000_xx: shift_ab <= 0;
        6'b1001_xx: shift_ab <= diff_gh_ab;
        6'b1010_0x: shift_ab <= diff_ab_ef;
        6'b1010_1x: shift_ab <= 0;
        6'b1011_xx: shift_ab <= diff_ab_ef;
        6'b1100_xx: shift_ab <= 0;
        6'b1101_xx: shift_ab <= diff_gh_ab;
        6'b1110_xx: shift_ab <= 0;
        default: shift_ab <= 0;
    endcase
end

always @(*) begin
    casex({comp_ab_cd, comp_cd_ef, comp_ef_gh, comp_gh_ab, comp_ab_ef, comp_cd_gh})
        6'b0001_xx: shift_cd <= diff_cd_gh;
        6'b0010_xx: shift_cd <= diff_cd_ef;
        6'b0011_xx: shift_cd <= diff_cd_ef;
        6'b0100_xx: shift_cd <= 0;
        6'b0101_x0: shift_cd <= diff_cd_gh;
        6'b0101_x1: shift_cd <= 0;
        6'b0110_xx: shift_cd <= 0;
        6'b0111_xx: shift_cd <= 0;
        6'b1000_xx: shift_cd <= diff_ab_cd;
        6'b1001_xx: shift_cd <= diff_cd_gh;
        6'b1010_0x: shift_cd <= diff_cd_ef;
        6'b1010_1x: shift_cd <= diff_ab_cd;
        6'b1011_xx: shift_cd <= diff_cd_ef;
        6'b1100_xx: shift_cd <= diff_ab_cd;
        6'b1101_xx: shift_cd <= diff_cd_gh;
        6'b1110_xx: shift_cd <= diff_ab_cd;
        default: shift_cd <= 0;
    endcase
end

always @(*) begin
    casex({comp_ab_cd, comp_cd_ef, comp_ef_gh, comp_gh_ab, comp_ab_ef, comp_cd_gh})
        6'b0001_xx: shift_ef <= diff_ef_gh;
        6'b0010_xx: shift_ef <= 0;
        6'b0011_xx: shift_ef <= 0;
        6'b0100_xx: shift_ef <= diff_cd_ef;
        6'b0101_x0: shift_ef <= diff_ef_gh;
        6'b0101_x1: shift_ef <= diff_cd_ef;
        6'b0110_xx: shift_ef <= diff_cd_ef;
        6'b0111_xx: shift_ef <= diff_cd_ef;
        6'b1000_xx: shift_ef <= diff_ab_ef;
        6'b1001_xx: shift_ef <= diff_ef_gh;
        6'b1010_0x: shift_ef <= 0;
        6'b1010_1x: shift_ef <= diff_ab_ef;
        6'b1011_xx: shift_ef <= 0;
        6'b1100_xx: shift_ef <= diff_ab_ef;
        6'b1101_xx: shift_ef <= diff_ef_gh;
        6'b1110_xx: shift_ef <= diff_ab_ef;
        default: shift_ef <= 0;
    endcase
end

always @(*) begin
    casex({comp_ab_cd, comp_cd_ef, comp_ef_gh, comp_gh_ab, comp_ab_ef, comp_cd_gh})
        6'b0001_xx: shift_gh <= 0;
        6'b0010_xx: shift_gh <= diff_ef_gh;
        6'b0011_xx: shift_gh <= diff_ef_gh;
        6'b0100_xx: shift_gh <= diff_cd_gh;
        6'b0101_x0: shift_gh <= 0;
        6'b0101_x1: shift_gh <= diff_cd_gh;
        6'b0110_xx: shift_gh <= diff_cd_gh;
        6'b0111_xx: shift_gh <= diff_cd_gh;
        6'b1000_xx: shift_gh <= diff_gh_ab;
        6'b1001_xx: shift_gh <= 0;
        6'b1010_0x: shift_gh <= diff_ef_gh;
        6'b1010_1x: shift_gh <= diff_gh_ab;
        6'b1011_xx: shift_gh <= diff_ef_gh;
        6'b1100_xx: shift_gh <= diff_gh_ab;
        6'b1101_xx: shift_gh <= 0;
        6'b1110_xx: shift_gh <= diff_gh_ab;
        default: shift_gh <= 0;
    endcase
end

assign gclk = clk & mode;

always @(posedge gclk or posedge reset) begin
    if(reset) begin
        exp_DP4_reg[7:5] <= 0;
        shift_ab_reg[7:5] <= 0;
        shift_cd_reg[7:5] <= 0;
        shift_ef_reg[7:5] <= 0;
        shift_gh_reg[7:5] <= 0;
        part_prod0_0_reg[24:0] <= 0;
        part_prod0_1_reg[24:0] <= 0;
        part_prod1_0_reg[24:0] <= 0;
        part_prod1_1_reg[24:0] <= 0;
        part_prod2_0_reg[24:0] <= 0;
        part_prod2_1_reg[24:0] <= 0;
        part_prod3_0_reg[24:0] <= 0;
        part_prod3_1_reg[24:0] <= 0;
    end
    else begin
        exp_DP4_reg[7:5] <= exp_DP4[7:5];
        shift_ab_reg[7:5] <= shift_ab[7:5];
        shift_cd_reg[7:5] <= shift_cd[7:5];
        shift_ef_reg[7:5] <= shift_ef[7:5];
        shift_gh_reg[7:5] <= shift_gh[7:5];
        part_prod0_0_reg[24:0] <= part_prod0_0[24:0];
        part_prod0_1_reg[24:0] <= part_prod0_1[24:0];
        part_prod1_0_reg[24:0] <= part_prod1_0[24:0];
        part_prod1_1_reg[24:0] <= part_prod1_1[24:0];
        part_prod2_0_reg[24:0] <= part_prod2_0[24:0];
        part_prod2_1_reg[24:0] <= part_prod2_1[24:0];
        part_prod3_0_reg[24:0] <= part_prod3_0[24:0];
        part_prod3_1_reg[24:0] <= part_prod3_1[24:0];
    end
end

always @(posedge clk or posedge reset) begin
    if(reset) begin
        sign_ab_reg <= 0;
        sign_cd_reg <= 0;
        sign_ef_reg <= 0;
        sign_gh_reg <= 0;
        exp_DP4_reg[4:0] <= 0;
        shift_ab_reg[4:0] <= 0;
        shift_cd_reg[4:0] <= 0;
        shift_ef_reg[4:0] <= 0;
        shift_gh_reg[4:0] <= 0;
        part_prod0_0_reg[49:25] <= 0;
        part_prod0_1_reg[49:25] <= 0;
        part_prod1_0_reg[49:25] <= 0;
        part_prod1_1_reg[49:25] <= 0;
        part_prod2_0_reg[49:25] <= 0;
        part_prod2_1_reg[49:25] <= 0;
        part_prod3_0_reg[49:25] <= 0;
        part_prod3_1_reg[49:25] <= 0;
    end
    else begin
        sign_ab_reg <= sign_ab;
        sign_cd_reg <= sign_cd;
        sign_ef_reg <= sign_ef;
        sign_gh_reg <= sign_gh;
        exp_DP4_reg[4:0] <= exp_DP4[4:0];
        shift_ab_reg[4:0] <= shift_ab[4:0];
        shift_cd_reg[4:0] <= shift_cd[4:0];
        shift_ef_reg[4:0] <= shift_ef[4:0];
        shift_gh_reg[4:0] <= shift_gh[4:0];
        part_prod0_0_reg[49:25] <= part_prod0_0[49:25];
        part_prod0_1_reg[49:25] <= part_prod0_1[49:25];
        part_prod1_0_reg[49:25] <= part_prod1_0[49:25];
        part_prod1_1_reg[49:25] <= part_prod1_1[49:25];
        part_prod2_0_reg[49:25] <= part_prod2_0[49:25];
        part_prod2_1_reg[49:25] <= part_prod2_1[49:25];
        part_prod3_0_reg[49:25] <= part_prod3_0[49:25];
        part_prod3_1_reg[49:25] <= part_prod3_1[49:25];
    end
end



endmodule