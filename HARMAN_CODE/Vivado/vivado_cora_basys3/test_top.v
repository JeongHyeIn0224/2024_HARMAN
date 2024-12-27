`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////
//����� = ���� Ŭ�� ��� 
//��ī���� �׽�Ʈ ž + ��ī���� fnd 

module up_counter_test_top( 
    input clk, reset_p,
    output [7:0] seg_7,
    output  [15:0] count,
    output [3:0] com );
    
    reg [31:0] count_32;  //always������ ���� �� reg �ٿ��� �� //16~31 �����ϱ� �� ������ ����� ������ 0���� �����������
     always @(posedge clk, posedge reset_p) begin //always���� �ø��÷� �� �ȿ� ���� ����ȸ�� 
        if(reset_p) count_32 = 0; //���� 1�̸� ī��Ʈ�� 0���� Ŭ���� 
        else count_32 = count_32 + 1;
    end
    
    assign count = count_32[31:16]; //assign������ ���� ī��Ʈ�� reg �������� ī��Ʈ�� 16��Ʈ ����̰� ���̾��� 
    
    ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
    reg [3:0] value; 
    //sensitive list �� edge�ƴ� ���� ��� �����Ƿ� case���� mux�� �� 
    always @(com) begin  //sensitive list�� psedge clk ������ ������ ȸ�� ������ posedge�� ������ 
//    com�� �尡�� ���ճ�ȸ�� �� ��� ���̽� �� �־���ؼ�  com�� �� ���� default ���ֱ� �Ƚ��ָ� ����Ʈ���Ÿ����� latch������� (pdt��������� �װ�Ƽ�� �����߻�) 
        case(com)
        4'b0111 : value = count_32[31:28]; //������ 4��� 2�� 4�±��� ���( value���� hex_value�� ����Ǿ� �����ϱ� 0~f���� ��°��� ) 
        //������ 2��� 2�� 2�±��� ��� ( 0~3���� ���) �׸��� �ֱ⸦ �ø��� ���� ���ڸ� �ø� �� 
        //0���ڸ����� ������ ���� õ���ڸ� 28��~31�� �ڸ��� �������� (���� �ڸ� �������� ����) 
        4'b1011 : value = count_32[27:24];    //����: �ڸ��� ex. 3�̸� 2^3 , ����: �ֱ� ���� Ŀ������ �ֱ� ����->������ ���� 
        4'b1101 : value = count_32[23:20]; //0���ڸ����� ���� �����ڸ� 
        4'b1110 : value = count_32[19:16];   //���� ���� �ϰڴ�. 
        default : value = count_32 [19:16]; 
       endcase
       //case�� ���ճ�ȸ�� (combinational) mux�� ������� 
       
//           always @(posedge clk) begin  

//        case(com)
//        4'b0111 : value = count_32[31:28]; //������ 4��� 2�� 4�±��� ���( value���� hex_value�� ����Ǿ� �����ϱ� 0~f���� ��°��� ) 
//        //������ 2��� 2�� 2�±��� ��� ( 0~3���� ���) �׸��� �ֱ⸦ �ø��� ���� ���ڸ� �ø� �� 
//        //0���ڸ����� ������ ���� õ���ڸ� 28��~31�� �ڸ��� �������� (���� �ڸ� �������� ����) 
//        4'b1011 : value = count_32[27:24];    
//        4'b1101 : value = count_32[23:20]; //0���ڸ����� ���� �����ڸ� 
//        4'b1110 : value = count_32[19:16];   //���� ���� �ϰڴ�. 
//       endcase
       
    end
    decoder_7seg fnd(.hex_value(value), .seg_7(seg_7));
 endmodule
 


//�����̴� LED�����
module led_bar_top (
    input clk, reset_p,
    output [7:0]led_bar);
    
    reg [28:0] clk_div; 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) clk_div = 0;
        else clk_div = clk_div +1;
    end

        assign led_bar= ~clk_div[28:21]; //����� 0�� �� �����µ� 1�� �� �����Բ� �ٲٱ� 

endmodule


////////////////////////////////////////////////////////////////////////////////
//��ư ��Ʈ�ѷ������ ������� �ʰ� ���� �����ͷ� ���� ��� 
//��ư�� clk�� ������ ������ , edge detector ����ϸ�  clk�� ����� �� ���� 
//basys3 ��ü�� �� ��ư �Է��� �޾� fnd�� ��� �ϴ� ī���� // ���� �����͸� ����Ͽ� clk�� ����� ���� ä�͸����� �ϱ� ���� ���ļ� ���ֱ� ��� 
module button_test_top(
 input clk, reset_p, 
 input btn,
 output [7:0] seg_7,
 output [3:0] com); //���� on ->an ->���� ���� 

    reg [15:0] btn_counter ; //4bit¥�� ��ư ī����  
    reg [3:0] value; 
    wire btnU_pedge;
    reg [16:0] clk_div =0 ; //���ֱ� ����� 
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
                    .p_edge(btnU_pedge)); //down 
         
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
    decoder_7seg fnd(.hex_value(value), .seg_7(seg_7));
//    assign seg_7 = ~seg_7_bar; 
    
    
    //fnd��� 
endmodule

module button_cntr_for_top(
 input clk, reset_p, 
 input [3:0] btn,
 output [7:0] seg_7,
 output [3:0] com); //���� on ->an ->���� ���� 

    reg [15:0] btn_counter ; //4bit¥�� ��ư ī���� 
    wire [3:0] btnU_pedge;
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0])); 
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1])); 
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2])); 
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3])); 

    genvar i; //ȸ�δ� ��������� ���� �� �ȿ��� �ݺ��ϱ� ���� ���� 
    generate 
        for(i=0; i<4; i=i+1) begin :btn_cntr //genblk �̸� �����ϱ� 
            button_cntr btn_inst (.clk(clk), .reset_p(reset_p), .btn(btn[i]), .btn_pe(btnU_pedge[i]));
        end
    endgenerate

  fnd_4digit_cntr(.clk(clk),  //��� �� �ʿ��� fnd ��Ʈ�ѷ� ��� �ҷ��� 
                  .reset_p(reset_p), 
                  .value(btn_counter), 
                  .seg_7_an(seg_7), //ca(ĳ�ҵ�Ÿ��)-1�� ������
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
 

 //////////////////
 //16��Ʈ¥�� ī��Ʈ �߰� fnd�� ������ Ű�Է��� 1�̸� 
// keyvalid�� �������� ���� �����ϴ� �ڵ� �߰� 
// ī��Ʈ �� fnd�� �Ĥ� ��� 
 
 //ž����� col�� ���̾� 
module keypad_test_top(
    input clk, reset_p,
    input [3:0] row,
    output [3:0] col,
    output [7:0] seg_7,
    output [3:0] com );
    wire key_valid_pe;
    wire [3:0] key_value; 
    reg [15:0] key_counter; 
        
     keypad_cntr_FSM key_pad(.clk(clk), .reset_p(reset_p),
                        .row(row), .col(col), .key_value(key_value), .key_valid(key_valid));
  edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(key_valid), .p_edge(key_valid_pe)); 
  
  
  always @(posedge clk or posedge reset_p) begin
      if(reset_p) key_counter = 0; 
      else if(key_valid_pe) begin
        if(key_value ==1) key_counter = key_counter +1;
        else if(key_value ==2) key_counter = key_counter -1; 
        
        end
    end
  
  //���տ����ڷ� 16��Ʈ �ޱ� 
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(key_counter), 
        .seg_7_ca(seg_7), .com(com)); 
        
endmodule

//set��ư�� ������ ��ư�Է��� �޾� count�ϰ�  �ٽ� ������ ������ min�� sec�� clk�� �޴� ȸ��)
module watch_top2(
    input clk, reset_p,
    input [2:0] btn, 
    output [3:0] com,
    output [7:0] seg_7);

    wire clk_usec , clk_msec, clk_sec, clk_min; 
    //����� ����� ���� ���� ������ �� ���� ��� ������ ������� .�� ������ ���� �ٲ㵵 ������� 
    ////////////////////////////////////////////////////
    clock_usec usec_clk(clk, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk,reset_p,clk_usec, clk_msec); //m clock
    
    clock_div_1000 sec_clk(clk,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk, reset_p, sec_in, clk_min);  //1�� Ŭ���� 60�� �־ clk_min ��� 
    
    /////////////////////////4 clk�� �и� but''������ ���� ���� .
    
    wire [3:0] sec1, sec10 , min1, min10; //4�ڸ� ���� 
    
    counter_dec_60 counter_sec( clk, reset_p, sec_in , sec1, sec10);//�ʸ� ī�����ϴ� ī����
    counter_dec_60 counter_min( clk, reset_p, min_in , min1, min10);

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value({min10, min1, sec10, sec1}),
        .seg_7_an(seg_7), .com(com)); 
        
        wire [2:0] btn_ne;
     
        
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_ne[0]));
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn_ne[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(btn_ne[2]));
     
     wire set_mode; 
     
     T_flip_flop_p t1(.clk(clk), .reset_p(reset_p), .t(btn_ne[0]), .q(set_mode));
     
   wire sec_in,min_in;
   
   assign sec_in  =set_mode ? clk_sec : btn_ne[1];
   assign min_in  =set_mode ? clk_min : btn_ne[2];
       

endmodule


//�ð踦 ���ÿ� �ҷ��ͼ� ī������ ���� �ð迡 ������ ��� 
//ver.professor
module watch_top(
    input clk, reset_p,
    input [2:0] btn, 
    output [3:0] com,
    output [7:0] seg_7);

    wire clk_usec , clk_msec, clk_sec, clk_min; 
    //����� ����� ���� ���� ������ �� ���� ��� ������ ������� .�� ������ ���� �ٲ㵵 ������� 
    ////////////////////////////////////////////////////
    clock_usec usec_clk(clk, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk,reset_p,clk_usec, clk_msec); //m clock
    
    clock_div_1000 sec_clk(clk,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk, reset_p, sec_edge, clk_min);  //1�� Ŭ���� 60�� �־ clk_min ��� 
    
    
    wire [3:0] sec1, sec10 , min1, min10; //4�ڸ� ���� 
    
    counter_dec_60 counter_sec( clk, reset_p, sec_edge, sec1, sec10); 
    counter_dec_60 counter_min( clk, reset_p, min_edge, min1, min10); 

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value({min10, min1, sec10, sec1}),
        .seg_7_an(seg_7), .com(com)); 
        
       wire [2:0] btn_pedge;
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
 

     
     wire set_mode; //1�� �� setmode 0�� �� setmode�ƴ�  
     wire sec_edge, min_edge;
     T_flip_flop_p t1(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));
  
   assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
   assign min_edge = set_mode ? btn_pedge[2] : clk_min;
      

endmodule
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//Ŭ�� ��� ���� clock�� ��� ����ϱ�
module clock_instance (
    input clk,reset_p,
    output clk_msec, clk_csec, clk_sec, clk_min);

    clock_usec usec_clk(clk, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk,reset_p,clk_usec, clk_msec); //m clock
    
    clock_div_10 csec_clk(clk, reset_p,clk_msec, clk_csec); //msec->10msec�� 
    
    clock_div_1000 sec_clk(clk,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk, reset_p, clk_sec , clk_min);  //1�� Ŭ���� 60�� �־ clk_min ��� 
   
endmodule  
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//

///////////////////////////////loadable_Watch_top���� ����� ��Ʈ�Ѹ� �ϱ� ���� �и� ���� �׾ȿ��� ���ư��� ��� ����/////////////////////////////
module loadable_watch(
    input clk, reset_p, 
    input [2:0] btn_pedge,//��ư�� ������ ���� );
    output [15:0] value);
    
    
   // wire clk_usec , clk_msec, clk_sec, clk_min; 
    wire sec_edge, min_edge;
    wire set_mode; //1�� �� setmode 0�� �� setmode�ƴ�   

    wire [3:0] cur_sec1,cur_sec10, set_sec1, set_sec10; //������ sec1�����ڸ�,10���ڸ�, ����sec�� 1���ڸ�, ����sec�� 10���ڸ� 
    wire [3:0] cur_min1,cur_min10, set_min1, set_min10; 
    wire [15:0] cur_time, set_time;

    clock_instance divide(.clk(clk), .reset_p(reset_p), .clk_sec(clk_sec)); 
    
    clock_min min_clk(clk, reset_p, sec_edge , clk_min);  



    loadable_counter_dec_60 cur_time_sec //���� �� ī��Ʈ �ϴ� ��� 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(clk_sec), 
                                            .load_enable(cur_time_load_en), 
                                            .set_value1(set_sec1), 
                                            .set_value10(set_sec10),
                                            .dec1(cur_sec1), 
                                            .dec10(cur_sec10));
    loadable_counter_dec_60 cur_time_min //���� �� ī��Ʈ �ϴ� ��� 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(clk_min), 
                                            .load_enable(cur_time_load_en), 
                                            .set_value1(set_min1), 
                                            .set_value10(set_min10),
                                            .dec1(cur_min1), 
                                            .dec10(cur_min10));                                          
     loadable_counter_dec_60 set_time_sec //���� �� ī��Ʈ �ϴ� ��� 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(btn_pedge[1]), 
                                            .load_enable(set_time_load_en), 
                                            .set_value1(cur_sec1), 
                                            .set_value10(cur_sec10),
                                            .dec1(set_sec1), 
                                            .dec10(set_sec10));     
      loadable_counter_dec_60 set_time_min //���� �� ī��Ʈ �ϴ� ��� 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(btn_pedge[2]), 
                                            .load_enable(set_time_load_en), 
                                            .set_value1(cur_min1), 
                                            .set_value10(cur_min10),
                                            .dec1(set_min1), 
                                            .dec10(set_min10));                                                  
    
 //value =0~9���� ǥ�� ����, ->4��Ʈ �ʿ� , but 4�ڸ� �ʿ��ϴϱ� 16bit�ʿ� 

    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    
    assign value = set_mode ? set_time :cur_time ; //set_mode�� 1�̸� ���� �� ���, 0�̸� �ð� ��� 
    
      T_flip_flop_p t1(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode)); //set_mode�� ��� ��Ŵ 

     edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(set_mode), .n_edge(cur_time_load_en), .p_edge(set_time_load_en)); //cur_time�� set_time�� ������ �ٸ��� �ؾ� �� 
        
      
        assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
        assign min_edge = set_mode ? btn_pedge[2] : clk_min;
endmodule
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//�ð踦 ���ÿ� �ҷ��ͼ� ī������ ���� �ð迡 ������ ��� //�ܺο��� ������ ��� //
module loadable_watch_top(
    input clk, reset_p,
    input [2:0] btn, 
    output [3:0] com,
    output [7:0] seg_7);
 
      wire [15:0] value;
      wire [2:0] btn_pedge;

   
     button_cntr btn_cntr0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
     button_cntr btn_cntr1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
     button_cntr btn_cntr2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
     
    loadable_watch(clk, reset_p,  btn_pedge,value);
                                
    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value),  .seg_7_ca(seg_7), .com(com)); 
      
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//


/////////////////////////////stopwatch/////////////////////////////
module stop_watch_top(
    input clk, reset_p, 
    input [3:0] btn,
    output [3:0] com, 
    output [7:0] seg_7);

     wire clk_usec , clk_msec, clk_sec, clk_min; 
     wire [2:0] btn_pedge;
     wire start_stop; 
     wire clk_start; 
     wire [3:0] sec1, sec10, min1, min10 ;   
     wire lap_swatch, lap_load; 
     reg [15:0] lap_time;
     wire [15:0] value; 
    //����� ����� ���� ���� ������ �� ���� ��� ������ ������� .�� ������ ���� �ٲ㵵 ������� 
    ////////////////////////////////////////////////////
    clock_usec usec_clk(clk_start, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec); //m clock //clk_start�� �����ϰԲ� �� 
    
    clock_div_1000 sec_clk(clk_start,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk_start, reset_p, clk_sec, clk_min);  //1�� Ŭ���� 60�� �־ clk_min ��� 
    
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_pedge[0])); //wire �̸��� btn_pedge �����δ� n edge�̾Ƴ� 
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(btn_pedge[2]));
      
     assign clk_start = start_stop ? clk : 0; // mux ����� 
     //�� ���ķ� �����ϴ� �ν��Ͻ� 
    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop)); 


    counter_dec_60 counter_sec( clk, reset_p, clk_sec, sec1, sec10); //�ϴ� ī����
    counter_dec_60 counter_min( clk, reset_p, clk_min, min1, min10); 
   
  
    T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(lap_swatch)); 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load)); //t-ff���� ���ϱ� posedge�� �� ��ƾ��� button�� �ƴϴϱ� nedge������ �ȵ� 

////    PIPO reg :�����Է� ������� 
 
    always @ (posedge clk or posedge reset_p) begin
        if(reset_p)lap_time =0;
        else if (lap_load) 
            lap_time= {min10, min1, sec10, sec1};
     end
/////     
     assign value = lap_swatch ? lap_time : {min10, min1, sec10, sec1};//1�� �� lap ������ 0�϶��� �����ġ�ϱ�  min~~~���� 
     
      fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value),
        .seg_7_an(seg_7), .com(com)); 

endmodule

//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
///////////////////////////// stop_watch_csec��� /////////////////////////////
 module stop_watch_csec(
 input clk, reset_p,
 input [2:0] btn_pedge,
 output [15:0 ]value);
 
     wire clk_usec , clk_msec, clk_csec, clk_sec; 
     wire start_stop; 
     wire clk_start; 
     wire [3:0] csec1, csec10 , sec1, sec10 ;   
     wire lap_swatch, lap_load; 
     reg [15:0] lap_time;
     wire [15:0] cur_time; 
    //����� ����� ���� ���� ������ �� ���� ��� ������ ������� .�� ������ ���� �ٲ㵵 ������� 
    ////////////////////////////////////////////////////
//      clock_usec usec_clk(clk_start, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
//    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec); //m clock //clk_start�� �����ϰԲ� �� 
    
//    clock_div_10 csec_clk(clk_start,reset_p,clk_msec, clk_csec); //msec->10msec�� 
    
//    clock_div_100 sec_clk(clk_start, reset_p, clk_csec, clk_sec);  //10msec�� 100�� -> clk_sec ��� 
      clock_instance divide(.clk(clk_start), .reset_p(reset_p), .clk_csec(clk_csec), .clk_sec(clk_sec));      
     //�� ���ķ� �����ϴ� �ν��Ͻ� 
       T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop)); 

     assign clk_start = start_stop ? clk : 0; // mux ����� 

     counter_dec_100 counter_msec( clk, reset_p, clk_csec, csec1, csec10); //�ϴ� ī����
     counter_dec_60 counter_sec( clk, reset_p, clk_sec, sec1, sec10); 

     T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch)); 
     edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load)); //t-ff���� ���ϱ� posedge�� �� ��ƾ��� button�� �ƴϴϱ� nedge������ �ȵ� 

     assign cur_time ={sec10, sec1,csec10, csec1};
     assign value = lap_swatch ? lap_time :cur_time;     //1�� �� lap ������ 0�϶��� �����ġ�ϱ�  min~~~���� 

////    PIPO reg :�����Է� ������� 
 
    always @ (posedge clk or posedge reset_p) begin
        if(reset_p)lap_time =0;
        else if (lap_load) 
            lap_time= {sec10, sec1,csec10, csec1}; //lap_time�� ���⼭ ������ 
     end
/////     
endmodule
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
/////////////////////////////stopwatch____100���� 1 /////////////////////////////
//��ư �Է¹ް� fnd ���//
module stop_watch_csec_top(
    input clk, reset_p, 
    input [2:0] btn,
    output [3:0] com, 
    output [7:0] seg_7  );

     wire [2:0] btn_pedge;
     wire [15:0] value;
    
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //wire �̸��� btn_pedge �����δ� n edge�̾Ƴ� 
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
     
    stop_watch_csec( clk, reset_p, btn_pedge, value);
      
    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value),
        .seg_7_ca(seg_7), .com(com)); 

endmodule
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//�ֹ� Ÿ�̸� ��� //
module cook_timer( 
    input clk, reset_p, 
    input [3:0] btn_pedge,
    output [15:0] value,
    output [5:0] led,
    output buzz_clk);

    reg alarm;  
    wire btn_start, inc_sec, inc_min, alarm_off; //��ư 0�� 1�� 2�� 3��
    wire [3:0] set_sec1, set_sec10, set_min1, set_min10; 
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; //     wire clk_usec , clk_msec, clk_sec, clk_min; 
    wire load_enable, dec_clk, clk_start; //clk_start : start���� ���� Ŭ���� �������� �� 
    reg start_stop;  
    wire [15:0] cur_time, set_time;       
    wire timeout_pedge;
    reg time_out;  
    
    assign {alarm_off, inc_min, inc_sec, btn_start } = btn_pedge; //btn_pedge�� ��ǲ
    
     assign led[5] = start_stop; 
     assign led[4] = time_out; 
  
    assign clk_start = start_stop ?  clk : 0; //start(1) ->clk, stop(0) -> 0
  
//    clock_usec usec_clk(clk_start, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
//    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec); //m clock //clk_start�� �����ϰԲ� �� 
//    clock_div_1000 sec_clk(clk_start,reset_p,clk_msec, clk_sec); //
      clock_instance divide(.clk(clk), .reset_p(reset_p), .clk_msec(clk_msec), .clk_sec(clk_sec));

    //��ư �Է��� �޴� count
    counter_dec_60 set_sec( clk, reset_p,inc_sec  ,set_sec1, set_sec10); 
    counter_dec_60 set_min( clk, reset_p,inc_min ,set_min1, set_min10); 
    
     //start or stop ���� ǥ�� tff
     //   T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_start), .q(start_stop)); 
     always @ (posedge clk or posedge reset_p)begin 
        if(reset_p) start_stop = 0; 
        else begin 
            if(btn_start) start_stop = ~start_stop; //start or stop 
            else if(timeout_pedge) start_stop = 0; //���� �ð��� 0000�̸� stop�� �ǵ��� �� //1msec�ϰ� 1Ŭ�� �Ŀ� 0�� �� 
        end
     end
 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); //t-ff���� ���ϱ� posedge�� �� ��ƾ��� button�� �ƴϴϱ� nedge������ �ȵ� 
    
 //��ŸƮ�� �� settime�� load�ؾ��� load_enable�� ���� ��Ƽ� ������� 
    loadable_down_counter_dec_60 cur_sec(clk, reset_p ,clk_sec ,load_enable,set_sec1,set_sec10 ,cur_sec1,cur_sec10 ,dec_clk);   
    loadable_down_counter_dec_60 cur_min(clk, reset_p ,dec_clk ,load_enable,set_min1,set_min10 ,cur_min1,cur_min10 ); 

    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) time_out =0; 
        else begin                                  //time_out =0 //0000�� 
            if(start_stop &&clk_msec && cur_time ==0) time_out = 1; //start_stop 1, cut_time 0 �� �Ǹ� 1msec �Ŀ� time_out�� 1�̵� �� ���������� start_stop�� 0�̵� ��
            else  time_out = 0; //1msec�� �ѹ��� time_out�� 0���� clear 
        end
    end 

    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));  //time_out�� ����ð��� 0�� �� 1�̵� -> �� Ÿ�̹��� timeout_pedge
    
//��¿��� ��Ƽ� 1�� ���� ��ŸƮ ���¿��� ���� 
 
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p)begin
            alarm  = 0;
        end
        else begin
            if(timeout_pedge) alarm = 1; 
            else if(alarm && alarm_off)alarm =0; 
        end
    end
    assign led[0] = alarm;

    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1}; //���� �ð� 
    assign set_time ={set_min10, set_min1, set_sec10, set_sec1};
    assign value = start_stop ? cur_time : set_time; 
    
    reg[16:0] clk_div = 0; 
    always @(posedge clk)clk_div = clk_div +1; 
    
    assign buzz_clk = alarm ? clk_div[14] :0;  //13�� 8000~9000h����  �ȴ�. 

endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// �ֹ� Ÿ�̸� ž��� /////////////////////////////
module cook_timer_top(
    input clk, reset_p, 
    input [3:0] btn,
    output [3:0] com, 
    output [7:0] seg_7,
    output [5:0] led,
    output buzz_clk);
       
     wire btn_start, inc_sec, inc_min, alarm_off; //��ư 0�� 1�� 2�� 3��
     wire [15:0] value;
     wire [3:0] btn_pedge;
     
     button_cntr btn_cntr0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //wire �̸��� btn_pedge �����δ� n edge�̾Ƴ� 
     button_cntr btn_cntr1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
     button_cntr btn_cntr2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
     button_cntr btn_cntr3 (.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));

    cook_timer cook(clk,reset_p, btn_pedge, value, led, buzz_clk);

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com)); 

endmodule


//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//�ٿ�ī��Ʈ ����, decreasement clk ���� 
//0 0���� 59�� �� �� Ŭ���� �ϳ� �ٿ�Ǵ� �� ���� 
module loadable_down_counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //��, ���̴ϱ� 0~9���� ��� -> 4bit �ʿ� 
    output reg [3:0] dec1, dec10,
    output reg dec_clk);
    
    always @(posedge clk, posedge reset_p) begin
     if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
     end 
    else begin //else�� ��Ŭ���� pos���� 
        if(load_enable) begin // 1�̸� �ܺο��� ���� ī���ͷ� ��� 
            dec1 = set_value1;  // dec1 : ���� �����ڸ��� ��µǴ� �� ( cur�� or setting�� �� ���� �� ����)
            dec10 = set_value10;  //set_value : ���� ���� ������ �� (���ø�� -���ð� or �ðԸ�� - �ð谪 �� ���� �� ����) 
        end
        else if(clk_time) begin  //load_enable�� 1�̾ƴϸ� ������ ���� 60�� ī���Ϳ� ���� 
                if(dec1 == 0) begin 
                   dec1 = 9; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                     if(dec10 == 0) begin
                         dec10 =5; 
                         dec_clk =1; //���� ���� �ʿ� ���� 1cycle pulse 
                      end
                     else dec10 = dec10 - 1; 
                     end 
                     else dec1 = dec1 - 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
       end
       else dec_clk=0; //posedge ���� �� �� Ŭ������ ��Ŭ�����ȸ� 1�� �� �� ���� 0 
        end 
            
     end
endmodule

//----------------------------------------------------------------------------------------//
///////////////////Ÿ�� ver. ------------------------------------------------------------
module timer_top(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output led
);
    wire clk_usec, clk_msec, clk_sec, clk_min;
    wire [2:0] btn_pedge, btn_nedge;
    wire clk_start;
    //���ֱ�
    clock_usec usec_clk(clk, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk, reset_p, clk_sec, clk_min);
    //��ư ��Ʈ�ѷ�
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]), .btn_ne(btn_nedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
    wire set_mode;
    //set_mode TFF

        T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode)); 

    
    
    wire [3:0] set_sec1, set_sec10;
    wire [3:0] set_min1, set_min10;
    wire [3:0] down_sec1, down_sec10;
    wire [3:0] down_min1, down_min10;
    wire clk_sec_down, clk_min_down;
    assign clk_sec_down = set_mode ? 1'b0 : clk_sec;
    assign clk_min_down = set_mode ? 1'b0 : clk_min;
    wire btn1_edge_wire, btn2_edge_wire;
    assign btn1_edge_wire = set_mode ? btn_pedge[1] : 1'b0;
    assign btn2_edge_wire = set_mode ? btn_pedge[2] : 1'b0;
    assign set_time_load_en = set_mode ;
    assign down_time_load_en = ~set_mode ;
    //60�� ī����
    loadable_counter_dec_60  set_time_sec(.clk(clk), 
                                        .reset_p(reset_p), 
                                        .clk_time(btn1_edge_wire),
                                      .load_enable(down_time_load_en), 
                                      .set_value1(set_sec1), 
                                            .set_value10(set_sec10),
                                           .dec1(down_sec1),
                                    .dec10(down_sec10));
                    
    loadable_counter_dec_60 set_time_min(.clk(clk), .reset_p(reset_p), .clk_time(btn2_edge_wire),
                .load_enable(down_time_load_en), .set_value1(set_min1), .set_value10(set_min10),
                .dec1(down_min1), .dec10(down_min10));
                
    loadable_down_counter_dec_60_min_sec min_sec_down(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec_down),
                .load_enable(set_time_load_en), .set_value1(down_sec1), .set_value10(down_sec10),
                .set_value100(down_min1), .set_value1000(down_min10), .dec1(set_sec1) , .dec10(set_sec10),
                .dec100(set_min1), .dec1000(set_min10));
                
    wire [15:0] value, set_value, down_value;
    assign set_value = {set_min10,set_min1,set_sec10,set_sec1};
    assign down_value = {down_min10, down_min1, down_sec10, down_sec1};
    assign value = set_mode ? set_value : down_value;
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
    assign led = down_value ? 1'b0 : set_mode ? 1'b0 : 1'b1;
endmodule



module loadable_down_counter_dec_60_min_sec(      //60�� loadable �ٿ� ī���� 4�ڸ�
    input clk, reset_p,
    input clk_time,
    input load_enable,
    input [3:0] set_value1, set_value10, set_value100, set_value1000 ,
    output reg [3:0] dec1, dec10, dec100, dec1000
);
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
                dec1 = 0;
                dec10 = 0;
                dec100 = 0;
                dec1000 = 0;
        end
        else begin
            if (load_enable)begin
                dec1 = set_value1;
                dec10 = set_value10;
                dec100 = set_value100;
                dec1000 = set_value1000;
            end
            else if(clk_time) begin
                   if ({dec1,dec10,dec100,dec1000} == 4'b0) dec1 = 0;
                   else if(dec1 <= 0) begin dec1 = 9;
                        if(dec10 <= 0) begin dec10 = 5;
                            if(dec100 <= 0) begin dec100 = 9;
                                if(dec1000 <= 0)  begin dec1000 = 5; end
                                else dec1000 = dec1000 - 1; end
                            else dec100 = dec100 - 1; end
                        else dec10 = dec10 - 1; end
                    else dec1 = dec1 - 1; end
             end
        end
endmodule

//----------------------------------------------------------------------------------------//
// /////////////////////////�ٱ�� �ð� ����� ////////////////////////////////////////////
 
 module multi_watch (
    input clk, reset_p,
    input [3:0] btn ,
    input mode_btn, //5�� ��ư 
    output [3:0] com,
    output [7:0] seg_7 ,
    //output buzz_clk,
    output [8:0] led );
 
  reg [2:0] mode;
  
  assign led [8:6] = mode; //ringcounter�� �� ������ led�� ǥ���ϵ��� �Ѵ�. 
  
    wire select_mode; 
    button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(mode_btn), .btn_pe(select_mode));

    always @ (posedge clk or posedge reset_p) begin 
        if(reset_p) mode = 3'b001;  //���� ���� �� 0001 (com�� �ֳ�� Ÿ���ε� �� �տ� not�� �پ� �����Ƿ� 0�� ��� ���� ) 
        else begin 
             if (select_mode) begin
                 case(mode) //mux 
                     3'b001 : mode = 3'b010; 
                     3'b010 : mode = 3'b100;
                     3'b100 : mode = 3'b001;
                     default: mode = 3'b001;       
                 endcase
             end
        end            
    end
   
    wire [7:0] seg_7_watch, seg_7_stop_watch, seg_7_cook_watch; 
    wire [3:0] com_watch, com_stop_watch, com_cook_watch;
   
    wire [3:0] watch_btn, stop_btn,cook_btn; 
    wire  watch_wire, stop_wire, cook_wire; 

    watch_top watch(.clk(clk), .reset_p(reset_p), .btn(watch_btn), .com(com_watch), .seg_7(seg_7_watch));
    stop_watch_top stop_watch (.clk(clk), .reset_p(reset_p), .btn(stop_btn), .com(com_stop_watch), .seg_7(seg_7_stop_watch));
    cook_timer_top cook_watch(.clk(clk), .reset_p(reset_p), .btn(cook_btn), .com(com_cook_watch), .seg_7(seg_7_cook_watch), .led(led[5:0]));
 
 //Demux 
    assign watch_btn =  ( mode == 3'b001) ? btn : 0; // [3:0] btn�� watch_top�� ���� 
    assign stop_btn = (mode == 3'b010) ? btn : 0; 
    assign cook_btn = ( mode == 3'b100) ? btn: 0 ; 

    
//Mux
    assign seg_7 = (mode == 3'b001) ? seg_7_watch : 
                   (mode == 3'b010) ? seg_7_stop_watch : 
                   (mode == 3'b100) ? seg_7_cook_watch : 8'b00000000 ; 
                         
    assign com = (mode == 3'b001) ? com_watch :
                 (mode == 3'b010) ? com_stop_watch :
                 (mode ==3'b100) ? com_cook_watch : 4'b0000 ;            
 
 
 endmodule
//----------------------------------------------------------------------------------------//
//----------------------------------------------------------------------------------------//
// /////////////////////////�ٱ�� �ð� ����� ��� ������ ���� ���� ver.professor ////////////////////////////////////////////
module multye_watch_no_top_divide(
    input clk, reset_p, 
    input [4:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output buzz_clk);
    
    parameter watch_mode = 3'b001;
    parameter stop_watch_mode = 3'b010; 
    parameter cook_timer_mode = 3'b100;
    
    wire [2:0] watch_btn, stopw_btn;// watch�κ����� �尡�� �κ� 
    wire [3:0] cook_btn; 
    
    wire [3:0] watch_com, stopw_com, cook_com; //fnd�� ������com
    wire [7:0] watch_seg7, stopw_seg7, cook_seg7; //fnd�� ������ seg7
    reg [2:0] mode; //001-watch mode, 010-stopw, 100-cook timer //3bit �ʿ� 
    
     button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[4]), .btn_pe(btn_mode));

    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) mode = watch_mode; 
        else if(btn_mode) begin
            case(mode)
                watch_mode      : mode = stop_watch_mode; 
                stop_watch_mode : mode = cook_timer_mode;
                cook_timer_mode : mode = watch_mode; 
                default         : mode = watch_mode;
             endcase  
        end
     end
    //Demux 
    assign {  cook_btn,stopw_btn,watch_btn} = (mode ==watch_mode ) ? {7'b0, btn [2:0] } : //0000000bbb
                                              (mode == stop_watch_mode) ? {4'b0, btn[2:0] , 3'b0 } : // 0000bbb000
                                              {btn[3:0], 6'b0};
    
   loadable_watch_top watch(clk, reset_p, watch_btn, watch_com, watch_seg7 ); 
   stop_watch_csec_top stop_watch( clk, reset_p, stopw_btn, stopw_com, stopw_seg7  );
   cook_timer_top cook(clk,reset_p, cook_btn, cook_com, cook_seg7,led, buzz_clk );
   
   
   assign com = (mode ==cook_timer_mode ) ? cook_com : 
                (mode == stop_watch_mode) ? stopw_com : 
                watch_com ;
                
   assign seg_7= (mode ==cook_timer_mode ) ? cook_seg7 : 
                 (mode == stop_watch_mode) ? stopw_seg7 : 
                 watch_seg7 ;

 endmodule
  
  
// /////////////////////////�ٱ�� �ð� ����� ��� �����͵� ��ģ �κ�  ////////////////////////////////////////////
   module multy_purpose_watch(
    input clk, reset_p, 
    input [4:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output [5:0] led,
    output buzz_clk);
    
    parameter watch_mode = 3'b001;
    parameter stop_watch_mode = 3'b010; 
    parameter cook_timer_mode = 3'b100;
    
    wire [2:0] watch_btn, stopw_btn;// watch�κ����� �尡�� �κ� 
    wire [3:0] cook_btn; 
    wire [15:0] value, watch_value, stop_watch_value, cook_timer_value;
    reg [2:0] mode; //001-watch mode, 010-stopw, 100-cook timer //3bit �ʿ� 
    wire btn_mode;
    wire [3:0] btn_pedge;
    
    loadable_watch watch(clk, reset_p, watch_btn, watch_value);
    stop_watch_csec stop_watch(clk, reset_p, stopw_btn, stop_watch_value);
    cook_timer(clk, reset_p, cook_btn, cook_timer_value, led, buzz_clk);
    
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
    button_cntr btn_cntr3(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));
    button_cntr btn_cntr4(.clk(clk), .reset_p(reset_p), .btn(btn[4]), .btn_pe(btn_mode));


    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) mode = watch_mode; 
        else if(btn_mode) begin
            case(mode)
                watch_mode      : mode = stop_watch_mode; 
                stop_watch_mode : mode = cook_timer_mode;
                cook_timer_mode : mode = watch_mode; 
                default         : mode = watch_mode;
             endcase  
        end
     end
    //Demux 
   assign {  cook_btn,stopw_btn,watch_btn} = (mode ==watch_mode ) ? {7'b0, btn_pedge [2:0] } : //0000000bbb
                                              (mode == stop_watch_mode) ? {4'b0, btn_pedge[2:0] , 3'b0 } : // 0000bbb000
                                              {btn_pedge[3:0], 6'b0};
                                              
   
   assign value = (mode == cook_timer_mode ) ? cook_timer_value : 
                  (mode == stop_watch_mode ) ? stop_watch_value : 
                  watch_value;
                  
  fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
 endmodule
 
  module dht11_top( //16������ ��µǴ°����� �д� �� 10������ ������ 
    input clk, reset_p,
    inout dht11_data,
    output [3:0] com,
    output [7:0] seg_7, 
    output [7:0] led_bar);
 
    wire [7:0] humidity, temperature;
    
    dht11 dht(clk, reset_p, dht11_data, humidity, temperature, led_bar);
    
    wire [15:0] bcd_humi, bcd_tmpr;
    bin_to_dec humi(.bin({4'b0000,humidity}), .bcd(bcd_humi));
    bin_to_dec tmpr(.bin({4'b0000,temperature}), .bcd(bcd_tmpr));
    
    wire [15:0] value; 
    assign value = {bcd_humi[7:0], bcd_tmpr[7:0]};
    
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
 
 endmodule
 
 
 
 //////////////////////////////ultrasonic////////////////////////////////////////////////////
module ultrasonic_top (
    input clk, reset_p, 
    input echo, 
    output trigger,
    output [3:0] com,
    output [7:0] seg_7,
    output [3:0] led_bar);
   
    wire [11:0] distance; //bin_to_dec�� bindl 12bit�� �����ֱ� ���� 
    wire [15:0] bcd_dist; //bcd�� 16bit�� �����ֱ� ���� 
     bin_to_dec dis(.bin(distance), .bcd(bcd_dist));
     fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_dist), .seg_7_an(seg_7), .com(com));
              
    ultrasonic ultra(clk, reset_p, echo, trigger, distance, led_bar);
    
 endmodule
 
 
 ////////////////////////LED��� ���� ///////////////////////////
 
 module led_pwm_top(
    input clk, reset_p,
    output [3:0] led_pwm);
    
    reg [27:0] clk_div; 
    always @(posedge clk) clk_div = clk_div +1; 
    //duty 0~ 63% ���� -> 6bit 
    pwm_128step pwm_r(.clk(clk), . reset_p(reset_p), .duty(clk_div[27:21]), .pwm_freq(10_000), .pwm_128(led_pwm[0])); 
    
    pwm_128step pwm_g(.clk(clk), . reset_p(reset_p), .duty(clk_div[26:20]), .pwm_freq(10_000), .pwm_128(led_pwm[1])); 
    
    pwm_128step pwm_b(.clk(clk), . reset_p(reset_p), .duty(clk_div[25:19]), .pwm_freq(10_000), .pwm_128(led_pwm[2])); 

    pwm_128step pwm_osiro(.clk(clk), . reset_p(reset_p), .duty(clk_div[27:21]), .pwm_freq(10_000), .pwm_128(led_pwm[3])); 
    //7bit�� �ø� -> 128�ܰ� ���� ó������ ������ �ܰ� ��� ���� ���� 
endmodule
//----------------------------------------------------------------------------------------------------------------//
//////////////////////////////////////////////////////////���� ����////////////////////////////////////////////////
module dc_motor_pwm_top (
    input clk, reset_p, 
    output motor_pwm); //for speed control);

    reg [32:0] clk_div; //27:0 ���� �ϸ� �ӵ��� ���� �Ⱥ��� 
    always @(posedge clk) clk_div = clk_div +1;

    pwm_128step pwm_motor (.clk(clk), .reset_p(reset_p), .duty(clk_div[32:26]), .pwm_freq(1_00), .pwm_128(motor_pwm)); //clk_div�� 7bit�� �� 128���� �ܰ������� ���� ���� 
endmodule


//------------------------------------------------------------------------------------------------------------------------------------------------//
//////////////////////////////////////////////////////////pwm�� �̿��Ͽ� sg90 �ٱ�� �������� �����////////////////////////////////////////////////
module servo_motor_pwm_top_1 (
     input clk, reset_p, 
     input [3:0] btn,
    output motor_pwm,
    output [7:0] seg_7,
    output [3:0] com); //for speed control);

    reg [32:0] clk_div; //27:0 ���� �ϸ� �ӵ��� ���� �Ⱥ��� 
    wire [3:0] btn_ne; 
  
    wire clk_div_24 ; 
    
   edge_detector_n ed (.clk(clk), .reset_p(reset_p), .cp(clk_div[24]), .p_edge(clk_div_24));
    
  always @(posedge clk) begin
     clk_div = clk_div + 1;
  end
    
    reg [7:0] duty;
    
  always @(posedge clk or posedge reset_p) begin 
        if( reset_p ) begin
            duty =6; 
        end
        else if(clk_div_24) begin
            duty = duty +1; 
            if(duty >= 32) duty = 6;    
        end
        else if( btn_ne[0])  duty=19; //0�� 
        else if( btn_ne[1])  duty=32; //90�� 
        else if( btn_ne[2])  duty=6; //90��     
  end
    
//        if (btn_ne[3]) begin 
//             duty= 32; 
//             if(6<=duty <=32) 
//               duty= duty-1;
    
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_ne[0]));
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn_ne[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(btn_ne[2]));
     button_cntr cn3 (.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_ne(btn_ne[3]));
 
     wire [15:0] bcd_duty;

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_duty), .seg_7_an(seg_7), .com(com)); 
    bin_to_dec dist(.bin(({7'b0,duty})), .bcd(bcd_duty));
    pwm_256step_servomotor pwm_motor (.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_256(motor_pwm)); //clk_div�� 7bit�� �� 128���� �ܰ������� ���� ���� 
endmodule

//------------------------------------------------------------------------------------------------------//
//512�ػ󵵻���� �������� //
module servo_sg90(
    input clk, reset_p,
    input [2:0]btn,
    output pwm_smotor,
    output [3:0] com, 
    output [7:0] seg_7);
   
   wire [2:0] btn_pedge; 
   
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_pedge[0]));
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(btn_pedge[2]));
    wire clk_div_pedge;

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(clk_div[24]), .p_edge(clk_div_pedge));
    reg [31:0] clk_div; 
    always @(posedge clk) clk_div = clk_div +1;
    
    reg [8:0] duty;  //32bitǥ�� ���� 
    reg up_down; 
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin 
            duty =14; 
            up_down = 1; 
        end
         else if(btn_pedge[0]) begin
                if(up_down) up_down = 0; 
                else up_down = 1; 
         end
         else if(btn_pedge[1])begin
            duty =14; 
         end 
         else if(btn_pedge[2]) begin
            duty =64; 
         end
        else if(clk_div_pedge) begin 
            if(duty >=  64) up_down = 0;           //up_down = 0 ( down) -> 1���� 
            else if(duty <=14) up_down =1;   
        
             if(up_down) duty =duty +1; 
              else duty = duty -1;    
       end
   end
   
   wire [15:0] bcd_duty;
    pwm_512step servo(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_512(pwm_smotor));
    bin_to_dec dist(.bin(({3'b0,duty})), .bcd(bcd_duty));
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_duty), .seg_7_an(seg_7), .com(com)); 
  endmodule
  
  
  
  //////512�ػ󵵻���� �������� //
module servo_sg90_period( //�¹����� �ϽŰɷ� 
    input clk, reset_p,
    input [2:0]btn,
    output sg90,
    output [3:0] com, 
    output [7:0] seg_7);
   
   wire [2:0] btn_pedge; 
   
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_pedge[0]));
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(btn_pedge[2]));
    wire clk_div_pedge;

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(clk_div[8]), .p_edge(clk_div_pedge));
    reg [31:0] clk_div; 
    always @(posedge clk) clk_div = clk_div +1;
    
    reg [20:0] duty;  //32bitǥ�� ���� 
    reg up_down; 
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin 
            duty =58_000; 
            up_down = 1; 
        end
         else if(btn_pedge[0]) begin
                if(up_down) up_down = 0; 
                else up_down = 1; 
         end
         else if(btn_pedge[1])begin
            duty =58_000; 
         end
         else if(btn_pedge[2]) begin
            duty =256_000; 
         end
        else if(clk_div_pedge) begin 
            if(duty >=  256_000) up_down = 0;           //200M �� 10% = 20�� 200_000
            else if(duty <=52_000) up_down =1;         //100_000
        
             if(up_down) duty =duty +1; 
              else duty = duty -1;    
       end
   end
   
   wire [15:0] bcd_duty;
    pwm_512_period servo(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_period(200_000_000), .pwm_512(sg90)); //�ֱ⸸ ����ؼ� ������� 
    bin_to_dec dist(.bin(duty[20:10]), .bcd(bcd_duty));//duty[20:10]- bin�� ���� �� duty�� 1024�� ������ ���� 10��Ʈ ����Ʈ 
    //58000/1024 =56.6  256000 / 1024 = 250 
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_duty), .seg_7_an(seg_7), .com(com)); 
  endmodule


//----------------------------------------------------------------------------------------------------------------//
//adc�� �̿��� led��� ���� 

module adc_top (
    input clk, reset_p,
    input vauxp6, vauxn6,
    output [3:0] com,
    output [7:0] seg_7,
    output led_pwm);
    
    wire [4:0] channel_out; 
    wire eoc_out; 
    wire [15:0] do_out;     //���� 12�� ������ �� 
    
 xadc_wiz_0 adc_ch6
  (
          .daddr_in({2'b0, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),              // Enable Signal for the dynamic reconfiguration port
//          di_in,               // Input data bus for the dynamic reconfiguration port
//          dwe_in,              // Write Enable for the dynamic reconfiguration port
          .reset_in(reset_p),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
//          busy_out,            // ADC Busy signal
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
//          .drdy_out,            // Data ready signal for the dynamic reconfiguration port
          .eoc_out(eoc_out)     //�Ƴ��αװ� -> �����з� ��ȯ�ϴ� converting�� ���� �� 1�̵�  // End of Conversion Signal
//          eos_out,             // End of Sequence Signal
//          alarm_out,           // OR'ed output of all the Alarms    
//          vp_in,               // Dedicated Analog Input Pair
//          vn_in
 );
    wire eoc_out_pedge; 
     edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(eoc_out), .p_edge(eoc_out_pedge)); // eoc_out�� 1���� �� �۵��ϰ� �ϱ� ���� pos edge ���� 
     
     reg[11:0] adc_value; 
     always @(posedge clk or posedge reset_p) begin
        if(reset_p) adc_value =0; 
        else if(eoc_out_pedge)  //posedge ���� ���� do_out�� adc_value�� ���� 
            adc_value ={4'b0, do_out[15:8]}; //[15:4]���е�  /4 ������������ �ߴ� �ִ� 4000, 15:6�����ν� 900~1000������ �� //���е� 8bit     
     end
     
    wire [15:0] bcd_value; 
    bin_to_dec adc_bcd(.bin(adc_value), .bcd(bcd_value)); //12bitǥ�� 
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_value), .seg_7_an(seg_7), .com(com)); 
    pwm_128step pwm_led(.clk(clk), .reset_p(reset_p), .duty(do_out[15:9]), .pwm_freq(10_000), .pwm_128(led_pwm));  //duty(adc_value[11:5])

endmodule


//----------------------------------------------------------------------------------------------------------------//
//���̽�ƽ�� �̿��Ͽ� 2���� adc���� ��� 

module adc_sequence2_top(
    input clk, reset_p,
    input vauxp6, vauxn6, 
    input vauxp15, vauxn15, 
    output led_r, led_g, 
    output led_r_b, led_g_b,
    output [3:0] com, 
    output [7:0] seg_7);

    wire [4:0] channel_out;  //          output [4:0] channel_out;
    wire [15:0] do_out; 
    wire eoc_out,eoc_out_pedge, eos_out; 
   
    adc_ch6_ch15 adc_seq2
    (
          .daddr_in({2'b0, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),     //converting ������ enable1 �� �� �ֵ��� eoc_out�� ����          // Enable Signal for the dynamic reconfiguration port
          .reset_in(reset_p),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
          .vauxp15(vauxp15),             // Auxiliary channel 15
          .vauxn15(vauxn15),
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out),             //������ ������ �� ä�� �� �޾Ƽ� ����// End of Conversion Signal
          .eos_out(eos_out)             // End of Sequence Signal
     );

//eoc_out�� ���� �� �����Ŵ�. 
     edge_detector_n ed_eoc(.clk(clk), .reset_p(reset_p), .cp(eoc_out), .p_edge(eoc_out_pedge)); // eoc_out�� 1���� �� �۵��ϰ� �ϱ� ���� pos edge ���� 
     
 /*    reg [6:0] duty_x, duty_y; 
     edge_detector_n ed_eos(.clk(clk), .reset_p(reset_p), .cp(eos_out), .p_edge(eos_out_pedge)); // eoc_out�� 1���� �� �۵��ϰ� �ϱ� ���� pos edge ���� 
     always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            duty_x=0;
            duty_y=0;
        end
        else if(eos_out_pedge)begin
            duty_x=adc_value_x[6:0];
            duty_y=adc_value_y[6:0];
        end
     end*/

     //�Ʊ� �ϳ��ϱ� eoc_out���� �� adc_value�� �����ϸ��µ� ���� 2���ϱ� 2��������. 
     reg[11:0] adc_value_x, adc_value_y; 
     always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            adc_value_x =0; 
            adc_value_y =0;            
         end    //ä���� 6�̳� 15�Ŀ� ���� ä���� �޶��� 
         else if(eoc_out_pedge)begin
             case(channel_out[3:0]) //[3:0]�����ָ� 4:0���� �ǰ����� ä�� 6�̾ȵǰ� 22, 31�� �� 
                 6 : adc_value_y = {4'b0, do_out[15:10]};
                 15 : adc_value_x = {4'b0, do_out[15:10]};
             endcase
         end      
     end
        wire [15:0] bcd_value_x,bcd_value_y;
        bin_to_dec adc_x_bcd(.bin(adc_value_x), .bcd(bcd_value_x)); //12bitǥ�� 
        bin_to_dec adc_y_bcd(.bin(adc_value_y), .bcd(bcd_value_y)); //12bitǥ�� 

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value({bcd_value_x[7:0], bcd_value_y[7:0]}), .seg_7_an(seg_7), .com(com)); 
    ///vrx= 6��, //vry = 15�� x, y, gnd 
    
    //duty 7��Ʈ ����� ��������Ʈ���� 7��Ʈ �߶�� 
   pwm_128step pwm_led_r(.clk(clk), .reset_p(reset_p), .duty(adc_value_x[6:0]), .pwm_freq(10_000), .pwm_128(led_r));  //duty(adc_value[11:5])
   pwm_128step pwm_led_g(.clk(clk), .reset_p(reset_p), .duty(adc_value_y[6:0]), .pwm_freq(10_000), .pwm_128(led_g));  //duty(adc_value[11:5])

    wire led_r_b, led_g_b;
    assign led_r_b = led_r;
    assign led_g_b = led_g; 
endmodule



//I2C��� 0����ư -0000000  ����, 1����ư - 11111111 : BT�� 1�Ǹ� on, 1�Ǹ� off 
module I2C_master_top(
    input clk, reset_p,
    input [1:0] btn,
    output sda, scl
);
    reg [7:0] data;
    reg valid; //i2c����� �������̽� ( �����ߴ� ������) 
    
    //rd_wr = 0 (write) //�츮�� ���� slave�ϳ��� ���Ŵϱ� �ϳ��� �ּҸ� ����Ѵ� 27 
    I2C_master mater( .clk(clk), .reset_p(reset_p), .rd_wr(0), .addr(7'h27), .data(data),
     .valid(valid), .sda(sda), .scl(scl)); 
    //0����ư ������ data�� 0*8�� �ְ� 0*8�� ���ư� 
    
    wire [1:0] btn_pedge, btn_nedge ;
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]), .btn_ne(btn_nedge[0]));
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]), .btn_ne(btn_nedge[1]));
    
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            data = 0; 
            valid =0; 
        end
        else begin
            if(btn_pedge[0])begin 
                data =8'b0000_0000;
                valid = 1; //valid�� ������ �� start 
            end
            else if(btn_nedge[0]) valid =0; //valid���������� ���� nedge���� 
            else if( btn_pedge[1]) begin
                data = 8'b0000_1000;
                valid = 1; 
            end 
            else if(btn_nedge[1]) valid =0;   
        end
    end
endmodule
////-------------------------------------------------------------------------------------------//

////-------------------------------------------------------------------------------------------//
////ic2����� �̿��Ͽ� textLCD�гο� ����ϱ�  

module i2c_txtlcd_top(
    input clk, reset_p,
    input btn, 
    output scl, sda);

    parameter IDLE = 6'b00_0001; 
    parameter INIT = 6'b00_0010; 
    parameter SEND = 6'b00_0100; 
    
    parameter SAMPLE_DATA = "A";    //A�� �ƽ�Ű �ڵ� ������ ����� 
    
    wire btn_pedge, btn_nedge; 
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));

    reg [7:0] send_buffer; 
    reg send_e, rs; 
    wire busy; 
    
    i2c_lcd_send_byte send_byte (.clk(clk), .reset_p(reset_p), .addr(7'h27),  .send_buffer(send_buffer), 
                                 .send(send_e), .rs(rs), .scl(scl), .sda(sda), .busy(busy));
                                 
     
    reg [21:0] count_usec; 
    reg count_usec_e; 
    wire clk_usec; 
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    //usec counter ���� Ŭ�� ����� 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //�̷��� �ؾ� ������������ �ƴ϶� �ٷ� �װſ������� Ŭ����� 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1���� �ٸ� ���� �� �� ������ �Ϲ������� flag�� �ϸ� true false�θ� ��� 
    reg init_flag; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
   always @(posedge clk or posedge reset_p) begin //textLCD�ٷ�� ��� ������ 
        if(reset_p) begin //�ʱ�ȭ���� i2c_led_send_byte�� ���� �κ� �ʱ�ȭ ������� 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //��ɺ����� �� 
            send_e =0; 
            init_flag =0; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
        end
        else begin
            case(state) 
                IDLE : begin   //�����ϸ� �ٷ� �ʱ�ȭ  //�� ���Ĵ� ��ư�� pedge�� �߸� send�� �Ѵ�. 
                    if(init_flag) begin //ó���� 0 init state�ٳ���� 1�̵� -> �ʱ�ȭ�� �Ϸ�� 
                        if(btn_pedge) next_state =SEND; 
                    end
                    else begin
                        if(count_usec <=22'd80_000) begin//40ms = 40_000us //usec�� ����Ŭ���� 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == �ʱ�ȭ 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms��ٸ� (200us*5��= 1ms���� �� ũ�� �� ��)  //�̹� ������ ���� �ٸ� �͵� �� ������ �� �ð� ���� ������ �� 
                        send_buffer = 8'h33;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us���� send_e =0
                    else if(count_usec <= 22'd2010)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h32;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us���� send_e =0
                    else if(count_usec <= 22'd3020)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h28;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h0c;    //08�ָ� display off�� 
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h01;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //�ʱ�ȭ 
                    else if(count_usec <= 22'd6050)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h06;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT���� state�ٽ� IDLE
                        init_flag = 1; //�ʱ�ȭ �Ϸ� 
                        count_usec_e =0; // �ʱ�ȭ �Ǿ����� �ٽ� ������ 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 ��� ��� ����� 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 ��� ��� ����� �ƴ� 
                        send_buffer =SAMPLE_DATA;// 8'h41;//+cnt_data ; //��ư���� ������ A,B,CD,...���� 
                        rs =1; //�����ž�????
                        send_e =1;                     
                    end                   
                end
            endcase
        end
   end                                                           
endmodule 
//////////////////////////////////////////
module i2c_txtlcd_top_1(
    input clk, reset_p,
    input btn, 
    output scl, sda);

    parameter IDLE = 6'b00_0001; 
    parameter INIT = 6'b00_0010; 
    parameter SEND = 6'b00_0100; 
    
    parameter SAMPLE_DATA = "A";    //A�� �ƽ�Ű �ڵ� ������ ����� 
    
    wire btn_pedge, btn_nedge; 
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));

    reg [7:0] send_buffer; 
    reg send_e, rs; 
    wire busy; 
    
    i2c_lcd_send_byte send_byte (.clk(clk), .reset_p(reset_p), .addr(7'h27),  .send_buffer(send_buffer), 
                                 .send(send_e), .rs(rs), .scl(scl), .sda(sda), .busy(busy));
                                 
     
    reg [21:0] count_usec; 
    reg count_usec_e; 
    wire clk_usec; 
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    //usec counter ���� Ŭ�� ����� 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //�̷��� �ؾ� ������������ �ƴ϶� �ٷ� �װſ������� Ŭ����� 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1���� �ٸ� ���� �� �� ������ �Ϲ������� flag�� �ϸ� true false�θ� ��� 
    reg init_flag; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
   reg [3:0] cnt_data;///////////////////////////////////////////////////////////////////////////////////                             
   always @(posedge clk or posedge reset_p) begin //textLCD�ٷ�� ��� ������ 
        if(reset_p) begin //�ʱ�ȭ���� i2c_led_send_byte�� ���� �κ� �ʱ�ȭ ������� 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //��ɺ����� �� 
            send_e =0; 
            init_flag =0; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
            cnt_data =0; ///////////////////////////////////////////////////////////////////////////////////   
        end
        else begin
            case(state) 
                IDLE : begin   //�����ϸ� �ٷ� �ʱ�ȭ  //�� ���Ĵ� ��ư�� pedge�� �߸� send�� �Ѵ�. 
                    if(init_flag) begin //ó���� 0 init state�ٳ���� 1�̵� -> �ʱ�ȭ�� �Ϸ�� 
                        if(btn_pedge) next_state =SEND; 
                    end
                    else begin
                        if(count_usec <=22'd40_000) begin//40ms = 40_000us //usec�� ����Ŭ���� 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == �ʱ�ȭ 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms��ٸ� (200us*5��= 1ms���� �� ũ�� �� ��)  //�̹� ������ ���� �ٸ� �͵� �� ������ �� �ð� ���� ������ �� 
                        send_buffer = 8'h33;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us���� send_e =0
                    else if(count_usec <= 22'd2010)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h32;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us���� send_e =0
                    else if(count_usec <= 22'd3020)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h28;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h0C;    //08�ָ� display off�� 
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h01;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //�ʱ�ȭ 
                    else if(count_usec <= 22'd6050)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h06;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT���� state�ٽ� IDLE
                        init_flag = 1; //�ʱ�ȭ �Ϸ� 
                        count_usec_e =0; // �ʱ�ȭ �Ǿ����� �ٽ� ������ 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 ��� ��� ����� 
                        next_state = IDLE; 
                        send_e =0; 
                        cnt_data = cnt_data +1; 
                    end
                    else begin  //busy=0 ��� ��� ����� �ƴ� 
                        send_buffer = SAMPLE_DATA +cnt_data ; //��ư���� ������ A,B,CD,...���� 
                        rs =1; //�����ž�????
                        send_e =1; 
                     //   cnt_data = cnt_data +1; ///////////////////////////////////////////////////////////////////////////////////   
                        
                        
                    end
                   
                end
            endcase
        end
   end                                                           
endmodule 
//////////////////////////////////////////
module i2c_txtlcd_top_2(
    input clk, reset_p,
    input [2:0] btn, 
    output scl, sda);

    parameter IDLE = 6'b00_0001; 
    parameter INIT = 6'b00_0010; 
    parameter SEND = 6'b00_0100; 
    parameter MOVE_CUROSR = 6'b00_1000;
    
    parameter SAMPLE_DATA = "A";    //A�� �ƽ�Ű �ڵ� ������ ����� 
    
    wire [2:0 ]btn_pedge ; 
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //������ SEND STATE��
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1])); //������ MOVE_CUROSR�� 
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    reg [7:0] send_buffer; 
    reg send_e, rs; 
    wire busy; 
    
    i2c_lcd_send_byte send_byte(.clk(clk), .reset_p(reset_p), .addr(7'h27),  .send_buffer(send_buffer), 
                                 .send(send_e), .rs(rs), .scl(scl), .sda(sda), .busy(busy));
                                 
    reg [21:0] count_usec; 
    reg count_usec_e; 
    wire clk_usec; 
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    //usec counter ���� Ŭ�� ����� 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //�̷��� �ؾ� ������������ �ƴ϶� �ٷ� �װſ������� Ŭ����� 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1���� �ٸ� ���� �� �� ������ �Ϲ������� flag�� �ϸ� true false�θ� ��� 
    reg init_flag; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
   reg [3:0] cnt_data;///////////////////////////////////////////////////////////////////////////////////                             
   always @(posedge clk or posedge reset_p) begin //textLCD�ٷ�� ��� ������ 
        if(reset_p) begin //�ʱ�ȭ���� i2c_led_send_byte�� ���� �κ� �ʱ�ȭ ������� 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //��ɺ����� �� 
            send_e =0; 
            init_flag =0; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
            cnt_data =0; ///////////////////////////////////////////////////////////////////////////////////   
        end
        else begin
            case(state) 
                IDLE : begin   //�����ϸ� �ٷ� �ʱ�ȭ  //�� ���Ĵ� ��ư�� pedge�� �߸� send�� �Ѵ�. 
                    if(init_flag) begin //ó���� 0 init state�ٳ���� 1�̵� -> �ʱ�ȭ�� �Ϸ�� 
                        if(btn_pedge[0]) next_state =SEND; 
                        else if(btn_pedge[1]) next_state = MOVE_CUROSR; //�ι� �� �ٿ� ù��° �ڸ��� �ű�� ��ɾ� 
                    end
                    else begin
                        if(count_usec <=22'd40_000) begin//40ms = 40_000us //usec�� ����Ŭ���� 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == �ʱ�ȭ 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms��ٸ� (200us*5��= 1ms���� �� ũ�� �� ��)  //�̹� ������ ���� �ٸ� �͵� �� ������ �� �ð� ���� ������ �� 
                        send_buffer = 8'h33;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us���� send_e =0
                    else if(count_usec <= 22'd2010)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h32;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us���� send_e =0
                    else if(count_usec <= 22'd3020)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h28;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h0C;    //08�ָ� display off�� 
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h01;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //�ʱ�ȭ 
                    else if(count_usec <= 22'd6050)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h06;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT���� state�ٽ� IDLE
                        init_flag = 1; //�ʱ�ȭ �Ϸ� 
                        count_usec_e =0; // �ʱ�ȭ �Ǿ����� �ٽ� ������ 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 ��� ��� ����� 
                        next_state = IDLE; 
                        send_e =0; 
                        cnt_data = cnt_data +1; 
                    end
                    else begin  //busy=0 ��� ��� ����� �ƴ� 
                        send_buffer = SAMPLE_DATA +cnt_data ; //��ư���� ������ A,B,CD,...���� 
                        rs =1; //�����ž�????
                        send_e =1; 
                    end           
                end
                MOVE_CUROSR : begin 
                   if(busy)begin   //busy =1 ��� ��� ����� 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 ��� ��� ����� �ƴ� 
                        send_buffer = 8'hc0 ; //�ι�°�ٿ��� ù��°�� �Ű��� 
                        rs =0; 
                        send_e =1; 
                    end           
                end
            endcase
        end
   end                                                           
endmodule 

//1byte�� data�� 4bit�� �ι� �����ִ� �� 
//busy�� ��Ʈ�ѷ����� �����ִ� ��(��� 4ibt�� ������ �����ϱ� ,send_e�� top��ü���� ����� �ȴ� �ȵȴٸ� �Ǵ��ϴ� ��) 
//////////////////////////////////////////
module i2c_txtlcd_top_3(
    input clk, reset_p,
    input [2:0] btn, 
    output scl, sda);

    parameter IDLE = 6'b00_0001; 
    parameter INIT = 6'b00_0010; 
    parameter SEND = 6'b00_0100; 
    parameter MOVE_CUROSR = 6'b00_1000;
    parameter SHIFT_DISPLAY = 6'b01_0000;
    
    parameter SAMPLE_DATA = "A";    //A�� �ƽ�Ű �ڵ� ������ ����� 
    
    wire [2:0 ]btn_pedge ; 
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //������ SEND STATE��
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1])); //������ MOVE_CUROSR�� 
    button_cntr btn_cntr2(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));

    reg [7:0] send_buffer; 
    reg send_e, rs; 
    wire busy; 
    
    i2c_lcd_send_byte send_byte (.clk(clk), .reset_p(reset_p), .addr(7'h27),  .send_buffer(send_buffer), 
                                 .send(send_e), .rs(rs), .scl(scl), .sda(sda), .busy(busy));
                                 
     
    reg [21:0] count_usec; 
    reg count_usec_e; 
    wire clk_usec; 
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    //usec counter ���� Ŭ�� ����� 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //�̷��� �ؾ� ������������ �ƴ϶� �ٷ� �װſ������� Ŭ����� 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(posedge clk, posedge reset_p) begin //negedge
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1���� �ٸ� ���� �� �� ������ �Ϲ������� flag�� �ϸ� true false�θ� ��� 
    reg init_flag; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
   reg [3:0] cnt_data;   //�� �ٿ� 16���� ���� ��                   
   always @(posedge clk or posedge reset_p) begin //textLCD�ٷ�� ��� ������ 
        if(reset_p) begin //�ʱ�ȭ���� i2c_led_send_byte�� ���� �κ� �ʱ�ȭ ������� 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //��ɺ����� �� 
            send_e =0; 
            init_flag =0; //IDLE���� �ʱ�ȭ�� �Ǿ����� �ȵǾ����� ǥ���ϴ� ���� 
            cnt_data =0;  
        end
        else begin
            case(state) 
                IDLE : begin   //�����ϸ� �ٷ� �ʱ�ȭ  //�� ���Ĵ� ��ư�� pedge�� �߸� send�� �Ѵ�. 
                    if(init_flag) begin //ó���� 0 init state�ٳ���� 1�̵� -> �ʱ�ȭ�� �Ϸ�� 
                        if(btn_pedge[0]) next_state =SEND; 
                        else if(btn_pedge[1]) next_state = MOVE_CUROSR; //�ι� �� �ٿ� ù��° �ڸ��� �ű�� ��ɾ� 
                        else if(btn_pedge[2]) next_state = SHIFT_DISPLAY; //�ι� �� �ٿ� ù��° �ڸ��� �ű�� ��ɾ� 
                    end
                    else begin
                        if(count_usec <=22'd40_000) begin//40ms = 40_000us //usec�� ����Ŭ���� 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == �ʱ�ȭ 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms��ٸ� (200us*5��= 1ms���� �� ũ�� �� ��)  //�̹� ������ ���� �ٸ� �͵� �� ������ �� �ð� ���� ������ �� 
                        send_buffer = 8'h33;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us���� send_e =0
                    else if(count_usec <= 22'd2010)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h32;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us���� send_e =0
                    else if(count_usec <= 22'd3020)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h28;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h0f;  //oc  //08�ָ� display off�� //�����̰Ե� 
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h01;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //�ʱ�ȭ 
                    else if(count_usec <= 22'd6050)begin //1010���� 2010���� �ð��� ���� 
                        send_buffer = 8'h06;
                        send_e =1; //�� ������ 5�� �����ڴ�. 200us * 5�� -> 1ms �ɸ�  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT���� state�ٽ� IDLE
                        init_flag = 1; //�ʱ�ȭ �Ϸ� 
                        count_usec_e =0; // �ʱ�ȭ �Ǿ����� �ٽ� ������ 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 ��� ��� ����� 
                        next_state = IDLE; 
                        send_e =0; 
                        cnt_data = cnt_data +1; 
                    end
                    else begin  //busy=0 ��� ��� ����� �ƴ� 
                        send_buffer = SAMPLE_DATA +cnt_data ; //��ư���� ������ A,B,CD,...���� 
                        rs =1; //�����͸�� 
                        send_e =1; 
                    end           
                end
                MOVE_CUROSR : begin 
                   if(busy)begin   //busy =1 ��� ��� ����� 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 ��� ��� ����� �ƴ� 
                        send_buffer = 8'hc0 ; //��ư���� ������ A,B,CD,...���� 
                        rs =0; 
                        send_e =1; 
                    end           
                end
                SHIFT_DISPLAY:begin
                 if(busy)begin   //busy =1 ��� ��� ����� 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 ��� ��� ����� �ƴ� 
                        send_buffer = 8'h1c ; //cursor or display shift
                        rs =0; 
                        send_e =1; 
                    end           
                end
            endcase
        end
   end                                                           
endmodule 
