//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2021 04:03:28 PM
// Design Name: 
// Module Name: Testbed_310591036
// Project Name: Merge Sort (2SRAMs)
// Target Devices: 
// Tool Versions: 
// Description: NYCU ICST DIC Exercise 5
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ps / 1ps
`include "Pattern_310591036.v"

`ifdef RTL
	`include "MS_310591036.v"
`endif

`ifdef GATE
  `include "Netlist/MS_310591036_SYN.v"
`endif

module Testbed_310591036;
    //input
    wire clk;
    wire rst_n;
    wire in_valid_Data;
    wire [11:0] Cnt_data;
    wire [31:0] Data;
    wire in_valid_Number;
    wire [9:0] Number;
    //output
    wire Out_valid;
    wire [31:0] Output;
    
	initial begin
	`ifdef RTL
		$fsdbDumpfile("MS.fsdb");
		$fsdbDumpvars(0, "+mda");
	`endif
	`ifdef GATE
		$sdf_annotate("Netlist/MS_310591036_SYN.sdf", Merge_Sort);
		$fsdbDumpfile("MS_310591036_SYN.fsdb");
		$fsdbDumpvars(0, "+mda");   
	`endif
	end
	
	`ifdef RTL
    MS_310591036 Merge_Sort(
        .clk(clk),
        .rst_n(rst_n),
        .in_valid_Data(in_valid_Data),
        .Cnt_data(Cnt_data),
        .Data(Data),
        .in_valid_Number(in_valid_Number),
        .Number(Number),
        .Out_valid(Out_valid),
        .Output(Output)
        );
	`endif
	
	`ifdef GATE
	MS_310591036 Merge_Sort(
        .clk(clk),
        .rst_n(rst_n),
        .in_valid_Data(in_valid_Data),
        .Cnt_data(Cnt_data),
        .Data(Data),
        .in_valid_Number(in_valid_Number),
        .Number(Number),
        .Out_valid(Out_valid),
        .Output(Output)
        );
	`endif
	
    Pattern_310591036 MS_Pattern(
        .clk(clk),
        .rst_n(rst_n),
        .in_valid_Data(in_valid_Data),
        .Cnt_data(Cnt_data),
        .Data(Data),
        .in_valid_Number(in_valid_Number),
        .Number(Number),
        .Out_valid(Out_valid),
        .Output(Output)
        );
endmodule
