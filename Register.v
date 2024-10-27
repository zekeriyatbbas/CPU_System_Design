`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2024 11:38:47 PM
// Design Name: 
// Module Name: register
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


module Register(I,E,FunSel,Clock,Q);
    input wire [2:0] FunSel;
    input wire [15:0] I;
    input wire E;
    input wire Clock;
    output reg [15:0] Q;
    
    
    always @(posedge Clock)
    begin
        if(E)
        begin
        case(FunSel)
            3'b000:     Q = Q-1;                    
            3'b001:     Q = Q+1;                       
            3'b010:     Q = I;             
            3'b011:     Q = 16'd0;                    
            3'b100:     Q = {8'd0,I[7:0]};    
            3'b101:     Q = {Q[15:8],I[7:0]};            
            3'b110:     Q = {I[7:0],Q[7:0]};       
            3'b111:     Q = {I[7],I[7],I[7],I[7],I[7],I[7],I[7],I[7],I[7:0]};
        endcase
        end
        else
        begin
            Q = Q; 
        end
    end

endmodule
