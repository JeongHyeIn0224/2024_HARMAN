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
    
    wire [2:0] watch_btn, stopw_btn;// watch부분으로 드가는 부분 
    wire [3:0] cook_btn; 
    wire [15:0] value, watch_value, stop_watch_value, cook_timer_value;
    reg [2:0] mode; //001-watch mode, 010-stopw, 100-cook timer //3bit 필요 
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
 
 ///////////////////////////////loadable_Watch_top에는 입출력 컨트롤만 하기 위해 분리 따라서 그안에서 돌아가는 모듈 넣음/////////////////////////////
module loadable_watch_1(
    input clk, reset_p, 
    input [2:0] btn_pedge,//버튼의 엣지를 받음 );
    output [15:0] value);
    
    wire sec_edge, min_edge;
    wire set_mode; //1일 때 setmode 0일 때 setmode아님   

    wire [3:0] cur_sec1,cur_sec10, set_sec1, set_sec10; //현재의 sec1일의자리,10의자리, 셋팅sec의 1의자리, 셋팅sec의 10의자리 
    wire [3:0] cur_min1,cur_min10, set_min1, set_min10; 
    wire [15:0] cur_time, set_time;

    clock_min min_clk(clk, reset_p, sec_edge , clk_min);  

    loadable_counter_dec_60 cur_time_sec //현재 초 카운트 하는 모듈 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(clk_sec), 
                                            .load_enable(cur_time_load_en), 
                                            .set_value1(set_sec1), 
                                            .set_value10(set_sec10),
                                            .dec1(cur_sec1), 
                                            .dec10(cur_sec10));
    loadable_counter_dec_60 cur_time_min //현재 분 카운트 하는 모듈 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(clk_min), 
                                            .load_enable(cur_time_load_en), 
                                            .set_value1(set_min1), 
                                            .set_value10(set_min10),
                                            .dec1(cur_min1), 
                                            .dec10(cur_min10));                                          
     loadable_counter_dec_60 set_time_sec //세팅 초 카운트 하는 모듈 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(btn_pedge[1]), //버튼 누러야 down_count 시작 
                                            .load_enable(set_time_load_en), 
                                            .set_value1(cur_sec1), 
                                            .set_value10(cur_sec10),
                                            .dec1(set_sec1), 
                                            .dec10(set_sec10));     
      loadable_counter_dec_60 set_time_min //세팅 분 카운트 하는 모듈 
                                            (.clk(clk), 
                                            .reset_p(reset_p), 
                                            .clk_time(btn_pedge[2]), 
                                            .load_enable(set_time_load_en), 
                                            .set_value1(cur_min1), 
                                            .set_value10(cur_min10),
                                            .dec1(set_min1), 
                                            .dec10(set_min10));                                                  
    
 //value =0~9까지 표현 가능, ->4비트 필요 , but 4자리 필요하니까 16bit필요 
    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1};
    assign set_time = {set_min10, set_min1, set_sec10, set_sec1};
    
    assign value = set_mode ? set_time :cur_time ; //set_mode가 1이면 셋팅 값 출력, 0이면 시계 출력 
    
    T_flip_flop_p t1(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode)); //set_mode로 토글 시킴 

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(set_mode), .n_edge(cur_time_load_en), .p_edge(set_time_load_en)); //cur_time과 set_time의 엣지를 다르게 해야 함  
   
    assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
    assign min_edge = set_mode ? btn_pedge[2] : clk_min;
endmodule
 //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//시계를 셋팅에 불러와서 카운팅한 값을 시계에 덮어씌우는 모듈 //외부와의 연결을 담당 //
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
    //모듈의 입출력 변수 명을 생략할 수 있음 대신 순서는 맞춰야함 .을 찍으면 순서 바꿔도 상관없음 
    ////////////////////////////////////////////////////
    clock_usec usec_clk(clk_start, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec); //m clock //clk_start로 동작하게끔 함 
    
    clock_div_1000 sec_clk(clk_start,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk_start, reset_p, clk_sec, clk_min);  //1초 클럭을 60번 넣어서 clk_min 출력 
    
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_pedge[0])); //wire 이름만 btn_pedge 실제로는 n edge뽑아냄 
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(btn_pedge[2]));
      
     assign clk_start = start_stop ? clk : 0; // mux 만들기 
     //다 병렬로 동작하는 인스턴스 
    T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop)); 


    counter_dec_60 counter_sec( clk, reset_p, clk_sec, sec1, sec10); //하는 카운터
    counter_dec_60 counter_min( clk, reset_p, clk_min, min1, min10); 
   
  
    T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(lap_swatch)); 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 

////    PIPO reg :병렬입력 병렬출력 
 
    always @ (posedge clk or posedge reset_p) begin
        if(reset_p)lap_time =0;
        else if (lap_load) 
            lap_time= {min10, min1, sec10, sec1};
     end
/////     
     assign value = lap_swatch ? lap_time : {min10, min1, sec10, sec1};//1일 때 lap 나가고 0일때는 스톱워치니까  min~~~나감 
     
      fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value),
        .seg_7_an(seg_7), .com(com)); 

endmodule

//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
///////////////////////////// stop_watch_csec모듈 /////////////////////////////
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
    //모듈의 입출력 변수 명을 생략할 수 있음 대신 순서는 맞춰야함 .을 찍으면 순서 바꿔도 상관없음 
    ////////////////////////////////////////////////////
//      clock_usec usec_clk(clk_start, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
//    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec); //m clock //clk_start로 동작하게끔 함    
//    clock_div_10 csec_clk(clk_start,reset_p,clk_msec, clk_csec); //msec->10msec로    
//    clock_div_100 sec_clk(clk_start, reset_p, clk_csec, clk_sec);  //10msec를 100번 -> clk_sec 출력 

      clock_instance divide(.clk(clk_start), .reset_p(reset_p), .clk_csec(clk_csec), .clk_sec(clk_sec));      
     //다 병렬로 동작하는 인스턴스 
       T_flip_flop_p tff_start(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(start_stop)); 

     assign clk_start = start_stop ? clk : 0; // mux 만들기 

     counter_dec_100 counter_msec( clk, reset_p, clk_csec, csec1, csec10); //하는 카운터
     counter_dec_60 counter_sec( clk, reset_p, clk_sec, sec1, sec10); 

     T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_pedge[1]), .q(lap_swatch)); 
     edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(lap_swatch), .p_edge(lap_load)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 

     assign cur_time ={sec10, sec1,csec10, csec1};
     assign value = lap_swatch ? lap_time :cur_time;     //1일 때 lap 나가고 0일때는 스톱워치니까  min~~~나감 

////    PIPO reg :병렬입력 병렬출력 
 
    always @ (posedge clk or posedge reset_p) begin
        if(reset_p)lap_time =0;
        else if (lap_load) 
            lap_time= {sec10, sec1,csec10, csec1}; //lap_time은 여기서 정해짐 
     end
/////     
endmodule
 ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
/////////////////////////////stopwatch____100분의 1 /////////////////////////////
//버튼 입력받고 fnd 출력//
module stop_watch_csec_top_1(
    input clk, reset_p, 
    input [2:0] btn,
    output [3:0] com, 
    output [7:0] seg_7  );

     wire [2:0] btn_pedge;
     wire [15:0] value;
    
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //wire 이름만 btn_pedge 실제로는 n edge뽑아냄 
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
     
    stop_watch_csec( clk, reset_p, btn_pedge, value);
      
    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value),
        .seg_7_an(seg_7), .com(com)); 

endmodule
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//주방 타이머 모듈 //
module cook_timer_1( 
    input clk, reset_p, 
    input [3:0] btn_pedge,
    output [15:0] value,
    output [5:0] led,
    output buzz_clk);

    reg alarm;  
    wire btn_start, inc_sec, inc_min, alarm_off; //버튼 0번 1번 2번 3번
    wire [3:0] set_sec1, set_sec10, set_min1, set_min10; 
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; //     wire clk_usec , clk_msec, clk_sec, clk_min; 
    wire load_enable, dec_clk, clk_start; //clk_start : start했을 때만 클럭이 나오도록 함 
    reg start_stop;  
    wire [15:0] cur_time, set_time;       
    wire timeout_pedge;
    reg time_out;  
    
    assign {alarm_off, inc_min, inc_sec, btn_start } = btn_pedge; //btn_pedge가 인풋
    
     assign led[5] = start_stop; 
     assign led[4] = time_out; 
  
    assign clk_start = start_stop ?  clk : 0; //start(1) ->clk, stop(0) -> 0
  
//    clock_usec usec_clk(clk_start, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
//    clock_div_1000 msec_clk(clk_start,reset_p,clk_usec, clk_msec); //m clock //clk_start로 동작하게끔 함 
//    clock_div_1000 sec_clk(clk_start,reset_p,clk_msec, clk_sec); //
      clock_instance divide(.clk(clk), .reset_p(reset_p), .clk_msec(clk_msec), .clk_sec(clk_sec));

    //버튼 입력을 받는 count
    counter_dec_60 set_sec( clk, reset_p,inc_sec  ,set_sec1, set_sec10); 
    counter_dec_60 set_min( clk, reset_p,inc_min ,set_min1, set_min10); 
    
     //start or stop 상태 표현 tff
     //   T_flip_flop_p tff_lap(.clk(clk), .reset_p(reset_p), .t(btn_start), .q(start_stop)); 
     always @ (posedge clk or posedge reset_p)begin 
        if(reset_p) start_stop = 0; 
        else begin 
            if(btn_start) start_stop = ~start_stop; //start or stop 
            else if(timeout_pedge) start_stop = 0; //현재 시간이 0000이면 stop이 되도록 함 //1msec하고도 1클럭 후에 0이 됨 
        end
     end
 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 
    
 //스타트할 때 settime을 load해야함 load_enable그 엣지 잡아서 넣으면됨 
    loadable_down_counter_dec_60 cur_sec(clk, reset_p ,clk_sec ,load_enable,set_sec1,set_sec10 ,cur_sec1,cur_sec10 ,dec_clk);   
    loadable_down_counter_dec_60 cur_min(clk, reset_p ,dec_clk ,load_enable,set_min1,set_min10 ,cur_min1,cur_min10 ); 

    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) time_out =0; 
        else begin                                  //time_out =0 //0000초 
            if(start_stop &&clk_msec && cur_time ==0) time_out = 1; //start_stop 1, cut_time 0 이 되면 1msec 후에 time_out이 1이됨 그 엣지가지고 start_stop이 0이됨 ㅇ
            else  time_out = 0; //1msec에 한번씩 time_out을 0으로 clear 
        end
    end 

    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));  //time_out이 현재시간이 0일 때 1이됨 -> 그 타이밍이 timeout_pedge
    
//상승엣지 잡아서 1씩 깎음 스타트 상태에서 깎음 
 
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

    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1}; //현재 시간 
    assign set_time ={set_min10, set_min1, set_sec10, set_sec1};
    assign value = start_stop ? cur_time : set_time; 
    
    reg[16:0] clk_div = 0; 
    always @(posedge clk)clk_div = clk_div +1; 
    
    assign buzz_clk = alarm ? clk_div[14] :0;  //13은 8000~9000h정도  된다. 

endmodule
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// 주방 타이머 탑모듈 /////////////////////////////
module cook_timer_top_1(
    input clk, reset_p, 
    input [3:0] btn,
    output [3:0] com, 
    output [7:0] seg_7,
    output [5:0] led,
    output buzz_clk);
       
     wire btn_start, inc_sec, inc_min, alarm_off; //버튼 0번 1번 2번 3번
     wire [15:0] value;
     wire [3:0] btn_pedge;
     
     button_cntr btn_cntr0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //wire 이름만 btn_pedge 실제로는 n edge뽑아냄 
     button_cntr btn_cntr1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
     button_cntr btn_cntr2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
     button_cntr btn_cntr3 (.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btn_pedge[3]));

    cook_timer cook(clk,reset_p, btn_pedge, value, led, buzz_clk);

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com)); 

endmodule


//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//다운카운트 만듦, decreasement clk 만들 
//0 0에서 59가 될 때 클럭이 하나 다운되는 것 만듦 
module loadable_down_counter_dec_60_1(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //초, 분이니까 0~9까지 출력 -> 4bit 필요 
    output reg [3:0] dec1, dec10,
    output reg dec_clk);
    
    always @(posedge clk, posedge reset_p) begin
     if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
     end 
    else begin //else문 매클럭의 pos엣지 
        if(load_enable) begin // 1이면 외부에서 쓰는 카운터로 덮어씀 
            dec1 = set_value1;  // dec1 : 현재 일의자리에 출력되는 값 ( cur값 or setting값 이 들어올 수 있음)
            dec10 = set_value10;  //set_value : 내가 현재 셋팅한 값 (셋팅모드 -셋팅값 or 시게모드 - 시계값 이 들어올 수 있음) 
        end
        else if(clk_time) begin  //load_enable이 1이아니면 이전에 쓰던 60진 카운터와 같음 
                if(dec1 == 0) begin 
                   dec1 = 9; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                     if(dec10 == 0) begin
                         dec10 =5; 
                         dec_clk =1; //엣지 잡은 필요 없음 1cycle pulse 
                      end
                     else dec10 = dec10 - 1; 
                     end 
                     else dec1 = dec1 - 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
       end
       else dec_clk=0; //posedge 들어올 때 매 클럭마다 한클럭동안만 1이 됨 그 이후 0 
        end 
            
     end
endmodule
module loadable_down_counter_dec_60_min_sec_1(      //60진 loadable 다운 카운터 4자리
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


 
 