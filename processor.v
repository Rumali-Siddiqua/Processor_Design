
module regn(R, Rin, Clock, Q);

	parameter n = 8;
	input [n-1:0] R;
	input Rin, Clock;
	output [n-1:0] Q;
	reg [n-1:0] Q;
//	reg Rin;
	
	always@(posedge Clock)
		if(Rin)
			Q<=R;
	
endmodule


module upcount(Clear,Clock,Q);

	input Clear,Clock;
	output [1:0] Q;
	reg [1:0] Q;
	
	always@(posedge Clock)
		if(Clear)
			Q <= 0;
		else
			Q <= Q+1;
	
endmodule


module dec2to4(W,Y,En);//(W,Y,En)

	input [1:0]W;
	input En;
	output [0:3]Y;
	reg [0:3]Y;
	integer k;
	
	always@(W or En)
		case ({En,W})
			3'b100: Y=4'b1000;	
			3'b101: Y=4'b0100;
			3'b110: Y=4'b0010;
			3'b111: Y=4'b0001;
			default:Y=4'b0000;
		endcase
		
endmodule

module processor(Data, Reset, w, Clock, F, Rx, Ry, Done, BusWires );
	input [7:0]Data;
	input Reset,Clock,w;
	input [1:0]F,Rx,Ry;
	output [7:0] BusWires;
	output Done;
	//output [7:0]R0,R1,R2,R3,A,G;
//variables
	reg [7:0] BusWires, Sum;
	reg [0:3] Rin,Rout;
	reg AddSub,Extern,Ain,Gin,Gout,Done;
	
	wire [1:0] Count,I;
	wire [0:3] Xreg,Y;
	//reg [0:3] Xreg,Y;
	wire [7:0]R0,R1,R2,R3,A,G;
	wire [1:6]Func,FuncReg,Sel;
	
wire Clear= Reset|Done|(~w & ~Count[1] & ~Count[0]);
upcount counter(Clear,Clock,Count);
assign Func={F,Rx,Ry};
wire FRin= w & ~Count[1] & ~Count[0];
regn functionreg (Func, FRin, Clock, FuncReg);
	defparam functionreg.n=6;
assign I = FuncReg[1:2];
dec2to4 (FuncReg[3:4],Xreg,1);
dec2to4 (FuncReg[5:6],Y,1);

always@(Count or I or Xreg or Y)
begin
//... specifyinitialvalues
	Extern=1'b0; Done=1'b0;
	Ain=1'b0; Gin=1'b0; Gout=1'b0; AddSub=1'b0; Rin=1'b0; Rout=1'b0;
case(Count)
	2'b00:;//storeDINinIRintimestep0
	2'b01://de?nesignalsintimestep1
		case (I)
			2'b00:
				begin
				Extern=1'b1; Rin=Xreg; Done=1'b1;
				end
			2'b01:
				begin
					Rout=Y; Rin=Xreg; Done=1'b1;
				end
			default:
				begin
					Rout=Xreg; Ain=1'b1;
				end
		endcase
	2'b10:
		case (I)
			2'b10:
				begin
					Rout=Y; Gin=1'b1;
				end
			2'b11:
				begin
					Rout=Y; AddSub=1'b1; Gin=1'b1;
				end
			default:;
		endcase
	2'b11://de?nesignalsintimestep3
		case (I)
			2'b10,2'b11:
				begin
					Gout=1'b1; Rin=Xreg; Done=1'b1;
				end
			default:;
		endcase
	endcase
end

regn reg_0(BusWires,Rin[0],Clock,R0);
regn reg_1(BusWires,Rin[1],Clock,R1);
regn reg_2(BusWires,Rin[2],Clock,R2);
regn reg_3(BusWires,Rin[3],Clock,R3);
regn reg_A(BusWires,Ain,Clock,A);
//... instantiateotherregistersandtheadder/subtracterunit


always @(AddSub or A or BusWires)
begin
	if(!AddSub)
		Sum=A + BusWires;
	else
		Sum=A - BusWires;
end

regn reg_G(Sum, Gin,Clock,G);

assign Sel={Rout, Gout, Extern};

always @(Sel or R0 or R1 or R2 or R3 or G or Data)
begin
	if(Sel == 6'b100000)
		BusWires=R0;
	else if(Sel == 6'b010000)
		BusWires=R1;
	else if(Sel == 6'b001000)
		BusWires=R2;
	else if(Sel == 6'b000100)
		BusWires=R3;
	else if(Sel == 6'b000010)
		BusWires=G;
	else BusWires=Data;
end

endmodule



/*
module upcount(Clear,Clock,Q);
input Clear,Clock;
output[1:0]Q;
reg[1:0]Q;
always@(posedgeClock)
if (Clear)
Q <=2’b0;
else
Q <=Q+1’b1;
endmodule
module dec3to8(W,En,Y);
input [2:0]W;
input En;
output[0:7]Y;
reg[0:7]Y;
always@(W orEn)
begin
if (En==1)
case(W)
3’b000:Y=8’b10000000;
3’b001:Y=8’b01000000;
3’b010:Y=8’b00100000;
3’b011:Y=8’b00010000;
3’b100:Y=8’b00001000;
3’b101:Y=8’b00000100;
3’b110:Y=8’b00000010;
3’b111:Y=8’b00000001;
endcase
else
Y=8’b00000000;
end
endmodule


module regn(R,Rin,Clock,Q);
parametern=16;
input [n-1:0]R;
input Rin,Clock;
output[n-1:0]Q;
reg[n-1:0]Q;
always@(posedgeClock)
if (Rin)
Q <=R;
endmodule
*/
