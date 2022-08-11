module upcount(Clear,Clock,Q);
	input Clear,Clock;
	output [1:0] Q;
	reg [1:0] Q;
	always @(posedge Clock)
	if (Clear)
		Q = 2'b0;	
	else
		Q = Q + 1'b1;
endmodule

module dec3to8(W,En,Y);
	input [2:0]W;
	input En;
	output [7:0] Y;
	
	reg [7:0] Y;
	always @(W or En)
	begin

	if (En == 1)
		case (W)
				3'b000: Y = 8'b00000001;
				3'b001: Y = 8'b00000010;
				3'b010: Y = 8'b00000100;
				3'b011: Y = 8'b00001000;
				3'b100: Y = 8'b00010000;
				3'b101: Y = 8'b00100000;
				3'b110: Y = 8'b01000000;
				3'b111: Y = 8'b10000000;
		endcase
	else
		Y = 8'b00000000;

	end
endmodule


module regn(R, Rin, Clock, Q, Clear);
	parameter n = 16;
	input [n-1:0] R;
	input Rin, Clock, Clear;
	output [n-1:0] Q;
	
	reg [n-1:0] Q;
	always @(posedge Clock)
		if (Rin)
			Q = R;
		else if(Clear) 
			Q = 8'b010;
endmodule


module adder_subtractor(input1,input2,sub,out);
	parameter n = 16;

	input [n-1:0] input1;
	input [n-1:0] input2;
	input sub;

	output [n-1:0] out;
	reg [n-1:0] out;
	
	always @(input1 or input2 or sub)
	begin

		if(sub)
			out <= input1 - input2;
		else
			out <= input1 + input2;

	end		
endmodule


module multiplexer(DIN,R0,R1,R2,R3,R4,R5,R6,R7,G,Rout,Dout,Gout,out);
	parameter n=16;
	input [n-1:0] DIN,R0,R1,R2,R3,R4,R5,R6,R7,G;
	input [7:0] Rout;
	
	input Dout,Gout;
	output [n-1:0] out;
	reg [n-1:0] out;
	
	always@(DIN or R0 or R1 or R2 or R3 or R4 or R5 or R6 or R7 or G or Rout or Dout or Gout)
	begin
	
		out = 16'b0;
		if(Rout)
			
			begin
				case(Rout)
					8'b00000001:
						out = R0;
					8'b00000010:
						out = R1;
					8'b00000100:
						out = R2;
					8'b00001000:
						out = R3;
					8'b00010000:
						out = R4;
					8'b00100100:
						out = R5;
					8'b01000000:
						out = R6;
					8'b10000000:
						out = R7;
				endcase
			
			end
		else if(Dout)
			out = DIN;
		else if(Gout)
			out = G;
		else
			out = 16'b0;

	end
endmodule


module processor(Datain,Resetn,Clock,Run,Count,Done,BusWires,R0,R1,IR,A,G,Tstep);
	parameter n = 16;
	input [n-1:0] Datain;
	input Resetn, Clock, Run;

	output Done;
	output [n-1:0] BusWires;
	output [n-1:0] R0,R1,IR,A,G;
	output [1:0] Tstep;
	output Count;
	
	wire [n-1:0] Datain,R0,R1,R2,R3,R4,R5,R6,R7,IR,A,G,ASout;
	wire [7:0] regX,regY;
	wire [2:0] I;
	wire [1:0] Tstep;
	wire Resetn, Clock, Run;
	
	reg Clear;
	reg Done;
	reg AddSub;
	reg [7:0] Rin;
	reg IRin;

	reg Ain;
	reg Gin;
	reg [7:0] Rout;
	reg Dout;
	reg Gout;
	reg Count;
	
	upcount Tstep_counter(Clear,Clock,Tstep);
	regn  reg_0(BusWires,Rin[0],Clock,R0,Clear);
	regn  reg_1(BusWires,Rin[1],Clock,R1,Clear);
	regn  reg_2(BusWires,Rin[2],Clock,R2,Clear);
	regn  reg_3(BusWires,Rin[3],Clock,R3,Clear);
	regn  reg_4(BusWires,Rin[4],Clock,R4,Clear);
	regn  reg_5(BusWires,Rin[5],Clock,R5,Clear);
	regn  reg_6(BusWires,Rin[6],Clock,R6,Clear);
	regn  reg_7(BusWires,Rin[7],Clock,R7,Clear);
	regn  reg_IR(Datain,IRin,Clock,IR,Clear);

	regn  reg_A(BusWires,Ain,Clock,A,Clear);
	regn  reg_G(ASout,Gin,Clock,G,Clear);
	adder_subtractor as(A,BusWires,AddSub,ASout);	
	multiplexer mymux(Datain,R0,R1,R2,R3,R4,R5,R6,R7,G,Rout,Dout,Gout,BusWires);
	
	dec3to8 decX(IR[5:3],1'b1,regX);
	dec3to8 decY(IR[2:0],1'b1,regY);
		
	always @(Tstep or IR)
	if(Run)
		begin
			IRin=1'b0;
			Rin=8'b0;
			Ain=1'b0;
			Gin=1'b0;
			Done=1'b0;
			Clear=1'b0;
			AddSub=1'b0;
			Rout=8'b0;
			Dout=1'b0;
			Gout=1'b0;
			Count=1'b0;
			
			case (Tstep)
				2'b00: 
					begin
						IRin = 1'b1;
						Count = 1'b1;
					end
				
				2'b01: 
					case (IR[8:6])
						3'b000:  
							begin
								Rout = regY;
								Rin  = regX;
							end
						3'b001: 
							begin
								Dout = 1'b1;
								Rin = regX;
								Done = 1'b1;
								Count = 1'b1;	
							end
						3'b010: 
							begin
								Rout = regX;
								Ain = 1'b1;
							end
						3'b011: 
							begin
								Rout = regX;
								Ain = 1'b1;
							end
					endcase
				
				2'b10: 
					case (IR[8:6])
						3'b010: 
							begin
								Rout = regY;
								Gin = 1'b1;
							end
						3'b011: 
							begin
								Rout = regY;
								Gin = 1'b1;
								AddSub = 1'b1;
							end
					endcase

				2'b11: 
					case (IR[8:6])
						3'b010: 
							begin
								Rin = regX;
								Gout = 1'b1;
								Done = 1'b1;
							end
						3'b011: 
							begin
								Gout = 1'b1;
								Rin = regX;
								Done = 1'b1;
							end
					endcase
			endcase
		end
	else
	begin

		IRin=1'b0;
		Rin=8'b0;
		Ain=1'b0;
		Gin=1'b0;
		Done=1'b0;
		AddSub=1'b0;
		Rout=8'b0;
		Dout=1'b0;
		Gout=1'b0;
		Clear = 1'b1;

	end
endmodule

module ram029 (
	address,
	clock,
	q);

	input	[4:0]  address;
	input	  clock;
	output	[15:0]  q;

	wire [15:0] sub_wire0;
	wire [15:0] q = sub_wire0[15:0];

	altsyncram	altsyncram_component (
				.clock0 (clock),
				.address_a (address),
				.q_a (sub_wire0),
				.aclr0 (1'b0),
				.aclr1 (1'b0),
				.q_b (),
				.clocken1 (1'b1),
				.clocken0 (1'b1),
				.data_b (1'b1),
				.wren_a (1'b0),
				.data_a ({16{1'b1}}),
				.rden_b (1'b1),
				.address_b (1'b1),
				.wren_b (1'b0),
				.byteena_b (1'b1),
				.addressstall_a (1'b0),
				.byteena_a (1'b1),
				.addressstall_b (1'b0),
				.clock1 (1'b1));
	defparam
		altsyncram_component.address_aclr_a = "NONE",
		altsyncram_component.init_file = "ram029.mif",
		altsyncram_component.intended_device_family = "Stratix",
		altsyncram_component.lpm_hint = "ENABLE_RUNTIME_MOD=NO",
		altsyncram_component.lpm_type = "altsyncram",
		altsyncram_component.numwords_a = 32,
		altsyncram_component.operation_mode = "ROM",
		altsyncram_component.outdata_aclr_a = "NONE",
		altsyncram_component.outdata_reg_a = "CLOCK0",
		altsyncram_component.power_up_uninitialized = "FALSE",
		altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
		altsyncram_component.widthad_a = 5,
		altsyncram_component.width_a = 16,
		altsyncram_component.width_byteena_a = 1;
endmodule

module address_count(clock,count,clear,out);
	parameter nbit = 5;
	input clock,count,clear;
	output [nbit-1:0] out;
	
	reg [nbit-1:0] out;
	
	always @(posedge clock)
	begin
		if(clear)out = 5'b0;
		else if(count) out = out+5'b1;
	end
endmodule


module processor029(Resetn,Clock,MClock,Run,Done,BusWires,R0,R1,IR,A,G,Tstep,address_bits);
	parameter n = 16;
	input Resetn, Clock, MClock, Run;

	output Done,address_bits;
	output [n-1:0] BusWires;
	output [n-1:0] R0,R1,IR,A,G;
	output [1:0] Tstep;
	
	wire [n-1:0] Datain;
	wire [4:0] address_bits;
	
	nand (inverseRun,Run,Run);
	
	processor p(Datain,Resetn,Clock,Run,Count,Done,BusWires,R0,R1,IR,A,G,Tstep);
	ram029 myram(address_bits,MClock,Datain);
	address_count ac(Clock,Count,inverseRun,address_bits);
endmodule