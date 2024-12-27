`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/05 14:37:38
// Design Name: 
// Module Name: processor
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

//MAR :ROM의 크기에 따라 정해짐 
//256개의 ROM메모리를 만들면 8bit로 어드레싱 할 수 있음 1bit로 2개, 2bit로 4개 ... 
//MAR에 받는 주소 8bit짜리로 만듦, 8bit짜리 레지스터 만드는 것 
module processor(
    input clk ,reset_p,
    input [3:0] key_value,   //외부에서 key값을 받아옴 
    input key_valid ,
    output [3:0] kout, //fnd 4bit 출력 
    output [7:0] outreg_data
    );
    wire [7:0] int_bus;     //버스로 부터 입력받는 8bit 
    wire [7:0]mar_out, rom_out;      //mar_out: 나중에 ROM의 주소 입력에 줄 것임 
    wire mar_inen, mdr_inen, mdr_oen; 
    
    register_Nbit_p #(.N(8)) MAR(   //주소받아서 rom addressing 
        .clk(clk), .reset_p(reset_p),
        .d(int_bus), .wr_en(mar_inen), .rd_en(1), //rd_en=1 상시출력 ) ROM으로 가니까 상시출력하면 됨 출력 제어할 필요 없음 
        .register_data(mar_out)) ;               //mar_out == MAR의 out  //rd_en=1  =>q써도되지만 상시출력이 register_data로 빼놨으니까 그거 사용 

//MDR- ROM으로 데이터 받고, bus로 출력 ( ROM의 출력 ROM_OUT) 
    register_Nbit_p #(.N(8)) MDR(
        .clk(clk), .reset_p(reset_p),
        .d(rom_out), .wr_en(mdr_inen), .rd_en(mdr_oen), 
        .q(int_bus)) ;             //버스로 나가는 건 무조건 q출력해줘야함 ( rd_en=1일 때만 출력해야하기 때문 )  

    wire [7:0] ir_in; 
    register_Nbit_p #(.N(8)) IR(
        .clk(clk), .reset_p(reset_p),
        .d(int_bus), .wr_en(ir_inen), 
        .register_data(ir_in));  

wire pc_inc, load_pc, pc_rd_en, pc_oen; 
    program_addr_counter pc(    //그림에서 pc는 버스에서 받고 버스로 출력한다. 양방향 화살표
        .clk(clk), .reset_p(reset_p),
        .pc_inc(pc_inc), .load_pc(load_pc), .pc_rd_en(pc_oen),
        .pc_in(int_bus), 
        .pc_out(int_bus));

//PC 1씩 증가, C언어에서 반복문 등은 점프 -> 그 주소로 덮어씌우고 그래야 ROM에 그 값을 가져온다. 
//그래서 읽기도 하지만 (읽을때마다 1씩 증가 , 버스에서 가져온 값을 특정 번지 갖다가 덮어씌울 수 있어야해서 방향이 양방향 

    wire acc_high_reset_p , acc_o_en , acc_in_select; //acc 상위 4bit는 control block에서 제어 //acc out enable 
    wire [1:0] acc_high_select_in, acc_low_select; 
    wire [3:0] bus_reg_data; 
    wire op_add, op_sub, op_mul, op_div, op_and;
    wire zero_flag, sign_flag; 
    
    block_alu_acc   alu_acc(
        .clk(clk), .reset_p(reset_p), .acc_high_reset_p(acc_high_reset_p), 
        .rd_en(acc_o_en), .acc_in_select(acc_in_select), 
        .acc_high_select_in(acc_high_select_in), .acc_low_select(acc_low_select),    //acc_high_select - 외부에서 들어오고 있음 
        .bus_data(int_bus[7:4]), .bus_reg_data(bus_reg_data), //bus_reg_data는 버스에서부터 받는거니까 외부에서 받아야해서 input으로 주었음
        .op_add(op_add), .op_sub(op_sub), .op_mul(op_mul), .op_div(op_div), .op_and(op_and),  
        .zero_flag(zero_flag), .sign_flag(sign_flag), 
        .acc_data(int_bus));

    wire inreg_oen; 
    register_Nbit_p #(.N(4)) INREG(   //키값을 받는 inreg 
        .clk(clk), .reset_p(reset_p),
        .d(key_value),
        .wr_en(1'b1), .rd_en(inreg_oen),    //버스로 이어짐 rd_en필요     
        .q(int_bus[7:4])); 
  
    wire keych_oen; 
    register_Nbit_p #(.N(4)) KEYCHREG(   //키 입력이 바뀌었을 때 key_valid가 1로 들어오면 1111됨 
        .clk(clk), .reset_p(reset_p),
        .d({key_valid,key_valid,key_valid,key_valid}),  //1bit를 4bit로 
        .wr_en(1'b1), .rd_en(keych_oen),    //버스로 이어짐 rd_en필요     
        .q(int_bus[7:4]));
   
    wire keyout_inen;    
    register_Nbit_p #(.N(4)) KEYOUTREG(   //키 입력을 fnd로 출력하는 reg 
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]),  
        .wr_en(keyout_inen), 
        .register_data(kout));  //fnd에 상시출력할 것이므로 register_data (Q출력X) kout을 fnd로 출력

    wire breg_inen; 
    register_Nbit_p #(.N(4)) BREG(   //4bit BREG
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]), .wr_en(breg_inen),  //rd_en=1 상시출력 ) ALU로 가니까 상시출력하면 됨 출력 제어할 필요 없음 -> q를 안쓰고 reg data로 사용      
        .register_data(bus_reg_data)) ; //bus로 출력하는거 X -> rd_en없애고 레지스터 출력 사용 
        
    wire tmpreg_inen, tmpreg_oen; 
    register_Nbit_p #(.N(4)) TEMPREG(   
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]), 
        .wr_en(tmpreg_inen), .rd_en(tmpreg_oen),       
        .q(int_bus[7:4])) ; 
        
    wire creg_inen, creg_oen; 
    register_Nbit_p #(.N(4)) CREG(   
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]), 
        .wr_en(creg_inen), .rd_en(creg_oen),       
        .q(int_bus[7:4]));       
   
    wire dreg_inen, dreg_oen;     
    register_Nbit_p #(.N(4)) DREG(   
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]), 
        .wr_en(dreg_inen), .rd_en(dreg_oen),       
        .q(int_bus[7:4]));    
    
    wire rreg_inen, rreg_oen;     
    register_Nbit_p #(.N(4)) RREG(   
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]), 
        .wr_en(rreg_inen), .rd_en(rreg_oen),       
        .q(int_bus[7:4]));    
        
     wire outreg_inen;   
  //   wire [7:0] outreg_data; -->출력으로 뽑았음
    register_Nbit_p #(.N(8)) OUTREG(   
        .clk(clk), .reset_p(reset_p),
        .d(int_bus), 
        .wr_en(outreg_inen),       
        .register_data(outreg_data)) ;        
        
    control_block cb(
         clk, reset_p,
         ir_in, 
         zero_flag, sign_flag,
         mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen, //load_pc = pc의 enable 
         breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen, 
         dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
         acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div, 
         outreg_inen, inreg_oen, keych_oen, keyout_inen, rom_en, 
         acc_low_select, acc_high_select_in );
         
      dist_mem_gen_0 rom( .a(mar_out), .qspo_ce(rom_en), .spo(rom_out));
        
endmodule

