`timescale 1ns / 1ps 

/////////////////////순서논리회로 시작 /////////////////////////////

//D_flip_floop 
module D_flip_floop_n( //클럭이 하강엣지에서 입력d가 출력q에 반영됨 
    input d, 
    input clk,//clock
    input reset_p, //포지티브 엣지일 때 리셋 됨 //상승엣지일 때 reset  
    output reg q);
    
    wire d_bar;
    not(d_bar,d);
    //엣지를 검출하는 회로 
   //fpga에서 클록펄스 사용하는 법 
   //하강엣지에서 실행되는 플립플롭 
    always @(negedge clk or posedge reset_p) begin //클록이 1에서 0으로 떨어질 때(하강엣지) always문 생성 
    //posedge 상승엣지일 때 이걸 한 번 실행하라 or대신 쉼표해도 됨 
    //reset _p가 1이면 clear 포지티브 엣지나 네거티브엣지가 1일 때 리셋 1 
    
    if(reset_p)  begin q = 0;  end //rest이면 q가 0 qbar는 1
    
    else begin q = d; end //d가q에 반영이 됨 그 이후 하강엣지 안들어오면 출력 유지 
    
    end
   
endmodule

 /////////////////////////////////////////////////////////////////////
//D 플립플롭의 네거티브 엣지 (엣지 트리거링) 
module D_flip_floop_p( //포지티브 엣지에서 입력d가 출력q에 반영됨 
    input d, 
    input clk,//clock
    input reset_p, //포지티브 엣지일 때 리셋 됨 
    output reg q);
    
    wire d_bar;
    not(d_bar,d);
  
    always @(negedge clk or posedge reset_p) begin 
    if(reset_p)  begin q = 0;  end //리셋이 우선 //리셋1이면 뭊건 출력 0  

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
    
//    always @(*) begin//입력 변수의 값이 하나라도 변하면 실행하는 코드 
//        if(t) d = qbar;
//        else d = q; 
//     end
    
  always @( posedge clk or posedge reset_p) begin 
    if(reset_p)  begin q = 0;  end //rest이면 q가 0 qbar는 1
     else begin  //(*)대체 부분 
        if(t) q = ~q;//t가 1일 때 토글되서 출력 
        else q = q; //t가 1아닐 때 그대로 출력 
       end     ///여기까지 
    end
       

    
endmodule

 /////////////////////////////////////////////////////////////////////
//클럭의 포지티브에서 동작하는  T플립플롭 보통 resest은 positive에서 동작하도록

module T_flip_flop_n(
    input clk, reset_p,
    input t,
    output reg q);
    
//    wire qbar;
//    reg d; 
//    assign qbar = ~q; 
    
//    always @(*) begin//입력 변수의 값이 하나라도 변하면 실행하는 코드 
//        if(t) d = qbar;
//        else d = q; 
//     end
    
  always @( negedge clk or posedge reset_p) begin // clk이 하강엣지이거나 reset이  positive(1)일 때  실행하는 구문 
    if(reset_p)  begin q = 0;  end //reset이 되면P는(positive일 때 ,1일때) 출력 된다. 그때 출력(q)=0이됨 
     else begin  //(*)대체 부분  //reset이 1이 아닐 경우 -> q를 그대로 출력 
        if(t) q = ~q; //입력의 t가 1이면 q는 toggle 된다. (0->1, 1->0으로 바뀜)  
        else q = q;  //t가 0일때 q는 유지 
       end     ///여기까지 
    end
      
    //하강엣지이거나 reset=1될 때 출력이 변함 
   //t가 1일 때 q가 토글 되고 t가 0일 때 q가 그대로 출력됨 
   //근데 클럭이 네거티브이거나 reset이 1일 때만 실행되는 구문 이니까 
   //t가 1일 때 항상 토글되는 게 아니라 그 중에서 클럭이 네거티브 이거나 reset이 1될 때생기는 것 
   
endmodule

 /////////////////////////////////////////////////////////////////////
//비동기식 상향 카운터 ->다운 엣지에서 변함  
module up_counter_asyc(
    input clk,reset_p,
    output [3:0] count
);

    T_flip_flop_n T0 (.clk(clk), . reset_p(reset_p), .t(1), .q(count[0]) );
    T_flip_flop_n T1 (.clk(count[0]), . reset_p(reset_p), .t(1), .q(count[1]) );    //클럭을 Qa의 출력으로 준다. 
    T_flip_flop_n T2 (.clk(count[1]), . reset_p(reset_p), .t(1), .q(count[2]) );    
    T_flip_flop_n T3 (.clk(count[2]), . reset_p(reset_p), .t(1), .q(count[3]) );    
    
endmodule


 /////////////////////////////////////////////////////////////////////
//비동기식 다운 카운터 -> 상승 엣지에서 변함 
module down_counter_asyc(
    input clk,reset_p,//reset_p=1이면 출력 = 0 
    output [3:0] count
);

    T_flip_flop_p T0 (.clk(clk), . reset_p(reset_p), .t(1), .q(count[0]) );//count[0]= Qa
    T_flip_flop_p T1 (.clk(count[0]), . reset_p(reset_p), .t(1), .q(count[1]) );  //클럭을 Qa의 출력으로 준다. Qb 
    T_flip_flop_p T2 (.clk(count[1]), . reset_p(reset_p), .t(1), .q(count[2]) );    //Qc
    T_flip_flop_p T3 (.clk(count[2]), . reset_p(reset_p), .t(1), .q(count[3]) );    //Qd
    
endmodule


 
 
 ///////////////////////////////////////////////////////////////////// 
 //같은 clk 줌 -> reset여부에 상관없이 ->동기식됨 reset만 오직 비동기임 
 //동기식 active-high positive upcounter 
 module up_counter_p(
    input clk, reset_p,
    output reg [3:0] count );
    //ff밖에 덧셈기 붙여놓은 것 
    //count 4개 -> clk을 같은 걸 주었음 -> 동기식 (clk만 동기) 
    //reset은 비동기 
    
  //플립플롭과 조합회로 이어져있음 -> 순차논리 회로 
    always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 
        if(reset_p) count = 0; //리셋 1이면 카운트를 0으로 클리어 
          else count = count+1;// 이게 조합회로 
    end
    
 endmodule
 
 
 ///////////////////////////////////////////////////////////////////// 
 //en=1이면 다운 카운터 동작 
 //동기식 active-high positive down counter 
module down_counter_p(
    input clk, reset_p,
    output reg [3:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 그 안에 들어간게 조합회로 
        if(reset_p) count = 0; //리셋 1이면 카운트를 0으로 클리어 
          else count = count-1;
    end
    
 endmodule
  /////////////////////////////////////////////////////////////////////
 //en있는 다운카운터 
 //en=1이면 다운카운터 됨 en=0이면 출력없음 
 module down_counter_p_en(
    input clk, reset_p,enable,
    output reg [3:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 그 안에 들어간게 조합회로 
        if(reset_p) count = 0; //리셋 1이면 카운트를 0으로 클리어 
         else begin
         
         if(enable)  count = count-1;
         else count = count;
          end   
    end
    
 endmodule
 
  /////////////////////////////////////////////////////////////////////
  //동기식 active-high down count(en이 있는) parameter 

  module down_counter_Nbit_p #(parameter N = 8)(
    input clk, reset_p,enable,
    output reg [N-1:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 그 안에 들어간게 조합회로 
        if(reset_p) count = 0; //리셋 1이면 카운트를 0으로 클리어 
          else begin
            if(enable)  count = count-1;
            else count = count;
          end   
    end
    
 endmodule
 

  /////////////////////////////////////////////////////////////////////
 //동기식 active-high BCD(10진) 어카운터
 module bcd_up_counter_p(
    input clk, reset_p,
    output reg [15:0] count );
    
    always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 그 안에 들어간게 조합회로 
        if(reset_p) count = 0; //리셋 1이면 카운트를 0으로 클리어 
          else begin
            count = count+1;
            if ( count == 10 ) count = 0;
           end
         end
 endmodule
 
  /////////////////////////////////////////////////////////////////////
 //4비트 동기식 상향/하향 카운터 
 //같은 clk 줌 -> reset여부에 상관없이 ->동기 ff됨 reset만 오직 비동기임 

 module up_down_count( //x=1 감소카운터  , x=0증가 카운터 
    input clk, reset_p,//리셋해야해서 필요 
    input down_up,//1일때 down, 0일 때 up 사실 바꿔도 됨 1일때 해당하는 것을 앞으로 
    output reg [3:0] count );
 
    always @(posedge clk, posedge reset_p)begin //always문이 플립플롭 
        if(reset_p) count = 0;   //if~else가 mux 
        else begin
            if(down_up) count = count-1 ; //-랑+가 연산자  // if.else문->mux만들어짐 
         else 
            count = count + 1; 
        
        end
 
    end
 endmodule
 
 
 
 /////////////////////////////////////////////////////////////////////
  //up_down카운트를 BCD카운터로 만들기 
 //up 10 이 되면 0 되게, down되면 0일때 9가 되도록 
 //012345678909876543210123456789
  module up_down_count_bcd( //x=1 감소카운터  , x=0증가 카운터 
    input clk, reset_p,//리셋해야해서 필요 
    input down_up,//1일때 down, 0일 때 up 사실 바꿔도 됨 1일때 해당하는 것을 앞으로 
    output reg [3:0] count );
 
always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 
    if(reset_p) count = 0;   //reset=1일 때 count = 0
    else begin 
           if(down_up == 0) begin //reset=0이면서 down_up=0( up) 
                 if(count >= 9 ) count = 0;  //>가 더 안전 
                 else count = count + 1; end//reset=1이 아닐 때 즉, 출력 값 0아닐 때 count에 +1 
       
     
            else begin
                 if(count <= 0) count = 9;
                 else count = count - 1; end
        
    
 end     
 end  
 endmodule
 
  /////////////////////////////////////////////////////////////////////
// made by 교수님 
  module up_down_count_bcd_profassor( //x=1 감소카운터  , x=0증가 카운터 
    input clk, reset_p,//리셋해야해서 필요 
    input down_up,//1일때 down, 0일 때 up 사실 바꿔도 됨 1일때 해당하는 것을 앞으로 
    output reg [3:0] count );
 
 always @(posedge clk, posedge reset_p) begin
    if(reset_p) count = 0; //if절 실행되면 else문 실행안됨 
    else begin 
       if((down_up==1) && (count ==0)) count = 9; 
          else if((down_up==1) && (count !=0)) count = count - 1;    
          else if((down_up == 0)  &&  (count ==9)) count = 0; 
          else if((down_up == 0) && (count !=9)) count = count + 1; 
 
         end
   end
 endmodule
 

 
  /////////////////////////////////////////////////////////////////////
  ///주파수 분주기 써서 주기 늘려줌 ((플립플롭 하나 쓴건가??)) 
  /////////링카운터 ////////////////// -->  if문이 mux 
 module ring_counter(
     input clk, reset_p,
      output reg [3:0] q);
    

    always @(posedge clk, posedge reset_p) begin //always문이 플립플롭 그 안에 들어간게 조합회로
        if(reset_p) q = 4'b0001; //리셋 했을 때 0001 일의자리에서 숫자가 들어옴 
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
////링카운터 fnd////////////
 module ring_counter_fnd(
     input clk, reset_p,
      output reg [3:0] com);
    
    reg [16:0] clk_div; //16번 비트 서서 주기 늘린다. 1280s ->1.3ms정도마다 바
    wire clk_div_16; 
    always @(posedge clk) clk_div = clk_div +1; 


    edge_detector_n ed (.clk(clk), .reset_p(reset_p), .cp(clk_div[16]), .p_edge(clk_div_16));
 // 27로 하면 주기가 빨라지고 31로하면 주기가 느려짐 clk_div는 일의자리에서 다음 자리로 바뀌는 주기 
    //즉 29번째 count가 0->1로 상승엣지 일 때 일의 자리에서 십의 자리로 바뀜  영상에서 29가 불들어올 때마다 다른 자리로 바뀜
      
    always @ (posedge clk or posedge reset_p) begin 
        if(reset_p) com = 4'b1110;  //리셋 했을 때 0001 (com이 애노드 타입인데 그 앞에 not이 붙어 있으므로 0을 줘야 켜짐 ) 
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
 //////링카운터 LED (0번비트 커졌다 꺼지면 1번비트로 넘어감) 
 module ring_counter_led (
    input clk, reset_p, 
    output  reg [15:0] count);

    reg [21:0] clk_div;//wire같은 느낌 
    always @(posedge clk) 
    clk_div = clk_div +1; //클럭분주기 2의 거듭제곱으로 클럭을 나눠서 사용할 때 이용 -> clk:10ns [0]->20ns, [1]->40ns
    always @(posedge clk_div[21], posedge reset_p) begin //always문이 플립플롭 그 안에 들어간게 조합회로 
      if(reset_p) count = 16'b0000_0000_0000_0001;
      
      else begin 
                case (count) 
                 16'b0000_0000_0000_0000 : count= 16'b0000_0000_0000_0001 ; //앞쪽의 0은 생략해도 됨 
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
//    reg [26:0] clk_div;  // 클럭 분주기
//    always @(posedge clk) clk_div = clk_div + 1;
//    always @(posedge clk_div[26] or posedge reset_p) begin //clk_div도 엄밀히 말하면 clk에 의해 발생하니 동기 
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
//비동기 회로 클럭과 
//엣지 디텍터를 연결하여 특정 곳에서만 발생하는 링카운터  LEd

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

 //주기 clk_div[20]이어도 겁나 많이 돌아가 1인 기간동안 --> 너무 많이 돌아가서 펄스전이검출기 필요해       
        //클럭 엄청 많이 들어와 상승엣지에서만 한 번식 밀려야하는데 계속 밀리잖아 
//   else begin
//        else count = {count[14:0],1'b0};//비어있는 곳에 0넣기 



//////////////////////////////////////////////////////////////////////////
//클럭의 네거티브에서 동작하는 엣지 디텍터 
//클럭의 한주기 만큼의 펄스가 나오는 것 = 1 cycle pulse를 만들어 줌 = 엣지 디텍터 (d ff*2 + and gate) 
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
         else begin //cp가 1일 때 (reset_p가 1이 아닐 때) 
         //이렇게 하면 플립플롭 2개 필요 
            ff_cur <= cp; //ff_cur는 cp가 나오면 cp가 들어가면 됨   //=이면 블러킹 문 앞에 실행되는 동안 뒤에 실행을 막음 // <=이면 넌블러킹문 회로가 병렬로 동작하는 것임 
            ff_old <= ff_cur; //ff_cur의 값을 ff_old으로 받음 
            end
      end
   
      assign p_edge = ({ff_cur,ff_old}==2'b10) ? 1 : 0 ;//ff_cur & ~ ff_old ->이건 LUT 만들어짐  ->lut은 mux로 만듦 //cur은 그냥 받고 old는 not붙여서 받고 
      assign n_edge = ({ff_cur,ff_old}==2'b01) ? 1 : 0 ; //and gate만들어지지 않으니까 mux로 만든다. -> trsut type딱 정해져 있음 -> lut임 
    
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
         else begin //cp가 1일 때 (reset_p가 1이 아닐 때) 
            ff_cur <= cp; //ff_cur는 cp가 나오면 cp가 들어가면 됨   //=이면 블러킹 문 앞에 실행되는 동안 뒤에 실행을 막음 // <=이면 넌블러킹문 회로가 병렬로 동작하는 것임 
            ff_old <= ff_cur; //ff_cur의 값을 ff_old으로 받음 
            end
      end
   
      assign p_edge = ({ff_cur,ff_old}==2'b10) ? 1 : 0 ;//ff_cur & ~ ff_old ->이건 구조적 모델링이라 mux안만들어짐 //cur은 그냥 받고 old는 not붙여서 받고 
      assign n_edge = ({ff_cur,ff_old}==2'b01) ? 1 : 0 ;
    
endmodule 

////////////////////////////////////////////////////////////////////////////////
//버튼 컨트롤러모듈을 사용하지 않고 엣지 디텍터로 만든 모듈 
//버튼과 clk은 완전히 독립적 , edge detector 사용하면  clk을 사용할 수 있음 
//basys3 자체의 업 버튼 입력을 받아 fnd에 출력 하는 카운터 // 엣지 디텍터를 사용하여 clk을 동기로 만듦 채터링방지 하기 위해 주파수 분주기 사용 
//module button_test_top(
// input clk, reset_p, 
// input btn,
// output [7:0] seg_7,
// output [3:0] com); //전부 on ->an ->설정 안함 

//    reg [15:0] btn_counter ; //4bit짜리 버튼 카운터  
//    reg [3:0] value; 
//    wire btnU_pedge;
//    reg [16:0] clk_div =0 ; //분주기 만들기 
//    wire clk_div_16; 
//    reg debounced_btn;
    
//    //[16:0] clk_div의 출력값 clk_div_16; 

//    always @(posedge clk) clk_div = clk_div +1; //clk에 의해 동작하는 분주기 
  
  
//    always @(posedge clk, posedge reset_p) begin //채터링 방지하기 위해 분주기로 1ms로 주기를 바꿈 
//        if(reset_p) debounced_btn = 0; 
//        else if (clk_div_16) debounced_btn = btn;
//    end
    
// edge_detector_n ed1(.clk( clk) , 
//                     .reset_p(reset_p),//버튼 입력을 clk의 동기로 받기 위해 edge detector랑 연결 
//                     .cp(clk_div[16]), 
//                     .p_edge(clk_div_16));            //up 
        
    
//edge_detector_n ed2(.clk( clk) , 
//                    .reset_p(reset_p),
//                    .cp(debounced_btn),
//                    .p_edge(btnU_pedge)); //down 
         
//     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
//        if(reset_p) btn_counter = 0; 
//         else begin
//            if (btnU_pedge) btn_counter = btn_counter +1;
//         end  
//      end
        
////        else begin
////            if(btnU_pedge)
////            btn_counter = btn_counter +1; //버튼 누를 때마다 1씩 증가 //account만듦 
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
    
    
//    //fnd출력 
//endmodule
///////////////////////////////////////////////////////////////////////
//button_컨트롤러를 인스턴스해서 만든 +회로 
//버튼입력받아 count1씩 증가, 감소, 좌시프트, 우시프트 
module button_cntr_seg_7_display(
 input clk, reset_p, 
 input [3:0] btn,
 output [7:0] seg_7,
 output [3:0] com); //전부 on ->an ->설정 안함 

    reg [15:0] btn_counter ; //4bit짜리 버튼 카운터  
    reg [3:0] value; 
    wire [3:0] btnU_pedge;


     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러

  fnd_4digit_cntr(.clk(clk),  //출력 시 필요한 fnd 컨트롤러 모듈 불러옴 
                  .reset_p(reset_p), 
                  .value(btn_counter), 
                  .seg_7_ca(seg_7), //ca(캐소드타입)-1일 때켜짐
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
////////////////////////////////////////////////////////////////////////////////
module button_cntr_seg_7_display_practice(
 input clk, reset_p, 
 input [3:0] btn,
 output [7:0] seg_7,
 output [3:0] com); //전부 on ->an ->설정 안함 

    reg [7:0] btn_counter ; //4bit짜리 버튼 카운터 
    wire [3:0] btnU_pedge;


     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btnU_pedge[0])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_pe(btnU_pedge[1])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_pe(btnU_pedge[2])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러
     button_cntr(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_pe(btnU_pedge[3])); //버튼 입력 시 필요한 엣지 디텍터 컨트롤러

  fnd_4digit_cntr(.clk(clk),  //출력 시 필요한 fnd 컨트롤러 모듈 불러옴 
                  .reset_p(reset_p), 
                  .value(btn_counter), 
                  .seg_7_ca(seg_7), //ca(캐소드타입)-1일 때켜짐
                  .com(com));        
                  
                   
       //이 always문 만 만들어서  count만 해주면 된다. 나머지는 다 인스턴스로 부러옴             
     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter +1;
            else if (btnU_pedge[1]) btn_counter = btn_counter -1;
            else if (btnU_pedge[2])  btn_counter = {btn_counter[6:0], btn_counter[7]}; //좌시프트
            else if (btnU_pedge[3])  btn_counter = {btn_counter[0] ,btn_counter[7:1]}; //우시프트 
         end  
      end
    
    //fnd출력 
endmodule



////////////////////////////////////////////////////////////////////////////////
//버튼입력으로 led_bar 입력받기 
//원하는 자리에 버튼으로 led_bar 출력받기 
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


//xdc에서 btnu를 주는 게아니라 JB1을 주면 됨 





///////////////////////////////////////////////////////////
//버튼 하나로 입력 받고 한 방향으로 움직이는 링카운터 출력하기 //동기화 시키고 난 후 
///////////////////////////////////////////////////////////
module button_ledbar_ring (
 input clk, reset_p, 
 input btn,
 output [7:0] led_bar); //전부 on ->an ->설정 안함 

    reg [7:0] btn_counter ; //
    wire btnU_pedge;
    reg [16:0] clk_div =0 ; //분주기 만들기 
    wire clk_div_16; 
    reg debounced_btn;
    
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
                    .n_edge(btnU_pedge)); //down 
         
     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
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
//버튼 하나로는  bit로 1,2,3 ... +받고 버튼하나로는  -받기 
module button_ledbar_updown (
 input clk, reset_p, 
 
 input [1:0] btn,
 output [7:0] led_bar); //전부 on ->an ->설정 안함 

    reg [7:0] btn_counter ; //8bit짜리 버튼 카운터  
    wire [1:0] btnU_pedge;
    reg [16:0] clk_div =0 ; //분주기 만들기 
    wire clk_div_16; 
    reg [1:0]debounced_btn ;

    
      always @(posedge clk) clk_div = clk_div +1; //clk에 의해 동작하는 분주기 
  
  
    always @(posedge clk, posedge reset_p) begin //채터링 방지하기 위해 분주기로 1ms로 주기를 바꿈 
        if(reset_p) debounced_btn = 0; 
        else if (clk_div_16) begin
            debounced_btn= btn;
        end
    end
 
 //클럭 주기 늘리기    
 edge_detector_n ed1(.clk( clk) , 
                     .reset_p(reset_p),
                     .cp(clk_div[16]), 
                     .p_edge(clk_div_16));           
        
   
edge_detector_n ed2(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[0]),
                    .p_edge(btnU_pedge[0])); //up에 연결 
                    
edge_detector_n ed3(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(debounced_btn[1]),
                    .p_edge(btnU_pedge[1])); //down에 연결                    
                                
         
     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
        if(reset_p) btn_counter = 0; 
         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter +1; //up
            else if (btnU_pedge[1]) btn_counter = btn_counter -1; //down  
         end  
      end
        
    assign led_bar = ~ btn_counter;
    
endmodule
////////////////////////////////////////////////////
//버튼 두개로 입력받는 링카운터 위 아래로 움직이기 
module button_ledbar_updown_ringcounter (
 input clk, reset_p, 
 input [1:0 ]btn,
 output [7:0] led_bar); //전부 on ->an ->설정 안함 

    reg [7:0] btn_counter ; //8bit짜리 버튼 카운터
    wire [1:0] btnU_pedge;
    reg [16:0] clk_div =0 ; //분주기 만들기 
    wire clk_div_16;
    reg [1:0] debounced_btn ;

    always @(posedge clk) clk_div = clk_div +1; //clk에 의해 동작하는 분주기 

    always @(posedge clk, posedge reset_p) begin  //16번 파형을 입력으로 받아 디바운싱 제거 
        if(reset_p) debounced_btn= 0; 
        else if (clk_div_16) begin 
            debounced_btn= btn; 
        end      
    end

      edge_detector_n edg_clk_1(
         .clk( clk) , 
         .reset_p(reset_p),//채터링 방지하기 위해 분주기로 1ms로 주기를 바꾼 파형만 빼냄 
         .cp(clk_div[16]), 
         .p_edge(clk_div_16));   

      edge_detector_n edg_clk_2(
         .clk( clk) , 
         .reset_p(reset_p),//여러 번 눌린 버튼의 값을 한 번만 받기 위해 edge detector와 연결 
         .cp(debounced_btn[0]), 
         .p_edge(btnU_pedge[0])); 

      edge_detector_n edg_clk_3(
         .clk( clk) , 
         .reset_p(reset_p),
         .cp(debounced_btn[1]),
         . p_edge(btnU_pedge[1])); //down 


     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
        if(reset_p) btn_counter = 8'b0000_0001;
         else begin
            if (btnU_pedge[0]) btn_counter = {btn_counter[6:0],btn_counter[7]};
            else if (btnU_pedge[1]) btn_counter =  {btn_counter[0], btn_counter[7:1]};
         end
      end

    assign led_bar = ~ btn_counter;

    endmodule


//////////////////////////////////////////////////////////////////
//버튼 4개사용으로  fnd에 출력 
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
    
    decoder_7seg (.hex_value(btn_counter[3:0]), .seg_7(seg_7_bar)); //디코더에 받은 값은 0일 때 켜지는 값 받음 
    //7_seg는 0에서 켜짐 우리가 쓰는fnd는 1에서 켜짐 -> 반전시켜서 받아야함 
    assign seg_7 = ~seg_7_bar;
    endmodule
 //////////////////////////////////////////
 //버튼 1개 사용으로 4자리fnd출력 
module button_4bit_fnd(
 input clk, reset_p, 
 input btn,
 output [7:0] seg_7,
 output [3:0] com); //전부 on ->an ->설정 안함 

    reg [15:0] btn_counter ; //4bit짜리 버튼 카운터  
    reg [3:0] value; 
    wire btnU_pedge;
    reg [16:0] clk_div ; //분주기 만들기 
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
                    .n_edge(btnU_pedge)); //down 
         
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
    decoder_7seg fnd(.hex_value(value), .seg_7(seg_7_bar));
    assign seg_7 = ~seg_7_bar; 
    //fnd출력 
endmodule


///////////////////////////////////////////////////
///////////////////////////////////////////////////

///////////////////////////////////////////////////
///////////////////////////////////////////////////


//////////////////////////////////////////////////////
 //4자리fnd출력 각자리 다르게 출력받기
module button_4bit_each_fnd(
 input clk, reset_p, 
 input [3:0] btnU,
 output [7:0] seg_7,
 output [3:0] com); //전부 on ->an ->설정 안함 

    reg [15:0] btn_counter ; //4bit짜리 버튼 카운터  

    
    reg [3:0] value; 
    wire [3:0] btnU_pedge;
    reg [16:0] clk_div =0 ; //분주기 만들기 
    wire clk_div_16; 
    reg  [3:0] debounced_btn;
    
    //[16:0] clk_div의 출력값 clk_div_16; 

    always @(posedge clk) clk_div = clk_div +1; //clk에 의해 동작하는 분주기 
  
  
    always @(posedge clk, posedge reset_p) begin //채터링 방지하기 위해 분주기로 1ms로 주기를 바꿈 
        if(reset_p) debounced_btn = 0; 
        else if (clk_div_16) debounced_btn = btnU;
    end
    
 edge_detector_n ed1(.clk( clk) , 
                     .reset_p(reset_p),//버튼 입력을 clk의 동기로 받기 위해 edge detector랑 연결 
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
         
     always @(posedge clk, posedge reset_p)begin //버튼입력의 positive edge에서 btn_count를 하나씩 증가
        if(reset_p) begin
        
        btn_counter = 0; 
 
        end

         else begin
            if (btnU_pedge[0]) btn_counter = btn_counter+16'h0001; //얘가 자릿수를 더해줌 
            if (btnU_pedge[1]) btn_counter = btn_counter +16'h0010;
            if (btnU_pedge[2]) btn_counter = btn_counter +16'h0100;
            if (btnU_pedge[3]) btn_counter = btn_counter +16'h1000;
          
         end  
      end
        
     ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
   
    always @(posedge clk) begin  //얘는 출력,출력되는 주기 만 설정 
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
    //fnd출력 
endmodule
///////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////
//레지스터 -직렬입력 직렬출력 
module shiht_register_SISO_n(
    input clk, reset_p,
    input d, 
    output q);

    reg [3:0] siso_reg; 

    always @(negedge clk or posedge reset_p )begin 
        if(reset_p) siso_reg = 0; 
        else begin 
            siso_reg[3] <= d; //non-blocking문 써야함 출력이 그 다음 입력과 연결되어있어서
            siso_reg[2] <= siso_reg[3];
            siso_reg[1] <= siso_reg[2];
            siso_reg[0] <= siso_reg[1]; 
            //여기에도 논블러킹 주면 레지스터 하나 더 만들어짐 
            //레지스터  5비트짜리 만들어짐 그냥 출력되는거니까 
        end
    end 

    assign q = siso_reg[0]; 
endmodule



//레지스터-직렬입력 병렬출력
module shift_register_SIPO_n(
    input clk, reset_p,
    input d, 
    input rd_en, //1일 때 클럭을 읽자 
    output [3:0] q); //serial input pararial out 

    reg [3:0] sipo_reg;
    
    always @(negedge clk or posedge reset_p)
        if(reset_p) begin
            sipo_reg = 0; 
        end
        else begin
            sipo_reg = {d, sipo_reg[3:1]};
        end

    assign q= rd_en ? sipo_reg : 4'bz; //z는 한비트만 써도 4비트 출력 모두zzzz 000z이려면 이렇게 써야함 
//     bufif1 (q[0], sipo_reg[0], re_en); //3상버퍼 : 출력, 입력, 제어입력 제어비트가 1이되면 출력q로 나오고 0이면 z인 버퍼
//     bufif1 (q[1], sipo_reg[1], re_en);
//     bufif1 (q[2], sipo_reg[2], re_en);
//     bufif1 (q[3], sipo_reg[3], re_en); 
endmodule
///////////////////////////////////////////////////
//병렬 입력 직렬 출력 레지스터 
module shift_register_PISO(
    input clk, reset_p,
    input [3:0] d, 
    input shift_load, //시프트할건지 load할 건지 정하는 select bit
    //0이면 load 1이면 shift 됨 
    output q); //직렬 출력이니 1bit만 필요 

reg [3:0] piso_reg;

always @(posedge clk or posedge reset_p)begin
    if(reset_p) piso_reg =0; //리셋시 piso_레지스터가 0이 됨 
    else begin
        if(shift_load) piso_reg = {1'b0, piso_reg[3:1]}; //우시프트, 최하위 0번비트는 버려지는 것 
        else piso_reg = d; //load시킴 - ff의 입력을 이전 ff의 출력으로 받음 
    end

end

    assign q= piso_reg[0];

endmodule
///////////////////////////////////////////////////
//병렬 입력 병렬 출력 레지스터 //가장 일반적인 레지스터라 이름을 레지스터라고 지정 
//클럭이 계속 들어오고 있으니 d가 들어오고 싶을 때 wr_en 쓰면 내가 원하는 입력이 레지스터로 들어옴 
//입력 다른 값으로 바꾸고 싶으면 en끊었다가 다시 주면 됨 
//출력하고 싶을 때 rd_en을 1로 주고 현재 저장된 값이 출력으로 나옴 
module register_Nbit_p #(parameter N = 8) (
    input clk, reset_p,
    input [N-1:0] d, 
    input wr_en, rd_en, // 읽고,쓰고 싶을 때만 레지스터 사용할 수 있도록 변수 선언함 
    output [N-1:0] q); 

    reg [7:0] register; //4bit 레지스터 선언 
    
    always @(posedge clk or posedge reset_p) begin
    if(reset_p) register = 0; 
    else if(wr_en) register = d; //d가아무리 바뀌어도 write 인에이블이 1일 때만 입력이 레지스터로 들ㅇ어와야 함 
    end
    
    assign q = rd_en ? register : 'bz ; //re_en=1일 때만 레지스터 값이 출력q로 나오고 , 그게 아닐 경우 z를 출력(출력을 끊음)   z하나만 쓰면 zzzz니까 몇 비트인지 쓸 필요 없음 
endmodule


//8bit짜리 메모리 1024개인 sram
module sram_8bit_1024( //메모리 - 리셋없음 전원버튼 끄면 됨 
    input clk,
    input wr_en,rd_en,
    input [9:0] addr, //1024개 있으면 bit 10개 필요 
    inout [7:0] data);  //inout = input도 가능, output도 가능 입력선,출력선 같이 사용 출력하지 않을 땐 반드시 z로 입력 

    reg [7:0] mem [0:1023]; //앞에 껀 비트 선언 뒤에껀 몇 개 만들기 (배열 선언) // 8비트짜리 메모리 1024개 만들겠다. 
    
    always @(posedge clk)begin 
     if(wr_en) mem [addr] <= data;
    end
    assign data = rd_en ? mem[addr] : 'bz;
endmodule