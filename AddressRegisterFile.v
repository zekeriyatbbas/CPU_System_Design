`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/27/2024 03:46:19 PM
// Design Name: 
// Module Name: Address_Register_File
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


module AddressRegisterFile(I,OutCSel,OutDSel,FunSel,RegSel,Clock,OutC,OutD);

	input wire [15:0] I;
	input wire [1:0] OutCSel;
	input wire [1:0] OutDSel;
	input wire [2:0] FunSel;
	input wire [2:0] RegSel;
	input wire Clock;
	output reg [15:0] OutC; 
	output reg [15:0] OutD;


	wire [15:0] pcq;
	wire [15:0] arq;
	wire [15:0] spq;

	Register PC(.I(I),.E(~RegSel[2]),.FunSel(FunSel),.Clock(Clock),.Q(pcq));
	Register AR(.I(I),.E(~RegSel[1]),.FunSel(FunSel),.Clock(Clock),.Q(arq));
	Register SP(.I(I),.E(~RegSel[0]),.FunSel(FunSel),.Clock(Clock),.Q(spq));

	always @(*)
	begin
		case(OutCSel)
			2'b00:	OutC <= pcq;
			2'b01:	OutC <= pcq;
			2'b10:	OutC <= arq;
			2'b11: 	OutC <= spq;
		endcase
		
		case(OutDSel)
			2'b00:	OutD <= pcq;
			2'b01:	OutD <= pcq;
			2'b10:	OutD <= arq;
			2'b11: 	OutD <= spq;
		endcase

	end

endmodule
