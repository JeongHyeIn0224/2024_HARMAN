`timescale 1ns / 1ps

/////////////////////////////////////////////////////////////////////
//동기식 = 같은 클럭 사용 
//업카운터 테스트 탑 + 링카운터 fnd 

module up_counter_test_top( 
    input clk, reset_p,
    output [7:0] seg_7,
    output  [15:0] count,
    output [3:0] com );
    
    reg [31:0] count_32;  //always문에서 쓰는 건 reg 붙여야 함 //16~31 쓸꺼니까 그 파형이 만들어 지려면 0부터 만들어져야함
     always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 그 안에 들어간게 조합회로 
        if(reset_p) count_32 = 0; //리셋 1이면 카운트를 0으로 클리어 
        else count_32 = count_32 + 1;
    end
    
    assign count = count_32[31:16]; //assign문에서 쓰는 카운트는 reg 지워야함 카운트의 16비트 출력이고 와이어임 
    
    ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
    reg [3:0] value; 
    //sensitive list 에 edge아닌 변수 들어 있으므로 case문은 mux가 됨 
    always @(com) begin  //sensitive list에 psedge clk 넣으면 순서논리 회로 순서가 posedge에 맞춰짐 
//    com이 드가면 조합논리회로 됨 모든 케이스 다 있어야해서  com이 들어갈 때만 default 써주기 안써주면 레벨트리거링으로 latch만들어짐 (pdt만들어져서 네거티브 슬랙발생) 
        case(com)
        4'b0111 : value = count_32[31:28]; //간격이 4라면 2의 4승까지 출력( value값이 hex_value랑 연결되어 있으니까 0~f까지 출력간ㅇ ) 
        //간격이 2라면 2의 2승까지 출력 ( 0~3까지 출력) 그리고 주기를 늘리기 위해 숫자를 늘린 것 
        //0인자리에서 켜지는 것임 천의자리 28번~31번 자리의 파형으로 (일의 자리 파형보다 느림) 
        4'b1011 : value = count_32[27:24];    //간격: 자릿수 ex. 3이면 2^3 , 숫자: 주기 길이 커질수록 주기 증가->느리게 동작 
        4'b1101 : value = count_32[23:20]; //0인자리에서 켜짐 일의자리 
        4'b1110 : value = count_32[19:16];   //빨리 돌게 하겠다. 
        default : value = count_32 [19:16]; 
       endcase
       //case문 조합논리회로 (combinational) mux가 만들어짐 
       
//           always @(posedge clk) begin  

//        case(com)
//        4'b0111 : value = count_32[31:28]; //간격이 4라면 2의 4승까지 출력( value값이 hex_value랑 연결되어 있으니까 0~f까지 출력간ㅇ ) 
//        //간격이 2라면 2의 2승까지 출력 ( 0~3까지 출력) 그리고 주기를 늘리기 위해 숫자를 늘린 것 
//        //0인자리에서 켜지는 것임 천의자리 28번~31번 자리의 파형으로 (일의 자리 파형보다 느림) 
//        4'b1011 : value = count_32[27:24];    
//        4'b1101 : value = count_32[23:20]; //0인자리에서 켜짐 일의자리 
//        4'b1110 : value = count_32[19:16];   //빨리 돌게 하겠다. 
//       endcase
       
    end
    decoder_7seg fnd(.hex_value(value), .seg_7(seg_7));
 endmodule
 


//깜빡이는 LED만들기
module led_bar_top (
    input clk, reset_p,
    output [7:0]led_bar);
    
    reg [28:0] clk_div; 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) clk_div = 0;
        else clk_div = clk_div +1;
    end

        assign led_bar= ~clk_div[28:21]; //출력이 0일 때 켜지는데 1일 때 켜지게끔 바꾸기 

endmodule


////////////////////////////////////////////////////////////////////////////////
//버튼 컨트롤러모듈을 사용하지 않고 엣지 디텍터로 만든 모듈 
//버튼과 clk은 완전히 독립적 , edge detector 사용하면  clk을 사용할 수 있음 
//basys3 자체의 업 버튼 입력을 받아 fnd에 출력 하는 카운터 // 엣지 디텍터를 사용하여 clk을 동기로 만듦 채터링방지 하기 위해 주파수 분주기 사용 
module button_test_top(
 input clk, reset_p, 
 input btn,
 output [7:0] seg_7,
 output [3:0] com); //전부 on ->an ->설정 안함 

    reg [15:0] btn_counter ; //4bit짜리 버튼 카운터  
    reg [3:0] value; 
    wire btnU_pedge;
    reg [16:0] clk_div =0 ; //분주기 만들기 
    wire clk_div_16; 
    reg debounced_btn;
    
    //[16:0] clk_div의 출력값 clk_div_16; 

    always @(posedge clk) clk_div = clk_div +1; //clk에 의해 동작하는 분주기 
  
  
    always @(posedge clk, posedge reset_p) begin //채터링 방지하기 위해 분주기로 1ms로 주기를 바꿈 
        if(reset_p) debounced_btn = 0; 
        else if (clk_div_16) debounced_btn = btn;
    end
    
 edge_detector_n ed1(.clk( clk) , 
                     .reset_p(reset_p),//버튼 입력을 clk의 동기로 받기 위해 edge detector랑 연결 
                     .cp(clk_div[16]), 
                     .p_edge(clk_div_16));            //up 
        
    
edge_detector_n ed2(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn),
                    .p_edge(btnU_pedge)); //down 
         
     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge) btn_counter = btn_counter +1;
         end  
      end
        
//        else begin
//            if(btnU_pedge)
//            btn_counter = btn_counter +1; //버튼 누를 때마다 1씩 증가 //account만듦 
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
    
    
    //fnd출력 
endmodule

module button_cntr_for_top(
 input clk, reset_p, 
 input [3:0] btn,
 output [7:0] seg_7,
 output [3:0] com); //전부 on ->an ->설정 안함 

    reg [15:0] btn_counter ; //4bit짜리 버튼 카운터 
    wire [3:0] btnU_pedge;
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0])); 
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1])); 
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2])); 
//     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3])); 

    genvar i; //회로는 만들어지지 않음 이 안에서 반복하기 위해 쓰임 
    generate 
        for(i=0; i<4; i=i+1) begin :btn_cntr //genblk 이름 설정하기 
            button_cntr btn_inst (.clk(clk), .reset_p(reset_p), .btn(btn[i]), .btn_pe(btnU_pedge[i]));
        end
    endgenerate

  fnd_4digit_cntr(.clk(clk),  //출력 시 필요한 fnd 컨트롤러 모듈 불러옴 
                  .reset_p(reset_p), 
                  .value(btn_counter), 
                  .seg_7_an(seg_7), //ca(캐소드타입)-1일 때켜짐
                  .com(com));        
                  
                   
       //이 always문 만 만들어서  count만 해주면 된다. 나머지는 다 인스턴스로 부러옴             
     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter +1;
            else if (btnU_pedge[1]) btn_counter = btn_counter -1;
            else if (btnU_pedge[2])  btn_counter = {btn_counter[14:0], btn_counter[15]}; //좌시프트
            else if (btnU_pedge[3])  btn_counter = {btn_counter[0] ,btn_counter[15:1]}; //우시프트 
         end  
      end
    
    //fnd출력 
endmodule
 

 //////////////////
 //16비트짜리 카운트 추가 fnd에 ㅊㄹ력 키입력이 1이면 
// keyvalid의 엣지에서 증가 감소하는 코드 추가 
// 카운트 값 fndㅇ ㅔㅔ 출력 
 
 //탑모듈의 col은 와이어 
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
  
  //결합연산자로 16비트 받기 
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(key_counter), 
        .seg_7_ca(seg_7), .com(com)); 
        
endmodule

//set버튼을 누르면 버튼입력을 받아 count하고  다시 누르면 원래의 min과 sec의 clk을 받는 회로)
module watch_top2(
    input clk, reset_p,
    input [2:0] btn, 
    output [3:0] com,
    output [7:0] seg_7);

    wire clk_usec , clk_msec, clk_sec, clk_min; 
    //모듈의 입출력 변수 명을 생략할 수 있음 대신 순서는 맞춰야함 .을 찍으면 순서 바꿔도 상관없음 
    ////////////////////////////////////////////////////
    clock_usec usec_clk(clk, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk,reset_p,clk_usec, clk_msec); //m clock
    
    clock_div_1000 sec_clk(clk,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk, reset_p, sec_in, clk_min);  //1초 클럭을 60번 넣어서 clk_min 출력 
    
    /////////////////////////4 clk씩 밀림 but''누적이 되진 않음 .
    
    wire [3:0] sec1, sec10 , min1, min10; //4자리 받음 
    
    counter_dec_60 counter_sec( clk, reset_p, sec_in , sec1, sec10);//초를 카운터하는 카운터
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


//시계를 셋팅에 불러와서 카운팅한 값을 시계에 덮어씌우는 모듈 
//ver.professor
module watch_top(
    input clk, reset_p,
    input [2:0] btn, 
    output [3:0] com,
    output [7:0] seg_7);

    wire clk_usec , clk_msec, clk_sec, clk_min; 
    //모듈의 입출력 변수 명을 생략할 수 있음 대신 순서는 맞춰야함 .을 찍으면 순서 바꿔도 상관없음 
    ////////////////////////////////////////////////////
    clock_usec usec_clk(clk, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk,reset_p,clk_usec, clk_msec); //m clock
    
    clock_div_1000 sec_clk(clk,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk, reset_p, sec_edge, clk_min);  //1초 클럭을 60번 넣어서 clk_min 출력 
    
    
    wire [3:0] sec1, sec10 , min1, min10; //4자리 받음 
    
    counter_dec_60 counter_sec( clk, reset_p, sec_edge, sec1, sec10); 
    counter_dec_60 counter_min( clk, reset_p, min_edge, min1, min10); 

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value({min10, min1, sec10, sec1}),
        .seg_7_an(seg_7), .com(com)); 
        
       wire [2:0] btn_pedge;
     button_cntr cn0 (.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0]));
     button_cntr cn1 (.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1]));
     button_cntr cn2 (.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btn_pedge[2]));
 

     
     wire set_mode; //1일 때 setmode 0일 때 setmode아님  
     wire sec_edge, min_edge;
     T_flip_flop_p t1(.clk(clk), .reset_p(reset_p), .t(btn_pedge[0]), .q(set_mode));
  
   assign sec_edge = set_mode ? btn_pedge[1] : clk_sec;
   assign min_edge = set_mode ? btn_pedge[2] : clk_min;
      

endmodule
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//클럭 모듈 만들어서 clock에 모듈 사용하기
module clock_instance (
    input clk,reset_p,
    output clk_msec, clk_csec, clk_sec, clk_min);

    clock_usec usec_clk(clk, reset_p, clk_usec); //clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    clock_div_1000 msec_clk(clk,reset_p,clk_usec, clk_msec); //m clock
    
    clock_div_10 csec_clk(clk, reset_p,clk_msec, clk_csec); //msec->10msec로 
    
    clock_div_1000 sec_clk(clk,reset_p,clk_msec, clk_sec); //sec clock
    
    clock_min min_clk(clk, reset_p, clk_sec , clk_min);  //1초 클럭을 60번 넣어서 clk_min 출력 
   
endmodule  
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//

///////////////////////////////loadable_Watch_top에는 입출력 컨트롤만 하기 위해 분리 따라서 그안에서 돌아가는 모듈 넣음/////////////////////////////
module loadable_watch(
    input clk, reset_p, 
    input [2:0] btn_pedge,//버튼의 엣지를 받음 );
    output [15:0] value);
    
    
   // wire clk_usec , clk_msec, clk_sec, clk_min; 
    wire sec_edge, min_edge;
    wire set_mode; //1일 때 setmode 0일 때 setmode아님   

    wire [3:0] cur_sec1,cur_sec10, set_sec1, set_sec10; //현재의 sec1일의자리,10의자리, 셋팅sec의 1의자리, 셋팅sec의 10의자리 
    wire [3:0] cur_min1,cur_min10, set_min1, set_min10; 
    wire [15:0] cur_time, set_time;

    clock_instance divide(.clk(clk), .reset_p(reset_p), .clk_sec(clk_sec)); 
    
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
                                            .clk_time(btn_pedge[1]), 
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
module stop_watch_csec_top(
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
        .seg_7_ca(seg_7), .com(com)); 

endmodule
//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//주방 타이머 모듈 //
module cook_timer( 
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
module cook_timer_top(
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

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com)); 

endmodule


//---------------------------------------------------------------------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------------------------------------------//
//다운카운트 만듦, decreasement clk 만들 
//0 0에서 59가 될 때 클럭이 하나 다운되는 것 만듦 
module loadable_down_counter_dec_60(
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

//----------------------------------------------------------------------------------------//
///////////////////타인 ver. ------------------------------------------------------------
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
    //분주기
    clock_usec usec_clk(clk, reset_p, clk_usec);
    clock_div_1000 msec_clk(clk, reset_p, clk_usec, clk_msec);
    clock_div_1000 sec_clk(clk, reset_p, clk_msec, clk_sec);
    clock_min min_clk(clk, reset_p, clk_sec, clk_min);
    //버튼 컨트롤러
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
    //60진 카운터
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



module loadable_down_counter_dec_60_min_sec(      //60진 loadable 다운 카운터 4자리
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
// /////////////////////////다기능 시계 만들기 ////////////////////////////////////////////
 
 module multi_watch (
    input clk, reset_p,
    input [3:0] btn ,
    input mode_btn, //5번 버튼 
    output [3:0] com,
    output [7:0] seg_7 ,
    //output buzz_clk,
    output [8:0] led );
 
  reg [2:0] mode;
  
  assign led [8:6] = mode; //ringcounter가 돌 때마다 led를 표시하도록 한다. 
  
    wire select_mode; 
    button_cntr btn_cntr(.clk(clk), .reset_p(reset_p), .btn(mode_btn), .btn_pe(select_mode));

    always @ (posedge clk or posedge reset_p) begin 
        if(reset_p) mode = 3'b001;  //리셋 했을 때 0001 (com이 애노드 타입인데 그 앞에 not이 붙어 있으므로 0을 줘야 켜짐 ) 
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
    assign watch_btn =  ( mode == 3'b001) ? btn : 0; // [3:0] btn을 watch_top과 연결 
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
// /////////////////////////다기능 시계 만들기 모듈 나누지 않은 버전 ver.professor ////////////////////////////////////////////
module multye_watch_no_top_divide(
    input clk, reset_p, 
    input [4:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output buzz_clk);
    
    parameter watch_mode = 3'b001;
    parameter stop_watch_mode = 3'b010; 
    parameter cook_timer_mode = 3'b100;
    
    wire [2:0] watch_btn, stopw_btn;// watch부분으로 드가는 부분 
    wire [3:0] cook_btn; 
    
    wire [3:0] watch_com, stopw_com, cook_com; //fnd로 나오는com
    wire [7:0] watch_seg7, stopw_seg7, cook_seg7; //fnd로 나오는 seg7
    reg [2:0] mode; //001-watch mode, 010-stopw, 100-cook timer //3bit 필요 
    
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
  
  
// /////////////////////////다기능 시계 만들기 모듈 나눈것들 합친 부분  ////////////////////////////////////////////
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
   assign {  cook_btn,stopw_btn,watch_btn} = (mode ==watch_mode ) ? {7'b0, btn_pedge [2:0] } : //0000000bbb
                                              (mode == stop_watch_mode) ? {4'b0, btn_pedge[2:0] , 3'b0 } : // 0000bbb000
                                              {btn_pedge[3:0], 6'b0};
                                              
   
   assign value = (mode == cook_timer_mode ) ? cook_timer_value : 
                  (mode == stop_watch_mode ) ? stop_watch_value : 
                  watch_value;
                  
  fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(value), .seg_7_ca(seg_7), .com(com));
 endmodule
 
  module dht11_top( //16진수로 출력되는거지만 읽는 건 10진수로 읽으면 
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
   
    wire [11:0] distance; //bin_to_dec의 bindl 12bit라 맞춰주기 위함 
    wire [15:0] bcd_dist; //bcd가 16bit라 맞춰주기 위함 
     bin_to_dec dis(.bin(distance), .bcd(bcd_dist));
     fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_dist), .seg_7_an(seg_7), .com(com));
              
    ultrasonic ultra(clk, reset_p, echo, trigger, distance, led_bar);
    
 endmodule
 
 
 ////////////////////////LED밝기 제어 ///////////////////////////
 
 module led_pwm_top(
    input clk, reset_p,
    output [3:0] led_pwm);
    
    reg [27:0] clk_div; 
    always @(posedge clk) clk_div = clk_div +1; 
    //duty 0~ 63% 조절 -> 6bit 
    pwm_128step pwm_r(.clk(clk), . reset_p(reset_p), .duty(clk_div[27:21]), .pwm_freq(10_000), .pwm_128(led_pwm[0])); 
    
    pwm_128step pwm_g(.clk(clk), . reset_p(reset_p), .duty(clk_div[26:20]), .pwm_freq(10_000), .pwm_128(led_pwm[1])); 
    
    pwm_128step pwm_b(.clk(clk), . reset_p(reset_p), .duty(clk_div[25:19]), .pwm_freq(10_000), .pwm_128(led_pwm[2])); 

    pwm_128step pwm_osiro(.clk(clk), . reset_p(reset_p), .duty(clk_div[27:21]), .pwm_freq(10_000), .pwm_128(led_pwm[3])); 
    //7bit로 늘림 -> 128단계 제어 처음부터 끝까지 단계 모두 보기 위해 
endmodule
//----------------------------------------------------------------------------------------------------------------//
//////////////////////////////////////////////////////////모터 제어////////////////////////////////////////////////
module dc_motor_pwm_top (
    input clk, reset_p, 
    output motor_pwm); //for speed control);

    reg [32:0] clk_div; //27:0 으로 하면 속도가 빨라서 안보임 
    always @(posedge clk) clk_div = clk_div +1;

    pwm_128step pwm_motor (.clk(clk), .reset_p(reset_p), .duty(clk_div[32:26]), .pwm_freq(1_00), .pwm_128(motor_pwm)); //clk_div에 7bit를 줌 128까지 단계적으로 보기 위해 
endmodule


//------------------------------------------------------------------------------------------------------------------------------------------------//
//////////////////////////////////////////////////////////pwm을 이용하여 sg90 다기능 서보모터 만들기////////////////////////////////////////////////
module servo_motor_pwm_top_1 (
     input clk, reset_p, 
     input [3:0] btn,
    output motor_pwm,
    output [7:0] seg_7,
    output [3:0] com); //for speed control);

    reg [32:0] clk_div; //27:0 으로 하면 속도가 빨라서 안보임 
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
        else if( btn_ne[0])  duty=19; //0도 
        else if( btn_ne[1])  duty=32; //90도 
        else if( btn_ne[2])  duty=6; //90도     
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
    pwm_256step_servomotor pwm_motor (.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_256(motor_pwm)); //clk_div에 7bit를 줌 128까지 단계적으로 보기 위해 
endmodule

//------------------------------------------------------------------------------------------------------//
//512해상도사용한 서보모터 //
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
    
    reg [8:0] duty;  //32bit표현 위해 
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
            if(duty >=  64) up_down = 0;           //up_down = 0 ( down) -> 1감소 
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
  
  
  
  //////512해상도사용한 서보모터 //
module servo_sg90_period( //승범님이 하신걸로 
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
    
    reg [20:0] duty;  //32bit표현 위해 
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
            if(duty >=  256_000) up_down = 0;           //200M 의 10% = 20만 200_000
            else if(duty <=52_000) up_down =1;         //100_000
        
             if(up_down) duty =duty +1; 
              else duty = duty -1;    
       end
   end
   
   wire [15:0] bcd_duty;
    pwm_512_period servo(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_period(200_000_000), .pwm_512(sg90)); //주기만 계산해서 넣으면됨 
    bin_to_dec dist(.bin(duty[20:10]), .bcd(bcd_duty));//duty[20:10]- bin에 넣을 때 duty를 1024로 나누기 위해 10비트 시프트 
    //58000/1024 =56.6  256000 / 1024 = 250 
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_duty), .seg_7_an(seg_7), .com(com)); 
  endmodule


//----------------------------------------------------------------------------------------------------------------//
//adc를 이용한 led밝기 제어 

module adc_top (
    input clk, reset_p,
    input vauxp6, vauxn6,
    output [3:0] com,
    output [7:0] seg_7,
    output led_pwm);
    
    wire [4:0] channel_out; 
    wire eoc_out; 
    wire [15:0] do_out;     //상위 12만 디지털 값 
    
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
          .eoc_out(eoc_out)     //아날로그값 -> 디지털로 변환하는 converting이 끝날 때 1이됨  // End of Conversion Signal
//          eos_out,             // End of Sequence Signal
//          alarm_out,           // OR'ed output of all the Alarms    
//          vp_in,               // Dedicated Analog Input Pair
//          vn_in
 );
    wire eoc_out_pedge; 
     edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(eoc_out), .p_edge(eoc_out_pedge)); // eoc_out이 1떴을 때 작동하게 하기 위해 pos edge 잡음 
     
     reg[11:0] adc_value; 
     always @(posedge clk or posedge reset_p) begin
        if(reset_p) adc_value =0; 
        else if(eoc_out_pedge)  //posedge 떴을 때만 do_out을 adc_value에 저장 
            adc_value ={4'b0, do_out[15:8]}; //[15:4]정밀도  /4 가변저항으로 뜨는 최댓값 4000, 15:6함으로써 900~1000정도가 뜸 //정밀도 8bit     
     end
     
    wire [15:0] bcd_value; 
    bin_to_dec adc_bcd(.bin(adc_value), .bcd(bcd_value)); //12bit표현 
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_value), .seg_7_an(seg_7), .com(com)); 
    pwm_128step pwm_led(.clk(clk), .reset_p(reset_p), .duty(do_out[15:9]), .pwm_freq(10_000), .pwm_128(led_pwm));  //duty(adc_value[11:5])

endmodule


//----------------------------------------------------------------------------------------------------------------//
//조이스틱을 이용하여 2개의 adc제어 사용 

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
          .den_in(eoc_out),     //converting 끝나면 enable1 될 수 있도록 eoc_out과 연결          // Enable Signal for the dynamic reconfiguration port
          .reset_in(reset_p),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
          .vauxp15(vauxp15),             // Auxiliary channel 15
          .vauxn15(vauxn15),
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
          .eoc_out(eoc_out),             //컨버팅 끝났을 때 채널 값 받아서 저장// End of Conversion Signal
          .eos_out(eos_out)             // End of Sequence Signal
     );

//eoc_out이 떴을 때 읽을거다. 
     edge_detector_n ed_eoc(.clk(clk), .reset_p(reset_p), .cp(eoc_out), .p_edge(eoc_out_pedge)); // eoc_out이 1떴을 때 작동하게 하기 위해 pos edge 잡음 
     
 /*    reg [6:0] duty_x, duty_y; 
     edge_detector_n ed_eos(.clk(clk), .reset_p(reset_p), .cp(eos_out), .p_edge(eos_out_pedge)); // eoc_out이 1떴을 때 작동하게 하기 위해 pos edge 잡음 
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

     //아깐 하나니까 eoc_out떴을 때 adc_value에 저장하면됬는데 이젠 2개니까 2개만들자. 
     reg[11:0] adc_value_x, adc_value_y; 
     always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            adc_value_x =0; 
            adc_value_y =0;            
         end    //채널이 6이냐 15냐에 따라 채널이 달라짐 
         else if(eoc_out_pedge)begin
             case(channel_out[3:0]) //[3:0]안해주면 4:0으로 되가지고 채널 6이안되고 22, 31이 됨 
                 6 : adc_value_y = {4'b0, do_out[15:10]};
                 15 : adc_value_x = {4'b0, do_out[15:10]};
             endcase
         end      
     end
        wire [15:0] bcd_value_x,bcd_value_y;
        bin_to_dec adc_x_bcd(.bin(adc_value_x), .bcd(bcd_value_x)); //12bit표현 
        bin_to_dec adc_y_bcd(.bin(adc_value_y), .bcd(bcd_value_y)); //12bit표현 

    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value({bcd_value_x[7:0], bcd_value_y[7:0]}), .seg_7_an(seg_7), .com(com)); 
    ///vrx= 6번, //vry = 15번 x, y, gnd 
    
    //duty 7비트 줘야함 최하위비트부터 7비트 잘라야 
   pwm_128step pwm_led_r(.clk(clk), .reset_p(reset_p), .duty(adc_value_x[6:0]), .pwm_freq(10_000), .pwm_128(led_r));  //duty(adc_value[11:5])
   pwm_128step pwm_led_g(.clk(clk), .reset_p(reset_p), .duty(adc_value_y[6:0]), .pwm_freq(10_000), .pwm_128(led_g));  //duty(adc_value[11:5])

    wire led_r_b, led_g_b;
    assign led_r_b = led_r;
    assign led_g_b = led_g; 
endmodule



//I2C통신 0번버튼 -0000000  보냄, 1번버튼 - 11111111 : BT에 1되면 on, 1되면 off 
module I2C_master_top(
    input clk, reset_p,
    input [1:0] btn,
    output sda, scl
);
    reg [7:0] data;
    reg valid; //i2c통신의 인터페이스 ( 시작했다 끝났다) 
    
    //rd_wr = 0 (write) //우리는 지금 slave하나만 쓸거니까 하나의 주소만 사용한다 27 
    I2C_master mater( .clk(clk), .reset_p(reset_p), .rd_wr(0), .addr(7'h27), .data(data),
     .valid(valid), .sda(sda), .scl(scl)); 
    //0번버튼 누르면 data에 0*8개 주고 0*8개 날아감 
    
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
                valid = 1; //valid가 들어왔을 때 start 
            end
            else if(btn_nedge[0]) valid =0; //valid빠져나가기 위해 nedge뽑음 
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
////ic2통신을 이용하여 textLCD패널에 출력하기  

module i2c_txtlcd_top(
    input clk, reset_p,
    input btn, 
    output scl, sda);

    parameter IDLE = 6'b00_0001; 
    parameter INIT = 6'b00_0010; 
    parameter SEND = 6'b00_0100; 
    
    parameter SAMPLE_DATA = "A";    //A의 아스키 코드 값으로 저장됨 
    
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
    
    //usec counter 기준 클럭 만들기 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //이렇게 해야 다음ㅋㄹ럭이 아니라 바로 네거에지에서 클리어됨 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1말고 다른 수도 올 수 있지만 일반적으로 flag라 하면 true false로만 사용 
    reg init_flag; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
   always @(posedge clk or posedge reset_p) begin //textLCD다루는 모듈 만들자 
        if(reset_p) begin //초기화에서 i2c_led_send_byte랑 이은 부분 초기화 해줘야함 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //명령보내는 것 
            send_e =0; 
            init_flag =0; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
        end
        else begin
            case(state) 
                IDLE : begin   //시작하면 바로 초기화  //그 이후는 버튼의 pedge가 뜨면 send를 한다. 
                    if(init_flag) begin //처음이 0 init state다녀오면 1이됨 -> 초기화가 완료됨 
                        if(btn_pedge) next_state =SEND; 
                    end
                    else begin
                        if(count_usec <=22'd80_000) begin//40ms = 40_000us //usec가 기준클럭임 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == 초기화 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms기다림 (200us*5번= 1ms보다 더 크게 준 것)  //이미 보내고 있음 다른 것들 못 보내게 이 시간 동안 보내는 거 
                        send_buffer = 8'h33;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us동안 send_e =0
                    else if(count_usec <= 22'd2010)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h32;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us동안 send_e =0
                    else if(count_usec <= 22'd3020)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h28;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h0c;    //08주면 display off됨 
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h01;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //초기화 
                    else if(count_usec <= 22'd6050)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h06;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT다음 state다시 IDLE
                        init_flag = 1; //초기화 완료 
                        count_usec_e =0; // 초기화 되었으니 다시 꺼주자 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 통신 모듈 사용중 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 통신 모듈 사용중 아님 
                        send_buffer =SAMPLE_DATA;// 8'h41;//+cnt_data ; //버튼누를 때마다 A,B,CD,...찍힘 
                        rs =1; //보낼거야????
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
    
    parameter SAMPLE_DATA = "A";    //A의 아스키 코드 값으로 저장됨 
    
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
    
    //usec counter 기준 클럭 만들기 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //이렇게 해야 다음ㅋㄹ럭이 아니라 바로 네거에지에서 클리어됨 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1말고 다른 수도 올 수 있지만 일반적으로 flag라 하면 true false로만 사용 
    reg init_flag; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
   reg [3:0] cnt_data;///////////////////////////////////////////////////////////////////////////////////                             
   always @(posedge clk or posedge reset_p) begin //textLCD다루는 모듈 만들자 
        if(reset_p) begin //초기화에서 i2c_led_send_byte랑 이은 부분 초기화 해줘야함 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //명령보내는 것 
            send_e =0; 
            init_flag =0; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
            cnt_data =0; ///////////////////////////////////////////////////////////////////////////////////   
        end
        else begin
            case(state) 
                IDLE : begin   //시작하면 바로 초기화  //그 이후는 버튼의 pedge가 뜨면 send를 한다. 
                    if(init_flag) begin //처음이 0 init state다녀오면 1이됨 -> 초기화가 완료됨 
                        if(btn_pedge) next_state =SEND; 
                    end
                    else begin
                        if(count_usec <=22'd40_000) begin//40ms = 40_000us //usec가 기준클럭임 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == 초기화 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms기다림 (200us*5번= 1ms보다 더 크게 준 것)  //이미 보내고 있음 다른 것들 못 보내게 이 시간 동안 보내는 거 
                        send_buffer = 8'h33;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us동안 send_e =0
                    else if(count_usec <= 22'd2010)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h32;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us동안 send_e =0
                    else if(count_usec <= 22'd3020)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h28;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h0C;    //08주면 display off됨 
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h01;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //초기화 
                    else if(count_usec <= 22'd6050)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h06;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT다음 state다시 IDLE
                        init_flag = 1; //초기화 완료 
                        count_usec_e =0; // 초기화 되었으니 다시 꺼주자 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 통신 모듈 사용중 
                        next_state = IDLE; 
                        send_e =0; 
                        cnt_data = cnt_data +1; 
                    end
                    else begin  //busy=0 통신 모듈 사용중 아님 
                        send_buffer = SAMPLE_DATA +cnt_data ; //버튼누를 때마다 A,B,CD,...찍힘 
                        rs =1; //보낼거야????
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
    
    parameter SAMPLE_DATA = "A";    //A의 아스키 코드 값으로 저장됨 
    
    wire [2:0 ]btn_pedge ; 
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //누르면 SEND STATE로
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1])); //누르면 MOVE_CUROSR로 
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
    
    //usec counter 기준 클럭 만들기 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //이렇게 해야 다음ㅋㄹ럭이 아니라 바로 네거에지에서 클리어됨 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(negedge clk, posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1말고 다른 수도 올 수 있지만 일반적으로 flag라 하면 true false로만 사용 
    reg init_flag; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
   reg [3:0] cnt_data;///////////////////////////////////////////////////////////////////////////////////                             
   always @(posedge clk or posedge reset_p) begin //textLCD다루는 모듈 만들자 
        if(reset_p) begin //초기화에서 i2c_led_send_byte랑 이은 부분 초기화 해줘야함 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //명령보내는 것 
            send_e =0; 
            init_flag =0; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
            cnt_data =0; ///////////////////////////////////////////////////////////////////////////////////   
        end
        else begin
            case(state) 
                IDLE : begin   //시작하면 바로 초기화  //그 이후는 버튼의 pedge가 뜨면 send를 한다. 
                    if(init_flag) begin //처음이 0 init state다녀오면 1이됨 -> 초기화가 완료됨 
                        if(btn_pedge[0]) next_state =SEND; 
                        else if(btn_pedge[1]) next_state = MOVE_CUROSR; //두번 재 줄에 첫번째 자리로 옮기는 명령어 
                    end
                    else begin
                        if(count_usec <=22'd40_000) begin//40ms = 40_000us //usec가 기준클럭임 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == 초기화 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms기다림 (200us*5번= 1ms보다 더 크게 준 것)  //이미 보내고 있음 다른 것들 못 보내게 이 시간 동안 보내는 거 
                        send_buffer = 8'h33;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us동안 send_e =0
                    else if(count_usec <= 22'd2010)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h32;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us동안 send_e =0
                    else if(count_usec <= 22'd3020)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h28;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h0C;    //08주면 display off됨 
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h01;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //초기화 
                    else if(count_usec <= 22'd6050)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h06;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT다음 state다시 IDLE
                        init_flag = 1; //초기화 완료 
                        count_usec_e =0; // 초기화 되었으니 다시 꺼주자 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 통신 모듈 사용중 
                        next_state = IDLE; 
                        send_e =0; 
                        cnt_data = cnt_data +1; 
                    end
                    else begin  //busy=0 통신 모듈 사용중 아님 
                        send_buffer = SAMPLE_DATA +cnt_data ; //버튼누를 때마다 A,B,CD,...찍힘 
                        rs =1; //보낼거야????
                        send_e =1; 
                    end           
                end
                MOVE_CUROSR : begin 
                   if(busy)begin   //busy =1 통신 모듈 사용중 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 통신 모듈 사용중 아님 
                        send_buffer = 8'hc0 ; //두번째줄에서 첫번째로 옮겨짐 
                        rs =0; 
                        send_e =1; 
                    end           
                end
            endcase
        end
   end                                                           
endmodule 

//1byte의 data를 4bit씩 두번 보내주는 것 
//busy는 컨트롤러에서 보내주는 것(얘네 4ibt씩 보내고 있으니까 ,send_e는 top자체에서 모듈이 된다 안된다를 판단하는 것) 
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
    
    parameter SAMPLE_DATA = "A";    //A의 아스키 코드 값으로 저장됨 
    
    wire [2:0 ]btn_pedge ; 
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge[0])); //누르면 SEND STATE로
    button_cntr btn_cntr1(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btn_pedge[1])); //누르면 MOVE_CUROSR로 
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
    
    //usec counter 기준 클럭 만들기 
    always @(negedge clk , posedge reset_p) begin
        if(reset_p) begin
            count_usec =0; 
        end
        else  begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
            else if(!count_usec_e) count_usec = 0;  //이렇게 해야 다음ㅋㄹ럭이 아니라 바로 네거에지에서 클리어됨 
        end
    end 
   
   //state reg
    reg [5:0] state, next_state; 
    always @(posedge clk, posedge reset_p) begin //negedge
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end                            
                    //0,1말고 다른 수도 올 수 있지만 일반적으로 flag라 하면 true false로만 사용 
    reg init_flag; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
   reg [3:0] cnt_data;   //한 줄에 16개의 문자 들어가                   
   always @(posedge clk or posedge reset_p) begin //textLCD다루는 모듈 만들자 
        if(reset_p) begin //초기화에서 i2c_led_send_byte랑 이은 부분 초기화 해줘야함 
            next_state = IDLE; 
            send_buffer =0; 
            rs = 0; //명령보내는 것 
            send_e =0; 
            init_flag =0; //IDLE에서 초기화가 되었는지 안되었는지 표기하는 변수 
            cnt_data =0;  
        end
        else begin
            case(state) 
                IDLE : begin   //시작하면 바로 초기화  //그 이후는 버튼의 pedge가 뜨면 send를 한다. 
                    if(init_flag) begin //처음이 0 init state다녀오면 1이됨 -> 초기화가 완료됨 
                        if(btn_pedge[0]) next_state =SEND; 
                        else if(btn_pedge[1]) next_state = MOVE_CUROSR; //두번 재 줄에 첫번째 자리로 옮기는 명령어 
                        else if(btn_pedge[2]) next_state = SHIFT_DISPLAY; //두번 재 줄에 첫번째 자리로 옮기는 명령어 
                    end
                    else begin
                        if(count_usec <=22'd40_000) begin//40ms = 40_000us //usec가 기준클럭임 
                            count_usec_e=1; //count start 
                        end
                        else begin
                            next_state = INIT; 
                            count_usec_e =0; //count stop == 초기화 
                         end
                    end
                end
                INIT : begin
                    if(count_usec <= 22'd1000)begin //5ms기다림 (200us*5번= 1ms보다 더 크게 준 것)  //이미 보내고 있음 다른 것들 못 보내게 이 시간 동안 보내는 거 
                        send_buffer = 8'h33;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd1010) send_e = 0;  //10us동안 send_e =0
                    else if(count_usec <= 22'd2010)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h32;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd2020) send_e = 0; //10us동안 send_e =0
                    else if(count_usec <= 22'd3020)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h28;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd3030) send_e = 0; 
                    else if(count_usec <= 22'd4030)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h0f;  //oc  //08주면 display off됨 //깜빡이게됨 
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd4040) send_e = 0; 
                    else if(count_usec <= 22'd5040)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h01;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd5050) send_e = 0; //초기화 
                    else if(count_usec <= 22'd6050)begin //1010부터 2010까지 시간을 보냄 
                        send_buffer = 8'h06;
                        send_e =1; //이 때부터 5번 보내겠다. 200us * 5번 -> 1ms 걸림  
                        count_usec_e =1; 
                    end
                    else if(count_usec <=22'd6060) send_e = 0; 
                    else begin 
                        next_state = IDLE; //INIT다음 state다시 IDLE
                        init_flag = 1; //초기화 완료 
                        count_usec_e =0; // 초기화 되었으니 다시 꺼주자 
                    end
                end
                SEND : begin
                    if(busy)begin   //busy =1 통신 모듈 사용중 
                        next_state = IDLE; 
                        send_e =0; 
                        cnt_data = cnt_data +1; 
                    end
                    else begin  //busy=0 통신 모듈 사용중 아님 
                        send_buffer = SAMPLE_DATA +cnt_data ; //버튼누를 때마다 A,B,CD,...찍힘 
                        rs =1; //데이터모드 
                        send_e =1; 
                    end           
                end
                MOVE_CUROSR : begin 
                   if(busy)begin   //busy =1 통신 모듈 사용중 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 통신 모듈 사용중 아님 
                        send_buffer = 8'hc0 ; //버튼누를 때마다 A,B,CD,...찍힘 
                        rs =0; 
                        send_e =1; 
                    end           
                end
                SHIFT_DISPLAY:begin
                 if(busy)begin   //busy =1 통신 모듈 사용중 
                        next_state = IDLE; 
                        send_e =0; 
                    end
                    else begin  //busy=0 통신 모듈 사용중 아님 
                        send_buffer = 8'h1c ; //cursor or display shift
                        rs =0; 
                        send_e =1; 
                    end           
                end
            endcase
        end
   end                                                           
endmodule 
