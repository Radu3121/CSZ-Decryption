`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:12:00 11/23/2020 
// Design Name: 
// Module Name:    demux 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module demux #(
		parameter MST_DWIDTH = 32,
		parameter SYS_DWIDTH = 8
	)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Input interface
		input [MST_DWIDTH -1  : 0]	 data_i,
		input 						 	 valid_i,
		
		//output interfaces
		output reg [SYS_DWIDTH - 1 : 0] 	data0_o,
		output reg     						valid0_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data1_o,
		output reg     						valid1_o,
		
		output reg [SYS_DWIDTH - 1 : 0] 	data2_o,
		output reg     						valid2_o
    );
	
	

	// TODO: Implement DEMUX logic
	
	`define reset 0;
	`define write 1;
	`define read1 2;
	`define read2 3;
	`define read3 4;
	
	reg [7:0] data [0:3];
	reg [3:0] state = 0;
	reg [3:0] next_state;
	reg [2:0] index;
	
	always @(posedge clk_sys) begin
		if (!rst_n) begin
			state <= 0;
		end else begin
			state <= next_state;
		end
	end
	
	always @(*) begin
	
		case (state)
			0: begin
				data[0] = 0;
				data[1] = 0;
				data[2] = 0;
				data[3] = 0;
				valid0_o = 0;
				valid1_o = 0;
				valid2_o = 0;
				data0_o = 0;
				data1_o = 0;
				data2_o = 0;
				if (valid_i) begin
					data[0] = data_i[31:24];
					data[1] = data_i[23:16];
					data[2] = data_i[15:8];
					data[3] = data_i[7:0];
					case(select) 
						0: begin
							valid0_o = 1;
							data0_o = data[0];
						end
						1: begin
							valid0_o = 1;
							data1_o = data[0];
						end
						2: begin
							valid0_o = 1;
							data2_o = data[0];
						end
					endcase
					next_state = 1;
				end
			end
			
			1: begin
				case(select) 
					0: begin
						valid0_o = 1;
						data0_o = data[1];
					end
					1: begin
						valid0_o = 1;
						data1_o = data[1];
					end
					2: begin
						valid0_o = 1;
						data2_o = data[1];
					end
				endcase
				next_state = 2;
			end
			
			2: begin
				case(select) 
					0: begin
						valid0_o = 1;
						data0_o = data[2];
					end
					1: begin
						valid0_o = 1;
						data1_o = data[2];
					end
					2: begin
						valid0_o = 1;
						data2_o = data[2];
					end
				endcase
				next_state = 3;
			end
			
			3: begin
				case(select) 
					0: begin
						valid0_o = 1;
						data0_o = data[3];
					end
					1: begin
						valid0_o = 1;
						data1_o = data[3];
					end
					2: begin
						valid0_o = 1;
						data2_o = data[3];
					end
				endcase
				next_state = 0;
			end
			
		endcase
	end

endmodule
