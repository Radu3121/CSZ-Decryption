`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:19:55 11/09/2020 
// Design Name: 
// Module Name:    division 
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
module division(output reg [7:0] Q, // cat
					 output reg [7:0] R,	// rest
					 input [7:0] N, // deimpartit
					 input [7:0] D); // deimpartitor
					 
	reg [3:0] i;
	reg [8:0] Qaux;
	reg [8:0] Raux;
	
//calculul restului si al catului	
	always @(*) begin
		Qaux = 1'b0;
		Raux = 1'b0;
		for (i = 7; i > 0; i = i - 1) begin
			Raux = Raux << 1;
			Raux[0] = N[i];
			if (Raux >= D) begin
				Raux = Raux - D;
				Qaux[i] = 1;
			end
		end
		Raux = Raux << 1;
			Raux[0] = N[0];
			if (Raux >= D) begin
				Raux = Raux - D;
				Qaux[0] = 1;
			end
		Q = Qaux;
		R = Raux;
	end
	


endmodule
