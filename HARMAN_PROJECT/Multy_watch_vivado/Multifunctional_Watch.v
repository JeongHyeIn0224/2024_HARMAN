`timescale 1ns / 1ps

   module multy_purpose_watch_1(
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
   assign {  cook_btn,stopw_btn,watch_btn} = (mode ==watch_mode ) ? { 7'b0, btn_pedge [2:0] } : //0000000bbb
                                              (mode == stop_watch_mode) ? {4'b0, btn_pedge[2:0] , 3'b0 } : // 0000bbb000
                                              {btn_pedge[3:0], 6'b0};
                                              
   
   assign value = (mode == cook_timer_mode ) ? cook_timer_value : 
                  (mode == stop_watch_mode ) ? stop_watch_value : 
                  watch_value;
                  
  fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));
 endmodule
 
 ///////////////////////////////loadable_Watch_top���� ����� ��Ʈ�Ѹ� �ϱ� ���� �и� ���� �׾ȿ��� ���ư��� ��� ����/////////////////////////////
module loadable_watch_1(
    input clk, reset_p, 
    input [2:0] btn_pedge,//��ư�� ������ ���� );
    output [15:0] value);
    
    wire sec_edge, min_edge;
    wire set_mode; //1�� �� setmode 0�� �� setmode�ƴ�   

    wire [3:0] cur_sec1,cur_sec10, set_sec1, set_sec10; //������ sec1�����ڸ�,10���ڸ�, ����sec�� 1���ڸ�, ����sec�� 10���ڸ� 
    wire [3:0] cur_min1,cur_min10, set_min1, set_min10; 
    wire [15:0] cur_time, set_time;

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
                                            .clk_time(btn_pedge[1]), //��ư ������ down_count ���� 
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
module loadable_watch_top_1(
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
                                
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value),  .seg_7_an(seg_7), .com(com)); 
      
endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//


/////////////////////////////stopwatch/////////////////////////////
module stop_watch_top_1(
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
 module stop_watch_csec_1(
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
module stop_watch_csec_top_1(
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
        .seg_7_an(seg_7), .com(com)); 

endmodule
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//�ֹ� Ÿ�̸� ��� //
module cook_timer_1( 
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
module cook_timer_top_1(
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

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com)); 

endmodule


//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//�ٿ�ī��Ʈ ����, decreasement clk ���� 
//0 0���� 59�� �� �� Ŭ���� �ϳ� �ٿ�Ǵ� �� ���� 
module loadable_down_counter_dec_60_1(
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
module loadable_down_counter_dec_60_min_sec_1(      //60�� loadable �ٿ� ī���� 4�ڸ�
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


 
 