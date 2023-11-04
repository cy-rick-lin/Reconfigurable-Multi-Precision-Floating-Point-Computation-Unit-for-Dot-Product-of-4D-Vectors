///////////////////////////////////////////////////////////
////////         Last edit: 2022/9/22 11:18        ////////
///////////////////////////////////////////////////////////

`timescale 1ns/1ps
`define CYCLE  2.29      // Modify your clock period here
`define INPUT_32 "./TestData/FP32.txt"
`define OUTPUT_32 "./TestData/FP32_answer.txt"
`define INPUT_16 "./TestData/FP16.txt"
`define OUTPUT_16 "./TestData/FP16_answer.txt"
`define SDFFILE "./DP4_pipe_dc_report/DP4_pipe_syn.sdf"
`define End_CYCLE  1000000
//`include "DP4_pipe.v"

module TB_DP4_pipe();

parameter width = 32;
parameter DatasetNum = 1000;

integer i, j, k, l, mem, process, err, out_f;
reg [width-1:0] INPUT_32 [0:DatasetNum-1][0:7];
reg [width-1:0] OUTPUT_32 [0:DatasetNum-1];
reg [15:0] INPUT_16 [0:DatasetNum-1][0:7];
reg [15:0] OUTPUT_16 [0:DatasetNum-1];

reg mode, clk, reset;
reg [31:0] OUTPUT;
reg [width-1:0] INPUT [0:DatasetNum-1][0:7];
reg [31:0] a, b, c, d, e, f, g, h;
wire [31:0] DP4;

initial begin
    $dumpvars(0, TB_DP4_pipe);
	$dumpfile("DP4_pipe.vcd");
    $fsdbDumpfile("DP4_pipe.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;
end

`ifdef SDF
    initial $sdf_annotate(`SDFFILE, D0);
`endif

`ifdef mode32
    initial begin
        mode = 1;
        mem = $fopen(`INPUT_32, "r");

        if(mem==0) begin
            $display("Memory file open error !");
		    $finish;
        end
        else
            $display("Memory file opened successfully !");

        for(k = 0; k < DatasetNum; k = k + 1) begin
            process = $fscanf(
                mem, "%h %h %h %h %h %h %h %h", 
                INPUT[k][0], INPUT[k][1], INPUT[k][2], INPUT[k][3], 
                INPUT[k][4], INPUT[k][5], INPUT[k][6], INPUT[k][7]
            );
            end

        $fclose(mem);
        $readmemh(`OUTPUT_32, OUTPUT_32);
    end
`else
    initial begin
        mode = 0;
        mem = $fopen(`INPUT_16, "r");

        for(l = 0; l < DatasetNum; l = l + 1) begin
            process = $fscanf(
                mem, "%h %h %h %h %h %h %h %h", 
                INPUT_16[l][0], INPUT_16[l][1], INPUT_16[l][2], INPUT_16[l][3],
                INPUT_16[l][4], INPUT_16[l][5], INPUT_16[l][6], INPUT_16[l][7]
                );
        end

        $fclose(mem);
        $readmemb(`OUTPUT_16, OUTPUT_16);
    end
`endif

initial begin
	out_f = $fopen("DP4_pipe.txt");

	if(out_f == 0) begin
		$display("Output file open error !");
		$finish;
	end
	
	else
		$display("Output file open successfully !");
end
    

DP4_pipe D0(
    mode, clk, reset,
    a, b, c, d, e, f, g, h, DP4
);

initial begin
    #(`CYCLE/4)
        reset = 1;

    #`CYCLE
        reset = 0;
end

always begin
    #(`CYCLE/2) clk = ~clk;
end

initial begin
    clk = 0;
    reset = 0;
    a = 0;
    b = 0;
    c = 0;
    d = 0;
    e = 0;
    f = 0;
    g = 0;
    h = 0;
    i = 0;
    j = 0;
    err = 0;

    #(`CYCLE/2 + `CYCLE/20 + `CYCLE);

    for(j = 0; j < DatasetNum; j = j + 1) begin
        a = (mode) ? INPUT[j][0] : {16'b0, INPUT_16[j][0]};
        b = (mode) ? INPUT[j][4] : {16'b0, INPUT_16[j][4]};
        c = (mode) ? INPUT[j][1] : {16'b0, INPUT_16[j][1]};
        d = (mode) ? INPUT[j][5] : {16'b0, INPUT_16[j][5]};
        e = (mode) ? INPUT[j][2] : {16'b0, INPUT_16[j][2]};
        f = (mode) ? INPUT[j][6] : {16'b0, INPUT_16[j][6]};
        g = (mode) ? INPUT[j][3] : {16'b0, INPUT_16[j][3]};
        h = (mode) ? INPUT[j][7] : {16'b0, INPUT_16[j][7]};
        #`CYCLE ;
    end
end

initial begin
    #(`CYCLE/2 + `CYCLE + `CYCLE * 5);

    for(i = 0; i < DatasetNum; i = i + 1) begin
        OUTPUT = (mode) ? OUTPUT_32[i] : {16'b0, OUTPUT_16[i]};

        if(DP4 == OUTPUT);

        else begin
            if(mode==1) begin
                /*$display("Error at TestData %d, DP4=%b %d %b", i+1, DP4[31], DP4[30:23], DP4[22:0]);
                $display("                               Ans=%b %d %b", OUTPUT[31], OUTPUT[30:23], OUTPUT[22:0]);
                $display("DP4=%h Ans=%h", DP4, OUTPUT);
                $display("-------------------------------------");*/

                $fdisplay(out_f, "%h", DP4);
                err = err + 1;
            end

            else begin
                /*$display("Error at TestData %d, DP4=%b %d %b", i+1, DP4[15], DP4[14:10], DP4[9:0]);
                $display("                               Ans=%b %d %b", OUTPUT[15], OUTPUT[14:10], OUTPUT[9:0]);
                $display("DP4=%h Ans=%h", DP4[15:0], OUTPUT[15:0]);
                $display("-------------------------------------");*/

                $fdisplay(out_f, "%h", DP4[15:0]);
                err = err + 1;
            end
        end

        # `CYCLE;
    end
    $display("There are %d errors", err);

    $finish;
end


initial  begin
	#`End_CYCLE ;
	
		$display("-----------------------------------------------------\n");
		$display("Error!!! The simulation can't be terminated under normal operation!\n");
		$display("There are %d errors!", err);
		$display("-------------------------FAIL------------------------\n");
		$display("-----------------------------------------------------\n");
		$finish;

end



endmodule