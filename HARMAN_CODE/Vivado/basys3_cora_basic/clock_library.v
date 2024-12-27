`timescale 1ns / 1ps
//ns ->usec ����� 
module clock_usec(
    input clk, reset_p,
    output clk_usec
    ); 
    
    reg [7:0] cnt_sysclk; //���̽ý� 10ns�� ī��Ʈ �ڶ�� 8ns 
    wire cp_usec ;
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) cnt_sysclk =0 ;
        else if (cnt_sysclk >= 99) cnt_sysclk = 0 ; //99���� ũ�� 0�� ��  //100�� ������ �� ������ �� �� ������ �ϱ� ���� 
        //10ns�����̴ϱ� 1msec�Ƿ��� 100���� count�ؾ��� 
        //100�̻��� �Ǹ� 0���� clr -> 0�� �Ǹ� 1umsec ���� �� 
        
        else cnt_sysclk= cnt_sysclk + 1 ; 
    end
    //0~49 0 50~99 1->1msec���ֱ⸦ ���� clk�� ������� 
        assign cp_usec = (cnt_sysclk < 50 ) ? 0 : 1; //�ڶ�� 63 

    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_usec), .n_edge(clk_usec)); //1usec�� �ý��� �ֱⰡ ������ 
//cp_usec�� ������ ��Ƽ� clk_usec�� ����ϱ� ���� cp_usec�� ���� (( ���� ���ϸ� � ���� ������ ��Ƽ� ����ϳ�?? ))  

endmodule
//usec -> msec ����� 
//Ŭ���� ���ļ��� 1000���� 1�� ���� 1000�� �ֱ� ���� 
module clock_div_1000( //msec
    input clk, reset_p,
    input clk_source,  //clk_usec
    output clk_div_1000); //clk_msec //1000���� �� Ŭ�� �޽��� ���� ->1msec�� �� ���� ������ clk 
    
    reg [8:0] cnt_clk_source; //1000�� �ʿ��ѵ� ����� �̿��ؼ� 500������ ����ϸ�Ǵϱ� 1+2+4+8+16+32+64+128
   reg  cp_div_1000; //1 cycle�� msec�� Ŭ�� �޽��� ������  �ֱⰡ 1msec 0.5msec���� 1 ������ 0 
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
        cnt_clk_source = 0; 
        cp_div_1000 = 0; 
        end
        else if (clk_source) begin
            if(cnt_clk_source >= 499) begin //500���� ���� �� ��� 
            cnt_clk_source = 0; 
            cp_div_1000 = ~cp_div_1000;
            end                
            
           else cnt_clk_source = cnt_clk_source +1;
         end
   end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_1000), .n_edge(clk_div_1000)); //1usec�� �ý��� �ֱⰡ ����  
endmodule

//1sec�� 1min���� �ٲٱ� 
module clock_min( //
    input clk, reset_p,
    input clk_sec, 
    output clk_min);
    
    reg [4:0] cnt_sec; //�ʸ� counting ���ִ� ������ �������� �������� 
    reg cp_min; //1�� ¥�� Ŭ���޽� 
    
   always @(posedge clk or posedge reset_p) begin
    if(reset_p) begin
        cnt_sec = 0; 
        cp_min = 0; 
    end
    else if(clk_sec) begin
        if(cnt_sec >= 29) begin //�� sec�� 60�ʰ� ���;� �Ǽ� 
            cnt_sec = 0; 
            cp_min = ~cp_min; 
        end
        else cnt_sec = cnt_sec +1; 
   end
   end
   edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_min), .n_edge(clk_min)); //1�п� �� �� �ý��� Ŭ���� ���� 
   
endmodule
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//msec�� 10msec�� �ٲٱ� 
//10���ֱ� 
module clock_div_10( //msec
    input clk, reset_p,
    input clk_source,  //clk_msec
    output clk_div_10); //clk10msec 
    
    reg [2:0] cnt_clk_source; //���ϱ� 10�ؾ��ϴµ� ������ ���ڷ� ��۽�Ű�ϱ� 1+2+4 -> 3��Ʈ �ʿ�  
   reg  cp_div_10; //1 cycle�� msec�� Ŭ�� �޽��� ������  �ֱⰡ 1msec 0.5msec���� 1 ������ 0 
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
        cnt_clk_source = 0; 
        cp_div_10 = 0; 
        end
        else if (clk_source) begin
                if(cnt_clk_source >=4  ) begin //5���� ���� �� ��� 
                cnt_clk_source = 0; 
                cp_div_10 = ~cp_div_10;
                end                            
            else cnt_clk_source = cnt_clk_source +1;
        end
    end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_10), .n_edge(clk_div_10)); //1usec�� �ý��� �ֱⰡ ����  
endmodule



//10msec�� 100�� ��� sec�����
module clock_div_100( //msec
    input clk, reset_p,
    input clk_source,  //clk_usec
    output clk_div_100); //clk_msec //1000���� �� Ŭ�� �޽��� ���� ->1msec�� �� ���� ������ clk 
    
    reg [5:0] cnt_clk_source; //50���� �ʿ� 1+2+4+8+16+32+64
   reg  cp_div_100; //1 cycle�� msec�� Ŭ�� �޽��� ������  �ֱⰡ 1msec 0.5msec���� 1 ������ 0 
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin
        cnt_clk_source = 0; 
        cp_div_100 = 0; 
        end
        else if (clk_source) begin
            if(cnt_clk_source >= 49) begin //500���� ���� �� ��� 
            cnt_clk_source = 0; 
            cp_div_100 = ~cp_div_100;
            end                
            
           else cnt_clk_source = cnt_clk_source +1;
         end
   end
        edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(cp_div_100), .n_edge(clk_div_100)); //1usec�� �ý��� �ֱⰡ ����  
endmodule


//100�� ī����
module counter_dec_100(
    input clk, reset_p, 
    input clk_time, 
    output reg [4:0] dec1, dec10); //���ڸ�����µ� 4��Ʈ �ʿ� 
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
           
        end 
        else begin 
            if(clk_time) begin 
                if(dec1 >= 9) begin 
                   dec1 = 0; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                  
                   if(dec10 >= 9) begin
                    dec10 =0; //�����ڸ����� 5�������� 0�� �Ǿ� �� 
              
                    end
                    
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
             end
         end 
            
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//60�� ī���� �ʵ����� �е� ���� 
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
                   dec1 = 9; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                   if(dec10 <= 0) dec10 =9; //�����ڸ����� 5�������� 0�� �Ǿ� �� 
                   else dec10 = dec10 - 1; 
                 end 
              else dec1 = dec1 - 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
             end
        end 
            
        end
endmodule


module loadable_downcounter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //��, ���̴ϱ� 0~9���� ��� -> 4bit �ʿ� 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
        if(load_enable) begin // 1�̸� �ܺο��� ���� ī���ͷ� ��� 
            dec1 = set_value1;  // dec1 : ���� �����ڸ��� ��µǴ� �� ( cur�� or setting�� �� ���� �� ����)
            dec10 = set_value10;  //set_value : ���� ���� ������ �� (���ø�� -���ð� or �ðԸ�� - �ð谪 �� ���� �� ����) 
        end
        else if(clk_time) begin  //load_enable�� 1�̾ƴϸ� ������ ���� 60�� ī���Ϳ� ���� 
                if(dec1 <= 0) begin 
                   dec1 = 9; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                  
                   if(dec10 <=0 ) dec10 = 5; //�����ڸ����� 5�������� 0�� �Ǿ� �� 
                   else dec10 = dec10 - 1; 
                 end 
              else dec1 = dec1 - 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
             end
        end 
            
        end
endmodule


//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
//60�� ī���� �ʵ����� �е� ���� 
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
                   dec1 = 0; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                   if(dec10 >= 5) dec10 =0; //�����ڸ����� 5�������� 0�� �Ǿ� �� 
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
             end
        end 
            
        end
endmodule

//���� ���ð��� 
module loadable_counter_dec_60(
    input clk, reset_p, 
    input clk_time, 
    input load_enable, 
    input [3:0] set_value1, set_value10, //��, ���̴ϱ� 0~9���� ��� -> 4bit �ʿ� 
    output reg [3:0] dec1, dec10);
    
    always @(posedge clk, posedge reset_p) begin
        if(reset_p) begin 
            dec1 = 0; 
            dec10 = 0; 
        end 
        else begin 
        if(load_enable) begin // 1�̸� �ܺο��� ���� ī���ͷ� ��� 
            dec1 = set_value1;  // dec1 : ���� �����ڸ��� ��µǴ� �� ( cur�� or setting�� �� ���� �� ����)
            dec10 = set_value10;  //set_value : ���� ���� ������ �� (���ø�� -���ð� or �ðԸ�� - �ð谪 �� ���� �� ����) 
        end
        else if(clk_time) begin  //load_enable�� 1�̾ƴϸ� ������ ���� 60�� ī���Ϳ� ���� 
                if(dec1 >= 9) begin 
                   dec1 = 0; //���� ���ڸ� �� �����ڸ����� 9�� �Ǹ� 0�̵ȴ�. 
                   if(dec10 >= 5) dec10 =0; //�����ڸ����� 5�������� 0�� �Ǿ� �� 
                   else dec10 = dec10 + 1; 
                 end 
              else dec1 = dec1 + 1; //�� Ŭ�� �ް� ���� ������ ������Ű�� dec1�� �� ���ڸ� �߿� 1�� �ڸ��� ������Ŵ 
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
//                        cm = cm+1; //neg edge ���� �� value�� ����� 
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


module sr04_div58( //58�� �ֱ� ī����. 
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