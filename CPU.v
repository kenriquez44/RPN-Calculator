`include "CPU.vh"

// CPU Module

module CPU(
	input [7:0]Din ,
	input Sample, 
	input [2:0]Btns, 
	input Clock,
	input Reset,
	input Turbo, 
	output wire [7:0]Dout, 
	output wire Dval, 
	output wire [5:0]GPO, 
	output wire [3:0]Debug,
	output reg [7:0]IP
 );
 
	
  
// Registers
	reg [7:0] Reg [0:31];
	
// Wires/ Sync Wires
	wire turbo_safe;
	Synchroniser tbo(Clock, Turbo, turbo_safe);
		
	wire [7:0] din_safe; 		
   Synchroniser s1(.clk(Clock), .in(Din[0]), .out(din_safe[0]));
	Synchroniser s2(.clk(Clock), .in(Din[1]), .out(din_safe[1]));
	Synchroniser s3(.clk(Clock), .in(Din[2]), .out(din_safe[2]));
	Synchroniser s4(.clk(Clock), .in(Din[3]), .out(din_safe[3]));
   Synchroniser s5(.clk(Clock), .in(Din[4]), .out(din_safe[4]));
   Synchroniser s6(.clk(Clock), .in(Din[5]), .out(din_safe[5]));
	Synchroniser s7(.clk(Clock), .in(Din[6]), .out(din_safe[6]));
	Synchroniser s8(.clk(Clock), .in(Din[7]), .out(din_safe[7]));
				
	wire [3:0] pb_safe;
	Synchroniser s9(.clk(Clock), .in(Sample), .out(pb_safe[3]));
	Synchroniser s10(.clk(Clock), .in(Btns[2]), .out(pb_safe[2]));
	Synchroniser s11(.clk(Clock), .in(Btns[1]), .out(pb_safe[1]));
	Synchroniser s12(.clk(Clock), .in(Btns[0]), .out(pb_safe[0]));
	
	genvar i;	
	wire [3:0] pb_activated;
	generate
		for(i=0; i<=3; i=i+1) begin :pb
			DetectFallingEdge dfe(Clock, pb_safe[i], pb_activated[i]);
		end
	endgenerate
		
// Use these to Read the Special Registers
	wire [7:0] Rgout = Reg[29];
	wire [7:0] Rdout = Reg[30];
	wire [7:0] Rflag = Reg[31];
	
	
// Use these to Write to the Flags and Din Registers
	`define RFLAG Reg[31]
	`define RDINP Reg[28]
	
// Connect certain registers to the external world
	assign Dout = Rdout;
	assign GPO =  Rgout[5:0];
	assign Dval = Rgout[`DVAL];
	
// Debugging assignments 
	assign Debug[3] = Rflag[`SHFT];
	assign Debug[2] = Rflag[`OFLW];
	assign Debug[1] = Rflag[`SMPL];
		
//Get number function	
	function [7:0] get_number;
		input [1:0] arg_type;
		input [7:0] arg;
		begin
			case (arg_type)
				`REG: get_number = Reg[arg[5:0]];
				`IND: get_number = Reg[Reg[arg[5:0]][5:0]];
				default: get_number = arg;
			endcase
		end
	endfunction	

//Get Location function
	function [5:0] get_location;
		input [1:0] arg_type;
		input [7:0] arg;
		begin
			case (arg_type)
				`REG: get_location = arg[5:0];
				`IND: get_location = Reg[arg[5:0]][5:0];
				default: get_location = 0;
			endcase
		end
	endfunction

// Clock circuitry (250 ms cycle)
	reg [34:0] cnt = 0;
	localparam CntMax = 12_500_000;		
	always @(posedge Clock) begin
		cnt <= (cnt == 12_500_000) ? 0 : cnt + 1;
	end

// Synchronise CPU operatons to when cnt == 0
	wire go = !Reset && ((cnt == 0) || turbo_safe);
	assign Debug[0] = go;
	
// Program Memory
	wire [34:0] instruction;
	AsyncROM Pmem(IP , instruction);
	
	// Instruction Cycle
	wire [3:0] cmd_grp = instruction[34:31];
	wire [2:0] cmd = instruction[30:28];
	wire [1:0] arg1_typ = instruction[27:26];
	wire [7:0] arg1 = instruction[25:18];
	wire [1:0] arg2_typ = instruction[17:16];
	wire [7:0] arg2 = instruction[15:8];
	wire [7:0] addr = instruction[7:0];

// Instructon Cycle - Instructon Cycle Block
	reg [7:0] cnum;	
	reg [7:0] cloc;
	reg [15:0] word;
	reg signed [15:0] s_word;
	reg cond;
	integer j;
	always @(posedge Clock) begin
		if (go) begin
			IP <= IP + 8'b1; // Default acton is to increment IP
			case (cmd_grp)
				 //Instruction set for MOV commands
				`MOV: begin
					cnum = get_number(arg1_typ, arg1);
					case (cmd)
						`SHL: begin
							`RFLAG[`SHFT] <= cnum[7];
							 cnum = {cnum[6:0], 1'b0};
						end
						`SHR: begin
								`RFLAG[`SHFT] <= cnum[0];
								 cnum = {1'b0, cnum[7:1]};
						end
					endcase
					Reg[get_location(arg2_typ, arg2) ] <= cnum;
				end
				//Instruction set for ACC commands
				
				`ACC: begin
						cnum = get_number(arg2_typ, arg2);
						cloc = get_location(arg1_typ, arg1);
						case (cmd)
							`UAD: word = Reg[ cloc ] + cnum;
							`SAD: s_word = $signed( Reg[ cloc ] ) + $signed( cnum );
							`UMT: word = Reg[cloc] * cnum;
							`SMT: s_word = $signed(Reg[cloc]) * $signed(cnum);
							`AND: cnum = Reg[ cloc ] & cnum;
							`OR: cnum = Reg[ cloc ] | cnum;
							`XOR: cnum = Reg[ cloc ] ^ cnum;
						endcase
						if (cmd[2] == 0) begin
							if (cmd[0] == 0) begin // Unsigned addition or multiplication
								cnum = word[7:0];
								`RFLAG[`OFLW] <= (word > 255);
							end
							else begin // Signed addition or multiplication
								cnum = s_word[7:0];
								`RFLAG[`OFLW] <= (s_word > 127 || s_word < -128);
							end
						end
						Reg[ cloc ] <= cnum;
				end
				
				//Instruction set for JMP commands
				`JMP: begin
					case (cmd)
						`UNC: cond = 1;
						`EQ:  cond = (get_number(arg1_typ, arg1) == get_number(arg2_typ, arg2));
						`ULT: cond = (get_number(arg1_typ, arg1) < get_number(arg2_typ, arg2));
						`SLT: cond = ($signed(get_number(arg1_typ, arg1)) < $signed(get_number(arg2_typ, arg2)));
						`ULE: cond = (get_number(arg1_typ, arg1) <= get_number(arg2_typ, arg2));
						`SLE: cond = ($signed(get_number(arg1_typ, arg1)) <= $signed(get_number(arg2_typ, arg2)));
						default: cond = 0;
					endcase
					if (cond) IP <= addr;
				end
				
				//Instruction set for ATC commands
				`ATC: begin
						if (`RFLAG[cmd]) IP <= addr;
							 `RFLAG[cmd] <= 0;
				end
			endcase			
		end	
		
		// Process Reset
		if (Reset) begin
			IP <= 8'b0;
			`RFLAG <= 0;
		end
		else begin	
			for(j=0; j<=3; j=j+1) begin
				if (pb_activated[j]) `RFLAG[j] <= 1;
			end
			
			if (pb_activated[3]) `RDINP <= din_safe;
			end
end
endmodule



