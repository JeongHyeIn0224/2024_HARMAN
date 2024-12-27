`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/10 10:19:06
// Design Name: 
// Module Name: control_block
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

module control_block(
    input clk, reset_p,
    input [7:0] ir_in, 
    input zero_flag, sign_flag,
    output  mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
            breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen, 
            dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
            acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div, 
            outreg_inen, inreg_oen, keych_oen, keyout_inen, rom_en, 
    output [1:0] acc_low_select, acc_high_select_in  );
   
    wire [11:0] t; 
    ring_counter_clk12 rcount(.clk(clk), .reset_p(reset_p), .t(t));
    
    wire  nop, outb, outs, add_s, sub_s, and_s, shl, clr_s, psah, shr, load, jz, jmp, jge ,div_s, mul_s,
            mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br, mov_tmp_cr ,mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br, mov_dr_ah,
            mov_dr_tmp, mov_dr_br, mov_rr_ah, mov_key_ah, mov_inr_tmp, mov_inr_rr;
    
    instr_decoder i_decoder(
            ir_in,  
            nop, outb, outs, add_s, sub_s, and_s, shl, clr_s, psah, shr, load, jz, jmp, jge ,div_s, mul_s,
            mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br, mov_tmp_cr ,mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br, mov_dr_ah,
            mov_dr_tmp, mov_dr_br, mov_rr_ah, mov_key_ah, mov_inr_tmp, mov_inr_rr );
    
    control_signal c_signal(
         t, 
         nop, outb, outs, add_s, sub_s, and_s, shl, clr_s, psah, shr, load, jz, jmp, jge ,div_s, mul_s,
         mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br, mov_tmp_cr ,mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br, mov_dr_ah,
         mov_dr_tmp, mov_dr_br, mov_rr_ah, mov_key_ah, mov_inr_tmp, mov_inr_rr ,
         zero_flag, sign_flag,        
         mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
         breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen, 
         dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
         acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div, 
         outreg_inen, inreg_oen, keych_oen, keyout_inen, rom_en, 
         acc_low_select, acc_high_select_in );
    
    
    
    
    
    
endmodule


module control_signal(
    input [11:0] t, 
    input nop, outb, outs, add_s, sub_s, and_s, shl, clr_s, psah, shr, load, jz, jmp, jge ,div_s, mul_s,
          mov_ah_cr, mov_ah_dr, mov_tmp_ah, mov_tmp_br, mov_tmp_cr ,mov_tmp_dr, mov_tmp_rr, mov_cr_ah, mov_cr_br, mov_dr_ah,
          mov_dr_tmp, mov_dr_br, mov_rr_ah, mov_key_ah, mov_inr_tmp, mov_inr_rr ,
    input zero_flag, sign_flag,        
    output mar_inen, mdr_inen, mdr_oen, ir_inen, pc_inc, load_pc, pc_oen,
            breg_inen, tmpreg_inen, tmpreg_oen, creg_inen, creg_oen, 
            dreg_inen, dreg_oen, rreg_inen, rreg_oen, acc_high_reset_p,
            acc_in_select, acc_o_en, op_add, op_sub, op_and, op_mul, op_div, 
            outreg_inen, inreg_oen, keych_oen, keyout_inen, rom_en, 
    output [1:0] acc_low_select, acc_high_select_in );

//acc의 high 네비트에 데이터로드 시 버스로부터 로드 or ALU로부터 로드 
//acc_in_select는 버스로부터 받을 때 1
//assign pc_oen                = t[0] | (t[3] & (load | jz | jmp | jge));                             //t[0]가 1일 때 pc_oen=1 출력  t[3]
//assign mar_inen              = t[0] | (t[3] & (load | jz | jmp | jge)); 
//assign pc_inc                = t[1] | (t[4] & (load | jz | jmp | jge));
//assign mdr_oen               = t[2] | (t[5] & (load | (jz & zero_flag) | jmp | (jge & ~sign_flag ))); //sign_flag가 0일 때 발생 
//assign rom_en                = ~ (t[1] | (t[4] & (load | jz | jmp | jge))); //0에서 동작 
//assign mdr_inen              = t[1] | (t[4] & (load | jz | jmp | jge));
//assign ir_inen               = t[2];
//assign tmpreg_oen            = t[3];   //tmp_oen
//assign keyout_inen           = t[3] & outb ;
//assign acc_o_en              = t[3] & (outs  | mov_ah_cr |mov_ah_dr); 
//assign outreg_inen           = t[3] & outs ; 
//assign acc_high_select_in[0] = (t[3] & (add_s | sub_s | and_s | shr | mov_tmp_ah | mov_cr_ah | mov_dr_ah | mov_rr_ah | mov_key_ah )) 
//                                | (t[4] & (add_s | mul_s)) 
//                                | (t[6] & mul_s)  | (t[8] & mul_s)  | (t[10] & mul_s);

//assign acc_high_select_in[1] = (t[3] & (add_s | sub_s | and_s | shl | div_s | mov_tmp_ah | mov_cr_ah | mov_dr_ah | mov_rr_ah | mov_key_ah ))
//                                | (t[5] & div_s) | (t[7] & div_s) | (t[9] & div_s);
//assign op_sub               = t[3] & sub_s;  
//assign op_and               = t[3] & and_s; 
//assign op_add               = t[3] & add_s; 
//assign acc_high_reset_p     = t[3] & clr_s;     //ah_reset
//assign acc_low_select[0]    =(t[3] & (psah | shr)) | (t[4] & add_s| mul_s) | ((t[6] | t[8] | t[10]) & mul_s);
//assign acc_low_select[1]    =(t[3] & (shl  | psah  | div_s))  | ((t[5] | t[7] | t[9] | t[11]) & div_s);
//assign tmpreg_inen          =(t[3] & (mov_dr_tmp | mov_inr_tmp )) | (t[5] & load); //tmp_inen
//assign acc_in_select        =(t[3] & (mov_tmp_ah | mov_cr_ah | mov_dr_ah | mov_rr_ah | mov_key_ah));
//assign inreg_oen            = t[3] & (mov_inr_tmp| mov_inr_rr);
//assign breg_inen            = t[3] & (mov_tmp_ah | mov_cr_br | mov_dr_br);
//assign creg_oen             = t[3] & (mov_cr_ah  | mov_cr_br);
//assign creg_inen            = t[3] & (mov_ah_cr  | mov_tmp_cr);
//assign dreg_inen            = t[3] & (mov_ah_dr  | mov_tmp_dr);
//assign dreg_oen             = t[3] & (mov_dr_ah  | mov_dr_tmp | mov_dr_br);
//assign rreg_inen            = t[3] & (mov_tmp_rr | mov_inr_rr);
//assign rreg_oen             = t[3] & mov_rr_ah;
//assign op_mul               = (t[3] | t[5] | t[7] | t[9]) & mul_s; //mul_o
//assign op_div               = (t[4] | t[6] | t[8] | t[10]) & div_s; //div_o 
//assign keych_oen            = t[3] & mov_key_ah; 
//assign load_pc              = t[5] & ((jz & zero_flag) | jmp | (jge & ~sign_flag ));


    assign pc_oen = t[0] | (t[3] & (load | jz | jmp | jge));
    assign mar_inen = t[0] | (t[3] & (load | jz | jmp | jge));
    assign pc_inc = t[1] | (t[4] & (load | jz | jmp | jge));
    assign mdr_oen = t[2] | (t[5] & (load | (jz & zero_flag) | jmp | (jge & ~sign_flag)));
    assign ir_inen = t[2];
    assign tmpreg_inen = (t[3]&(mov_dr_tmp|mov_inr_tmp))|(t[5]&load);
    assign tmpreg_oen = t[3]&(outb|mov_tmp_ah|mov_tmp_br|mov_tmp_cr | mov_tmp_dr|mov_tmp_rr);
    assign creg_inen = t[3]&(mov_ah_cr|mov_tmp_cr);
    assign creg_oen = t[3]&(mov_cr_ah|mov_cr_br);
    assign dreg_inen = t[3]&(mov_ah_dr|mov_tmp_dr);
    assign dreg_oen = t[3]&(mov_dr_ah|mov_dr_br|mov_dr_tmp);
    assign rreg_inen = t[3]&(mov_tmp_rr|mov_inr_rr);
    assign rreg_oen = t[3]&mov_rr_ah;
    assign breg_inen = t[3]&(mov_tmp_br|mov_cr_br|mov_dr_br);
    assign load_pc = t[5]&((zero_flag&jz)|(~sign_flag&jge)|jmp);
    assign acc_o_en = t[3]&(outs|mov_ah_cr|mov_ah_dr);
    assign acc_in_select = t[3]&(mov_tmp_ah|mov_cr_ah|mov_rr_ah|mov_key_ah|mov_dr_ah);
    assign acc_high_reset_p = t[3]&clr_s;
    assign acc_high_select_in[1] = (t[3]&(add_s|sub_s|and_s|div_s|mul_s|shl|mov_tmp_ah|mov_cr_ah|
        mov_rr_ah|mov_key_ah|mov_dr_ah))|(mul_s&(t[5]|t[7]|t[9]))|
        (div_s&(t[4]|t[5]|t[6]|t[7]|t[8]|t[9]|t[10]));
    assign acc_high_select_in[0] = (t[3]&(add_s|sub_s|and_s|mul_s|shr|mov_tmp_ah|mov_cr_ah|mov_rr_ah|
        mov_key_ah|mov_dr_ah))|(t[4]&(add_s|div_s|mul_s))|
        (mul_s&(t[5]|t[6]|t[7]|t[8]|t[9]|t[10]))| (div_s&(t[6]|t[8]|t[10]));
    assign acc_low_select[1] = (t[3]&(div_s|psah|shl))|(div_s&(t[5]|t[7]|t[9]|t[11]));
    assign acc_low_select[0] = (t[3]&(psah|shr))|(t[4]&(add_s|mul_s))|(mul_s&(t[6]|t[8]|t[10]));
    assign op_add = t[3]&add_s;
    assign op_sub = t[3]&sub_s;
    assign op_and = t[3]&and_s;
    assign op_div = div_s&(t[4]|t[6]|t[8]|t[10]);
    assign op_mul = mul_s&(t[3]|t[5]|t[7]|t[9]);
    assign rom_en = ~(t[1]|((load|jz|jmp|jge)&t[4]));
    assign mdr_inen = t[1]|((load|jz|jmp|jge)&t[4]);
    assign inreg_oen = t[3]&(mov_inr_tmp|mov_inr_rr);
    assign keych_oen = t[3]&mov_key_ah;
    assign outreg_inen = t[3]&outs;
    assign keyout_inen = t[3]&outb;

endmodule 