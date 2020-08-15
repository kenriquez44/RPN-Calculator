`include "CPU.vh"

// Asynchronous ROM (Program Memory)

module AsyncROM(input [7:0] addr, output reg [34:0] data);	
	always @(addr)
			//Instructions
			case (addr)			
			//Initialize after a reset
			0: data = set(`DINP,0);
			1: data = set(`GOUT,0);
			2: data = set(`DOUT,0);
			3: data = set(1,0);
			4: data = set(2,0);
			5: data = set(3,0);
			6: data = set(4,0);
			//wait
			7: data = atc(3,12);
			8: data = atc(2,48);
			9: data = atc(1,64);
			10: data = atc(0,80);
			11: data = jmp(7);
			//push
			12: data = mov(0,10);
			13: data = mov(1,11);
			14: data = mov(2,12);
			15: data = mov(10,1);
			16: data = mov(11,2);
			17: data = mov(12,3);
			18: data = mov(`DINP,0);
			19: data = mov(0,`DOUT);
			20: data = set_bit(`GOUT,7);
			21: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd8, 8'd45}; //jmp to overflow
			22: data = clr_bit(`GOUT, 5); //clear overflow leds
			23: data = clr_bit(`GOUT, 4);
			24: data = clr_bit(`FLAG, 3); //clear sample/ push in flag register		
			25: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd0, 8'd28}; //if reg size equals 0, go to 28
			26: data = {`MOV, `SHL, `REG, 8'd4, `REG, 8'd4,`N8};
			27: data = jmp(29);
			28: data = set_bit(4, 0);						
			//send contents of reg 4 to LEDS
			29: data = clr_bit(`GOUT, 3); //clear all the stack size leds
			30: data = clr_bit(`GOUT, 2);
			31: data = clr_bit(`GOUT, 1);
			32: data = clr_bit(`GOUT, 0);			
			33: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd8, 8'd37};
			34: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd4, 8'd39};
			35: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd2, 8'd41};
			36: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd1, 8'd43};
			37: data = set_bit(`GOUT,3);
			38: data = jmp(7); //jmp to wait
			39: data = set_bit(`GOUT, 2);
			40: data = jmp(7); //jmp to wait
			41: data = set_bit(`GOUT, 1);
			42: data = jmp(7);//jmp to wait
			43: data = set_bit(`GOUT,0);
			44: data = jmp(7); //jmp to wait
			//overflow
			45: data = set_bit(`GOUT,4); // stack overflow led on
			46: data = clr_bit(`GOUT,5); // arithmetic overflow led off
			47: data = jmp(7); //jmp to wait
			//pop
			48: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd0, 8'd7}; //jmp to wait if stack size is 0
			49: data = clr_bit(`GOUT, 5); //clear both overflow leds
			50: data = clr_bit(`GOUT, 4);
			51: data = clr_bit(`FLAG, 2);
			52: data = mov(3,10); //move stacks down
			53: data = mov(2,11);
			54: data = mov(1,12);
			55: data = mov(10,2);
			56: data = mov(11,1);
			57: data = mov(12,0);
			58: data = {`MOV, `SHR, `REG, 8'd4, `REG, 8'd4,`N8}; //shift reg 4 to right, decrease stack size
			59: data = clr_bit(`GOUT,7); // turn off display
			60: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd0, 8'd100}; //if size is 0, go to wait
			61: data = mov(0,`DOUT);
			62: data = set_bit(`GOUT,7);
			63: data = jmp(29);
			//add
			64: data = clr_bit(`GOUT,5);
			65: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd1, 8'd7};
			66: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd0, 8'd7};
			67: data = {`ACC, `SAD, `REG, 8'd0, `REG, 8'd1,`N8}; // add reg 1 to reg 0
			68: data = mov(0,`DOUT);
			69: data = clr_bit(`FLAG, 1); 
			70: data = atc(`OFLW,72);
			71: data = jmp(73);
			72: data = set_bit(`GOUT,5);
			73: data = clr_bit(`GOUT,4);
			74: data = mov(3,10); //move stacks down
			75: data = mov(2,11);
			76: data = mov(10,2);
			77: data = mov(11,1);
			78: data = {`MOV, `SHR, `REG, 8'd4, `REG, 8'd4,`N8}; //shift reg 4 to right, decrease stack size
			79: data = jmp(29);
			//multiplcation
			80: data = {`JMP, `EQ, `REG, 8'd4, `NUM, 8'd0, 8'd7};
			81: data = clr_bit(`GOUT, 5); 
			82: data = {`JMP, `SLT, `NUM, 8'd1, `REG, 8'd4, 8'd86}; //jmp to normal
			83: data = set(0,0);
			84: data = mov(0,`DOUT);
			85: data = jmp(7);			
			//normal
			86: data = {`ACC, `SMT, `REG, 8'd0, `REG, 8'd1,`N8};
			87: data = clr_bit(`FLAG, 0); 
			88: data = atc(`OFLW,91);
			90: data = jmp(92);
			91: data = set_bit(`GOUT,5);
			92: data = clr_bit(`GOUT,4);
			93: data = mov(0,`DOUT);
			94: data = mov(3,10); //move stacks down
			95: data = mov(2,11);
			96: data = mov(10,2);
			97: data = mov(11,1);
			98: data  = {`MOV, `SHR, `REG, 8'd4, `REG, 8'd4,`N8}; //shift reg 4 to the right, decrease stack size
			99: data = jmp(29);	
			//pop continued (turn off led 0 when stack size is 0)
			100: data = clr_bit(`GOUT, 0);
			101: data = jmp(7);
			default: data = 35'b0; // NOP
		endcase
			
			
		
		//Set Function
		function [34:0] set;
				input [7:0] reg_num;
				input [7:0] value;
				set = {`MOV, `PUR, `NUM, value, `REG, reg_num, `N8};
		endfunction
				
		//Mov Function		
		function [34:0] mov;
					input [7:0] src_reg;
					input [7:0] dst_reg;
					mov = {`MOV, `PUR, `REG, src_reg, `REG, dst_reg, `N8};
		endfunction
		
		//Jmp Function
		function [34:0] jmp;
				input [7:0] addr;
				jmp = {`JMP, `UNC, `N10, `N10, addr};
				endfunction
				
		//Atc Function		
		function [34:0] atc;
				input [2:0] bit;
				input [7:0] addr;
				atc = {`ATC, bit, `N10, `N10, addr};
		endfunction
		
		//ACC Function
		function [34:0] acc;
					input [2:0] op;
					input [7:0] reg_num;
					input [7:0] value;
					acc = {`ACC, op, `REG, reg_num, `NUM, value, `N8};
		endfunction
		
		//Sets a a certain bit without affecting any other bits
		function [34:0] set_bit;
			input [7:0] reg_num;
			input [2:0] bit;
			set_bit = {`ACC, `OR, `REG, reg_num, `NUM, 8'b1 << bit, `N8};
		endfunction
		
		//Clears a certain bit without affecting any other bits
		function [34:0] clr_bit;
			input [7:0] reg_num;
			input [2:0] bit;
			clr_bit = {`ACC, `AND, `REG, reg_num, `NUM, ~(8'b1 << bit), `N8};
		endfunction
		
		
endmodule




