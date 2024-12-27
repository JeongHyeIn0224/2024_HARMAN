`timescale 1ns / 1ps
//ns ->usec 만들기 
module clock_usec(
    input clk, reset_p,
    output clk_usec
    ); 
    
    reg [7:0] cnt_sysclk; //베이시스 10ns를 카운트 코라는 8ns 
    wire cp_usec ;
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) cnt_sysclk =0 ;
        else if (cnt_sysclk >= 99) cnt_sysclk = 0 ; //99보다 크면 0이 됨  //100번 들어왔을 때 파형이 한 번 들어오게 하기 위함 
        //10ns기준이니까 1msec되려면 100까지 count해야함 
        //100이상이 되면 0으로 clr -> 0이 되면 1umsec 지난 것 
        
        else cnt_sysclk= cnt_sysclk + 1 ; 
    end
    //0~49 0 50~99 1->1msec의주기를 갖는 clk이 만들어짐 
        assign cp_usec = (cnt_sysclk < 50 ) ? 0 : 1; //코라는 63 

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_usec), .n_edge(clk_usec)); //1usec씩 시스템 주기가 나ㄱㅁ 
//cp_usec의 엣지를 잡아서 clk_usec에 사용하기 위해 cp_usec를 선언 (( 선언 안하면 어떤 것의 엣지를 잡아서 출력하나?? ))  

endmodule
//usec -> msec 만들기 
//클럭의 주파수를 1000분의 1로 나눈 1000분 주기 만듦 
module clock_div_1000( //msec
    input clk, reset_p,
    input clk_source,  //clk_usec
    output clk_div_1000); //clk_msec //1000분주 된 클럭 펄스가 나옴 ->1msec에 한 번씩 나오는 clk 
    
    reg [8:0] cnt_clk_source; //1000이 필요한데 토글을 이용해서 500까지만 사용하면되니까 1+2+4+8+16+32+64+128
   reg  cp_div_1000; //1 cycle임 msec의 클럭 펄스를 만ㄷ름  주기가 1msec 0.5msec동안 1 나머지 0 
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
        cnt_clk_source = 0; 
        cp_div_1000 = 0; 
        end
        else if (clk_source) begin
            if(cnt_clk_source >= 499) begin //500부터 리셋 후 토글 
            cnt_clk_source = 0; 
            cp_div_1000 = ~cp_div_1000;
            end                
            
           else cnt_clk_source = cnt_clk_source +1;
         end
   end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_1000), .n_edge(clk_div_1000)); //1usec씩 시스템 주기가 나감  
endmodule

//1sec를 1min으로 바꾸기 
module clock_min( //
    input clk, reset_p,
    input clk_sec, 
    output clk_min);
    
    reg [4:0] cnt_sec; //초를 counting 해주는 변수를 레지스터 선언해줌 
    reg cp_min; //1분 짜리 클럭펄스 
    
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) begin
        cnt_sec = 0; 
        cp_min = 0; 
    end
    else if(clk_sec) begin
        if(cnt_sec >= 29) begin //총 sec가 60초가 나와야 되서 
            cnt_sec = 0; 
            cp_min = ~cp_min; 
        end
        else cnt_sec = cnt_sec +1; 
   end
   end
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_min), .n_edge(clk_min)); //1분에 한 번 시스템 클럭이 나옴 
   
endmodule
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//msec를 10msec로 바꾸기 
//10분주기 
module clock_div_10( //msec
    input clk, reset_p,
    input clk_source,  //clk_msec
    output clk_div_10); //clk10msec 
    
    reg [2:0] cnt_clk_source; //곱하기 10해야하는데 절반의 숫자로 토글시키니까 1+2+4 -> 3비트 필요  
   reg  cp_div_10; //1 cycle임 msec의 클럭 펄스를 만ㄷ름  주기가 1msec 0.5msec동안 1 나머지 0 
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
        cnt_clk_source = 0; 
        cp_div_10 = 0; 
        end
        else if (clk_source) begin
                if(cnt_clk_source >=4  ) begin //5부터 리셋 후 토글 
                cnt_clk_source = 0; 
                cp_div_10 = ~cp_div_10;
                end                            
            else cnt_clk_source = cnt_clk_source +1;
        end
    end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_10), .n_edge(clk_div_10)); //1usec씩 시스템 주기가 나감  
endmodule



//10msec를 100개 세어서 sec만들기
module clock_div_100( //msec
    input clk, reset_p,
    input clk_source,  //clk_usec
    output clk_div_100); //clk_msec //1000분주 된 클럭 펄스가 나옴 ->1msec에 한 번씩 나오는 clk 
    
    reg [5:0] cnt_clk_source; //50까지 필요 1+2+4+8+16+32+64
   reg  cp_div_100; //1 cycle임 msec의 클럭 펄스를 만ㄷ름  주기가 1msec 0.5msec동안 1 나머지 0 
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
        cnt_clk_source = 0; 
        cp_div_100 = 0; 
        end
        else if (clk_source) begin
            if(cnt_clk_source >= 49) begin //500부터 리셋 후 토글 
            cnt_clk_source = 0; 
            cp_div_100 = ~cp_div_100;
            end                
            
           else cnt_clk_source = cnt_clk_source +1;
         end
   end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_100), .n_edge(clk_div_100)); //1usec씩 시스템 주기가 나감  
endmodule


//100진 카운터
module counter_dec_100(
    input clk, reset_p, 
    input clk_time, 
    output reg [4:0] dec1, dec10); //한자리만드는데 4비트 필요 
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
           
        end 
        else begin 
            if(clk_time) begin 
                if(dec1 >= 9) begin 
                   dec1 = 0; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                  
                   if(dec10 >= 9) begin
                    dec10 =0; //십의자리에서 5다음에는 0이 되야 함 
              
                    end
                    
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
             end
         end 
            
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//60진 카운터 초도세고 분도 세고 
module downcounter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
            if(clk_time) begin 
                if(dec1 <=0) begin 
                   dec1 = 9; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                   if(dec10 <= 0) dec10 =9; //십의자리에서 5다음에는 0이 되야 함 
                   else dec10 = dec10 - 1; 
                 end 
              else dec1 = dec1 - 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
             end
        end 
            
        end
endmodule


module loadable_downcounter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //초, 분이니까 0~9까지 출력 -> 4bit 필요 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
        if(load_enable) begin // 1이면 외부에서 쓰는 카운터로 덮어씀 
            dec1 = set_value1;  // dec1 : 현재 일의자리에 출력되는 값 ( cur값 or setting값 이 들어올 수 있음)
            dec10 = set_value10;  //set_value : 내가 현재 셋팅한 값 (셋팅모드 -셋팅값 or 시게모드 - 시계값 이 들어올 수 있음) 
        end
        else if(clk_time) begin  //load_enable이 1이아니면 이전에 쓰던 60진 카운터와 같음 
                if(dec1 <= 0) begin 
                   dec1 = 9; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                  
                   if(dec10 <=0 ) dec10 = 5; //십의자리에서 5다음에는 0이 되야 함 
                   else dec10 = dec10 - 1; 
                 end 
              else dec1 = dec1 - 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
             end
        end 
            
        end
endmodule


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//60진 카운터 초도세고 분도 세고 
module counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
            if(clk_time) begin 
                if(dec1 >= 9) begin 
                   dec1 = 0; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                   if(dec10 >= 5) dec10 =0; //십의자리에서 5다음에는 0이 되야 함 
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
             end
        end 
            
        end
endmodule

//현재 셋팅값을 
module loadable_counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //초, 분이니까 0~9까지 출력 -> 4bit 필요 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
        if(load_enable) begin // 1이면 외부에서 쓰는 카운터로 덮어씀 
            dec1 = set_value1;  // dec1 : 현재 일의자리에 출력되는 값 ( cur값 or setting값 이 들어올 수 있음)
            dec10 = set_value10;  //set_value : 내가 현재 셋팅한 값 (셋팅모드 -셋팅값 or 시게모드 - 시계값 이 들어올 수 있음) 
        end
        else if(clk_time) begin  //load_enable이 1이아니면 이전에 쓰던 60진 카운터와 같음 
                if(dec1 >= 9) begin 
                   dec1 = 0; //초의 두자리 중 일의자리에서 9가 되면 0이된다. 
                   if(dec10 >= 5) dec10 =0; //십의자리에서 5다음에는 0이 되야 함 
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //초 클럭 받고 들어올 때마다 증가시키는 dec1은 초 두자리 중에 1의 자리를 증가시킴 
             end
        end 
            
        end
endmodule





//module sr04_div58(
//    input clk, reset_p, 
//    input clk_usec,
//    input cnt_e,            //count start
//    output reg [11:0] cm); 
    
//    integer cnt;
    
//    always @(posedge clk, posedge reset_p) begin
//        if(reset_p) begin 
//            cm =0 ;           
//        end 
//        else begin 
//            if(cnt_e) begin 
//                if(clk_usec) begin 
//                    cnt = cnt+1;
//                    if(cnt >= 58) begin 
//                        cnt =0 ; 
//                        cm = cm+1; //neg edge 떴을 때 value에 저장됨 
//                    end
//                end                         
//              end     
//              else begin
//                  cnt =0;           //count clear 
//                  cm =0;                
//               end           
//         end
//    end
 
//endmodule


module sr04_div58( //58분 주기 카운터. 
    input clk, reset_p,
    input clk_usec, cnt_e,
    output reg [11:0] cm
 );
    
    integer cnt;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin 
            cm = 0;
            cnt = 0;
        end
        else begin
            if(cnt_e)begin
                if(clk_usec)begin
                    cnt = cnt + 1;
                    if(cnt >= 58)begin
                        cnt = 0;
                        cm = cm + 1;
                    end    
                end
            end
            else begin
                cnt = 0;
                cm = 0;
            end
        end
    end

endmodule