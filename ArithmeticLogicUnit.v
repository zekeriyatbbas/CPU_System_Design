`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2024 04:57:16 PM
// Design Name: 
// Module Name: ALU
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

module ArithmeticLogicUnit(A,B,FunSel,WF,Clock,ALUOut,FlagsOut);

input wire Clock;
input wire [15:0] A;
input wire [15:0] B;
input wire [4:0] FunSel;
input wire WF;
output reg [15:0] ALUOut;
output reg [3:0] FlagsOut;

reg [8:0] sum_8;
reg [16:0] sum_16;

reg [8:0] sub_8;
reg [16:0] sub_16;

reg [8:0] sumc_8;
reg [16:0] sumc_16;


always @(*) begin
	sum_8 = {1'b0,A[7:0]} + {1'b0,B[7:0]};
	sum_16 = {1'b0,A} + {1'b0,B}; 
	
	sub_8 = {1'b0,A[7:0]} + {1'b0,~B[7:0]} + {9'd1}; 
    sub_16 = {1'b0,A} + {1'b0,~B} + {17'd1};
	
	sumc_8 = {1'b0,A[7:0]} + {1'b0,B[7:0]} + {8'd0,FlagsOut[2]};
    sumc_16 = {1'b0,A} + {1'b0,B} + {16'd0,FlagsOut[2]}; 
end

always @(*)
begin 
	case(FunSel)	
		5'b00000:	ALUOut = {8'd0,A[7:0]};
		5'b00001:	ALUOut = {8'd0,B[7:0]};					
		5'b00010:	ALUOut = {8'd0,~(A[7:0])};
		5'b00011:	ALUOut = {8'd0,~(B[7:0])};
		5'b00100:	ALUOut = {8'd0,A[7:0]+B[7:0]};
		5'b00101:	ALUOut = {8'd0,A[7:0]+B[7:0]+{7'd0,FlagsOut[2]}}; 
		5'b00110:	ALUOut = {8'd0,A[7:0]+~B[7:0]+8'd1};		
		5'b00111:	ALUOut = {8'd0,A[7:0]&B[7:0]};					
		5'b01000:	ALUOut = {8'd0,A[7:0]|B[7:0]};					
		5'b01001:	ALUOut = {8'd0,A[7:0]^B[7:0]};									
		5'b01010:	ALUOut = {8'd0,~(A[7:0]&B[7:0])};							
		5'b01011:	ALUOut = {8'd0, A[6:0],1'b0};					
		5'b01100:	ALUOut = {8'd0,1'b0,A[7:1]};			
		5'b01101:	ALUOut = {8'd0,A[7],A[7:1]};					
		5'b01110:	ALUOut = {8'd0,A[6:0],FlagsOut[2]};		
		5'b01111:	ALUOut = {8'd0,FlagsOut[2],A[7:1]};	

		5'b10000:	ALUOut = A;									
		5'b10001:	ALUOut = B;					
		5'b10010:	ALUOut = ~A;					
		5'b10011:	ALUOut = ~B;						
		5'b10100:	ALUOut = A+B;					
		5'b10101:	ALUOut = A+B+{15'd0,FlagsOut[2]};					
		5'b10110:	ALUOut = A + ~B + 16'd1;				
		5'b10111:	ALUOut = A&B;						
		5'b11000:	ALUOut = A|B;	
		5'b11001:	ALUOut = A^B;	
		5'b11010:	ALUOut = ~(A&B);					
		5'b11011:	ALUOut = {A[14:0],1'b0};					
		5'b11100:	ALUOut = {1'b0,A[15:1]};					
		5'b11101:	ALUOut = {A[15],A[15:1]};					
		5'b11110:	ALUOut = {A[14:0],FlagsOut[2]};
		5'b11111:	ALUOut = {FlagsOut[2],A[15:1]};					
	endcase
end

always @(posedge Clock)
begin

if(WF) begin

case(FunSel)	
		5'b00000:	FlagsOut[1] = ALUOut[7];	
		5'b00001:   FlagsOut[1] = ALUOut[7];				
		5'b00010:	FlagsOut[1] = ALUOut[7];
		5'b00011:	FlagsOut[1] = ALUOut[7];
		5'b00100:	FlagsOut[1] = ALUOut[7];
		5'b00101:	FlagsOut[1] = ALUOut[7];
		5'b00110:	FlagsOut[1] = ALUOut[7];
		5'b00111:   FlagsOut[1] = ALUOut[7];
		5'b01000:	FlagsOut[1] = ALUOut[7];
		5'b01001:	FlagsOut[1] = ALUOut[7];					
		5'b01010:	FlagsOut[1] = ALUOut[7];					
		5'b01011:	FlagsOut[1] = ALUOut[7];	 				
		5'b01100:	FlagsOut[1] = ALUOut[7];
		5'b01101:	FlagsOut[1] = FlagsOut[1];	
		5'b01110:	FlagsOut[1] = ALUOut[7];		
		5'b01111:	FlagsOut[1] = ALUOut[7];			
		5'b10000:	FlagsOut[1] = ALUOut[15];							
		5'b10001:	FlagsOut[1] = ALUOut[15];			
		5'b10010:	FlagsOut[1] = ALUOut[15];				
		5'b10011:	FlagsOut[1] = ALUOut[15];					
		5'b10100:	FlagsOut[1] = ALUOut[15];				
		5'b10101:	FlagsOut[1] = ALUOut[15];				
		5'b10110:	FlagsOut[1] = ALUOut[15];				
		5'b10111:	FlagsOut[1] = ALUOut[15];						
		5'b11000:	FlagsOut[1] = ALUOut[15];	
		5'b11001:	FlagsOut[1] = ALUOut[15];	
		5'b11010:	FlagsOut[1] = ALUOut[15];				
		5'b11011:	FlagsOut[1] = ALUOut[15];				
		5'b11100:	FlagsOut[1] = ALUOut[15];				
		5'b11101:	FlagsOut[1] = FlagsOut[1];		
		5'b11110:	FlagsOut[1] = ALUOut[15];
		5'b11111:	FlagsOut[1] = ALUOut[15];				
	endcase



if(ALUOut === 16'd0)
begin
	FlagsOut[3] = 1'b1;
end    
else begin
	FlagsOut[3] = 1'b0;
end

case(FunSel)
	    5'b01011: FlagsOut[2] =  A[7];
    	5'b01100: FlagsOut[2] =  A[0];
    	5'b01101: FlagsOut[2] =  A[0];
    	5'b01110: FlagsOut[2] =  A[7];
    	5'b01111: FlagsOut[2] =  A[0];

	    5'b11011: FlagsOut[2] =  A[15];
    	5'b11100: FlagsOut[2] =  A[0];
    	5'b11101: FlagsOut[2] =  A[0];
    	5'b11110: FlagsOut[2] =  A[15];
    	5'b11111: FlagsOut[2] =  A[0];

    	// A + B ; A + B + Carry ; A - B 
    	
    	5'b00100: FlagsOut[2] = sum_8[8];          
   		5'b00101: FlagsOut[2] = sumc_8[8]; 
   		5'b00110: FlagsOut[2] = ~sub_8[8]; 

		5'b10100: FlagsOut[2] = sum_16[16];     
		5'b10101: FlagsOut[2] = sumc_16[16]; 
		5'b10110: FlagsOut[2] = ~sub_16[16]; 


endcase

case(FunSel) 
    5'b00100: FlagsOut[0] = (A[7]& B[7] & ~sum_8[7]) | (~A[7]& ~B[7] & sum_8[7]);
    5'b00101: FlagsOut[0] = (A[7]& B[7] & ~sumc_8[7]) | (~A[7]& ~B[7] & sumc_8[7]);
    5'b00110: FlagsOut[0] = (~A[7]& B[7] & sub_8[7]) | (A[7]& ~B[7] & ~sub_8[7]);
    
    5'b10100: FlagsOut[0] = (A[15]& B[15] & ~sum_16[15]) | (~A[15]& ~B[15] & sum_16[15]);     
    5'b10101: FlagsOut[0] = (A[15]& B[15] & ~sumc_16[15]) | (~A[15]& ~B[15] & sumc_16[15]);
    5'b10110: FlagsOut[0] = (~A[15]& B[15] & sub_16[15]) | (A[15]& ~B[15] & ~sub_16[15]);
    
endcase

end

end

endmodule