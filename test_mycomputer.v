`timescale 10ns / 1ns
module test_mycomputer;

	reg clk;
	reg [3:0] key;
	reg [9:0] sw;
	
	
	wire [9:0] ledr;
	wire [6:0] hex0;
	wire [6:0] hex1;
	wire [6:0] hex2;
	wire [6:0] hex3;
	wire [6:0] hex4;
	wire [6:0] hex5;
	
	
	 MyComputer test(.CLOCK_50(clk), .KEY(key[3:0]), .SW(sw[9:0]), .LEDR(ledr[9:0]), .HEX0(hex0[6:0]), .HEX1(hex1[6:0]), .HEX2(hex2[6:0]), 
	.HEX3(hex3[6:0]), .HEX4(hex4[6:0]), .HEX5(hex5[6:0]));
	         
	//Clock

		initial begin
					clk = 0;
					forever begin
										#1
										clk=!clk;
					end
		end
		
		
		
		initial begin		
			sw[9] = 1;
			#3000050
			sw[9] = 0;
			#3000100
			#3000
			
			$stop;
			
		end
		endmodule
		