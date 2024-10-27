`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2024 01:20:02 PM
// Design Name: 
// Module Name: RegisterFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module RegisterFile(I,OutASel,OutBSel,FunSel,RegSel,ScrSel,Clock,OutA,OutB);

	input wire Clock;
	input wire [15:0] I;
	input wire [2:0] OutASel;
	input wire [2:0] OutBSel;
	input wire [2:0] FunSel;
	input wire [3:0] RegSel;
	input wire [3:0] ScrSel;
	output reg [15:0] OutA;	
	output reg [15:0] OutB;

	wire [15:0] r1; 
	wire [15:0] r2;
	wire [15:0] r3;
	wire [15:0] r4;

	wire [15:0] s1;
	wire [15:0] s2;
	wire [15:0] s3;
	wire [15:0] s4;


	Register R1(.I(I),.E(~RegSel[3]),.FunSel(FunSel),.Clock(Clock),.Q(r1));
	Register R2(.I(I),.E(~RegSel[2]),.FunSel(FunSel),.Clock(Clock),.Q(r2));
	Register R3(.I(I),.E(~RegSel[1]),.FunSel(FunSel),.Clock(Clock),.Q(r3));
	Register R4(.I(I),.E(~RegSel[0]),.FunSel(FunSel),.Clock(Clock),.Q(r4));

	Register S1(.I(I),.E(~ScrSel[3]),.FunSel(FunSel),.Clock(Clock),.Q(s1));
	Register S2(.I(I),.E(~ScrSel[2]),.FunSel(FunSel),.Clock(Clock),.Q(s2));
	Register S3(.I(I),.E(~ScrSel[1]),.FunSel(FunSel),.Clock(Clock),.Q(s3));
	Register S4(.I(I),.E(~ScrSel[0]),.FunSel(FunSel),.Clock(Clock),.Q(s4));
	
	always @(*)
	begin	
		case(OutASel)
			3'b000:		OutA <= r1;
			3'b001:		OutA <= r2;
			3'b010:		OutA <= r3;
			3'b011:		OutA <= r4;
			3'b100:		OutA <= s1;
			3'b101:		OutA <= s2;
			3'b110:		OutA <= s3;
			3'b111: 	OutA <= s4;
		endcase
		case(OutBSel)
			3'b000:		OutB <= r1;
			3'b001:		OutB <= r2;
			3'b010:		OutB <= r3;
			3'b011:		OutB <= r4;
			3'b100:		OutB <= s1;
			3'b101:		OutB <= s2;
			3'b110:		OutB <= s3;
			3'b111: 	OutB <= s4; 	
		endcase
	end


endmodule
