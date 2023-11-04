///////////////////////////////////////////////////////////
////////         Last edit: 2022/10/21 22:26        ///////
////////         Author: Rick Lin                   ///////
///////////////////////////////////////////////////////////
`timescale 1ns/1ps
`include "/EDA_Tools/Synopsys/synthesis/2018.06/dw/sim_ver/DW02_multp.v"

module Dadda_tree(
    inst_a, inst_b, 
    part_prod1, part_prod2
);

input [23:0] inst_a, inst_b;
output [49:0] part_prod1, part_prod2;

DW02_multp #(24, 24, 50, 3) M0(
    .a(inst_a), .b(inst_b),.tc(1'b0),                 // tc = 0 for unsigned multiplication
    .out0(part_prod1), .out1(part_prod2)
 );



endmodule