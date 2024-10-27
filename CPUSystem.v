`timescale 1ns / 1ps

module CPUSystem (Clock, Reset, T);

input wire Clock;
input wire Reset;
output reg[7:0] T;

reg[2:0] SC;

reg [2:0] RF_OutASel;
reg [2:0] RF_OutBSel;
reg [2:0] RF_FunSel;
reg [3:0] RF_RegSel;
reg [3:0] RF_ScrSel;

reg [4:0] ALU_FunSel;
reg ALU_WF;

reg [1:0] ARF_OutCSel; 
reg [1:0] ARF_OutDSel;
reg [2:0] ARF_FunSel;
reg [2:0] ARF_RegSel;

reg IR_LH;
reg IR_Write;

reg Mem_WR; 
reg Mem_CS;

reg [1:0] MuxASel;
reg [1:0] MuxBSel;
reg MuxCSel;


ArithmeticLogicUnitSystem _ALUSystem(.RF_OutASel(RF_OutASel),.RF_OutBSel(RF_OutBSel),.RF_FunSel(RF_FunSel),.RF_RegSel(RF_RegSel),.RF_ScrSel(RF_ScrSel),.ALU_FunSel(ALU_FunSel),.ALU_WF(ALU_WF),.ARF_OutCSel(ARF_OutCSel),.ARF_OutDSel(ARF_OutDSel),.ARF_FunSel(ARF_FunSel),.ARF_RegSel(ARF_RegSel),.IR_LH(IR_LH),.IR_Write(IR_Write),.Mem_WR(Mem_WR),.Mem_CS(Mem_CS),.MuxASel(MuxASel),.MuxBSel(MuxBSel),.MuxCSel(MuxCSel),.Clock(Clock));

always @(*)
begin
    case (SC)
        3'b000: T = 8'b00000001;
        3'b001: T = 8'b00000010;
        3'b010: T = 8'b00000100;
        3'b011: T = 8'b00001000;
        3'b100: T = 8'b00010000;
        3'b101: T = 8'b00100000;
        3'b110: T = 8'b01000000;
        3'b111: T = 8'b10000000;
    endcase
end

always @(negedge Reset)
begin
    _ALUSystem.RF.R1.Q = 16'b0000000000000000;
    _ALUSystem.RF.R2.Q = 16'b0000000000000000;
    _ALUSystem.RF.R3.Q = 16'b0000000000000000;
    _ALUSystem.RF.R4.Q = 16'b0000000000000000;
    _ALUSystem.RF.S1.Q = 16'b0000000000000000;
    _ALUSystem.RF.S2.Q = 16'b0000000000000000;
    _ALUSystem.RF.S3.Q = 16'b0000000000000000;
    _ALUSystem.RF.S4.Q = 16'b0000000000000000;
    _ALUSystem.ARF.PC.Q = 16'b0000000000000000;
    _ALUSystem.ARF.SP.Q = 16'b0000000011111111;
    SC = 3'b000;
end

always @(posedge Clock)
begin
    if (SC === 3'b000 || SC === 3'b001) begin SC = SC + 1; end
    else begin
    case (_ALUSystem.IROut[15:10])
    
    6'h11, 6'h14, 6'h20: if(SC === 3'b010) begin SC = 3'b000; end else begin SC = SC + 1; end    //T2
    
    6'h04, 6'h05, 6'h06, 6'h12, 6'h13: if(SC === 3'b011) begin SC = 3'b000; end else begin SC = SC + 1; end    //T3
    
    6'h03: if(SC === 3'b100) begin SC = 3'b000; end else begin SC = SC + 1; end    //T4
    
    6'h1E, 6'h1F: if(SC === 3'b101) begin SC = 3'b000; end else begin SC = SC + 1; end    //T5
    
    6'h21: if(SC === 3'b111) begin SC = 3'b000; end else begin SC = SC + 1; end   //Changes based on condition
    
    6'h00, 6'h01, 6'h02:
    begin
        if((_ALUSystem.IROut[15:10] === 6'b000001 && _ALUSystem.alufl[3]) || (_ALUSystem.IROut[15:10] === 6'b000010 && ~_ALUSystem.alufl[3])) begin if (SC === 3'b010) begin SC = 3'b000; end else begin SC = SC + 1; end end
        else begin if(SC === 3'b100) begin SC = 3'b000; end else begin SC = SC + 1; end end
    end
    
    6'h07, 6'h08, 6'h09, 6'h0A, 6'h0B, 6'h0E, 6'h18:
    begin
        case (_ALUSystem.IROut[5])
            1'b0: if(SC === 3'b011) begin SC = 3'b000; end else begin SC = SC + 1; end
            1'b1: if(SC === 3'b010) begin SC = 3'b000; end else begin SC = SC + 1; end
        endcase
    end
    
    6'h0C, 6'h0D, 6'h0F, 6'h10, 6'h15, 6'h16, 6'h17, 6'h19, 6'h1A, 6'h1B, 6'h1C, 6'h1D:
    begin
        case (_ALUSystem.IROut[5])
            1'b0:
            begin
                case (_ALUSystem.IROut[2])
                    1'b0: if(SC === 3'b100) begin SC = 3'b000; end else begin SC = SC + 1; end
                    1'b1: if(SC === 3'b011) begin SC = 3'b000; end else begin SC = SC + 1; end
                endcase
            end
            1'b1:
            begin
                case (_ALUSystem.IROut[2])
                    1'b0: if(SC === 3'b011) begin SC = 3'b000; end else begin SC = SC + 1; end
                    1'b1: if(SC === 3'b010) begin SC = 3'b000; end else begin SC = SC + 1; end
                endcase
            end
        endcase
    end
    endcase
    end
end

always @(*)
begin
    if(Reset)
	begin
        if(SC === 3'b000)
        begin
            RF_RegSel = 4'b1111;
            RF_ScrSel = 4'b1111;
            ALU_WF = 1'b0;
            ARF_OutDSel = 2'b00;
            Mem_CS = 1'b0;
            Mem_WR = 1'b0;
            IR_Write = 1'b1;
            IR_LH = 1'b0;
            ARF_RegSel = 3'b011;
            ARF_FunSel = 3'b001;
        end

        else if(SC === 3'b001)
        begin
            IR_LH = 1'b1;
        end
        
        else if (~(SC === 3'b000 || SC === 3'b001))
        begin
            case(_ALUSystem.IROut[15:10])
            6'h00, 6'h01, 6'h02: //BRA, BNE, BEQ =========================================================================
            begin
                if (SC === 3'b010)  
                begin
                    RF_RegSel = 4'b1111;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b111;
                    ALU_WF = 1'b0;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    if((_ALUSystem.IROut[15:10] === 6'b000001 && _ALUSystem.alufl[3]) || (_ALUSystem.IROut[15:10] === 6'b000010 && ~_ALUSystem.alufl[3])) 
                    begin 
                        RF_FunSel = 3'b010;
                        RF_ScrSel = 4'b1111;
                        ALU_FunSel = 5'b10000;
                    end
                    else
                    begin
                        MuxASel = 2'b11;
                        RF_FunSel = 3'b100;
                        RF_ScrSel = 4'b0111;
                        RF_OutASel = 3'b100;
                        RF_OutBSel = 3'b101;
                        ALU_FunSel = 5'b10100;
                        
                    end
                end
                
                else if (SC === 3'b011)
                begin
                    ARF_OutCSel = 2'b00;
                    MuxASel = 2'b01;
                    RF_FunSel = 3'b010;
                    RF_ScrSel = 4'b1011;
                    
                end
                
                else if (SC === 3'b100)
                begin
                    MuxBSel = 2'b00;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b011;
                    
                end
            end
            
            6'h03: //POP =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_FunSel = 3'b010;
                    RF_RegSel = 4'b1111;
                    RF_ScrSel = 4'b1111;
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 1'b0;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = 3'b110;
                    
                end
                
                else if (SC === 3'b011)
                begin
                    ARF_OutDSel = 2'b11;
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b100;
                    case (_ALUSystem.IROut[9:8])
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                end
                
                else if (SC === 3'b100)
                begin
                    ARF_RegSel = 3'b111;
                    RF_FunSel = 3'b110;
                    
                end
            end
            
            6'h04: //PSH =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_FunSel = 3'b010;
                    RF_RegSel = 4'b1111;
                    RF_ScrSel = 4'b1111;
                    ALU_WF = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b1;
                    ARF_OutDSel = 2'b11;
                    RF_OutASel = {1'b0, _ALUSystem.IROut[9:8]};
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 2'b1;
                    ARF_FunSel = 3'b000;
                    ARF_RegSel = 3'b110;
                    
                end
                
                else if (SC === 3'b011)
                begin
                    MuxCSel = 0;
                    
                end
            end
            
            6'h05, 6'h06: //INC, DEC =========================================================================
            begin              
                if (SC === 3'b010)
                begin
                    RF_ScrSel = 4'b1111;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    ALU_WF = _ALUSystem.IROut[9];
                    ALU_FunSel = 5'b10000;
                    case(_ALUSystem.IROut[5])
                    1'b0:
                    begin
                        ARF_OutCSel = {_ALUSystem.IROut[4], ~_ALUSystem.IROut[3]};
                        case(_ALUSystem.IROut[8])
                            1'b0: MuxBSel = 2'b01;
                            1'b1: MuxASel = 2'b01;
                        endcase
                    end
                    1'b1:
                    begin
                        RF_OutASel = {1'b0, _ALUSystem.IROut[4:3]};
                        case(_ALUSystem.IROut[8])
                            1'b0: MuxBSel = 2'b00;
                            1'b1: MuxASel = 2'b00;
                        endcase
                    end
                    endcase
                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        RF_FunSel = 3'b010;
                        RF_RegSel = 4'b1111;
                        ARF_FunSel = 3'b010;
                        case (_ALUSystem.IROut[7:6])
                            2'b00: ARF_RegSel = 3'b011;
                            2'b01: ARF_RegSel = 3'b011;
                            2'b10: ARF_RegSel = 3'b110;
                            2'b11: ARF_RegSel = 3'b101;
                        endcase
                    end
                    1'b1:
                    begin
                        ARF_FunSel = 3'b010;
                        ARF_RegSel = 4'b1111;
                        RF_FunSel = 3'b010;
                        case (_ALUSystem.IROut[7:6])
                            2'b00: RF_RegSel = 4'b0111;
                            2'b01: RF_RegSel = 4'b1011;
                            2'b10: RF_RegSel = 4'b1101;
                            2'b11: RF_RegSel = 4'b1110;
                        endcase
                    end
                    endcase
                    
                end
                
                if (SC === 3'b011)
                begin
                    case(_ALUSystem.IROut[8])
                        1'b0: ARF_FunSel = {2'b00, _ALUSystem.IROut[10]};
                        1'b1: RF_FunSel = {2'b00, _ALUSystem.IROut[10]};
                    endcase
                    
                end
            end
        
            6'h07, 6'h08, 6'h09, 6'h0A, 6'h0B, 6'h0E, 6'h18: //LSL, LSR, ASR, CSL, CSR, NOT, MOVS =========================================================================
            begin
                ALU_WF = _ALUSystem.IROut[9];
                if (SC === 3'b010 && ~_ALUSystem.IROut[5])
                begin
                    RF_RegSel = 4'b1111;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b111;
                    ALU_FunSel = 5'b10000;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    ARF_OutCSel = {_ALUSystem.IROut[4], ~_ALUSystem.IROut[3]};
                    MuxASel = 2'b01;
                    RF_FunSel = 3'b010;
                    RF_ScrSel = 4'b0111;
                             
                end
                
                else if ((SC === 3'b010 && _ALUSystem.IROut[5]) || (SC === 3'b011 && ~_ALUSystem.IROut[5]))
                begin
                    RF_ScrSel = 4'b1111;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    case (_ALUSystem.IROut[5])
                        1'b1: RF_OutASel = {1'b0, _ALUSystem.IROut[4:3]};
                        1'b0: RF_OutASel = 3'b100;
                    endcase
                    RF_OutASel = {1'b0, _ALUSystem.IROut[4:3]};
                    case (_ALUSystem.IROut[15:10])
                        6'h07: ALU_FunSel = 5'b11011;
                        6'h08: ALU_FunSel = 5'b11100;
                        6'h09: ALU_FunSel = 5'b11101;
                        6'h0A: ALU_FunSel = 5'b11110;
                        6'h0B: ALU_FunSel = 5'b11111;
                        6'h0E: ALU_FunSel = 5'b10010;
                        6'h18: ALU_FunSel = 5'b10000;
                    endcase
                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        RF_FunSel = 3'b010;
                        RF_RegSel = 4'b1111;
                        MuxBSel = 2'b00;
                        ARF_FunSel = 3'b010;
                        case (_ALUSystem.IROut[7:6])
                            2'b00: ARF_RegSel = 3'b011;
                            2'b01: ARF_RegSel = 3'b011;
                            2'b10: ARF_RegSel = 3'b110;
                            2'b11: ARF_RegSel = 3'b101;
                        endcase
                    end
                    1'b1:
                    begin
                        ARF_FunSel = 3'b010;
                        ARF_RegSel = 4'b1111;
                        MuxASel = 2'b00;
                        RF_FunSel = 3'b010;
                        case (_ALUSystem.IROut[7:6])
                            2'b00: RF_RegSel = 4'b0111;
                            2'b01: RF_RegSel = 4'b1011;
                            2'b10: RF_RegSel = 4'b1101;
                            2'b11: RF_RegSel = 4'b1110;
                        endcase
                    end
                    endcase
                    
                end
            end
            
            6'h0C, 6'h0D, 6'h0F, 6'h10, 6'h15, 6'h16, 6'h17, 6'h19, 6'h1A, 6'h1B, 6'h1C, 6'h1D: //AND, ORR, XOR, NAND, ADD, ADC, SUB, ADDS, SUBS, ANDS, ORRS, XORS =========================================================================
            begin
                ALU_WF = _ALUSystem.IROut[9];
                if (SC === 3'b010 && ~(_ALUSystem.IROut[2] && _ALUSystem.IROut[5]))
                begin
                    RF_RegSel = 4'b1111;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b111;
                    ALU_FunSel = 5'b10000;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    case ({_ALUSystem.IROut[2], _ALUSystem.IROut[5]})
                        2'b01: ARF_OutCSel = {_ALUSystem.IROut[1], ~_ALUSystem.IROut[0]};
                        2'b00, 2'b10: ARF_OutCSel = {_ALUSystem.IROut[4], ~_ALUSystem.IROut[3]};
                    endcase
                    MuxASel = 2'b01;
                    RF_FunSel = 3'b010;
                    RF_ScrSel = 4'b0111;
                    
                end 
                
                else if (SC === 3'b011 && ~(_ALUSystem.IROut[2] || _ALUSystem.IROut[5]))
                begin
                    ARF_OutCSel = {_ALUSystem.IROut[1], ~_ALUSystem.IROut[0]};
                    RF_ScrSel = 4'b1011;
                    
                end
                
                else if ((SC === 3'b010 && (_ALUSystem.IROut[2] && _ALUSystem.IROut[5])) || (SC === 3'b011 && ((_ALUSystem.IROut[2] && ~_ALUSystem.IROut[5]) || (~_ALUSystem.IROut[2] && _ALUSystem.IROut[5]))) || (SC === 3'b100 && ~(_ALUSystem.IROut[2] && _ALUSystem.IROut[5])))
                begin
                    RF_ScrSel = 4'b1111;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    case ({_ALUSystem.IROut[2], _ALUSystem.IROut[5]})
                    2'b11:
                    begin
                        RF_OutASel = {1'b0, _ALUSystem.IROut[4:3]};
                        RF_OutBSel = {1'b0, _ALUSystem.IROut[1:0]};
                    end
                    2'b10:
                    begin
                        RF_OutASel = 3'b100;
                        RF_OutBSel = {1'b0, _ALUSystem.IROut[1:0]};
                    end
                    2'b01:
                    begin
                        RF_OutASel = {1'b0, _ALUSystem.IROut[4:3]};
                        RF_OutBSel = 3'b100;
                    end
                    2'b00:
                    begin
                        RF_OutASel = 3'b100;
                        RF_OutBSel = 3'b101;
                    end
                    endcase
                    case (_ALUSystem.IROut[15:10])
                        6'h0C, 6'h1B: ALU_FunSel = 5'b10111; //and
                        6'h0D, 6'h1C: ALU_FunSel = 5'b11000; //orr
                        6'h0F, 6'h1D: ALU_FunSel = 5'b11001; //xor
                        6'h10: ALU_FunSel = 5'b11010; //nand
                        6'h15, 6'h19: ALU_FunSel = 5'b10100; //add
                        6'h16: ALU_FunSel = 5'b10101; //addc
                        6'h17, 6'h1A: ALU_FunSel = 5'b10110; //sub
                    endcase
                    case(_ALUSystem.IROut[8])
                    1'b0:
                    begin
                        RF_FunSel = 3'b010;
                        RF_RegSel = 4'b1111;
                        MuxBSel = 2'b00;
                        ARF_FunSel = 3'b010;
                        case (_ALUSystem.IROut[7:6])
                            2'b00: ARF_RegSel = 3'b011;
                            2'b01: ARF_RegSel = 3'b011;
                            2'b10: ARF_RegSel = 3'b110;
                            2'b11: ARF_RegSel = 3'b101;
                        endcase
                    end
                    1'b1:
                    begin
                        ARF_FunSel = 3'b010;
                        ARF_RegSel = 4'b1111;
                        MuxASel = 2'b00;
                        RF_FunSel = 3'b010;
                        case (_ALUSystem.IROut[7:6])
                            2'b00: RF_RegSel = 4'b0111;
                            2'b01: RF_RegSel = 4'b1011;
                            2'b10: RF_RegSel = 4'b1101;
                            2'b11: RF_RegSel = 4'b1110;
                        endcase
                    end
                    endcase
                    
                end
            end
            
            6'h11, 6'h14: //MOVH, MOVL =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_ScrSel = 4'b1111;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b111;
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 1'b0;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    MuxASel = 2'b11;
                    case (_ALUSystem.IROut[15:10])
                        6'h11: RF_FunSel = 3'b110;
                        6'h14: RF_FunSel = 3'b101;
                    endcase
                    case (_ALUSystem.IROut[9:8])
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                end
            end
            
            6'h12: //LDR =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_ScrSel = 4'b1111;
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    ARF_OutDSel = 2'b10;
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b101;
                    case (_ALUSystem.IROut[9:8])
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = 3'b101;
                    
                end
                
                else if (SC === 3'b011)
                begin
                    RF_FunSel = 3'b110;
                    ARF_FunSel = 3'b000;
                    
                end
            end
            
            6'h13: //STR =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_FunSel = 3'b010;
                    RF_RegSel = 4'b1111;
                    RF_ScrSel = 4'b1111;
                    ALU_WF = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    RF_OutASel = {1'b0, _ALUSystem.IROut[9:8]};
                    ALU_FunSel = 5'b10000;
                    ARF_OutDSel = 2'b10;
                    MuxCSel = 1'b0;
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b1;
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = 3'b101;
                    
                end
                
                else if (SC === 3'b011)
                begin
                    MuxCSel = 1'b1;
                    ARF_FunSel = 3'b000;
                    
                end
            end
            
            6'h1E: //BX =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_RegSel = 4'b1111;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b111;
                    ALU_WF = 1'b0;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    ARF_OutCSel = 2'b00;
                    MuxASel =  2'b01;
                    RF_FunSel = 3'b010;
                    RF_ScrSel = 4'b0111;
                    ALU_FunSel = 5'b10000;
                    
                end
                
                else if (SC === 3'b011)
                begin
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b1;
                    RF_ScrSel = 4'b1111;
                    ARF_OutDSel = 2'b11;
                    RF_OutASel = 3'b100;
                    MuxCSel = 1'b1;
                    ARF_FunSel = 3'b000;
                    ARF_RegSel = 3'b110;
                    
                end
                
                else if (SC === 3'b100)
                begin
                    MuxCSel = 1'b0;
                    
                end
                
                else if (SC === 3'b101)
                begin
                    Mem_CS = 1'b1;
                    RF_OutASel = {1'b0, _ALUSystem.IROut[9:8]};
                    MuxBSel = 2'b00;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b011;
                    
                end
            end
            
            6'h1F: //BL =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_FunSel = 3'b010;
                    RF_RegSel = 4'b1111;
                    RF_ScrSel = 4'b1111;
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 1'b0;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = 3'b110;
                    
                end
                
                else if (SC === 3'b011)
                begin
                    ARF_OutDSel = 2'b11;
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b0;
                    MuxASel = 2'b10;
                    RF_FunSel = 3'b101;
                    RF_ScrSel = 4'b0111;
                    
                end
                
                else if (SC === 3'b100)
                begin
                    RF_FunSel = 3'b110;
                    ARF_RegSel = 3'b111;
                    
                end
                
                else if (SC === 3'b101)
                begin
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b10000;
                    MuxBSel = 2'b00;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b011;
                    
                end
            end
            
            6'h20: //LDRIM =========================================================================
            begin
                if (SC === 3'b010)
                begin
                    RF_ScrSel = 4'b1111;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b111;
                    ALU_FunSel = 5'b10000;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    ALU_WF = 1'b0;
                    MuxASel = 2'b11;
                    RF_FunSel = 3'b100;
                    case (_ALUSystem.IROut[9:8])
                        2'b00: RF_RegSel = 4'b0111;
                        2'b01: RF_RegSel = 4'b1011;
                        2'b10: RF_RegSel = 4'b1101;
                        2'b11: RF_RegSel = 4'b1110;
                    endcase
                    
                end
            end
            
            6'h21: //STRIM =========================================================================
            begin
                if(SC === 3'b010)
                begin
                    RF_RegSel = 4'b1111;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b111;
                    ALU_FunSel = 5'b10000;
                    ALU_WF = 1'b0;
                    Mem_CS = 1'b1;
                    Mem_WR = 1'b0;
                    IR_Write = 1'b0;
                    IR_LH = 1'b0;
                    MuxASel = 2'b11;
                    RF_FunSel = 3'b100;
                    RF_ScrSel = 4'b1011;
                    
                end
                
                else if (SC === 3'b011)
                begin
                    ARF_OutCSel = 2'b10;
                    MuxASel = 2'b01;
                    RF_FunSel = 3'b010;
                    RF_ScrSel = 4'b0111;
                    RF_OutASel = 3'b100;
                    RF_OutBSel = 3'b101;
                    ALU_FunSel = 5'b10100;
                    
                end
                
                else if (SC === 3'b100)
                begin
                    RF_ScrSel = 4'b1111;
                    MuxBSel = 2'b00;
                    ARF_FunSel = 3'b010;
                    ARF_RegSel = 3'b101;
                    
                end
                
                else if (SC === 3'b101)
                begin
                    Mem_CS = 1'b0;
                    Mem_WR = 1'b1;
                    ARF_OutDSel =  2'b10;
                    RF_OutASel = {1'b0, _ALUSystem.IROut[9:8]};
                    ALU_FunSel = 5'b10000;
                    MuxCSel = 1'b0;
                    ARF_FunSel = 3'b001;
                    ARF_RegSel = 3'b101;
                    
                end
                
                else if (SC === 3'b110)
                begin
                    MuxCSel = 1'b1;
                    ARF_FunSel = 3'b000;
                    
                end
                
                else if (SC === 3'b111)
                begin
                    Mem_CS = 1'b1;
                    RF_OutASel = 3'b100;
                    ALU_FunSel = 5'b10000;
                    ARF_FunSel = 3'b010;
                    
                end
            end
            endcase 
        end	
        
    end
	

end


endmodule