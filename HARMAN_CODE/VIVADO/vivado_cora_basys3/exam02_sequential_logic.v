`timescale 1ns / 1ps 

/////////////////////������ȸ�� ���� /////////////////////////////

//D_flip_floop 
module D_flip_floop_n( //Ŭ���� �ϰ��������� �Է�d�� ���q�� �ݿ��� 
    input d, 
    input clk,//clock
    input reset_p, //����Ƽ�� ������ �� ���� �� //��¿����� �� reset  
    output reg q);
    
    wire d_bar;
    not(d_bar,d);
    //������ �����ϴ� ȸ�� 
   //fpga���� Ŭ���޽� ����ϴ� �� 
   //�ϰ��������� ����Ǵ� �ø��÷� 
    always @(negedge clk or posedge reset_p) begin //Ŭ���� 1���� 0���� ������ ��(�ϰ�����) always�� ���� 
    //posedge ��¿����� �� �̰� �� �� �����϶� or��� ��ǥ�ص� �� 
    //reset _p�� 1�̸� clear ����Ƽ�� ������ �װ�Ƽ�꿧���� 1�� �� ���� 1 
    
    if(reset_p)  begin q = 0;  end //rest�̸� q�� 0 qbar�� 1
    
    else begin q = d; end //d��q�� �ݿ��� �� �� ���� �ϰ����� �ȵ����� ��� ���� 
    
    end
   
endmodule

 /////////////////////////////////////////////////////////////////////
//D �ø��÷��� �װ�Ƽ�� ���� (���� Ʈ���Ÿ�) 
module D_flip_floop_p( //����Ƽ�� �������� �Է�d�� ���q�� �ݿ��� 
    input d, 
    input clk,//clock
    input reset_p, //����Ƽ�� ������ �� ���� �� 
    output reg q);
    
    wire d_bar;
    not(d_bar,d);
  
    always @(negedge clk or posedge reset_p) begin 
    if(reset_p)  begin q = 0;  end //������ �켱 //����1�̸� �U�� ��� 0  

    else begin q = d; end 
    
    end
   
endmodule


 /////////////////////////////////////////////////////////////////////
module T_flip_flop_p(
    input clk, reset_p,
    input t,
    output reg q);
    
//    wire qbar;
//    reg d; 
//    assign qbar = ~q; 
    
//    always @(*) begin//�Է� ������ ���� �ϳ��� ���ϸ� �����ϴ� �ڵ� 
//        if(t) d = qbar;
//        else d = q; 
//     end
    
  always @( posedge clk or posedge reset_p) begin 
    if(reset_p)  begin q = 0;  end //rest�̸� q�� 0 qbar�� 1
     else begin  //(*)��ü �κ� 
        if(t) q = ~q;//t�� 1�� �� ��۵Ǽ� ��� 
        else q = q; //t�� 1�ƴ� �� �״�� ��� 
       end     ///������� 
    end
       

    
endmodule

 /////////////////////////////////////////////////////////////////////
//Ŭ���� ����Ƽ�꿡�� �����ϴ�  T�ø��÷� ���� resest�� positive���� �����ϵ���

module T_flip_flop_n(
    input clk, reset_p,
    input t,
    output reg q);
    
//    wire qbar;
//    reg d; 
//    assign qbar = ~q; 
    
//    always @(*) begin//�Է� ������ ���� �ϳ��� ���ϸ� �����ϴ� �ڵ� 
//        if(t) d = qbar;
//        else d = q; 
//     end
    
  always @( negedge clk or posedge reset_p) begin // clk�� �ϰ������̰ų� reset��  positive(1)�� ��  �����ϴ� ���� 
    if(reset_p)  begin q = 0;  end //reset�� �Ǹ�P��(positive�� �� ,1�϶�) ��� �ȴ�. �׶� ���(q)=0�̵� 
     else begin  //(*)��ü �κ�  //reset�� 1�� �ƴ� ��� -> q�� �״�� ��� 
        if(t) q = ~q; //�Է��� t�� 1�̸� q�� toggle �ȴ�. (0->1, 1->0���� �ٲ�)  
        else q = q;  //t�� 0�϶� q�� ���� 
       end     ///������� 
    end
      
    //�ϰ������̰ų� reset=1�� �� ����� ���� 
   //t�� 1�� �� q�� ��� �ǰ� t�� 0�� �� q�� �״�� ��µ� 
   //�ٵ� Ŭ���� �װ�Ƽ���̰ų� reset�� 1�� ���� ����Ǵ� ���� �̴ϱ� 
   //t�� 1�� �� �׻� ��۵Ǵ� �� �ƴ϶� �� �߿��� Ŭ���� �װ�Ƽ�� �̰ų� reset�� 1�� ������� �� 
   
endmodule

 /////////////////////////////////////////////////////////////////////
//�񵿱�� ���� ī���� ->�ٿ� �������� ����  
module up_counter_asyc(
    input clk,reset_p,
    output [3:0] count
);

    T_flip_flop_n T0 (.clk(clk), . reset_p(reset_p), .t(1), .q(count[0]) );
    T_flip_flop_n T1 (.clk(count[0]), . reset_p(reset_p), .t(1), .q(count[1]) );    //Ŭ���� Qa�� ������� �ش�. 
    T_flip_flop_n T2 (.clk(count[1]), . reset_p(reset_p), .t(1), .q(count[2]) );    
    T_flip_flop_n T3 (.clk(count[2]), . reset_p(reset_p), .t(1), .q(count[3]) );    
    
endmodule


 /////////////////////////////////////////////////////////////////////
//�񵿱�� �ٿ� ī���� -> ��� �������� ���� 
module down_counter_asyc(
    input clk,reset_p,//reset_p=1�̸� ��� = 0 
    output [3:0] count
);

    T_flip_flop_p T0 (.clk(clk), . reset_p(reset_p), .t(1), .q(count[0]) );//count[0]= Qa
    T_flip_flop_p T1 (.clk(count[0]), . reset_p(reset_p), .t(1), .q(count[1]) );  //Ŭ���� Qa�� ������� �ش�. Qb 
    T_flip_flop_p T2 (.clk(count[1]), . reset_p(reset_p), .t(1), .q(count[2]) );    //Qc
    T_flip_flop_p T3 (.clk(count[2]), . reset_p(reset_p), .t(1), .q(count[3]) );    //Qd
    
endmodule


 
 
 ///////////////////////////////////////////////////////////////////// 
 //���� clk �� -> reset���ο� ������� ->����ĵ� reset�� ���� �񵿱��� 
 //����� active-high positive upcounter 
 module up_counter_p(
    input clk, reset_p,
    output reg [3:0] count );
    //ff�ۿ� ������ �ٿ����� �� 
    //count 4�� -> clk�� ���� �� �־��� -> ����� (clk�� ����) 
    //reset�� �񵿱� 
    
  //�ø��÷Ӱ� ����ȸ�� �̾������� -> ������ ȸ�� 
    always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� 
        if(reset_p) count = 0; //���� 1�̸� ī��Ʈ�� 0���� Ŭ���� 
          else count = count+1;// �̰� ����ȸ�� 
    end
    
 endmodule
 
 
 ///////////////////////////////////////////////////////////////////// 
 //en=1�̸� �ٿ� ī���� ���� 
 //����� active-high positive down counter 
module down_counter_p(
    input clk, reset_p,
    output reg [3:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� �� �ȿ� ���� ����ȸ�� 
        if(reset_p) count = 0; //���� 1�̸� ī��Ʈ�� 0���� Ŭ���� 
          else count = count-1;
    end
    
 endmodule
  /////////////////////////////////////////////////////////////////////
 //en�ִ� �ٿ�ī���� 
 //en=1�̸� �ٿ�ī���� �� en=0�̸� ��¾��� 
 module down_counter_p_en(
    input clk, reset_p,enable,
    output reg [3:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� �� �ȿ� ���� ����ȸ�� 
        if(reset_p) count = 0; //���� 1�̸� ī��Ʈ�� 0���� Ŭ���� 
         else begin
         
         if(enable)  count = count-1;
         else count = count;
          end   
    end
    
 endmodule
 
  /////////////////////////////////////////////////////////////////////
  //����� active-high down count(en�� �ִ�) parameter 

  module down_counter_Nbit_p #(parameter N = 8)(
    input clk, reset_p,enable,
    output reg [N-1:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� �� �ȿ� ���� ����ȸ�� 
        if(reset_p) count = 0; //���� 1�̸� ī��Ʈ�� 0���� Ŭ���� 
          else begin
            if(enable)  count = count-1;
            else count = count;
          end   
    end
    
 endmodule
 

  /////////////////////////////////////////////////////////////////////
 //����� active-high BCD(10��) ��ī����
 module bcd_up_counter_p(
    input clk, reset_p,
    output reg [15:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� �� �ȿ� ���� ����ȸ�� 
        if(reset_p) count = 0; //���� 1�̸� ī��Ʈ�� 0���� Ŭ���� 
          else begin
            count = count+1;
            if ( count == 10 ) count = 0;
           end
         end
 endmodule
 
  /////////////////////////////////////////////////////////////////////
 //4��Ʈ ����� ����/���� ī���� 
 //���� clk �� -> reset���ο� ������� ->���� ff�� reset�� ���� �񵿱��� 

 module up_down_count( //x=1 ����ī����  , x=0���� ī���� 
    input clk, reset_p,//�����ؾ��ؼ� �ʿ� 
    input down_up,//1�϶� down, 0�� �� up ��� �ٲ㵵 �� 1�϶� �ش��ϴ� ���� ������ 
    output reg [3:0] count );
 
    always @(posedge clk, posedge reset_p)begin //always���� �ø��÷� 
        if(reset_p) count = 0;   //if~else�� mux 
        else begin
            if(down_up) count = count-1 ; //-��+�� ������  // if.else��->mux������� 
         else 
            count = count + 1; 
        
        end
 
    end
 endmodule
 
 
 
 /////////////////////////////////////////////////////////////////////
  //up_downī��Ʈ�� BCDī���ͷ� ����� 
 //up 10 �� �Ǹ� 0 �ǰ�, down�Ǹ� 0�϶� 9�� �ǵ��� 
 //012345678909876543210123456789
  module up_down_count_bcd( //x=1 ����ī����  , x=0���� ī���� 
    input clk, reset_p,//�����ؾ��ؼ� �ʿ� 
    input down_up,//1�϶� down, 0�� �� up ��� �ٲ㵵 �� 1�϶� �ش��ϴ� ���� ������ 
    output reg [3:0] count );
 
always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� 
    if(reset_p) count = 0;   //reset=1�� �� count = 0
    else begin 
           if(down_up == 0) begin //reset=0�̸鼭 down_up=0( up) 
                 if(count >= 9 ) count = 0;  //>�� �� ���� 
                 else count = count + 1; end//reset=1�� �ƴ� �� ��, ��� �� 0�ƴ� �� count�� +1 
       
     
            else begin
                 if(count <= 0) count = 9;
                 else count = count - 1; end
        
    
 end     
 end  
 endmodule
 
  /////////////////////////////////////////////////////////////////////
// made by ������ 
  module up_down_count_bcd_profassor( //x=1 ����ī����  , x=0���� ī���� 
    input clk, reset_p,//�����ؾ��ؼ� �ʿ� 
    input down_up,//1�϶� down, 0�� �� up ��� �ٲ㵵 �� 1�϶� �ش��ϴ� ���� ������ 
    output reg [3:0] count );
 
 always @(posedge clk, posedge reset_p) begin
    if(reset_p) count = 0; //if�� ����Ǹ� else�� ����ȵ� 
    else begin 
       if((down_up==1) && (count ==0)) count = 9; 
          else if((down_up==1) && (count !=0)) count = count - 1;    
          else if((down_up == 0)  &&  (count ==9)) count = 0; 
          else if((down_up == 0) && (count !=9)) count = count + 1; 
 
         end
   end
 endmodule
 

 
  /////////////////////////////////////////////////////////////////////
  ///���ļ� ���ֱ� �Ἥ �ֱ� �÷��� ((�ø��÷� �ϳ� ���ǰ�??)) 
  /////////��ī���� ////////////////// -->  if���� mux 
 module ring_counter(
     input clk, reset_p,
      output reg [3:0] q);
    

    always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� �� �ȿ� ���� ����ȸ��
        if(reset_p) q = 4'b0001; //���� ���� �� 0001 �����ڸ����� ���ڰ� ���� 
        else begin
            if(q == 4'b0001) q = 4'b1000;
            else if ( q ==4'b1000)  q=4'b0100;
            else if ( q ==4'b0100)  q=4'b0010;
            else if ( q ==4'b0100)  q=4'b0001;
            else q = 4'b0001;
         end
//       else begin
//            case(q) 
//                4'b0001 : q=4'b0001;
//                4'b0010 : q=4'b0100;
//                4'b0100 : q=4'b1000;
//                4'b1000 : q=4'b1000;          
                   //default : q= 4'b0001     
//             endcase
             
     end
   
endmodule 

 /////////////////////////////////////////////////////////////////////
////��ī���� fnd////////////
 module ring_counter_fnd(
     input clk, reset_p,
      output reg [3:0] com);
    
    reg [16:0] clk_div; //16�� ��Ʈ ���� �ֱ� �ø���. 1280s ->1.3ms�������� ��
    wire clk_div_16; 
    always @(posedge clk) clk_div = clk_div +1; 


    edge_detector_n ed (.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
 // 27�� �ϸ� �ֱⰡ �������� 31���ϸ� �ֱⰡ ������ clk_div�� �����ڸ����� ���� �ڸ��� �ٲ�� �ֱ� 
    //�� 29��° count�� 0->1�� ��¿��� �� �� ���� �ڸ����� ���� �ڸ��� �ٲ�  ���󿡼� 29�� �ҵ��� ������ �ٸ� �ڸ��� �ٲ�
      
    always @ (posedge clk or posedge reset_p) begin 
        if(reset_p) com = 4'b1110;  //���� ���� �� 0001 (com�� �ֳ�� Ÿ���ε� �� �տ� not�� �پ� �����Ƿ� 0�� ��� ���� ) 
        else if(clk_div_16)begin 
            case(com) // 
                4'b1110 : com= 4'b1101;
                4'b1101 : com=4'b1011;
                 4'b1011: com=4'b0111;
                4'b0111 : com=4'b1110;
                default: com = 4'b1110;
             endcase
        end            
   end
endmodule 


 
 
 /////////////////////////////////////////////////////////////////////
 //////��ī���� LED (0����Ʈ Ŀ���� ������ 1����Ʈ�� �Ѿ) 
 module ring_counter_led (
    input clk, reset_p, 
    output  reg [15:0] count);

    reg [21:0] clk_div;//wire���� ���� 
    always @(posedge clk) 
    clk_div = clk_div +1; //Ŭ�����ֱ� 2�� �ŵ��������� Ŭ���� ������ ����� �� �̿� -> clk:10ns [0]->20ns, [1]->40ns
    always @(posedge clk_div[21], posedge reset_p) begin //always���� �ø��÷� �� �ȿ� ���� ����ȸ�� 
      if(reset_p) count = 16'b0000_0000_0000_0001;
      
      else begin 
                case (count) 
                 16'b0000_0000_0000_0000 : count= 16'b0000_0000_0000_0001 ; //������ 0�� �����ص� �� 
                 16'b0000_0000_0000_0001 : count= 16'b0000_0000_0000_0010 ;        
                 16'b0000_0000_0000_0010 : count= 16'b0000_0000_0000_0100 ;       
                 16'b0000_0000_0000_0100 : count= 16'b0000_0000_0000_1000 ;      
                 16'b0000_0000_0000_1000 : count= 16'b0000_0000_0001_0000 ;      
                 16'b0000_0000_0001_0000 : count= 16'b0000_0000_0010_0000 ;      
                 16'b0000_0000_0010_0000 : count= 16'b0000_0000_0100_0000 ;               
                 16'b0000_0000_0100_0000 : count= 16'b0000_0000_1000_0000 ;               
                 16'b0000_0000_1000_0000 : count= 16'b0000_0001_0000_0000 ;               
                 16'b0000_0001_0000_0000 : count= 16'b0000_0010_0000_0000 ;               
                 16'b0000_0010_0000_0000 : count= 16'b0000_0100_0000_0000 ;               
                 16'b0000_0100_0000_0000 : count= 16'b0000_1000_0000_0000 ;              
                 16'b0000_1000_0000_0000 : count= 16'b0001_0000_0000_0000 ;              
                 16'b0001_0000_0000_0000 : count= 16'b0010_0000_0000_0000 ;              
                 16'b0010_0000_0000_0000 : count= 16'b0100_0000_0000_0000 ;              
                 16'b0100_0000_0000_0000 : count= 16'b1000_0000_0000_0000 ;              
                 16'b1000_0000_0000_0000 : count= 16'b0000_0000_0000_0000 ;         
                 endcase
     end   
end
endmodule     




/////////////////////////////////////////////////
//module ring_counter_led(
//    input clk, reset_p,
//    output reg [15:0] led
//    );
//    reg [26:0] clk_div;  // Ŭ�� ���ֱ�
//    always @(posedge clk) clk_div = clk_div + 1;
//    always @(posedge clk_div[26] or posedge reset_p) begin //clk_div�� ������ ���ϸ� clk�� ���� �߻��ϴ� ���� 
//        if(reset_p) led = 16'h0000;  // 16'b0000_0000_0000_0000
//        else begin
//            if (led == 16'h0000) led = 16'h0001;
//            else if (led == 16'h8000) led = 16'h0001;
//            else led = led * 2;
//        end
//    end
//endmodule
//////////////////////////////////////////////////////////
//module ring_counter_en(
//    input clk, reset_p, enable,
//    output reg[3:0]count
//    );
//    always @ (posedge clk, posedge reset_p)
//    if      (reset_p) count = 0;
//    else if (enable == 0) count = 0;
//    else if (count == 0) count = count +1;
//    else if (count == 4'b0001) count = 4'b0010;
//    else if (count == 4'b0010) count = 4'b0100;
//    else if (count == 4'b0100) count = 4'b1000;
//    else count = 4'b0001;
//endmodule
//module ring_counter_16bit_led_s(
//    input clk, reset_p,
//    output wire[15:0]led
//    );
//    wire [3:0]w;
//    reg [22:0]clk_div;
//    always @(posedge clk)
//    clk_div = clk_div + 1;
//    ring_counter_en rc0 ( .clk(clk_div[22]), .reset_p(reset_p), .enable(1), .count(w));
//    ring_counter_en rc1 ( .clk(clk_div[20]), .reset_p(reset_p), .enable(w[0]), .count(led[3:0]));
//    ring_counter_en rc2 ( .clk(clk_div[20]), .reset_p(reset_p), .enable(w[1]), .count(led[7:4]));
//    ring_counter_en rc3 ( .clk(clk_div[20]), .reset_p(reset_p), .enable(w[2]), .count(led[11:8]));
//    ring_counter_en rc4 ( .clk(clk_div[20]), .reset_p(reset_p), .enable(w[3]), .count(led[15:12]));
//////////////////////////////////////////////////////////////////////////
//�񵿱� ȸ�� Ŭ���� 
//���� �����͸� �����Ͽ� Ư�� �������� �߻��ϴ� ��ī����  LEd

/////////////////////////////////////////////////////////
module ring_counter_led_hw(
    input clk, reset_p,
    output reg [15:0] count);
    reg [20:0] clk_div;
    wire posedge_clk_div_20;
   always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
            count = 15'b1;
            clk_div = 0;
        end
        else begin
            clk_div = clk_div + 1;
            if(posedge_clk_div_20) count = {count[14:0], count[15]};
        end
    end
    edge_detector_n ed(.clk(clk), .reset_p(reset_p),
            .cp(clk_div[20]), .p_edge(posedge_clk_div_20));
endmodule

 //�ֱ� clk_div[20]�̾ �̳� ���� ���ư� 1�� �Ⱓ���� --> �ʹ� ���� ���ư��� �޽����̰���� �ʿ���       
        //Ŭ�� ��û ���� ���� ��¿��������� �� ���� �з����ϴµ� ��� �и��ݾ� 
//   else begin
//        else count = {count[14:0],1'b0};//����ִ� ���� 0�ֱ� 



//////////////////////////////////////////////////////////////////////////
//Ŭ���� �װ�Ƽ�꿡�� �����ϴ� ���� ������ 
//Ŭ���� ���ֱ� ��ŭ�� �޽��� ������ �� = 1 cycle pulse�� ����� �� = ���� ������ (d ff*2 + and gate) 
module edge_detector_n(
    input clk, reset_p,
    input cp,
    output p_edge, n_edge);
    
    
    reg ff_cur, ff_old; 
    
    always @(negedge clk, posedge reset_p) begin 
        if(reset_p) begin
           ff_cur = 0;
           ff_old = 0;
         end
         else begin //cp�� 1�� �� (reset_p�� 1�� �ƴ� ��) 
         //�̷��� �ϸ� �ø��÷� 2�� �ʿ� 
            ff_cur <= cp; //ff_cur�� cp�� ������ cp�� ���� ��   //=�̸� ��ŷ �� �տ� ����Ǵ� ���� �ڿ� ������ ���� // <=�̸� �ͺ�ŷ�� ȸ�ΰ� ���ķ� �����ϴ� ���� 
            ff_old <= ff_cur; //ff_cur�� ���� ff_old���� ���� 
            end
      end
   
      assign p_edge = ({ff_cur,ff_old}==2'b10) ? 1 : 0 ;//ff_cur & ~ ff_old ->�̰� LUT �������  ->lut�� mux�� ���� //cur�� �׳� �ް� old�� not�ٿ��� �ް� 
      assign n_edge = ({ff_cur,ff_old}==2'b01) ? 1 : 0 ; //and gate��������� �����ϱ� mux�� �����. -> trsut type�� ������ ���� -> lut�� 
    
endmodule 


//////////////////////////////////////////////////////////
module edge_detector_p(
    input clk, reset_p,
    input cp,
    output p_edge, n_edge);
    
    
    reg ff_cur, ff_old; 
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin
           ff_cur = 0;
           ff_old = 0;
         end
         else begin //cp�� 1�� �� (reset_p�� 1�� �ƴ� ��) 
            ff_cur <= cp; //ff_cur�� cp�� ������ cp�� ���� ��   //=�̸� ��ŷ �� �տ� ����Ǵ� ���� �ڿ� ������ ���� // <=�̸� �ͺ�ŷ�� ȸ�ΰ� ���ķ� �����ϴ� ���� 
            ff_old <= ff_cur; //ff_cur�� ���� ff_old���� ���� 
            end
      end
   
      assign p_edge = ({ff_cur,ff_old}==2'b10) ? 1 : 0 ;//ff_cur & ~ ff_old ->�̰� ������ �𵨸��̶� mux�ȸ������ //cur�� �׳� �ް� old�� not�ٿ��� �ް� 
      assign n_edge = ({ff_cur,ff_old}==2'b01) ? 1 : 0 ;
    
endmodule 

////////////////////////////////////////////////////////////////////////////////
//��ư ��Ʈ�ѷ������ ������� �ʰ� ���� �����ͷ� ���� ��� 
//��ư�� clk�� ������ ������ , edge detector ����ϸ�  clk�� ����� �� ���� 
//basys3 ��ü�� �� ��ư �Է��� �޾� fnd�� ��� �ϴ� ī���� // ���� �����͸� ����Ͽ� clk�� ����� ���� ä�͸����� �ϱ� ���� ���ļ� ���ֱ� ��� 
//module button_test_top(
// input clk, reset_p, 
// input btn,
// output [7:0] seg_7,
// output [3:0] com); //���� on ->an ->���� ���� 

//    reg [15:0] btn_counter ; //4bit¥�� ��ư ī����  
//    reg [3:0] value; 
//    wire btnU_pedge;
//    reg [16:0] clk_div =0 ; //���ֱ� ����� 
//    wire clk_div_16; 
//    reg debounced_btn;
    
//    //[16:0] clk_div�� ��°� clk_div_16; 

//    always @(posedge clk) clk_div = clk_div +1; //clk�� ���� �����ϴ� ���ֱ� 
  
  
//    always @(posedge clk, posedge reset_p) begin //ä�͸� �����ϱ� ���� ���ֱ�� 1ms�� �ֱ⸦ �ٲ� 
//        if(reset_p) debounced_btn = 0; 
//        else if (clk_div_16) debounced_btn = btn;
//    end
    
// edge_detector_n ed1(.clk( clk) , 
//                     .reset_p(reset_p),//��ư �Է��� clk�� ����� �ޱ� ���� edge detector�� ���� 
//                     .cp(clk_div[16]), 
//                     .p_edge(clk_div_16));            //up 
        
    
//edge_detector_n ed2(.clk( clk) , 
//                    .reset_p(reset_p),
//                    .cp(debounced_btn),
//                    .p_edge(btnU_pedge)); //down 
         
//     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
//        if(reset_p) btn_counter = 0; 
//         else begin
//            if (btnU_pedge) btn_counter = btn_counter +1;
//         end  
//      end
        
////        else begin
////            if(btnU_pedge)
////            btn_counter = btn_counter +1; //��ư ���� ������ 1�� ���� //account���� 
////            else if(btnD_nedge)
////            btn_counter = btn_counter - 1; 
////        end
    
//     ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
   
//    always @(posedge clk) begin  
//        case(com)
//        4'b0111 : value = btn_counter[15:12];   
//        4'b1011 : value = btn_counter[11:8];    
//        4'b1101 : value = btn_counter[7:4]; 
//        4'b1110 : value = btn_counter[3:0];   
//        endcase
//    end
    

    
//     wire [7:0] seg_7_bar;
//    decoder_7seg fnd(.hex_value(value), .seg_7(seg_7_bar));
//    assign seg_7 = ~seg_7_bar; 
    
    
//    //fnd��� 
//endmodule
///////////////////////////////////////////////////////////////////////
//button_��Ʈ�ѷ��� �ν��Ͻ��ؼ� ���� +ȸ�� 
//��ư�Է¹޾� count1�� ����, ����, �½���Ʈ, �����Ʈ 
module button_cntr_seg_7_display(
 input clk, reset_p, 
 input [3:0] btn,
 output [7:0] seg_7,
 output [3:0] com); //���� on ->an ->���� ���� 

    reg [15:0] btn_counter ; //4bit¥�� ��ư ī����  
    reg [3:0] value; 
    wire [3:0] btnU_pedge;


     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�

  fnd_4digit_cntr(.clk(clk),  //��� �� �ʿ��� fnd ��Ʈ�ѷ� ��� �ҷ��� 
                  .reset_p(reset_p), 
                  .value(btn_counter), 
                  .seg_7_ca(seg_7), //ca(ĳ�ҵ�Ÿ��)-1�� ������
                  .com(com));        
                  
                   
       //�� always�� �� ����  count�� ���ָ� �ȴ�. �������� �� �ν��Ͻ��� �η���             
     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter +1;
            else if (btnU_pedge[1]) btn_counter = btn_counter -1;
            else if (btnU_pedge[2])  btn_counter = {btn_counter[14:0], btn_counter[15]}; //�½���Ʈ
            else if (btnU_pedge[3])  btn_counter = {btn_counter[0] ,btn_counter[15:1]}; //�����Ʈ 
         end  
      end
    
    //fnd��� 
endmodule
////////////////////////////////////////////////////////////////////////////////
module button_cntr_seg_7_display_practice(
 input clk, reset_p, 
 input [3:0] btn,
 output [7:0] seg_7,
 output [3:0] com); //���� on ->an ->���� ���� 

    reg [7:0] btn_counter ; //4bit¥�� ��ư ī���� 
    wire [3:0] btnU_pedge;


     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3])); //��ư �Է� �� �ʿ��� ���� ������ ��Ʈ�ѷ�

  fnd_4digit_cntr(.clk(clk),  //��� �� �ʿ��� fnd ��Ʈ�ѷ� ��� �ҷ��� 
                  .reset_p(reset_p), 
                  .value(btn_counter), 
                  .seg_7_ca(seg_7), //ca(ĳ�ҵ�Ÿ��)-1�� ������
                  .com(com));        
                  
                   
       //�� always�� �� ����  count�� ���ָ� �ȴ�. �������� �� �ν��Ͻ��� �η���             
     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter +1;
            else if (btnU_pedge[1]) btn_counter = btn_counter -1;
            else if (btnU_pedge[2])  btn_counter = {btn_counter[6:0], btn_counter[7]}; //�½���Ʈ
            else if (btnU_pedge[3])  btn_counter = {btn_counter[0] ,btn_counter[7:1]}; //�����Ʈ 
         end  
      end
    
    //fnd��� 
endmodule



////////////////////////////////////////////////////////////////////////////////
//��ư�Է����� led_bar �Է¹ޱ� 
//���ϴ� �ڸ��� ��ư���� led_bar ��¹ޱ� 
module led_bar_btn (
    input clk, reset_p,
    input [3:0] btn,
    output reg [7:0]led_bar);
    
    always @(posedge clk, posedge reset_p )begin
    if(reset_p) led_bar=0;
    else begin 
        case(btn) 
        4'b0000  : led_bar=8'b0000_0000;
        4'b0001  : led_bar=8'b0000_0011; 
        4'b0010  : led_bar=8'b0000_1100; 
        4'b0011  : led_bar=8'b0000_1111; 
        4'b0100  : led_bar=8'b0011_0000; 
        4'b0101  : led_bar=8'b0011_0011; 
        4'b0100  : led_bar=8'b0011_0000; 
        4'b0101  : led_bar=8'b0011_0011; 
        4'b0110  : led_bar=8'b0011_1100; 
        4'b0111  : led_bar=8'b0011_1111; 
        4'b1000  : led_bar=8'b1100_0000;       
        4'b1001  : led_bar=8'b1100_0011; 
        4'b1010  : led_bar=8'b1100_1100; 
        4'b1011  : led_bar=8'b1100_1111; 
        4'b1100  : led_bar=8'b1111_0000;        
        4'b1101  : led_bar=8'b1111_0011; 
        4'b1110  : led_bar=8'b1111_1100; 
        4'b1111  : led_bar=8'b1111_1111; 
        endcase
    end
   end

endmodule


//xdc���� btnu�� �ִ� �Ծƴ϶� JB1�� �ָ� �� 





///////////////////////////////////////////////////////////
//��ư �ϳ��� �Է� �ް� �� �������� �����̴� ��ī���� ����ϱ� //����ȭ ��Ű�� �� �� 
///////////////////////////////////////////////////////////
module button_ledbar_ring (
 input clk, reset_p, 
 input btn,
 output [7:0] led_bar); //���� on ->an ->���� ���� 

    reg [7:0] btn_counter ; //
    wire btnU_pedge;
    reg [16:0] clk_div =0 ; //���ֱ� ����� 
    wire clk_div_16; 
    reg debounced_btn;
    
      always @(posedge clk) clk_div = clk_div +1; //clk�� ���� �����ϴ� ���ֱ� 
  
  
    always @(posedge clk, posedge reset_p) begin //ä�͸� �����ϱ� ���� ���ֱ�� 1ms�� �ֱ⸦ �ٲ� 
        if(reset_p) debounced_btn = 0; 
        else if (clk_div_16) debounced_btn = btn;
    end
    
 edge_detector_n ed1(.clk( clk) , 
                     .reset_p(reset_p),//��ư �Է��� clk�� ����� �ޱ� ���� edge detector�� ���� 
                     .cp(clk_div[16]), 
                     .p_edge(clk_div_16));            //up 
        
    
edge_detector_n ed2(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn),
                    .n_edge(btnU_pedge)); //down 
         
     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
        if(reset_p) btn_counter = 8'b0000_0001; 
         else begin
            if (btnU_pedge) btn_counter = {btn_counter[6:0],btn_counter[7]};
         end  
      end
        
        
        
    assign led_bar = ~ btn_counter;
    
endmodule
///////////////////////////////////////////////////////////
//##Pmod Header JB
//set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33 } [get_ports {btn[0]}];#Sch name = JB1
//set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33 } [get_ports {btn[1]}];#Sch name = JB2
///////////////////////////////////////////////////////////
//��ư �ϳ��δ�  bit�� 1,2,3 ... +�ް� ��ư�ϳ��δ�  -�ޱ� 
module button_ledbar_updown (
 input clk, reset_p, 
 
 input [1:0] btn,
 output [7:0] led_bar); //���� on ->an ->���� ���� 

    reg [7:0] btn_counter ; //8bit¥�� ��ư ī����  
    wire [1:0] btnU_pedge;
    reg [16:0] clk_div =0 ; //���ֱ� ����� 
    wire clk_div_16; 
    reg [1:0]debounced_btn ;

    
      always @(posedge clk) clk_div = clk_div +1; //clk�� ���� �����ϴ� ���ֱ� 
  
  
    always @(posedge clk, posedge reset_p) begin //ä�͸� �����ϱ� ���� ���ֱ�� 1ms�� �ֱ⸦ �ٲ� 
        if(reset_p) debounced_btn = 0; 
        else if (clk_div_16) begin
            debounced_btn= btn;
        end
    end
 
 //Ŭ�� �ֱ� �ø���    
 edge_detector_n ed1(.clk( clk) , 
                     .reset_p(reset_p),
                     .cp(clk_div[16]), 
                     .p_edge(clk_div_16));           
        
   
edge_detector_n ed2(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[0]),
                    .p_edge(btnU_pedge[0])); //up�� ���� 
                    
edge_detector_n ed3(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[1]),
                    .p_edge(btnU_pedge[1])); //down�� ����                    
                                
         
     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter +1; //up
            else if (btnU_pedge[1]) btn_counter = btn_counter -1; //down  
         end  
      end
        
    assign led_bar = ~ btn_counter;
    
endmodule
////////////////////////////////////////////////////
//��ư �ΰ��� �Է¹޴� ��ī���� �� �Ʒ��� �����̱� 
module button_ledbar_updown_ringcounter (
 input clk, reset_p, 
 input [1:0 ]btn,
 output [7:0] led_bar); //���� on ->an ->���� ���� 

    reg [7:0] btn_counter ; //8bit¥�� ��ư ī����
    wire [1:0] btnU_pedge;
    reg [16:0] clk_div =0 ; //���ֱ� ����� 
    wire clk_div_16;
    reg [1:0] debounced_btn ;

    always @(posedge clk) clk_div = clk_div +1; //clk�� ���� �����ϴ� ���ֱ� 

    always @(posedge clk, posedge reset_p) begin  //16�� ������ �Է����� �޾� ��ٿ�� ���� 
        if(reset_p) debounced_btn= 0; 
        else if (clk_div_16) begin 
            debounced_btn= btn; 
        end      
    end

      edge_detector_n edg_clk_1(
         .clk( clk) , 
         .reset_p(reset_p),//ä�͸� �����ϱ� ���� ���ֱ�� 1ms�� �ֱ⸦ �ٲ� ������ ���� 
         .cp(clk_div[16]), 
         .p_edge(clk_div_16));   

      edge_detector_n edg_clk_2(
         .clk( clk) , 
         .reset_p(reset_p),//���� �� ���� ��ư�� ���� �� ���� �ޱ� ���� edge detector�� ���� 
         .cp(debounced_btn[0]), 
         .p_edge(btnU_pedge[0])); 

      edge_detector_n edg_clk_3(
         .clk( clk) , 
         .reset_p(reset_p),
         .cp(debounced_btn[1]),
         . p_edge(btnU_pedge[1])); //down 


     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
        if(reset_p) btn_counter = 8'b0000_0001;
         else begin
            if (btnU_pedge[0]) btn_counter = {btn_counter[6:0],btn_counter[7]};
            else if (btnU_pedge[1]) btn_counter =  {btn_counter[0], btn_counter[7:1]};
         end
      end

    assign led_bar = ~ btn_counter;

    endmodule


//////////////////////////////////////////////////////////////////
//��ư 4���������  fnd�� ��� 
module button_4_fnd ( 
   input clk, reset_p,
    input [3:0] btn,
    output [7:0] seg_7
);
    reg [7:0] btn_counter;
    wire [3:0]btnU_pedge;
    reg [16:0] clk_div;
    always @(posedge clk) clk_div = clk_div + 1;
    wire clk_div_16;
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p),
        .cp(clk_div[16]), .p_edge(clk_div_16)
        );
    reg [3:0]debounced_btn;
    always @(posedge clk, posedge reset_p)begin
        if(reset_p) debounced_btn = 0;
        else if(clk_div_16) debounced_btn = btn;
    end
    edge_detector_n ed2(.clk(clk), .reset_p(reset_p),
        .cp(debounced_btn[0]), .p_edge(btnU_pedge[0])
        );
    edge_detector_n ed3(.clk(clk), .reset_p(reset_p),
        .cp(debounced_btn[1]), .p_edge(btnU_pedge[1])
        );
     edge_detector_n ed4(.clk(clk), .reset_p(reset_p),
        .cp(debounced_btn[2]), .p_edge(btnU_pedge[2])
        );
     edge_detector_n ed5(.clk(clk), .reset_p(reset_p),
        .cp(debounced_btn[3]), .p_edge(btnU_pedge[3])
        );
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)btn_counter = 0;
        else begin
            if(btnU_pedge[0]) btn_counter = btn_counter + 1;
            else if(btnU_pedge[1]) btn_counter = btn_counter - 1;
             else if(btnU_pedge[2]) btn_counter = {btn_counter[6:0], btn_counter[7]};
            else if(btnU_pedge[3]) btn_counter = {btn_counter[0], btn_counter[7:1]};
        end
    end
      
     wire [7:0] seg_7_bar;
    
    decoder_7seg (.hex_value(btn_counter[3:0]), .seg_7(seg_7_bar)); //���ڴ��� ���� ���� 0�� �� ������ �� ���� 
    //7_seg�� 0���� ���� �츮�� ����fnd�� 1���� ���� -> �������Ѽ� �޾ƾ��� 
    assign seg_7 = ~seg_7_bar;
    endmodule
 //////////////////////////////////////////
 //��ư 1�� ������� 4�ڸ�fnd��� 
module button_4bit_fnd(
 input clk, reset_p, 
 input btn,
 output [7:0] seg_7,
 output [3:0] com); //���� on ->an ->���� ���� 

    reg [15:0] btn_counter ; //4bit¥�� ��ư ī����  
    reg [3:0] value; 
    wire btnU_pedge;
    reg [16:0] clk_div ; //���ֱ� ����� 
    wire clk_div_16; 
    reg debounced_btn;
    
    //[16:0] clk_div�� ��°� clk_div_16; 

    always @(posedge clk) clk_div = clk_div +1; //clk�� ���� �����ϴ� ���ֱ� 
  
  
    always @(posedge clk, posedge reset_p) begin //ä�͸� �����ϱ� ���� ���ֱ�� 1ms�� �ֱ⸦ �ٲ� 
        if(reset_p) debounced_btn = 0; 
        else if (clk_div_16) debounced_btn = btn;
    end
    
 edge_detector_n ed1(.clk( clk) , 
                     .reset_p(reset_p),//��ư �Է��� clk�� ����� �ޱ� ���� edge detector�� ���� 
                     .cp(clk_div[16]), 
                     .p_edge(clk_div_16));            //up 
        
    
edge_detector_n ed2(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn),
                    .n_edge(btnU_pedge)); //down 
         
     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge) btn_counter = btn_counter +1;
         end  
      end
        
//        else begin
//            if(btnU_pedge)
//            btn_counter = btn_counter +1; //��ư ���� ������ 1�� ���� //account���� 
//            else if(btnD_nedge)
//            btn_counter = btn_counter - 1; 
//        end
    
     ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
   
    always @(posedge clk) begin  
        case(com)
        4'b0111 : value = btn_counter[15:12];   
        4'b1011 : value = btn_counter[11:8];    
        4'b1101 : value = btn_counter[7:4]; 
        4'b1110 : value = btn_counter[3:0];   
        endcase
    end
        wire [7:0] seg_7_bar;
    decoder_7seg fnd(.hex_value(value), .seg_7(seg_7_bar));
    assign seg_7 = ~seg_7_bar; 
    //fnd��� 
endmodule


///////////////////////////////////////////////////
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///////////////////////////////////////////////////


//////////////////////////////////////////////////////
 //4�ڸ�fnd��� ���ڸ� �ٸ��� ��¹ޱ�
module button_4bit_each_fnd(
 input clk, reset_p, 
 input [3:0] btnU,
 output [7:0] seg_7,
 output [3:0] com); //���� on ->an ->���� ���� 

    reg [15:0] btn_counter ; //4bit¥�� ��ư ī����  

    
    reg [3:0] value; 
    wire [3:0] btnU_pedge;
    reg [16:0] clk_div =0 ; //���ֱ� ����� 
    wire clk_div_16; 
    reg  [3:0] debounced_btn;
    
    //[16:0] clk_div�� ��°� clk_div_16; 

    always @(posedge clk) clk_div = clk_div +1; //clk�� ���� �����ϴ� ���ֱ� 
  
  
    always @(posedge clk, posedge reset_p) begin //ä�͸� �����ϱ� ���� ���ֱ�� 1ms�� �ֱ⸦ �ٲ� 
        if(reset_p) debounced_btn = 0; 
        else if (clk_div_16) debounced_btn = btnU;
    end
    
 edge_detector_n ed1(.clk( clk) , 
                     .reset_p(reset_p),//��ư �Է��� clk�� ����� �ޱ� ���� edge detector�� ���� 
                     .cp(clk_div[16]), 
                     .p_edge(clk_div_16));            //up 
        
    
edge_detector_n ed2(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[0]),
                    .p_edge(btnU_pedge[0])); //down 
                    
 edge_detector_n ed3(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[1]),
                    .p_edge(btnU_pedge[1])); //down                    
                    
 edge_detector_n ed4(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[2]),
                    .p_edge(btnU_pedge[2])); //down                    
                    
edge_detector_n ed5(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[3]),
                    .p_edge(btnU_pedge[3])); //down                     
         
     always @(posedge clk, posedge reset_p)begin //��ư�Է��� positive edge���� btn_count�� �ϳ��� ����
        if(reset_p) begin
        
        btn_counter = 0; 
 
        end

         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter+16'h0001; //�갡 �ڸ����� ������ 
            if (btnU_pedge[1]) btn_counter = btn_counter +16'h0010;
            if (btnU_pedge[2]) btn_counter = btn_counter +16'h0100;
            if (btnU_pedge[3]) btn_counter = btn_counter +16'h1000;
          
         end  
      end
        
     ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
   
    always @(posedge clk) begin  //��� ���,��µǴ� �ֱ� �� ���� 
        case(com)
        4'b0111 : value = btn_counter[15:12];   
        4'b1011 : value = btn_counter[11:8];    
        4'b1101 : value = btn_counter[7:4]; 
        4'b1110 : value = btn_counter[3:0];   
        endcase

        end
        wire [7:0] seg_7_bar;
    decoder_7seg fnd(.hex_value(value), .seg_7(seg_7_bar));
    assign seg_7 = ~seg_7_bar; 
    //fnd��� 
endmodule
///////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////
//�������� -�����Է� ������� 
module shiht_register_SISO_n(
    input clk, reset_p,
    input d, 
    output q);

    reg [3:0] siso_reg; 

    always @(negedge clk or posedge reset_p )begin 
        if(reset_p) siso_reg = 0; 
        else begin 
            siso_reg[3] <= d; //non-blocking�� ����� ����� �� ���� �Է°� ����Ǿ��־
            siso_reg[2] <= siso_reg[3];
            siso_reg[1] <= siso_reg[2];
            siso_reg[0] <= siso_reg[1]; 
            //���⿡�� ���ŷ �ָ� �������� �ϳ� �� ������� 
            //��������  5��Ʈ¥�� ������� �׳� ��µǴ°Ŵϱ� 
        end
    end 

    assign q = siso_reg[0]; 
endmodule



//��������-�����Է� �������
module shift_register_SIPO_n(
    input clk, reset_p,
    input d, 
    input rd_en, //1�� �� Ŭ���� ���� 
    output [3:0] q); //serial input pararial out 

    reg [3:0] sipo_reg;
    
    always @(negedge clk or posedge reset_p)
        if(reset_p) begin
            sipo_reg = 0; 
        end
        else begin
            sipo_reg = {d, sipo_reg[3:1]};
        end

    assign q= rd_en ? sipo_reg : 4'bz; //z�� �Ѻ�Ʈ�� �ᵵ 4��Ʈ ��� ���zzzz 000z�̷��� �̷��� ����� 
//     bufif1 (q[0], sipo_reg[0], re_en); //3����� : ���, �Է�, �����Է� �����Ʈ�� 1�̵Ǹ� ���q�� ������ 0�̸� z�� ����
//     bufif1 (q[1], sipo_reg[1], re_en);
//     bufif1 (q[2], sipo_reg[2], re_en);
//     bufif1 (q[3], sipo_reg[3], re_en); 
endmodule
///////////////////////////////////////////////////
//���� �Է� ���� ��� �������� 
module shift_register_PISO(
    input clk, reset_p,
    input [3:0] d, 
    input shift_load, //����Ʈ�Ұ��� load�� ���� ���ϴ� select bit
    //0�̸� load 1�̸� shift �� 
    output q); //���� ����̴� 1bit�� �ʿ� 

reg [3:0] piso_reg;

always @(posedge clk or posedge reset_p)begin
    if(reset_p) piso_reg =0; //���½� piso_�������Ͱ� 0�� �� 
    else begin
        if(shift_load) piso_reg = {1'b0, piso_reg[3:1]}; //�����Ʈ, ������ 0����Ʈ�� �������� �� 
        else piso_reg = d; //load��Ŵ - ff�� �Է��� ���� ff�� ������� ���� 
    end

end

    assign q= piso_reg[0];

endmodule
///////////////////////////////////////////////////
//���� �Է� ���� ��� �������� //���� �Ϲ����� �������Ͷ� �̸��� �������Ͷ�� ���� 
//Ŭ���� ��� ������ ������ d�� ������ ���� �� wr_en ���� ���� ���ϴ� �Է��� �������ͷ� ���� 
//�Է� �ٸ� ������ �ٲٰ� ������ en�����ٰ� �ٽ� �ָ� �� 
//����ϰ� ���� �� rd_en�� 1�� �ְ� ���� ����� ���� ������� ���� 
module register_Nbit_p #(parameter N = 8) (
    input clk, reset_p,
    input [N-1:0] d, 
    input wr_en, rd_en, // �а�,���� ���� ���� �������� ����� �� �ֵ��� ���� ������ 
    output [N-1:0] q); 

    reg [7:0] register; //4bit �������� ���� 
    
    always @(posedge clk or posedge reset_p) begin
    if(reset_p) register = 0; 
    else if(wr_en) register = d; //d���ƹ��� �ٲ� write �ο��̺��� 1�� ���� �Է��� �������ͷ� �餷��;� �� 
    end
    
    assign q = rd_en ? register : 'bz ; //re_en=1�� ���� �������� ���� ���q�� ������ , �װ� �ƴ� ��� z�� ���(����� ����)   z�ϳ��� ���� zzzz�ϱ� �� ��Ʈ���� �� �ʿ� ���� 
endmodule


//8bit¥�� �޸� 1024���� sram
module sram_8bit_1024( //�޸� - ���¾��� ������ư ���� �� 
    input clk,
    input wr_en,rd_en,
    input [9:0] addr, //1024�� ������ bit 10�� �ʿ� 
    inout [7:0] data);  //inout = input�� ����, output�� ���� �Է¼�,��¼� ���� ��� ������� ���� �� �ݵ�� z�� �Է� 

    reg [7:0] mem [0:1023]; //�տ� �� ��Ʈ ���� �ڿ��� �� �� ����� (�迭 ����) // 8��Ʈ¥�� �޸� 1024�� ����ڴ�. 
    
    always @(posedge clk)begin 
     if(wr_en) mem [addr] <= data;
    end
    assign data = rd_en ? mem[addr] : 'bz;
endmodule