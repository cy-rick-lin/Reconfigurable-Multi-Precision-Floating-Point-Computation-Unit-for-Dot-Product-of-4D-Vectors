///////////////////////////////////////////////////////////
////////         Last edit: 2022/11/19 17:09        ///////
////////         Author: Rick Lin                   ///////
////////         Min time: 0.59 ns                  ///////
///////////////////////////////////////////////////////////
`timescale 1ns/1ps

module DP4_pipe_stage4(
    mode, clk, reset,
    sign_DP4_reg,
    exp_DP4_3_reg, LOD_reg,
    mantissa_DP4_reg, 
    DP4
);

input mode, clk, reset;
input sign_DP4_reg;
input [7:0] exp_DP4_3_reg, LOD_reg;
input [51:0] mantissa_DP4_reg;
output reg [31:0] DP4;

reg [7:0] exp_DP4_4;
reg [51:0] mantissa_DP4_1;

wire [7:0] LOD, exp_DP4_5;
wire [15:0] DP4_16;
wire [22:0] mantissa_DP4_4;
wire [23:0] mantissa_DP4_2;
wire [24:0] mantissa_DP4_round, mantissa_DP4_3;
wire [31:0] DP4_32;
wire [51:0] mantissa_DP4;

wire [4:0] exp_DP4_16;
wire [9:0] mantissa_DP4_16_3;
wire [10:0] mantissa_DP4_16_1;
wire [11:0] mantissa_DP4_round_16, mantissa_DP4_16_2;



always @(*) begin
    if(LOD_reg < 5) begin
        mantissa_DP4_1 <= mantissa_DP4_reg >> (5 - LOD_reg);
        exp_DP4_4 <= exp_DP4_3_reg + (5 - LOD_reg);
    end
    
    else begin
        mantissa_DP4_1 <= mantissa_DP4_reg << (LOD_reg - 5);
        exp_DP4_4 <= exp_DP4_3_reg - (LOD_reg - 5);
    end
end

// FLP 32
assign mantissa_DP4_2 = mantissa_DP4_1[46:23];              // 24 bits, {hidden, mantissa}

assign Guard_DP4 = mantissa_DP4_1[22];
assign Round_DP4 = mantissa_DP4_1[21];
assign Sticky_DP4 = |mantissa_DP4_1[20:0];

assign carry_DP4 = ( Guard_DP4 & (Round_DP4 | mantissa_DP4_1[23] | Sticky_DP4) );

assign mantissa_DP4_round = {1'b0, mantissa_DP4_2} + {24'b0, carry_DP4};          // 25 bits, {carry, hidden, mantissa}

assign mantissa_DP4_3 = (mantissa_DP4_reg[51] | mantissa_DP4_reg[50] | mantissa_DP4_reg[49] | mantissa_DP4_reg[48] | mantissa_DP4_reg[47]) ? mantissa_DP4_round : {1'b0, mantissa_DP4_2};

assign mantissa_DP4_4 = (mantissa_DP4_3[24]) ? (mantissa_DP4_3[23:1]) : mantissa_DP4_3[22:0];
assign exp_DP4_5 = exp_DP4_4 + {7'b0, mantissa_DP4_3[24]};

assign DP4_32 = {sign_DP4_reg, exp_DP4_5, mantissa_DP4_4};

// FLP 16
assign mantissa_DP4_16_1 = mantissa_DP4_1[46:36];    // 11 bits, {hidden, mantissa}

assign Guard_DP4_16 = mantissa_DP4_1[35];
assign Round_DP4_16 = mantissa_DP4_1[34];
assign Sticky_DP4_16 = |mantissa_DP4_1[33:25];          // 47:26

assign carry_DP4_16 = Guard_DP4_16 & (Round_DP4_16 | mantissa_DP4_1[36] | Sticky_DP4_16);

assign mantissa_DP4_round_16 = {1'b0, mantissa_DP4_16_1} + {11'b0, carry_DP4};          // 12 bits, {carry, hidden, mantissa}

assign mantissa_DP4_16_2 = (mantissa_DP4_reg[51] | mantissa_DP4_reg[50] | mantissa_DP4_reg[49] | mantissa_DP4_reg[48] | mantissa_DP4_reg[47]) ? mantissa_DP4_round_16 : {1'b0, mantissa_DP4_16_1};

assign mantissa_DP4_16_3 = (mantissa_DP4_16_2[11]) ? (mantissa_DP4_16_2[10:1]) : mantissa_DP4_16_2[9:0];
assign exp_DP4_16 = exp_DP4_4[4:0] + {4'b0, mantissa_DP4_16_2[11]};

assign DP4_16 = {sign_DP4_reg, exp_DP4_16, mantissa_DP4_16_3};


assign gclk = clk & mode;

always @(posedge gclk or posedge reset) begin
    if(reset)
        DP4[31:16] <= 0;
    
    else
        DP4[31:16] <= DP4_32[31:16];
end

always @(posedge clk or posedge reset) begin
    if(reset)
        DP4[15:0] <= 0;

    else
        DP4[15:0] <= (mode) ? DP4_32[15:0] : DP4_16;
end





endmodule