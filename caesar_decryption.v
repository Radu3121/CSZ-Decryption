`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:17:08 11/23/2020 
// Design Name: 
// Module Name:    ceasar_decryption 
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
module caesar_decryption #(
				parameter D_WIDTH = 8,
				parameter KEY_WIDTH = 16
			)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
            output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );

// TODO: Implement Caesar Decryption here
		 
			reg [D_WIDTH - 1 : 0] data; // variabila nenecesara 
			reg [D_WIDTH - 1 : 0] decodified; // variabila pentru stocarea datelor de input 

			always @(posedge clk) begin
				valid_o <= 0;
				if (!rst_n) begin
					data <= 0;
				end
				if (valid_i) begin // citirea si afisarea datelor
					data <= data_i;
					data_o <= decodified;
					valid_o <= valid_i;
				end
				if (valid_o) begin // afisarea pentru ultimul caracter al sirului
					data_o <= decodified;
				end		
			end
			
			always @(*) begin
				decodified = data_i - key; // decodificarea efectiva
			end

endmodule
