// Add more auxillary modules here...



// Display a Hexadecimal Digit, a Negative Sign, or a Blank, on a 7-segment Display
module SSeg(input [3:0] bin, input neg, input enable, output reg [6:0] segs);
	always @(*)
		if (enable) begin
			if (neg) segs = 7'b011_1111;
			else begin
				case (bin)
					0: segs = 7'b100_0000;	
					1: segs = 7'b111_1001;
					2: segs = 7'b010_0100;
					3: segs = 7'b011_0000;
					4: segs = 7'b001_1001;
					5: segs = 7'b001_0010;
					6: segs = 7'b000_0010;
					7: segs = 7'b111_1000;
					8: segs = 7'b000_0000;
					9: segs = 7'b001_1000;
					10: segs = 7'b000_1000;
					11: segs = 7'b000_0011;
					12: segs = 7'b100_0110;
					13: segs = 7'b010_0001;
					14: segs = 7'b000_0110;
					15: segs = 7'b000_1110;
				endcase
			end
		end
		else segs = 7'b111_1111;
endmodule

//Debounces a signal
module Debounce(input clk, input wire in, output reg out);
	parameter DURATION1 = 1_500_000;
	reg [30:0]count;
	wire in_sync;
	reg last, current;
	initial out = 0;
	Synchroniser sync(.clk(clk), .in(in), .out(in_sync));
	
	always@(posedge clk) begin 	
		last<=current;
		current<= in_sync;
		
		if(count >= DURATION1) begin
			 out <= last;
			 count=0;
		end
		
		else begin
			if(current == last) begin 
				count=count+1;
			end
		
			else begin
			count = 0;
			end 
		
		end
					
	end		
endmodule

//Converts a 2's complement number to be displayed on a hexadecimal display
module Disp2cNum(input signed [7:0] x, input enable, output [6:0] H3,H2,H1,H0);
	wire neg = (x < 0);
	wire [7:0] ux = neg ? -x : x;
	wire [7:0] xo0, xo1, xo2, xo3;
	wire eno0, eno1, eno2, eno3;
	// You fll in the rest: create four instances of DispDec
	DispDec dd0(.x(ux[7:0]),.neg(neg), .enable(enable), .xo(xo0[7:0]), .eno(eno0), .segs(H0[6:0]));
	DispDec dd1(.x(xo0[7:0]),.neg(neg), .enable(eno0), .xo(xo1[7:0]), .eno(eno1), .segs(H1[6:0]));
	DispDec dd2(.x(xo1[7:0]),.neg(neg), .enable(eno1), .xo(xo2[7:0]), .eno(eno2), .segs(H2[6:0]));
	DispDec dd3(.x(xo2[7:0]),.neg(neg), .enable(eno2), .xo(xo3[7:0]), .eno(eno3), .segs(H3[6:0]));
	
	
endmodule

//Converts a 2's complement number into a decimal
module DispDec(input [7:0] x, input neg, enable, output reg [7:0] xo, output reg eno, output
[6:0] segs);
	wire [3:0] digit;
	wire n;
	SSeg converter(digit, n, enable, segs);
	assign digit = x%10;	
	assign n = x==0 && neg && enable;
	always@(*) begin
		eno=0;
		if(enable) begin
			xo=x/10;	
			eno = ((!(xo==0)   || xo==0 && neg) &&!n);
		end
		end
endmodule
		
//Displays a number on a hexadecimal display
module DispHex(input [7:0]x, output [6:0] H5, H4);
		SSeg sseg1(.bin(x[7:4]), .neg(0), .enable(1), .segs(H5[6:0]));
		SSeg sseg2(.bin(x[3:0]), .neg(0), .enable(1), .segs(H4[6:0]));
endmodule

//Detects a falling edge on any of the push buttons
module DetectFallingEdge(input clk, input btn_sync, output reg active) ;
	reg last;
	always@(posedge clk) begin
		last <= btn_sync;
	end
	
	always@(*) begin
		if(last && !btn_sync) begin
			active = 1;
		end
		else begin
			active = 0;
		end
	end			
endmodule

//Synchronises a input signal to the clock
module Synchroniser(input clk, input wire in, output wire out);
	reg ff1,ff2;
	assign out = ff2;
	always@(posedge clk) begin
		ff1<=in;
		ff2<=ff1;
	end
endmodule

