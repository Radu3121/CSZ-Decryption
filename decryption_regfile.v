`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:13:49 11/23/2020 
// Design Name: 
// Module Name:    decryption_regfile 
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
module decryption_regfile #(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16
		)(
			// Clock and reset interface
			input clk, 
			input rst_n,
			
			// Register access interface
			input[addr_witdth - 1:0] addr,
			input read,
			input write,
			input [reg_width -1 : 0] wdata,
			output reg [reg_width -1 : 0] rdata,
			output reg done,
			output reg error,
			
			// Output wires
			output reg[reg_width - 1 : 0] select,
			output reg[reg_width - 1 : 0] caesar_key,
			output reg[reg_width - 1 : 0] scytale_key,
			output reg[reg_width - 1 : 0] zigzag_key
    );

// TODO implementati bancul de registre.
// registri necesari retinerii datelor de intrare
			reg[reg_width - 1 : 0] select_register;
			reg[reg_width - 1 : 0] caesar_key_register;
			reg[reg_width - 1 : 0] scytale_key_register;
			reg[reg_width - 1 : 0] zigzag_key_register;
		
// scriere, citire, resetare si setarea semnalelor de done is reset in mod sincron
			always @(posedge clk) begin
				error <= 0;
				done <= 0;
				if (!rst_n) begin							// reset cu valorile din cerinta
						select_register <= 16'h0;
						caesar_key_register <= 16'h0;
						scytale_key_register <= 16'hFFFF;
						zigzag_key_register <= 16'h2;
						error <= 0;
				end else if (write && !read) begin  // write
					done <= 1;
					case (addr) 							// write in adresa primita prin addr
						16'h0: begin
								 // scrierea primilor 2 biti din select_register cu 
								 // primi 2 biti din wdata, iar restul de 14 cu 0
								 select_register <= {14'h0, wdata[1:0]}; 
								 error <= 0;
						end
						16'h10: begin
								 caesar_key_register <= wdata;
								 error <= 0;
						end
						16'h12: begin
								 scytale_key_register <= wdata;
								 error <= 0;
						end
						16'h14: begin
								 zigzag_key_register <= wdata;
								 error <= 0;
						end
						default: error <= 1;  // caz adresa invalida in timpul write
					endcase	
				end else if (read && !write) begin  // read
					done <= 1;
					case (addr)								// read de la adresa primita prin addr
						16'h0: begin
								rdata <= select_register;
								error <= 0;
						end
						16'h10: begin
								rdata <= caesar_key_register;
								error <= 0;
						end
						16'h12: begin
								rdata <= scytale_key_register;
								error <= 0;
						end
						16'h14: begin
								rdata <= zigzag_key_register;
								error <= 0;
						end
						default: error <= 1;  			// caz adresa invalida in timpul read
					endcase	
				end
				
			end
			
// assignarea asincrona a datelor din registrii pe iesiri
			always @(*) begin
				select = select_register;
				caesar_key = caesar_key_register;
				scytale_key = scytale_key_register;
				zigzag_key = zigzag_key_register;
			end
endmodule
