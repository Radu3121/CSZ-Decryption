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

module decryption_top#(
			parameter addr_witdth = 8,
			parameter reg_width 	 = 16,
			parameter MST_DWIDTH = 32,
			parameter SYS_DWIDTH = 8
		)(
		// Clock and reset interface
		input clk_sys,
		input clk_mst,
		input rst_n,
		
		// Input interface
		input [MST_DWIDTH -1 : 0] data_i,
		input 						  valid_i,
		output busy,
		
		//output interface
		output [SYS_DWIDTH - 1 : 0]  data_o,
		output      					 valid_o,
		
		// Register access interface
		input[addr_witdth - 1:0] addr,
		input read,
		input write,
		input [reg_width - 1 : 0] wdata,
		output[reg_width - 1 : 0] rdata,
		output done,
		output error
		
    );
	
	wire [15:0] caesar_key;
	wire [15:0] scytale_key;
	wire [15:0] zigzag_key;
	wire [15:0] select;
	wire [7:0] data_i_caesar;
	wire [7:0] data_i_scytale;
	wire [7:0] data_i_zigzag;
	wire valid_i_caesar;
	wire valid_i_scytale;
	wire valid_i_zigzag;
	wire busy_caesar;
	wire busy_scytale;
	wire busy_zigzag;
	wire [7:0] data_o_caesar;
	wire [7:0] data_o_scytale;
	wire [7:0] data_o_zigzag;
	wire valid_o_caesar;
	wire valid_o_scytale;
	wire valid_o_zigzag;
	
	
	// TODO: Add and connect all Decryption blocks
		
	decryption_regfile decrypt(clk, rst_n, addr, read, write, wdata, rdata, done, error,
										select, caesar_key, scytale_key, zigzag_key);
										
	demux demx(clk_sys, clk_mst, rst_n, select[1:0], data_i, valid_i,
				  data_i_caesar, valid_i_caesar, data_i_scytale, valid_i_scytale, data_i_zigzag, valid_i_zigzag);
				  
	caesar_decryption caesar(clk, rst_n, data_i_caesar, valid_i_caesar, caesar_key[15:0],
									 busy_caesar, data_o_caesar, valid_o_caesar);
									 
	scytale_decryption scytale(clk, rst_n, data_i_scytale, valid_i_scytale, scytale_key[15:8], scytale_key[7:0],
										data_o_scytale, valid_o_scytale, busy_scytale);
										
	zigzag_decryption zigzag(clk, rst_n, data_i_zigzag, valid_i_zigzag, zigzag_key[7:0],
									 busy_zigzag, data_o_zigzag, valid_o_zigzag);
	
	mux mx(clk, rst_n, select[1:0], data_o, valid_o, data_o_caesar, valid_o_caesar, data_o_scytale, valid_o_scytale, data_o_zigzag, valid_o_zigzag);
	
	or bsy(busy, busy_caesar, busy_scytale, busy_zigzag);
	
endmodule
