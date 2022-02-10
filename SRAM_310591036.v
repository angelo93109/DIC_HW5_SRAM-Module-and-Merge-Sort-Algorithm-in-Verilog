`timescale 1ps / 1ps
//==============================================
//==============================================				
//	Author	:	Yen-Chieh Yu																	
//----------------------------------------------
//												
//	File Name		:	sram.v					
//	Module Name		:	sram						
//	Release version	:	v1.0					
//												
//----------------------------------------------								
//----------------------------------------------											
//	Input	:	clk,
//				rst_n,
//              IFM,
//				Weights,					
//												
//	Output	:	OFM,
//				out_valid					
//==============================================
//==============================================

module sram(input clk,
			input CEN,
			input WEN, 
			input [31:0] Din,
			input [8:0] Address,
			output reg signed [31:0] Dout //512 32-bits SRAMs
			);
			
	reg signed [31:0] temp [511:0];
	reg signed [31:0] out_buffer;
	reg notice; 
	
	////////////timing specification
	specify
		//$setuphold(posedge clk, Din, 20, 20, notice);	    //setup time 20ps, hold time 20ps
		$setup(Din, posedge clk, 20, notice);
		$hold(posedge clk, Din, 20, notice);
		$period(posedge clk, 500, notice);		      //Maximum Freq 2GHz, Minimum period 500ps
	endspecify
	
	always @(notice) 
	  begin 
	     Dout <= 32'hXXXXXXXX;
	     temp[Address] <= 32'hXXXXXXXX;
	  end
	
	//////////sram function
	always @(posedge clk)
	begin
		if(!CEN)  //CEN=0 enable
			begin
				if(!WEN)   //WEN=0 Write Operation
					temp[Address] <= Din;
				else if (WEN)	   //WEN=1 Read Operation
					out_buffer = temp[Address];
				    #450
			        Dout = out_buffer;
			end
		else if (CEN) 	//CEN=1 Disable
			Dout <= 32'h0;
	end	
endmodule
			
		