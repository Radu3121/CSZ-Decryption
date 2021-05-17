`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:24:12 11/27/2020 
// Design Name: 
// Module Name:    scytale_decryption 
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
module scytale_decryption#(
			parameter D_WIDTH = 8, 
			parameter KEY_WIDTH = 8, 
			parameter MAX_NOF_CHARS = 50,
			parameter START_DECRYPTION_TOKEN = 8'hFA
		)(
			// Clock and reset interface
			input clk,
			input rst_n,
			
			// Input interface
			input[D_WIDTH - 1:0] data_i,
			input valid_i,
			
			// Decryption Key
			input[KEY_WIDTH - 1 : 0] key_N,
			input[KEY_WIDTH - 1 : 0] key_M,
			
			// Output interface
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o,
			
			output reg busy
    );

// TODO: Implement Scytale Decryption here
			reg [399 : 0] data = 0; // array pentru memorarea datelor de input
			reg [6:0] count = 0; // numarul de caractere citite
			// pos, col, pos_out sunt folosite pentru accesarea elementelor din array
			reg [6:0] pos = 0;
			reg [6:0] col = 0;
			reg [6:0] pos_out = 0;
			
			initial begin
				busy = 0;
				valid_o = 0;
				data_o = 0;
			end
			
			always @(posedge clk) begin
				data_o <= 0;
				
				if (!rst_n) begin
					data <= 0;
				end
				
				// scrierea datelor de intrare in data
				if (valid_i) begin
					data[((pos + 1) * 8) - 1 -: 8] <= data_i;
					pos <= pos + 1;
				end
				
				// incheierea ciclului de scriere si semnalarea inceperii decriptarii
				// prin busy = 1
				if (valid_i && data_i == 16'hFA) begin
					busy <= 1;
					count <= pos;
					pos <= 0;
				end
				
				// afisarea si decriptarea efectiva
				if (busy) begin
					valid_o <= 1;
					if (count > 0) begin // conditie de incheiere a afisarii 
						data_o <= data[8 * (pos_out + 1 + col) - 1 -: 8];
						count <= count - 1;
						if (pos_out >= key_N * (key_M - 1)) begin	// conditie pentru decriptare
							pos_out <= 0;
							if (col < key_M) begin // conditie pentru decriptare
								col <= col + 1;
							end else begin
								col <= 0;
							end
						end else begin
							pos_out <= pos_out + key_N;
						end
					end else begin // resetarea semnalelor specifice unui ciclu de afisare/decriptare
						busy <= 0;
						valid_o <= 0;
						data <= 0;
						data_o <= 0;
						col <= 0;
						pos_out <= 0;
						count <= 0;
					end	
				end			
			end

endmodule
