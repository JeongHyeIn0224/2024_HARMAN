`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

////0605
module block_alu_acc(
    input clk, reset_p, acc_high_reset_p, 
    input rd_en, acc_in_select, 
    input [1:0] acc_high_select_in, acc_low_select,    //acc_high_select - �ܺο��� ������ ���� 
    input [3:0] bus_data, bus_reg_data, //bus_reg_data�� ������������ �޴°Ŵϱ� �ܺο��� �޾ƾ��ؼ� input���� �־���
    input op_add, op_sub, op_mul, op_div, op_and,  
    output zero_flag, sign_flag, 
    output [7:0] acc_data );
    
    wire fill_value; 
    wire [3:0] high_data2bus, acc_high_data2alu;
    wire [3:0] low_data2bus, acc_low_data;
    wire [3:0] alu_data; 
    wire [1:0] acc_high_select;
   
    wire  [3:0] acc_high_data;   //acc�κ��� ���� 
    wire alu_lsb, carry_flag, cout; 
   //acc_high_select[1] (�����ڸ�) , cc_high_select[0] ( �����ڶ��)
   //���ϱ��̸� 
   assign acc_high_select[1] = (op_mul | op_div) ? (op_mul & acc_low_data[0]) |  (op_div & cout) : acc_high_select_in[1];   //1�� ���� 11���� �ε� 
   assign acc_high_select[0] = (op_mul | op_div) ? (op_mul & acc_low_data[0]) |  (op_div & cout) : acc_high_select_in[0];   //0�� ���� 00���� �ε�X  
   
    acc block_acc(// full acc 
         clk, reset_p, acc_high_reset_p, 
         fill_value, rd_en, //acc_high_reset_p: ���� 4bit�� ������ �� 
         acc_in_select,
         acc_high_select, acc_low_select,
         bus_data, alu_data, 
         high_data2bus, acc_high_data2alu,//acc_high_data2alu ������ , high_data2bus rd_en�� 1�� ���� ��� 
         low_data2bus, acc_low_data);
    
    assign acc_data = {high_data2bus, low_data2bus};
  
    alu block_alu(
        clk, reset_p, 
        op_add, op_sub, op_mul, op_div, op_and, alu_lsb, 
        acc_high_data, bus_reg_data, 
        alu_data,
        zero_flag, sign_flag, carry_flag, cout);
        
    assign fill_value = carry_flag; 
    assign acc_high_data = acc_high_data2alu;
    assign alu_lsb = acc_high_data2alu[0];
    
endmodule
