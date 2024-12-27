`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/04 12:15:17
// Design Name: 
// Module Name: acc
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
//4bi짜리 acc 2개로 2개 이어 붙여서 8bit acc만들예정 
module half_acc(
    input clk, reset_p,
    input load_msb, load_lsb, // 4bit짜리 좌시프트 우시프트 할 ㄸ 사용 
    input rd_en,
    input [1:0] s, //00-data유지, 01- 우시프트, 10- 좌시프트 , 11-load //select bit 
    input [3:0] data_in, 
    output [3:0] data2bus, register_data
    );
    
    reg [3:0] d; 
    always @* begin //* ->level trigger, 조합회로 
        case(s) 
            2'b00 : d = register_data;  //data유지 
            2'b01 : d = {load_msb, register_data[3:1]}; //상위 3bit , 우시프트  외부에서 최상위비트 받음 -load_msb
            2'b10 : d = {register_data[2:0], load_lsb}; //하위 3bit ,좌시프트  외부에서 최하위비트 받음 -load_lsb
            2'b11 : d = data_in; 
        endcase
    end
        
    register_Nbit_p #(.N(4)) h_acc(.clk(clk), .reset_p(reset_p),
        .d(d), .wr_en(1), .rd_en(rd_en), 
        .register_data(register_data),
        .q(data2bus));  //rd_en=1, q가 나가고 rd_en=0, q=임피던스 , 
endmodule

////0604
module acc (// full acc 
    input clk, reset_p, acc_high_reset_p, 
    input fill_value, rd_en, //acc_high_reset_p: 상위 4bit만 리셋할 때 
    input acc_in_select,
    input [1:0] acc_high_select, acc_low_select,
    input [3:0] bus_data, alu_data, 
    output [3:0] high_data2bus, acc_high_data2alu,//acc_high_data2alu 상시출력 , high_data2bus rd_en이 1일 때만 출력 
    output [3:0] low_data2bus, acc_low_data);      //하위 2bit는 alu로 나감 
    
    wire [3:0] acc_high_in;
    assign acc_high_in = acc_in_select ? bus_data : alu_data; //alu or bus 중 어디로 데이터 받을 지 결정 
    
     half_acc acc_high(
    .clk(clk), .reset_p(reset_p | acc_high_reset_p),    
    .load_msb(fill_value), .load_lsb(acc_low_data[3]), // 좌시프트를 하면 acc_low_data가 들어오고 , 우시프트를 하면 fill_value가 들어옴
    .rd_en(rd_en), 
    .s(acc_high_select), 
    .data_in(acc_high_in), 
    .data2bus(high_data2bus), .register_data(acc_high_data2alu));   //상위 4bit의 상시출력 acc_high_data가 alu로감 
    
     half_acc acc_low(
    .clk(clk), .reset_p(reset_p),
    .load_msb(acc_high_data2alu[0]), .load_lsb(fill_value), 
    .rd_en(rd_en),
    .s(acc_low_select), 
    .data_in(acc_high_data2alu), //acc 하위 4bit는 버스입력을 무조건 acc상위 4bit로부터 받는다. 
    .data2bus(low_data2bus), .register_data(acc_low_data)
    );

endmodule 