`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/26/2024 11:57:39 AM
// Design Name: 
// Module Name: IR_register
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


module InstructionRegister(I,Write,LH,Clock,IROut);
    input wire Write;
    input wire LH;
    output reg [15:0] IROut;
    input wire [7:0] I;
    input wire Clock;
    
    always @(posedge Clock)
    begin
        if(Write)
        begin
        case(LH)               
            1'b0:     IROut = {IROut[15:8],I[7:0]};            
            1'b1:     IROut = {I[7:0],IROut[7:0]};       
        endcase
        end
        else
        begin
            IROut = IROut; 
        end
        
    end


endmodule
