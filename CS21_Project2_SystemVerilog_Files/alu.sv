//`timescale 1ns / 1ps
module alu(input  logic [31:0] a, b,
           input  logic [4:0]  alucontrol,
           output logic [31:0] result,
           output logic        zero);
  
  logic [31:0] condinvb, sum, uplowbit, assistlhu, lhu, sllv, slt;

  assign condinvb = alucontrol[4] ? ~b : b;
  assign sum = a + condinvb + alucontrol[4];
  
  assign uplowbit = (b == 32'b0) ? a[15:0] : a[31:16];
  assign assistlhu = (b == 32'b0 || b == 'd2) ? uplowbit : 16'b0;
  assign lhu = {16'b0, assistlhu}; // LHU
  assign sllv = {16'b0, a[4:0]}; // SLLV
  assign slt = (a < b) ? 1 : 0; // BLT; slt: 1 if rs < rt, else 0
 
  always_comb
    case (alucontrol)
      4'b0000: result = a & b;
      4'b0001: result = a | b;
      4'b0010: result = sum;
      4'b0011: result = sum[31];
      4'b0100: result = (b == 32'b0) ? a : 'bx; // MOVZ
      4'b0101: result = lhu; // LHU
      4'b0110: result = b << sllv; // SLLV
      4'b0111: result = (slt != 'b0) ? 0 : 1; // BLT; bne: branch if slt!=0
      4'b1000: result = {16'b0, b[15:0]}; // LI; zero extend immediate
      4'b1001: result = {a[31:24], b[23:16], a[15:8], b[7:0]}; // MIX 4
    endcase

  assign zero = (result == 32'b0);
endmodule
