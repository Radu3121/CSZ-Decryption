`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:53:30 11/26/2020 
// Design Name: 
// Module Name:    mux 
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
module mux #(
		parameter D_WIDTH = 8
	)(
		// Clock and reset interface
		input clk,
		input rst_n,
		
		//Select interface
		input[1:0] select,
		
		// Output interface
		output reg[D_WIDTH - 1 : 0] data_o,
		output reg						 valid_o,
				
		//output interfaces
		input [D_WIDTH - 1 : 0] 	data0_i,
		input   							valid0_i,
		
		input [D_WIDTH - 1 : 0] 	data1_i,
		input   							valid1_i,
		
		input [D_WIDTH - 1 : 0] 	data2_i,
		input     						valid2_i
    );
	
	//TODO: Implement MUX logic here
		
		reg [1:0] state = 0;
		reg [1:0] next_state = 0;
		reg [7:0] data;
		
		always @(posedge clk) begin
			if (!rst_n) begin
				state <= 0;
			end else begin
				state <= next_state;
			end
		end
		
		always @(*) begin
			case (state)
				0: begin
					data_o = 0;
					valid_o = 0;
					data = 0;
					if (valid0_i) begin
						data = data0_i;
						next_state = 1;
					end
					if (valid1_i) begin
						data = data1_i;
						next_state = 1;
					end
					if (valid2_i) begin
						data = data2_i;
						next_state = 1;
					end
				end
				
				1: begin
					data_o = data;
					valid_o = 1;
					next_state = 0;
				end
			endcase
		end
		
endmodule
