`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:33:04 11/23/2020 
// Design Name: 
// Module Name:    zigzag_decryption 
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
module zigzag_decryption #(
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
			input[KEY_WIDTH - 1 : 0] key,
			
			// Output interface
            output reg busy,
			output reg[D_WIDTH - 1:0] data_o,
			output reg valid_o
    );
		
// // TODO: Implement ZigZag Decryption here
		
			initial begin
				busy = 0;
				valid_o = 0;
			end
		
			
			reg [399:0] data; // memorarea datelor pentru cheia 2
			reg [7:0] data3 [0:49]; // memorarea datelor pentru cheia 3
			// variabile folosite pentru navigarea prin array-uri
			reg [7:0] data_aux;
			reg [7:0] pos = 0;
			reg [6:0] pos_out = 0;
			reg [6:0] pos_out_aux = 0;
			reg [6:0] pos_out_aux2 = 0;
			reg [6:0] remaining = 0;
			reg [6:0] remaining_aux = 0;
			reg [6:0] i = 0;
			reg [1:0] state = 0;
			reg [1:0] next_state = 0;
			reg [2:0] state_key3 = 0;
			reg [2:0] next_state_key3 = 0;
			
			
			wire [7 : 0] half_data; // key == 2
			wire [7 : 0] rest; // key == 2
			
			wire [7:0] no_cycles; // key == 3
			wire [7:0] rest_cycles; // key == 3
			
			// gasirea jumatati sirului de afisat
			division div(half_data, rest, pos, key);

			// determinarea numarului de ciclii necesari decriptarii - no_cycles
			// si a numarului de caractere din ultimul ciclu, care poate fi
			// incomplet - rest_cycles
			division cycles(no_cycles, rest_cycles, pos - 8'b1, key + 8'b1); 

			always @(posedge clk) begin
				data_o <= 0;
				
				if (!rst_n) begin // resetarea registrelor de memorare
					data <= 0;
					for (i = 0; i < 50; i = i + 1) begin
						data3[i] <= 0;
					end
				end
				
				if (valid_i && key == 2) begin // scrierea in data pentru cheia 2
					data[((pos + 1) * 8) - 1 -: 8] <= data_i;
					pos <= pos + 1;
				end
				
				if (valid_i && key == 3) begin // scrierea in data3 pentru cheia 3
					data3[pos] <= data_i;
					pos <= pos + 1;
				end
				
				if (valid_i && data_i == 16'hFA) begin // incetarea ciclului de preluare de input
					busy <= 1;
					state <= 0;
					state_key3 <= 0;
					remaining <= pos;
				end
				
				if (busy) begin // afisarea / decodificarea efectiva 
					valid_o <= 1;
					if (key == 2) begin // afisare / decodificare cheia 2
						if (pos_out < half_data && data_aux != 16'hFA) begin
									data_o <= data_aux;
									pos_out <= pos_out_aux;
									state <= next_state;
						end else begin // resetarea semnalelor necesare unui ciclu de afisare
								busy <= 0;
								valid_o <= 0;
								pos_out <= 0;
								pos <= 0;
								data <= 0;
						end
					end else if (key == 3) begin // afisare / decodificare cheia 2
						if (remaining > 0) begin
							data_o <= data_aux;
							pos_out <= pos_out_aux;
							state_key3 <= next_state_key3;
							remaining <= remaining_aux;
						end else begin // resetarea semnalelor necesare unui ciclu de afisare
							busy <= 0;
							valid_o <= 0;
							pos_out <= 0;
							pos <= 0;
						end
					end
				end
			
			end
			

			always @(*) begin
				if (busy) begin
					if (key == 2) begin // afisare / decriptare cheia 2
						if (pos_out < half_data) begin
							case (state) 
								0:	begin
									if (data[((pos_out + 1) * 8) - 1 -: 8] != 16'hFA) begin
										data_aux = data[((pos_out + 1) * 8) - 1 -: 8];
										next_state = 1;
									end else begin
										data_aux = 0;
										pos_out_aux = 0;
										next_state = 0;
									end
								end
								1: begin
									if (data[((pos_out + 1) * 8) - 1 -: 8] != 16'hFA) begin
										data_aux = data[((pos_out + 1 + half_data) * 8) - 1 -: 8];
										pos_out_aux = pos_out + 1;
										next_state = 0;
									end else begin
										data_aux = 0;
										pos_out_aux = 0; 
										next_state = 0;
									end
								end
							endcase
				
						end
					end else if (key == 3) begin // afisare / decriptare cheia 3
						 case (state_key3) 
								0: begin // afisare primului caracter dintr-un ciclu de decriptare
									data_aux = data3[pos_out];
									next_state_key3 = 1;
									remaining_aux = remaining - 1;
								end
								
								1: begin // afisarea celui de al doilea caracter dintr-un ciclu
									if (rest_cycles == 0) begin
										data_aux = data3[no_cycles + pos_out_aux2];
									end else begin
										data_aux = data3[no_cycles + pos_out_aux2 + 1];
									end
									pos_out_aux2 = pos_out_aux2 + 1;
									next_state_key3 = 2;
									remaining_aux = remaining - 1;
								end
								
								2:begin // afisarea celui de al treilea caracter dintr-un ciclu
									if (rest_cycles == 0) begin
										data_aux = data3[3 * no_cycles + pos_out];
									end else if (rest_cycles == 1) begin
										data_aux = data3[3 * no_cycles + pos_out + 1];
									end else if (rest_cycles >= 2) begin
										data_aux = data3[3 * no_cycles + pos_out + 2];
									end
									next_state_key3 = 3;
									remaining_aux = remaining - 1;
								end
								
								3:begin // afisarea ultimul caracter dintr-un ciclu
									if (rest_cycles == 0) begin
										data_aux = data3[no_cycles + pos_out_aux2];
									end else begin
										data_aux = data3[no_cycles + pos_out_aux2 + 1];
									end
									pos_out_aux2 = pos_out_aux2 + 1;
									pos_out_aux = pos_out + 1;
									next_state_key3 = 0; // trecerea intr-un nou ciclu de decriptare
									remaining_aux = remaining - 1;
								end
						 endcase
					end
				end else begin 
							pos_out_aux = 0;
							pos_out_aux2 = 0;
				end
				
			end

endmodule

			
