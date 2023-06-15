`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	Esteban Looser Rojas (ELR)
// 
// Create Date:    17:28:17 05/01/2023 
// Design Name:
// Module Name:    SNES_to_NES 
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
//	NES button order:
//		0:A, B, SELECT, START, UP, DOWN, LEFT, 7:RIGHT
//	SNES button order:
//		0:B, Y, SELECT, START, UP, DOWN, LEFT, RIGHT, A, X, L, 11:R
//////////////////////////////////////////////////////////////////////////////////
module SNES_to_NES(
		input wire clk,
		input wire[11:0] snes_button,
		input wire nes_latch,
		input wire nes_clk,
		output reg nes_data_q
	);

	reg[11:0] snes_button_s;
	reg nes_latch_s;
	reg nes_clk_s;
	
	reg prev_nes_latch;
	reg prev_nes_clk;
	
	reg[7:0] nes_shift;
	reg[1:0] ab_mask;
	reg[19:0] timer;
	
	wire nes_clk_edge;
	wire nes_latch_edge;
	
	assign nes_clk_edge = nes_clk_s & ~prev_nes_clk;
	assign nes_latch_edge = nes_latch_s & ~prev_nes_latch;
	
	initial
	begin
		timer = 20'h00000;
	end
	
	always @(posedge clk)
	begin
		snes_button_s <= snes_button;
		nes_latch_s <= nes_latch;
		nes_clk_s <= nes_clk;
		
		prev_nes_latch <= nes_latch_s;
		prev_nes_clk <= nes_clk_s;
		
		if(nes_clk_edge | nes_latch_edge)
		begin
			if(nes_latch_edge)
				nes_shift <= {snes_button_s[7:2], ({snes_button_s[0], snes_button_s[8]} & snes_button_s[11:10]) ^ ab_mask};
			else
				nes_shift <= {1'b0, nes_shift[7:1]};
		end
		
		timer <= timer + 20'h00001;
		ab_mask <= ~{snes_button_s[1], snes_button_s[9]} & {2{timer[19]}};
		
		nes_data_q <= ~nes_shift[0];
	end

endmodule
