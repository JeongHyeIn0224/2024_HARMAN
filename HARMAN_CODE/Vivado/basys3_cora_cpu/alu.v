`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/04 11:17:48
// Design Name: 
// Module Name: alu
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

////0604
module alu(
    input clk, reset_p, 
    input op_add, op_sub, op_mul, op_div, op_and, alu_lsb, 
    input [3:0] acc_high_data, bus_reg_data, //breg 
    output [3:0] alu_data,  //alu�� �������ִ� data 
    output zero_flag, sign_flag, carry_flag, cout   //zero, sign -�񱳿��� �� �ʿ�, caary_flag-ĳ���� �߻��ϸ� 1 cout - ĳ�� �� 
    //carry_flag ĳ���߻� �� 1 
    //cout = carry out 
    //zero_flag 0�Ǹ� 1 
    //sign_flag 1�̸� ���� 0�̸� ��� 
    //�񱳿��� ����� ��ü ���� 
    //a vs b -> ���� ����� 0�Ǹ� ���� -->���� zero flag�� ���� �� 
    // a-b�� ������ �ֻ�����Ʈ�� ����. ���� sign�� 1�̸� a<b
    //���ϱ� ��ɽ� op_add�� 1 �������� �� 0 
    );
    
    wire [3:0] sum;
    
    //fadd : s=1�̸� ��, s=0�̸� + 
 fadd_sub_4bit fadd( 
    .A(acc_high_data), .B(bus_reg_data), 
    .s(op_sub | op_div),
    .sum(sum), 
    .carry(cout));
    
      //and�� ������ �ΰ��� ����ó�� 1�̸� �ص忬���� ������ 
    assign alu_data = op_and ? (acc_high_data & bus_reg_data) : sum; 
    
     register_Nbit_p #(.N(1)) sign_f(
        .clk(clk), .reset_p(reset_p),
        .d(!cout & op_sub), .wr_en(op_sub), .rd_en(1), // �а�,���� ���� ���� �������� ����� �� �ֵ��� ���� ������ 
        //�׻� �а� ���°� �����϶��� ���� ���ؼ� ( sign_flag�� ����� ���� wr_en�� �ʿ� )
        .q(sign_flag));
     
    register_Nbit_p #(.N(1)) zero_f(
        .clk(clk), .reset_p(reset_p),
        .d(~(|sum )), .wr_en(op_sub), .rd_en(1),  //|sum�̸� �� ��Ʈ���� or�Ѵ�. 
        .q(zero_flag));
               
        //�����Ҷ��� ���� �����ÿ� cout�� �� ����� ������ 0 ����� 1 ( �����Ҷ��� �ø����� �ǹ� �ƴ�) 
      register_Nbit_p #(.N(1)) carry_f(
        .clk(clk), .reset_p(reset_p),
        .d(cout & (op_add | op_div |(op_mul & alu_lsb))), .wr_en(1), .rd_en(1),  //|sum�̸� �� ��Ʈ���� or�Ѵ�. 
        .q(carry_flag));  
        
endmodule
