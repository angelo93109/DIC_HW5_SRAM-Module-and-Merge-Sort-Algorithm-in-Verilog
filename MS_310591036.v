`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2021 04:03:28 PM
// Design Name: 
// Module Name: MS_310591036
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//synopsys translate_off
`include "SRAM_310591036.v"
//synopsys translate_on


module MS_310591036(
    input clk,
    input rst_n,
    input in_valid_Data,
    input [11:0] Cnt_data,
    input signed [31:0] Data,
    input in_valid_Number,
    input [9:0] Number,
    output reg Out_valid,
    output reg signed [31:0] Output
    );
    
    //------------------------------
    //	Parameter & Integer
    //------------------------------
    //FSM_1 GET DATA & NUM
	parameter IDLE = 4'd0;
    parameter DATA1 = 4'd1;
	parameter DATA2 = 4'd2;
	parameter DATA2_NUM1 = 4'd3;
	parameter DATA1_NUM2 = 4'd4;
	parameter WAIT = 4'd5;
    parameter NUM2 = 4'd6;
	parameter OUT = 4'd7;
	parameter DO_NOTHING = 4'd8;
	parameter MAXTWO_1 = 4'd9;
	parameter MAXTWO_2 = 4'd10;
	parameter STORE = 4'd11;
	parameter MS2V2_1 = 4'd12;
	parameter MS2V2_2 = 4'd13;
	parameter MS4V4 = 4'd14; 
    //------------------------------
    //	Reg & Wire Declaration
    //------------------------------
    reg [3:0] cstate;
    reg [3:0] nstate;
    reg CEN_1;
    reg CEN_2;
    reg WEN_1;
    reg WEN_2;	
	reg signed [31:0] Data_1;
	reg signed [31:0] Data_2;
	reg [8:0] Address_1;
	reg [8:0] Address_2;
	
	wire signed [31:0] Din_1;
	wire signed [31:0] Din_2;
    wire signed [31:0] Output_Value_1;
	wire signed [31:0] Output_Value_2;
	
	reg [3:0] cstate_sort;
	reg [3:0] nstate_sort; 
	reg [3:0] count_10;
	reg [2:0] count_4;
	reg [2:0] count_output;
	reg [2:0] i;
	reg [2:0] j;
    reg signed [31:0] max_first;
    reg signed [31:0] max_second;
	
    reg signed [31:0] OUT1_1 [1:0];
	reg signed [31:0] OUT1_2 [1:0];
	reg signed [31:0] OUT1_3 [1:0];
	reg signed [31:0] OUT1_4 [1:0];
	reg signed [31:0] OUT2_1 [3:0];
	reg signed [31:0] OUT2_2 [3:0];
	reg signed [31:0] Final_OUT [7:0];
    // Two SRAMs Module
    sram sram_1(
        .clk(clk),
        .CEN(CEN_1),
        .WEN(WEN_1),
        .Din(Din_1),
        .Address(Address_1),
        .Dout(Output_Value_1)
        );
        
    sram sram_2(
        .clk(clk),
        .CEN(CEN_2),
        .WEN(WEN_2),
        .Din(Din_2),
        .Address(Address_2),
        .Dout(Output_Value_2)
        );
    //----------------------------------------------
    //	Finite State Machine (FSM)
    //----------------------------------------------
	assign Din_1 = Data_1;
	assign Din_2 = Data_2;
	
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            cstate <= IDLE;
        else
            cstate <= nstate;
    end
	
    always @(*)
    begin
        case(cstate)
			IDLE:	// 0
				begin
					if (in_valid_Data)
						nstate = DATA1;
					else
						nstate = cstate;
				end
            DATA1:	// 1
				begin
					if(Cnt_data == 511 || Cnt_data == 1535) 
						nstate = DATA2;
					else if(Cnt_data == 1024)
						nstate = DATA1_NUM2;
					else
						nstate = cstate;
				end
			DATA2:	// 2
				begin
					if(Cnt_data==1023) 
						nstate = DATA1;
					else if(Cnt_data == 512 || Cnt_data == 1536)
						nstate = DATA2_NUM1;
					else if (Cnt_data == 2047) 
						nstate = WAIT;
					else
						nstate = cstate;
				end
            DATA2_NUM1:	// 3
				begin
					if(Cnt_data == 522 || Cnt_data == 1546) 
						nstate = DATA2;
					else
						nstate = cstate;
				end
            DATA1_NUM2:	// 4
				begin
					if(Cnt_data == 1034) 
						nstate = DATA1;
					else
						nstate = cstate;
				end
			WAIT:	// 5
				begin
					if(Cnt_data == 2048)
						nstate = NUM2;
					else if (Cnt_data == 2079 || Cnt_data == 2080)
						nstate = OUT;
					else 
						nstate = cstate;
				end
            NUM2:	// 6
				begin
					if(Cnt_data == 2058)
						nstate = WAIT;
					else
						nstate = cstate;
				end
			OUT:	// 7
				begin
					if(count_output == 7)
						nstate = IDLE; 
					else 
						nstate = cstate;
				end
			default
                nstate = cstate;
        endcase
    end
    
	//Send Data at posedge clk
	always @(*)
	begin
		if(!rst_n)
			begin
				Data_1 <= 0;
				Data_2 <= 0;
			end
		else if (in_valid_Data == 1 && Cnt_data == 0)
			begin
				Data_1 <= Data;
				Data_2 <= 0;
			end
		else if (cstate == IDLE)
			begin
				Data_1 <= 0;
				Data_2 <= 0;
			end
		else if (cstate == DATA1)
			begin
				Data_1 <= Data;
				Data_2 <= 0;
			end
		else if (cstate == DATA2)
			begin
				Data_1 <= 0;
				Data_2 <= Data;
			end
		else if (cstate == DATA2_NUM1)
			begin
				Data_1 <= 0;
				Data_2 <= Data;
			end
		else if (cstate == DATA1_NUM2)
			begin
				Data_1 <= Data;
				Data_2 <= 0;
			end
		else if (cstate == WAIT)
			begin
				Data_1 <= 0;
				Data_2 <= 0;
			end
		else if (cstate == NUM2)
			begin
				Data_1 <= 0;
				Data_2 <= 0;
			end
		else if (cstate == OUT)
			begin
				Data_1 <= 0;
				Data_2 <= 0;
			end
		else 
			begin
				Data_1 <= Data_1;
				Data_2 <= Data_2;
			end
	end
	//CEN & WEN signal to SRAM	
    always @(*)
    begin
        if(!rst_n)
            begin
                CEN_1 <= 1'd1; //disable sram1
                CEN_2 <= 1'd1; //disable sram2
				WEN_1 <= 1'd0;
				WEN_2 <= 1'd0;
            end
		else if (cstate == IDLE)
			begin
				if(rst_n)
					begin
						CEN_1 <= 1'd0;
						WEN_1 <= 1'd0; //write sram1
					end
				else
					begin
						CEN_1 <= 1'd1;
						WEN_1 <= 1'd0;
					end
                CEN_2 <= 1'd1; //disable sram2
				WEN_2 <= 1'd0;
			end
        else if(cstate == DATA1) //in_valid_Number = 0, in_valid_DATA=1, write SRAM1
            begin
                CEN_1 <= 1'd0;
				CEN_2 <= 1'd1;
				WEN_1 <= 1'd0; //write sram1
				WEN_2 <= 1'd0;
            end
		else if (cstate == DATA2)
            begin
				CEN_1 <= 1'd1;
				CEN_2 <= 1'd0;
				WEN_1 <= 1'd0;
				WEN_2 <= 1'd0;	//write sram2
            end
        else if(cstate == DATA2_NUM1) //in_valid_Number = 1, in_valid_DATA=1
            begin
                CEN_1 <= 1'd0;
                CEN_2 <= 1'd0;
				WEN_1 <= 1'd1;	//read sram1
                WEN_2 <= 1'd0;	//write sram2
            end
        else if (cstate == DATA1_NUM2)
            begin
                CEN_1 <= 1'd0;
                CEN_2 <= 1'd0;
				WEN_1 <= 1'd0;	//write sram1
                WEN_2 <= 1'd1;	//read sram2			
            end
		else if(cstate == WAIT)
			begin
				CEN_1 <= 1'd1; //disable sram1
				CEN_2 <= 1'd1; //disable sram2
				WEN_1 <= 1'd0;
				WEN_2 <= 1'd0;
			end
        else if(cstate == NUM2)
            begin
				CEN_1 <= 1'd1;
                CEN_2 <= 1'd0;
				WEN_1 <= 1'd0;	//write sram1
                WEN_2 <= 1'd1;  //read sram1
            end
        else
            begin
				CEN_1 <= CEN_1;
				CEN_2 <= CEN_2;
				WEN_1 <= WEN_1;
				WEN_2 <= WEN_2;
            end
    end
	
	//Address Signal
	always@(*)
	begin
		if(!rst_n) 
			begin
				Address_1 <= 0;
				Address_2 <= 0;
			end
		else if (cstate == IDLE)
			begin
				Address_1 <= 0;
				Address_2 <= 0;
			end
		else if (cstate == DATA1)
			begin
				Address_1 <= Cnt_data;
				Address_2 <= 0;
			end
		else if (cstate == DATA2)
			begin
				Address_1 <= 0;
				Address_2 <= Cnt_data;
			end
		else if(cstate == DATA2_NUM1)
			begin
				if(Cnt_data <= 512)
					Address_1 <= 0;
				else
					Address_1 <= Number;

				Address_2 <= Cnt_data;
			end
		else if(cstate == DATA1_NUM2)
			begin
				Address_1 <= Cnt_data;
				Address_2 <= Number;
			end
		else if (cstate == WAIT)
			begin
				Address_1 <= 0;
				Address_2 <= 0;
			end
		else if(cstate == NUM2)
			begin
				Address_1 <= 0;
				Address_2 <= Number;
			end
		else 
			begin
				Address_1 <= Address_1;
				Address_2 <= Address_2;
			end
	end
	//-------------------------------------------------------------
	// FSM for SORTING
	//-------------------------------------------------------------	
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            cstate_sort <= DO_NOTHING;
        else
            cstate_sort <= nstate_sort;
    end

	always @(*)
	begin
		case(cstate_sort)
			DO_NOTHING:	// 8
				begin
					if(Cnt_data == 513 || Cnt_data == 1537)
						begin
							nstate_sort = MAXTWO_1;
							//count_4 = count_4 + 1;
						end
					else if (Cnt_data == 1025 || Cnt_data == 2049)
						begin
							nstate_sort = MAXTWO_2;
							//count_4 = count_4 + 1;
						end 
					else if (Cnt_data == 2060 || Cnt_data == 2061)
						begin
							nstate_sort = MS2V2_1;
						end
					else if(Cnt_data == 2065 || Cnt_data == 2066)
						begin
							nstate_sort = MS2V2_2;
						end
					else if(Cnt_data == 2070 || Cnt_data == 2071)
						begin
							nstate_sort = MS4V4;
						end
					else 
						begin
							nstate_sort = cstate_sort;
						end
				end
			MAXTWO_1:	// 9
				begin
					if(count_10 > 8)
						nstate_sort = STORE;
					else 
						nstate_sort = cstate_sort;
				end
			MAXTWO_2:	// 10
				begin
					if(count_10 > 8)
						nstate_sort = STORE;
					else 
						nstate_sort = cstate_sort;
				end
			STORE:	// 11
				begin
					nstate_sort = DO_NOTHING;
				end
			MS2V2_1:	// 12
				begin
					if(count_10 == 3)
						nstate_sort = DO_NOTHING;
					else 
						nstate_sort = cstate_sort;
				end
			MS2V2_2:	// 13
				begin
					if(count_10 == 3)
						nstate_sort = DO_NOTHING;
					else 
						nstate_sort = cstate_sort;
				end
			MS4V4:	// 14
				begin
					if(Cnt_data == 2080)
						nstate_sort = DO_NOTHING;
					else
						nstate_sort = cstate_sort;
				end
			default
				nstate_sort = cstate_sort;
		endcase
	end
	
	always @(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
			begin
				max_first <= 0;
				max_second <= 0;
				count_10 <= 0;
				count_4 <= 0;
				OUT1_1[0] <= 0;
				OUT1_1[1] <= 0;
				OUT1_2[0] <= 0;
				OUT1_2[1] <= 0;
				OUT1_3[0] <= 0;
				OUT1_3[1] <= 0;
				OUT1_4[0] <= 0;
				OUT1_4[1] <= 0;
				OUT2_1[0] <= 0;
				OUT2_1[1] <= 0;
				OUT2_1[2] <= 0;
				OUT2_1[3] <= 0;
				OUT2_2[0] <= 0;
				OUT2_2[1] <= 0;
				OUT2_2[2] <= 0;
				OUT2_2[3] <= 0;
				Final_OUT[0] <= 0;
				Final_OUT[1] <= 0;
				Final_OUT[2] <= 0;
				Final_OUT[3] <= 0;
				Final_OUT[4] <= 0;
				Final_OUT[5] <= 0;
				Final_OUT[6] <= 0;
				Final_OUT[7] <= 0;
				i = 0;
				j = 0;
			end
			
		else if(cstate_sort == DO_NOTHING)
			begin
				max_first <= 0;
				max_second <= 0;
				count_10 <= 0;
				count_4 <= count_4;
				i = 0;
				j = 0;
			end
			
		else if(cstate_sort == MAXTWO_1)
			begin
				if(count_10 == 0)
					begin
						max_first <= Output_Value_1;
						max_second <= max_second;
					end
				else if(count_10 == 1)
					begin
						if(Output_Value_1 > max_first)
							begin
								max_second <= max_first;
								max_first <= Output_Value_1;
							end
						else 
							begin
								max_second <= Output_Value_1;
								max_first <= max_first;
							end
					end
				else 
					begin
						if(Output_Value_1 > max_first) //c > a > b
							begin
								max_first <= Output_Value_1;
								max_second <= max_first;
							end
						else if((Output_Value_1 <= max_first) && (Output_Value_1 > max_second)) //a >= c > b
							begin
								max_second <= Output_Value_1;
								max_first <= max_first;
							end
						else
							begin
								max_first <= max_first;
								max_second <= max_second;
							end
					end
				count_10 <= count_10 + 1;
			end
			
		else if(cstate_sort == MAXTWO_2)
			begin
				if(count_10 == 0)
					begin
						max_first <= Output_Value_2;
						max_second <= max_second;
				    end
				else if(count_10 == 1)
					begin
						if(Output_Value_2 > max_first)
							begin
								max_first <= Output_Value_2;
								max_second <= max_first;
							end
						else 
							begin
								max_first <= max_first;
								max_second <= Output_Value_2;
							end
					end
				else 
					begin
						if(Output_Value_2 > max_first) //c > a > b
							begin
								max_first <= Output_Value_2;
								max_second <= max_first;
							end
						else if((Output_Value_2 <= max_first) && (Output_Value_2 > max_second)) //a >= c > b
							begin
								max_first <= max_first;
								max_second <= Output_Value_2;
							end
						else
							begin
								max_first <= max_first;
								max_second <= max_second;
							end
					end
				count_10 <= count_10 + 1;
			end
		
		else if(cstate_sort == STORE)
			begin
				count_4 <= count_4 + 1;
				if(count_4 == 0)
					begin
						OUT1_1[0] <= max_first;
						OUT1_1[1] <= max_second;
					end
				else if(count_4 == 1)
					begin
						OUT1_2[0] <= max_first;
						OUT1_2[1] <= max_second;
					end
				else if(count_4 == 2)
					begin
						OUT1_3[0] <= max_first;
						OUT1_3[1] <= max_second;
					end
				else if(count_4 == 3)
					begin
						OUT1_4[0] <= max_first;
						OUT1_4[1] <= max_second;
					end
				else
					begin
						OUT1_1[0] <= OUT1_1[0];
						OUT1_1[1] <= OUT1_1[1];
						OUT1_2[0] <= OUT1_2[0];
						OUT1_2[1] <= OUT1_2[1];
						OUT1_3[0] <= OUT1_3[0];
						OUT1_3[1] <= OUT1_3[1];
						OUT1_4[0] <= OUT1_4[0];
						OUT1_4[1] <= OUT1_4[1];
					end
			end
		else if (cstate_sort == MS2V2_1)
			begin
				if(count_10 == 3)
					begin
						OUT2_1[count_10] <= (i==2) ? OUT1_2[1] : OUT1_1[1];
					end
				else if(OUT1_1[i] > OUT1_2[j])
					begin
						OUT2_1[count_10] <= OUT1_1[i];
						i = i + 1;
					end
				else // OUT1_1[i] <= OUT1_2[j]
					begin
						OUT2_1[count_10] <= OUT1_2[j];
						j = j + 1;
					end
				count_10 <= count_10 + 1;
			end
		else if (cstate_sort == MS2V2_2)
			begin
				if(count_10 == 3)
					begin
						OUT2_2[count_10] <= (i==2) ? OUT1_4[1] : OUT1_3[1];
					end
				else if(OUT1_3[i] > OUT1_4[j])
					begin
						OUT2_2[count_10] <= OUT1_3[i];
						i = i + 1;
					end
				else // OUT1_3[i] <= OUT1_4[j]
					begin
						OUT2_2[count_10] <= OUT1_4[j];
						j = j + 1;
					end
				count_10 <= count_10 + 1;
			end
		else if (cstate_sort == MS4V4)
			begin
				if(count_10 == 8)
					begin
						Final_OUT[count_10] <= (i==4) ? OUT2_2[3] : OUT2_1[3];
					end
				else if(OUT2_1[i] > OUT2_2[j])
					begin
						Final_OUT[count_10] <= OUT2_1[i];
						i = i + 1;
					end
				else // OUT2_1[i] <= OUT2_2[j]
					begin
						Final_OUT[count_10] <= OUT2_2[j];
						j = j + 1;
					end
				count_10 <= count_10 + 1;
			end
		else
			begin
				max_first <= max_first;
				max_second <= max_second;
				count_10 <= count_10;
				count_4 <= count_4;
				OUT1_1[0] <= OUT1_1[0];
				OUT1_1[1] <= OUT1_1[1];
				OUT1_2[0] <= OUT1_2[0];
				OUT1_2[1] <= OUT1_2[1];
				OUT1_3[0] <= OUT1_3[0];
				OUT1_3[1] <= OUT1_3[1];
				OUT1_4[0] <= OUT1_4[0];
				OUT1_4[1] <= OUT1_4[1];
				OUT2_1[0] <= OUT2_1[0];
				OUT2_1[1] <= OUT2_1[1];
				OUT2_1[2] <= OUT2_1[2];
				OUT2_1[3] <= OUT2_1[3];
				OUT2_2[0] <= OUT2_2[0];
				OUT2_2[1] <= OUT2_2[1];
				OUT2_2[2] <= OUT2_2[2];
				OUT2_2[3] <= OUT2_2[3];
				Final_OUT[0] <= Final_OUT[0];
				Final_OUT[1] <= Final_OUT[1];
				Final_OUT[2] <= Final_OUT[2];
				Final_OUT[3] <= Final_OUT[3];
				Final_OUT[4] <= Final_OUT[4];
				Final_OUT[5] <= Final_OUT[5];
				Final_OUT[6] <= Final_OUT[6];
				Final_OUT[7] <= Final_OUT[7];
				i = i;
				j = j;
			end
	end
	
//--------------------------------------------------------------------
//		OUTPUT
//--------------------------------------------------------------------
	always @(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				begin
					Output <= 32'd0;
					count_output <= 3'd0;
				end
			else if (cstate == IDLE)
				begin
					Output <= 32'd0;
					count_output <= 3'd0;
				end
			else if(cstate == OUT)
				begin
					Output <= Final_OUT[count_output];
					count_output <= count_output + 1;
				end
			else
				begin
					Output <= Output;
					count_output <= count_output;
				end
		end
	always @(posedge clk or negedge rst_n)
		begin
			if(!rst_n)
				Out_valid <= 1'd0;
			else if(cstate == IDLE)
				Out_valid <= 1'd0;
			else if(cstate == OUT)
                Out_valid <= 1'd1;
			else
				Out_valid <= Out_valid; 
		end
endmodule