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
    output [3:0] alu_data,  //alu가 내보내주는 data 
    output zero_flag, sign_flag, carry_flag, cout   //zero, sign -비교연산 시 필요, caary_flag-캐리가 발생하면 1 cout - 캐리 값 
    //carry_flag 캐리발생 시 1 
    //cout = carry out 
    //zero_flag 0되면 1 
    //sign_flag 1이면 음수 0이면 양수 
    //비교연산 빼기로 대체 가능 
    //a vs b -> 빼기 결과가 0되면 같음 -->빼고 zero flag를 보면 됨 
    // a-b뺀 다음에 최상위비트를 본다. 빼고 sign이 1이면 a<b
    //더하기 명령시 op_add만 1 나머지는 다 0 
    );
    
    wire [3:0] sum;
    
    //fadd : s=1이면 뺌, s=0이면 + 
 fadd_sub_4bit fadd( 
    .A(acc_high_data), .B(bus_reg_data), 
    .s(op_sub | op_div),
    .sum(sum), 
    .carry(cout));
    
      //andㄱ 들어오면 두개를 엔드처리 1이면 앤드연산결과 나오기 
    assign alu_data = op_and ? (acc_high_data & bus_reg_data) : sum; 
    
     register_Nbit_p #(.N(1)) sign_f(
        .clk(clk), .reset_p(reset_p),
        .d(!cout & op_sub), .wr_en(op_sub), .rd_en(1), // 읽고,쓰고 싶을 때만 레지스터 사용할 수 있도록 변수 선언함 
        //항상 읽고 쓰는건 빼기일때만 쓰기 위해서 ( sign_flag의 사용을 위해 wr_en이 필요 )
        .q(sign_flag));
     
    register_Nbit_p #(.N(1)) zero_f(
        .clk(clk), .reset_p(reset_p),
        .d(~(|sum )), .wr_en(op_sub), .rd_en(1),  //|sum이면 각 비트들을 or한다. 
        .q(zero_flag));
               
        //덧셈할때만 나옴 뺄셈시에 cout은 뺀 결과가 음수면 0 양수면 1 ( 빼기할때는 올림수의 의미 아님) 
      register_Nbit_p #(.N(1)) carry_f(
        .clk(clk), .reset_p(reset_p),
        .d(cout & (op_add | op_div |(op_mul & alu_lsb))), .wr_en(1), .rd_en(1),  //|sum이면 각 비트들을 or한다. 
        .q(carry_flag));  
        
endmodule
