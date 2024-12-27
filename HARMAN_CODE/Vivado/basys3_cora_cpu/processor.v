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

//MAR :ROM�� ũ�⿡ ���� ������ 
//256���� ROM�޸𸮸� ����� 8bit�� ��巹�� �� �� ���� 1bit�� 2��, 2bit�� 4�� ... 
//MAR�� �޴� �ּ� 8bit¥���� ����, 8bit¥�� �������� ����� �� 
module processor(
    input clk ,reset_p,
    input [3:0] key_value,   //�ܺο��� key���� �޾ƿ� 
    input key_valid ,
    output [3:0] kout, //fnd 4bit ��� 
    output [7:0] outreg_data
    );
    wire [7:0] int_bus;     //������ ���� �Է¹޴� 8bit 
    wire [7:0]mar_out, rom_out;      //mar_out: ���߿� ROM�� �ּ� �Է¿� �� ���� 
    wire mar_inen, mdr_inen, mdr_oen; 
    
    register_Nbit_p #(.N(8)) MAR(   //�ּҹ޾Ƽ� rom addressing 
        .clk(clk), .reset_p(reset_p),
        .d(int_bus), .wr_en(mar_inen), .rd_en(1), //rd_en=1 ������ ) ROM���� ���ϱ� �������ϸ� �� ��� ������ �ʿ� ���� 
        .register_data(mar_out)) ;               //mar_out == MAR�� out  //rd_en=1  =>q�ᵵ������ �������� register_data�� �������ϱ� �װ� ��� 

//MDR- ROM���� ������ �ް�, bus�� ��� ( ROM�� ��� ROM_OUT) 
    register_Nbit_p #(.N(8)) MDR(
        .clk(clk), .reset_p(reset_p),
        .d(rom_out), .wr_en(mdr_inen), .rd_en(mdr_oen), 
        .q(int_bus)) ;             //������ ������ �� ������ q���������� ( rd_en=1�� ���� ����ؾ��ϱ� ���� )  

    wire [7:0] ir_in; 
    register_Nbit_p #(.N(8)) IR(
        .clk(clk), .reset_p(reset_p),
        .d(int_bus), .wr_en(ir_inen), 
        .register_data(ir_in));  

wire pc_inc, load_pc, pc_rd_en, pc_oen; 
    program_addr_counter pc(    //�׸����� pc�� �������� �ް� ������ ����Ѵ�. ����� ȭ��ǥ
        .clk(clk), .reset_p(reset_p),
        .pc_inc(pc_inc), .load_pc(load_pc), .pc_rd_en(pc_oen),
        .pc_in(int_bus), 
        .pc_out(int_bus));

//PC 1�� ����, C���� �ݺ��� ���� ���� -> �� �ּҷ� ������ �׷��� ROM�� �� ���� �����´�. 
//�׷��� �б⵵ ������ (���������� 1�� ���� , �������� ������ ���� Ư�� ���� ���ٰ� ����� �� �־���ؼ� ������ ����� 

    wire acc_high_reset_p , acc_o_en , acc_in_select; //acc ���� 4bit�� control block���� ���� //acc out enable 
    wire [1:0] acc_high_select_in, acc_low_select; 
    wire [3:0] bus_reg_data; 
    wire op_add, op_sub, op_mul, op_div, op_and;
    wire zero_flag, sign_flag; 
    
    block_alu_acc   alu_acc(
        .clk(clk), .reset_p(reset_p), .acc_high_reset_p(acc_high_reset_p), 
        .rd_en(acc_o_en), .acc_in_select(acc_in_select), 
        .acc_high_select_in(acc_high_select_in), .acc_low_select(acc_low_select),    //acc_high_select - �ܺο��� ������ ���� 
        .bus_data(int_bus[7:4]), .bus_reg_data(bus_reg_data), //bus_reg_data�� ������������ �޴°Ŵϱ� �ܺο��� �޾ƾ��ؼ� input���� �־���
        .op_add(op_add), .op_sub(op_sub), .op_mul(op_mul), .op_div(op_div), .op_and(op_and),  
        .zero_flag(zero_flag), .sign_flag(sign_flag), 
        .acc_data(int_bus));

    wire inreg_oen; 
    register_Nbit_p #(.N(4)) INREG(   //Ű���� �޴� inreg 
        .clk(clk), .reset_p(reset_p),
        .d(key_value),
        .wr_en(1'b1), .rd_en(inreg_oen),    //������ �̾��� rd_en�ʿ�     
        .q(int_bus[7:4])); 
  
    wire keych_oen; 
    register_Nbit_p #(.N(4)) KEYCHREG(   //Ű �Է��� �ٲ���� �� key_valid�� 1�� ������ 1111�� 
        .clk(clk), .reset_p(reset_p),
        .d({key_valid,key_valid,key_valid,key_valid}),  //1bit�� 4bit�� 
        .wr_en(1'b1), .rd_en(keych_oen),    //������ �̾��� rd_en�ʿ�     
        .q(int_bus[7:4]));
   
    wire keyout_inen;    
    register_Nbit_p #(.N(4)) KEYOUTREG(   //Ű �Է��� fnd�� ����ϴ� reg 
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]),  
        .wr_en(keyout_inen), 
        .register_data(kout));  //fnd�� �������� ���̹Ƿ� register_data (Q���X) kout�� fnd�� ���

    wire breg_inen; 
    register_Nbit_p #(.N(4)) BREG(   //4bit BREG
        .clk(clk), .reset_p(reset_p),
        .d(int_bus[7:4]), .wr_en(breg_inen),  //rd_en=1 ������ ) ALU�� ���ϱ� �������ϸ� �� ��� ������ �ʿ� ���� -> q�� �Ⱦ��� reg data�� ���      
        .register_data(bus_reg_data)) ; //bus�� ����ϴ°� X -> rd_en���ְ� �������� ��� ��� 
        
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
  //   wire [7:0] outreg_data; -->������� �̾���
    register_Nbit_p #(.N(8)) OUTREG(   
        .clk(clk), .reset_p(reset_p),
        .d(int_bus), 
        .wr_en(outreg_inen),       
        .register_data(outreg_data)) ;        
        
    control_block cb(
         clk, reset_p,
         ir_in, 
         zero_flag, sign_flag,
         mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen, //load_pc = pc�� enable 
         breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen, 
         dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
         acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div, 
         outreg_inen, inreg_oen, keych_oen, keyout_inen, rom_en, 
         acc_low_select, acc_high_select_in );
         
      dist_mem_gen_0 rom( .a(mar_out), .qspo_ce(rom_en), .spo(rom_out));
        
endmodule

