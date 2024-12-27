`timescale 1ns / 1ps
//엣지 디텍터를 다른 모듈에서 불러서 바로 사용할 수 있도록 모듈을 만ㄷ름 
module button_cntr(
    input clk, reset_p,
    input btn,
    output btn_pe,btn_ne);
        
     reg [16:0] clk_div ; //분주기 만들기 
     wire clk_div_16; 
     reg [3 :0] debounced_btn;
            
    always @(posedge clk) clk_div = clk_div +1; //clk에 의해 동작하는 분주기 
             
    edge_detector_n ed1(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(clk_div[16]), 
                    .p_edge(clk_div_16));    
                 
     always @(posedge clk, posedge reset_p) begin //채터링 방지하기 위해 분주기로 1ms로 주기를 바꿈 
                if(reset_p) debounced_btn = 0; 
                else if (clk_div_16) debounced_btn = btn;
     end
                         
     edge_detector_n ed2(.clk( clk) , 
                     .reset_p(reset_p),
                     .cp(debounced_btn),
                     .p_edge(btn_pe), //버튼누를 때 동작 시킴 누를 때 동작 시작 일정 시간 지나면 롱키입력 
                     .n_edge(btn_ne)); //버튼 뗄 때 동작 시킴 n_edge니까 
endmodule


//////////////////////////////////////////////////////////////////////////////
//fnd컨트롤러 
module fnd_4digit_cntr(
    input clk,reset_p,
    input [15:0] value,//value 16bit값을 받음 
    output [7:0] seg_7_an, seg_7_ca, //an(애노드타입)-0일때켜짐, ca(캐소드타입)-1일 때켜짐 
    output [3:0] com);

    reg [3:0] hex_value;
      
     ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
   
    always @(posedge clk) begin  //얘는 출력,출력되는 주기 만 설정 
        case(com)
        4'b0111 : hex_value = value[15:12];   //value의 4비트씩(0~f)까지 출력할 수 있도록 함 
        4'b1011 : hex_value = value[11:8];  //value의 값을 hex_value에 넣어서 불빛 출력 
        4'b1101 : hex_value = value[7:4];  //hex_value = 불빛 
        4'b1110 : hex_value = value[3:0];   
        endcase
    end

//이 모듈을 다른 곳에 인스턴스 할거니까 0일때도 1일때도 모두 받을 수 있도록 코드를 만들어줌 
    decoder_7seg fnd(.hex_value(hex_value), .seg_7(seg_7_an)); //애노드 타입 받기 - 0일 때 켜짐 
    assign seg_7_ca = ~seg_7_an; //캐소드 타입 받기 - 1일 때 켜짐 
    
endmodule

//키패드 컨트롤러 
module key_pad_cntr(
    input clk, reset_p,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value, //key 16가지 표현하기 위해 ->4bit써야함 
    output reg key_valid //key값이 바뀌면 1 안눌리면 0      //0눌리면 0 1이면 1 아무것도 안눌렸을 때 신호 받기 위함

    );  
    //ring counter 돌릴 때 쓸 clk_div
    reg  [19:0] clk_div; //8ms 한 줄읽는데 걸리는 시간  4줄 읽는데 총 걸리는 시간 :32ms
    
    always @ (posedge clk) clk_div = clk_div+1; 
  
    wire clk_8msec_p,clk_8msec_n; //8msec에 한 번씩 증가 
    
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]), .p_edge(clk_8msec_p), .n_edge(clk_8msec_n));
    
   always @ (posedge clk or posedge reset_p) begin 
        if(reset_p) col = 4'b0001; 
        else if(clk_8msec_p && !key_valid)begin //key_valid가 1이 아닐 때(0일 때-아무 것도 안눌렀을 때 ) col값 바뀜 
                case(col) //valid= 0 ineable, valid =1 visiable 
                    4'b0001 :col = 4'b0010;// clk_8msec_p 클럭이 들어올 때마다 링카운터 처럼 바뀐다. 
                    4'b0010 :col = 4'b0100;
                     4'b0100:col = 4'b1000;
                    4'b1000 :col = 4'b0001;
                    default: col = 4'b0001;
             endcase
        end            
   end
   
   always @(posedge clk, posedge reset_p) begin
    if(reset_p) begin //reset들어오면 0
        key_value = 0;  
        key_valid = 0;    
        
    end
    else begin //키가 0000이면 아무값도 안들어옴 뭐가 하나라도 1들어오면 거기에 값 들어온 것 
        if(clk_8msec_n) begin // 원래 이게 없었음 . 
            if(row ) begin  //row값이 0이 아닐 때 어느 것 하나 1들어오면 키를 하나 눌렀다는 뜻 
                key_valid = 1; 
                case({col,row}) //어떤 키가 눌렸냐에 따라 key_value가 변함 
                    8'b0001_0001 : key_value = 4'h7; // 4비트 헥사 값으로 0 
                    8'b0001_0010 : key_value = 4'h4; //  1
                    8'b0001_0100 : key_value = 4'h1; //  2 
                    8'b0001_1000 : key_value = 4'h3; //  3 
                    
                    8'b0010_0001 : key_value = 4'h8; //  4
                    8'b0010_0010 : key_value = 4'h5; //  5
                    8'b0010_0100 : key_value = 4'h2; //  6 
                    8'b0010_1000 : key_value = 4'h0; //  7 
                    
                    8'b0100_0010 : key_value = 4'h9; //  8
                    8'b0100_0010 : key_value = 4'h6; //  9
                    8'b0100_0100 : key_value = 4'hE; // 10 
                    8'b0100_1000 : key_value = 4'hF; // 11 
                      
                    8'b1000_0001 : key_value = 4'hA; // 12
                    8'b1000_0010 : key_value = 4'hb; // 13
                    8'b1000_0100 : key_value = 4'hE; // 14 
                    8'b1000_1000 : key_value = 4'hd; // 15                                       
                endcase
            end    
            else begin //row 가 0이면 키 입력이 없다는 뜻 
                key_valid = 0;  //key_valid바꾸는 거 8mec에 한 번씩 
                key_value = 0; 
    //0번 키 눌렀을 때 key_value안바뀜 0번키 눌렸는지 안눌렸는지는 key_valid봐야함 
              end
          end
   end
end
endmodule

//유한상태머신만들기 
//1누르면 count+1, 2누르면 count -1 되게 함 
module keypad_cntr_FSM(
    input clk,reset_p,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value,
    output reg key_valid);

//parameter 변수: 상수 선언 더이상 값 바뀌지 않음  
    parameter SCAN_0 = 1; 
    parameter SCAN_1 = 2; //5'b00010
    parameter SCAN_2 = 3; //5'b00100; 
    parameter SCAN_3 = 4; 
    parameter KEY_PROCESS = 5; 
    
    reg [2:0] state, next_state; //state를 0~7까지(2^3) 사용할 수 있음 3비트 
                                //5'b00010되면 reg [4:0] 이 되어야함 5bit 
  //FSM case문으로 나타내기 
  //상태천이 조건 = only row(키가 눌렸냐 안눌렸냐)   
  //조합 회로 앞에 뗴어냄 
    always @* begin
        case(state)
            SCAN_0 : begin 
                if(row==0) next_state =  SCAN_1;//next_state에 2줌 
                else  next_state = KEY_PROCESS;
            end
             SCAN_1 : begin 
                if(row ==0) next_state = SCAN_2;
                else next_state = KEY_PROCESS;
            end           
              SCAN_2 : begin 
                if(row ==0) next_state = SCAN_3;
                else next_state = KEY_PROCESS;
            end
              SCAN_3 : begin 
                if(row ==0) next_state = SCAN_0;
                else next_state = KEY_PROCESS;
            end         
            KEY_PROCESS : begin
                if(row!=0) next_state = KEY_PROCESS;
                else next_state = SCAN_0;
            end           
        endcase    
    end
    
    reg [19:0] clk_div; 
    always @(posedge clk) clk_div = clk_div +1; 
    
    wire clk_8msec;
    
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]), 
    .p_edge(clk_8msec));
  //state 와 next_state 를 연결 
  //플립플롭 뒤쪽에 연결 
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) state = SCAN_0; 
        else if(clk_8msec) state = next_state; 
    end
     
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin 
            key_value = 0; //key_value 초기화 
            key_valid = 0; 
            col = 4'b0001; 
        end
        else begin 
            case(state) 
                SCAN_0 : begin col = 4'b0001; key_valid = 0; end //SCAN0에 머무는동안 key_valid는 0임 
                SCAN_1 : begin col = 4'b0010; key_valid = 0; end 
                SCAN_2 : begin col = 4'b0100; key_valid = 0; end 
                SCAN_3 : begin col = 4'b1000; key_valid = 0; end 
                KEY_PROCESS :begin
                   key_valid = 1;
                   case({col,row}) //어떤 키가 눌렸냐에 따라 key_value가 변함 
                    8'b0001_0001 : key_value = 4'h7; // 4비트 헥사 값으로 0 
                    8'b0001_0010 : key_value = 4'h4; //  1
                    8'b0001_0100 : key_value = 4'h1; //  2 
                    8'b0001_1000 : key_value = 4'h3; //  3 
                    
                    8'b0010_0001 : key_value = 4'h8; //  4
                    8'b0010_0010 : key_value = 4'h5; //  5
                    8'b0010_0100 : key_value = 4'h2; //  6 
                    8'b0010_1000 : key_value = 4'h0; //  7 
                    
                    8'b0100_0010 : key_value = 4'h9; //  8
                    8'b0100_0010 : key_value = 4'h6; //  9
                    8'b0100_0100 : key_value = 4'hE; // 10 
                    8'b0100_1000 : key_value = 4'hF; // 11 
                      
                    8'b1000_0001 : key_value = 4'hA; // 12
                    8'b1000_0010 : key_value = 4'hb; // 13
                    8'b1000_0100 : key_value = 4'hE; // 14 
                    8'b1000_1000 : key_value = 4'hd; // 15                                       
                endcase
            end
        endcase
    end
  end
endmodule


///////////////////////FSM 온습도 센서 ////////////////////////////////
module dht11_mine( //혠코드 
    input clk, reset_p,
    inout dht11_data,//  선 하나가지고 인풋도 되고 아웃풋도 되어야함 signal 선 이 하나기 때문 
    output reg [7:0] humidity, temperature, // data40bit받지만 그 중에서 속도랑 온도를 츨력할거야
    output [7:0]led_bar); //디버깅을 위해 led출력을 만들어 놓음   
   
   parameter S_IDLE      = 6'b000001;
   parameter S_LOW_18MS  = 6'b000010; 
   parameter S_HIGH_20US = 6'b000100;
   parameter S_LOW_80US  = 6'b001000; //응답비트 
   parameter S_HIGH_80US = 6'b010000; //응답비트 
   parameter S_READ_DATA = 6'b100000;               //입력선의 엣지받아서 출력 
   
  parameter S_WAIT_PEDGE = 2'b01; //read data바꿀 상태 데이터 low->high 40번 왔다갔다 해야함 
  parameter S_WAIT_NEDGE = 2'b10;
   
  reg [21:0] count_usec;
  wire clk_usec; 
  reg count_usec_e;
  clock_usec usec_clk(clk, reset_p, clk_usec);
   
 always @(negedge clk or posedge reset_p)begin 
// 처음엔 useccout가 삼만개개가 되면 다음 상태로 넘어감 
    if(reset_p) count_usec = 0; 
    else begin 
        if(clk_usec && count_usec_e) count_usec = count_usec +1;  // 1되었을 때마다 1cycle pusle가 나옴 
        else if( !count_usec_e) count_usec = 0; 
        //인에이블 1이면 마이크로세크 카우넡 1로 유지 0을주면 0으로 리셋됨  
    end  
 end 
 
    wire dht_pedge, dht_nedge; 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data), .p_edge(dht_pedge), .n_edge(dht_nedge)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 

    reg [5:0] state, next_state; 
    reg [1:0] read_state; 
    
    ////////////////추가 한 부분 
    assign led_bar [5:0] = state; 

     always @(negedge clk or posedge reset_p) begin 
        if(reset_p) state = S_IDLE; 
        else state = next_state; 
    end
   
   
   reg [39:0] temp_data; //data하나 씩 읽어서 여기다가 저장할 거임 
   reg [5:0] data_count; //data 40개 세기위해서 6bit사용 데이터 40개 들어오면 통신을 끝냄 
   
   reg dht11_buffer;
   assign dht11_data = dht11_buffer;
   
    always @(posedge clk or posedge reset_p) begin 
         if(reset_p) begin 
            count_usec_e = 0; //인에이블을 0으로 
            next_state = S_IDLE; 
            dht11_buffer = 1'bz;//data선에 처음에 임피던스 출력 
            read_state = S_WAIT_PEDGE; 
            data_count = 0; //datacount는 처음에는 0 아직 하나도 안받음 
       end 
       else begin //else문에서는 state를 봐야함 
           case(state) 
                S_IDLE: begin 
                    if(count_usec < 22'd3 ) begin //실제 : 3_000_000  simul: 3 
                        count_usec_e = 1;  //마이크로 카운트가 3초보다 작으면 1로 유지하도록 
                        dht11_buffer = 1'bz; //외부에서 결정됨 1이든 0이든 
                    end
                    else begin //3초가 지났음 다음 상태로 넘어가야함 , 마이크로세크 카운트 클리어 
                        next_state = S_LOW_18MS;
                        count_usec_e = 0; //인에이블 (카운트) clear( 다시 18Ms세야함) 
                    end
                 end
                S_LOW_18MS: begin   
                    if(count_usec < 22'd20_000) begin //10진수로 20ms표현 20ms아직 안지났을 때 
                        count_usec_e = 1; //카운트 시작 
                        dht11_buffer = 0; // 0출력으로 low로 떨어뜨림 
                    end
                    else begin //18ms 지났을 때 
                        count_usec_e = 0; //count클리어 
                        next_state = S_HIGH_20US; //다음스테이트로 넘어감 
                        dht11_buffer = 1'bz; // 버퍼에 임피던스 줘서 연결을 끊어줘야함 
                    end
                end     
                S_HIGH_20US : begin //high로 떨어지길 기다림   
                        count_usec_e = 1; 
                        if(dht_nedge) begin //neg엣지가 들어오면 넘어감 
                            next_state = S_LOW_80US;
                            count_usec_e = 0; 
                        end
                          if(count_usec > 22'd20_000)begin //20_000us 
                            next_state = S_IDLE;
                            count_usec_e = 0;
                           end
                      end                                
                S_LOW_80US  : begin 
                   count_usec_e = 1; 
                   if(dht_pedge) begin //neg엣지가 들어오면 넘어감 //neg엣지 기다림 = level이 high임 
                            next_state = S_HIGH_80US;
                            count_usec_e = 0; 
                   end
                   if(count_usec > 22'd20_000)begin
                            next_state = S_IDLE;
                            count_usec_e = 0;
                   end                           
                end
                 
                S_HIGH_80US: begin 
                     count_usec_e = 1; 
                      if(dht_nedge)begin //pedge뜨면 상태 바뀌니까 얘 기달 
                        next_state = S_READ_DATA;
                        count_usec_e = 0;
                     end
                     
                  if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                  end
               end            
                S_READ_DATA : begin //wait posedge, wait nedge data카운트 `1씩 증가시키고 데이터 40이 되면 그때 상태천이가 idle로 가면됨 
                    case(read_state)
                        S_WAIT_PEDGE : begin //pedge기다리는 상태 시간count필요없고 pedge만 기다리면 됨 
                            if(dht_pedge)begin
                            read_state = S_WAIT_NEDGE;
                            end
                            count_usec_e = 0; //엣지 뜨기 전까지는 0                            
                        end 
                        S_WAIT_NEDGE : begin
                            if(dht_nedge)begin
                                if(count_usec< 50 ) begin 
                                    temp_data = {temp_data[38:0], 1'b0} ;
                                end
                                else begin
                                     temp_data = {temp_data[38:0], 1'b1} ;                                   
                                end
                                data_count = data_count + 1; 
                                read_state = S_WAIT_PEDGE;
                            end
                            else begin 
                                count_usec_e = 1; //nedge상태에서는 카운트 필요 카운트 세겠다.
                            end
                        end
                    endcase  
                    if(data_count >= 40) begin //==보다 >=가 더 안전함 //data40개 다 받았음 
                        data_count = 0; 
                        next_state = S_IDLE;
                        humidity = temp_data [39:32];
                        temperature = temp_data[23:16];
                    end                         
                if(count_usec > 22'd50_000)begin
                        data_count =0; //나중에 추가한 코드 
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                default:next_state = S_IDLE;
            endcase
        end
    end   
endmodule


//-----------------------------------------------------------------------------------------//
module ultrasonic(
    input clk, reset_p,
    input echo, 
    output reg trigger,
    output reg [11:0] distance,
    output [3:0] led_bar
);
    
    parameter S_IDLE    = 3'b001;
    parameter TRI_10US  = 3'b010;
    parameter ECHO_STATE= 3'b100;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    reg [21:0] count_usec;
    wire clk_usec;  //us마다 one cycle 펄스가 나옴
    reg count_usec_e;
    
    clock_usec usec_clk(clk, reset_p, clk_usec);
        //us counter
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end

    wire echo_pedge, echo_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(echo), .p_edge(echo_pedge), .n_edge(echo_nedge));

    reg [3:0] state, next_state;
    reg [1:0] read_state;
    
    reg cnt_e;
    wire [11:0] cm;
    sr04_div58 div58(clk, reset_p, clk_usec, cnt_e, cm);
    
    assign led_bar[3:0] = state;

    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE; 
        else state = next_state;
    end
    
    reg [11:0] echo_time;
    
    //건드릴 애들은 그 always문 안에서 클리어 해줘야 됨. 리셋 했을 때.
    always @(posedge clk or posedge reset_p)begin 
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            trigger = 0;
            read_state = S_WAIT_PEDGE;
        end
        else begin
            case(state)
                S_IDLE:begin
                    if(count_usec < 22'd100_000)begin  //tb 돌릴 때는 22'd10정도로 줄여줌.
                        count_usec_e = 1; 
                         //trig = 0; 외부에서 결정됨 1이든 0이든 
                        //distance = 0;
                    end
                    else begin  //3초가 지났음 다음 상태로 넘어가야함 , 마이크로세크 카운트 클리어
                        next_state = TRI_10US;
                        count_usec_e = 0;   //인에이블 (카운트) clear( 다시 18Ms세야함) 
                    end
                end
                TRI_10US:begin 
                    if(count_usec <= 22'd10)begin 
                        count_usec_e = 1;  //카운트 시작 
                        trigger = 1;
                    end
                    else begin
                        count_usec_e = 0;
                        trigger = 0;
                        next_state = ECHO_STATE;
                    end
                end
                ECHO_STATE:begin 
                    case(read_state)
                        S_WAIT_PEDGE:begin
                            count_usec_e = 0;
                            if(echo_pedge)begin
                                read_state = S_WAIT_NEDGE;
                                cnt_e = 1;
                            end
                        end
                        S_WAIT_NEDGE:begin
                            if(echo_nedge)begin       
                                read_state = S_WAIT_PEDGE;
                                count_usec_e = 0;                    
                                distance = cm;
                                cnt_e = 0; //count clear                               
                                next_state = S_IDLE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end
                    endcase
                end
                default:next_state = S_IDLE;
            endcase
        end
    end
    
    
//    always @(posedge clk or posedge reset_p)begin
//        if(reset_p)distance = 0;
//        else begin
            
        
//            distance = echo_time / 58;
//            if(echo_time < 58) distance = 0;
//            else if(echo_time < 116) distance = 1;
//            else if(echo_time < 174) distance = 2;
//            else if(echo_time < 232) distance = 3;
//            else if(echo_time < 290) distance = 4;
//            else if(echo_time < 348) distance = 5;
//            else if(echo_time < 406) distance = 6;
//            else if(echo_time < 464) distance = 7;
//            else if(echo_time < 522) distance = 8;
//            else if(echo_time < 580) distance = 9;
//            else if(echo_time < 638) distance = 10;
//            else if(echo_time < 696) distance = 11;
//            else if(echo_time < 754) distance = 12;
//            else if(echo_time < 812) distance = 13;
//            else if(echo_time < 870) distance = 14;
//            else if(echo_time < 928) distance = 15;
//            else if(echo_time < 986) distance = 16;
//            else if(echo_time < 1044) distance = 17;
//            else if(echo_time < 1102) distance = 18;
//            else if(echo_time < 1160) distance = 19;
//            else if(echo_time < 1218) distance = 20;
//            else if(echo_time < 1276) distance = 21;
//            else if(echo_time < 1334) distance = 22;
//            else if(echo_time < 1392) distance = 23;
//            else if(echo_time < 1450) distance = 24;
//            else if(echo_time < 1508) distance = 25;
//            else if(echo_time < 1566) distance = 26;
//            else if(echo_time < 1624) distance = 27;
//            else if(echo_time < 1682) distance = 28;
//            else if(echo_time < 1740) distance = 29;
//            else if(echo_time < 1798) distance = 30;
            
//        end
//    end

endmodule



////-------------------------------------------------------------------------//
//////////////주파수 제어, 펄스 폭(듀티 비) 제어를 통한 LED 밝기 조절 ////////////////
module pwm_100pc (
    input clk, reset_p, 
    input [6:0] duty,        //sign in 100%
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_100pc );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX100;        //for % 단위100 count / duty:10% -> 10: 1, 90: 0 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX100 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >= sys_clk_freq / pwm_freq /100 -1)   cnt =0;  // 나누기 2는 토글을 위함 //100배 하기 위함 
            else cnt = cnt +1;    //분주기
//                pwm_freqX100 = ~pwm_freqX100;                     //클럭이 짝수인 경우 주파수 정확한 제어 불가 
                        
            if(cnt < sys_clk_freq / pwm_freq / 100 / 2) pwm_freqX100=0;
            else pwm_freqX100 = 1;   
        end
    end
    
      wire pwm_freqX100_nedge;
     edge_detector_n echo_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX100), .n_edge(pwm_freqX100_nedge));
    reg [6:0] cnt_duty; //count 100 
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            cnt_duty = 0; 
            pwm_100pc = 0;        
        end
        else begin
            if(pwm_freqX100_nedge)begin //100번마다 한 클럭씩 내보내줌 
                if(cnt_duty >=99) cnt_duty = 0;         //cnt_duty clear 
                else cnt_duty = cnt_duty +1;             //cnt_duty <99 
             
                if(cnt_duty< duty)pwm_100pc=1;          // duty-input ex) if duty=90, 
                else pwm_100pc =0;                      //when 100-duty(90) = 0 출력 
             end
             else begin
             
             end   
                  
        end   
    end 

endmodule

//-------------------------------------------------------------------------//
////////////128단계의 모터제어   ////////////////
module pwm_128step (
    input clk, reset_p, 
    input [6:0] duty,        //sign in 100%
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_128 ); //pc추가

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX128;        //for % 단위100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhz표현 
    assign temp = sys_clk_freq / pwm_freq; //temp자체는 clk에 영향이 없기 때문에 (조합회로) 따로 분주기 만들 필요 없음 
    
// //   integer cnt_sysclk;
//    always @(posedge clk or posedge reset_p) begin
//        if(reset_p) cnt_sysclk = 0; 
//        else if(cnt_sysclk >= pwm_freq -1) begin 
//            cnt_sysclk = 0;
//            temp=temp +1;
//        end      
//        else cnt_sysclk = cnt_sysclk +1;
//    end
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX128 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >=temp[26:7] -1)   cnt =0;       //나누기 하기 위해 7비트 시프트 //sts_clk/pwm_freq/128 -1 
            else cnt = cnt +1;    //분주기
//                pwm_freqX100 = ~pwm_freqX100;                     //클럭이 짝수인 경우 주파수 정확한 제어 불가 
                        
            if(cnt < temp[26:8]) pwm_freqX128=0; //나누기 256 //sts_clk/pwm_freq/128 /2
            else pwm_freqX128 = 1;   
        end
    end
    
      wire pwm_freqX128_nedge;
     edge_detector_n echo_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX128), .n_edge(pwm_freqX128_nedge));
    reg [6:0] cnt_duty; //count 128
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            cnt_duty = 0; 
            pwm_128 = 0;        
        end
        else begin
            if(pwm_freqX128_nedge)begin //100번마다 한 클럭씩 내보내줌 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 128 단계      
             
                if(cnt_duty< duty)pwm_128=1;          // duty-input ex) if duty=90, 
                else pwm_128 =0;                      //when 100-duty(90) = 0 출력 
             end
             else begin
             
             end   
                  
        end   
    end 

endmodule


//-------------------------------------------------------------------------//
////////////////256단계의 모터제어   ////////////////
//module pwm_256step_servormoter (
//    input clk, reset_p, 
//    input [9:0] duty,        //sign in 100%
//    input [13:0] pwm_freq,  //setting frequency 
//    output reg pwm_256 );

//    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
//    //100_000_000
//    integer cnt; 
//    //reg [26:0] cnt; //count 
//    reg pwm_freqX256;        //for % 단위100 count / duty:10% -> 10: 1, 90: 0 
    
//    wire [26:0] temp; //100Mhz표현 
//    assign temp = sys_clk_freq / pwm_freq; //temp자체는 clk에 영향이 없기 때문에 (조합회로) 따로 분주기 만들 필요 없음 
        
//    always @(posedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            pwm_freqX256 =0; 
//            cnt =0; 
//        end
//        else begin
//            if(cnt >=temp[26:8] -1)   cnt =0;       //나누기 하기 위해 8비트 시프트 //sts_clk/pwm_freq/256 -1 
//            else cnt = cnt +1;    //분주기
////                pwm_freqX100 = ~pwm_freqX100;                     //클럭이 짝수인 경우 주파수 정확한 제어 불가 
                        
//            if(cnt < temp[26:9]) pwm_freqX256=0; //나누기 512 //sts_clk/pwm_freq/256 /2
//            else pwm_freqX256 = 1;   
//        end
//    end
    
//      wire pwm_freqX256_nedge;
//     edge_detector_n echo_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX256), .n_edge(pwm_freqX256_nedge));
//    reg [7:0] cnt_duty; //count 256
   
////   reg down_up ; 
////   down_up = 
////  always @(posedge clk or posege reset_p) begin 
////     if(!down_up) count = 0;   //if~else가 mux 
////     else if 
////          count = count+1 ; 
////     if (down_up) co
////             count = count + 1; 
     
////     end
   
   
   
////   end
   
//    always @(posedge clk or posedge reset_p) begin 
//        if(reset_p) begin
//            cnt_duty = 0; 
//            pwm_256 = 0;        
//        end
//        else begin
//            if(pwm_freqX256_nedge)begin //100번마다 한 클럭씩 내보내줌 
             
//                cnt_duty = cnt_duty +1;  //cnt_duty = 256 단계      
             
//                if(cnt_duty< duty)pwm_256=1;          // duty-input ex) if duty=90, 
//                else pwm_256 =0;                      //when 100-duty(90) = 0 출력 
//             end
         
//        end   
//    end 

//endmodule
//////////////256단계의 모터제어   ////////////////혠ver
module pwm_256step_servomotor (
    input clk, reset_p, 
    input [7:0] duty,        //sign in 100%
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_256 );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX256;        //for % 단위100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhz표현 
    assign temp = sys_clk_freq / pwm_freq; //temp자체는 clk에 영향이 없기 때문에 (조합회로) 따로 분주기 만들 필요 없음 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX256 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >=temp[26:8] -1)   cnt =0;       //나누기 하기 위해 8비트 시프트 //sts_clk/pwm_freq/256 -1 
            else cnt = cnt +1;    //분주기
//                pwm_freqX100 = ~pwm_freqX100;                     //클럭이 짝수인 경우 주파수 정확한 제어 불가 
                        
            if(cnt < temp[26:9]) pwm_freqX256=0; //나누기 512 //sts_clk/pwm_freq/256 /2
            else pwm_freqX256 = 1;   
        end
    end
    
      wire pwm_freqX256_nedge;
     edge_detector_n echo_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX256), .n_edge(pwm_freqX256_nedge));
    reg [7:0] cnt_duty; //count 256
   
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            cnt_duty = 0; 
            pwm_256 = 0;        
        end
        else begin
            if(pwm_freqX256_nedge)begin //100번마다 한 클럭씩 내보내줌 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 256 단계      
             
                if(cnt_duty< duty)pwm_256=1;          // duty-input ex) if duty=90, 
                else pwm_256 =0;                      //when 100-duty(90) = 0 출력 
             end
         
        end   
    end 

endmodule

//ver.professor
//////////////256단계의 모터제어   ////////////////
module pwm_256step (
    input clk, reset_p, 
    input [7:0] duty,        //32까지 5:0 서보모터에서만 쓸 게 아니므로  count cnt_duty와 비트 수 맞춰줘야함 
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_256 );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX256;        //for % 단위100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhz표현 
    assign temp = sys_clk_freq / pwm_freq; //temp자체는 clk에 영향이 없기 때문에 (조합회로) 따로 분주기 만들 필요 없음 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX256 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >=temp[26:8] -1)   cnt =0;       //나누기 하기 위해 8비트 시프트 //sts_clk/pwm_freq/256 -1 
            else cnt = cnt +1;    //분주기
//                pwm_freqX100 = ~pwm_freqX100;                     //클럭이 짝수인 경우 주파수 정확한 제어 불가 
                        
            if(cnt < temp[26:9]) pwm_freqX256=0; //나누기 512 //sts_clk/pwm_freq/256 /2
            else pwm_freqX256 = 1;   
        end
    end
    
      wire pwm_freqX256_nedge;
     edge_detector_n echo_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX256), .n_edge(pwm_freqX256_nedge));
    reg [7:0] cnt_duty; //count 256
   
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            cnt_duty = 0; 
            pwm_256 = 0;        
        end
        else begin
            if(pwm_freqX256_nedge)begin //100번마다 한 클럭씩 내보내줌 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 256 단계      
             
                if(cnt_duty< duty)pwm_256=1;          // duty-input ex) if duty=90, 
                else pwm_256 =0;                      //when 100-duty(90) = 0 출력 
             end
         
        end   
    end 
endmodule


///////////////////////////////////////////////////////
//ver.professor
//////////////256단계의 모터제어   ////////////////
module pwm_512step (
    input clk, reset_p, 
    input [8:0] duty,        //64 까지 필요 but''duty랑 cnt_duty 맞춰주기 위함 
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_512 );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX512;        //for % 단위100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhz표현 
    assign temp = sys_clk_freq / pwm_freq; //temp자체는 clk에 영향이 없기 때문에 (조합회로) 따로 분주기 만들 필요 없음 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX512 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >=temp[26:9] -1)   cnt =0;       //나누기 하기 위해 8비트 시프트 //sts_clk/pwm_freq/256 -1 
            else cnt = cnt +1;    //분주기
//                pwm_freqX100 = ~pwm_freqX100;                     //클럭이 짝수인 경우 주파수 정확한 제어 불가 
                        
            if(cnt < temp[26:10]) pwm_freqX512=0; //나누기 512 //sts_clk/pwm_freq/256 /2
            else pwm_freqX512 = 1;   
        end
    end
    
      wire pwm_freqX512_nedge;
     edge_detector_n echo_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX512), .n_edge(pwm_freqX512_nedge));
    reg [8:0] cnt_duty; //count 512
   
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            cnt_duty = 0; 
            pwm_512 = 0;        
        end
        else begin
            if(pwm_freqX512_nedge)begin //100번마다 한 클럭씩 내보내줌 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 256 단계      
             
                if(cnt_duty< duty)pwm_512=1;          // duty-input ex) if duty=90, 
                else pwm_512 =0;                      //when 100-duty(90) = 0 출력 
             end
         
        end   
    end 
endmodule

//나누기를 하지 않기 위해서 주파수를 받는 것이 아니라 주기를 받음 
module pwm_512_period(
    input clk, reset_p,
    input [20:0] duty, //count 512
    input [20:0] pwm_period, //2000_000
    output reg pwm_512 );

//nedge는 우리가 카운트할 때마다 한 번식 움직임 
//인풋으로 받은 주기에 한 번씩 카운트 증가시킬 것임 
//    integer cnt; 
//    reg pwm_freqX512; 
    
//    always @(posedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            pwm_freqX512 =0; 
//            cnt =0; 
//        end
//        else begin
//            if(cnt >=pwm_period -1)   cnt =0;       ///sts_clk/pwm_freq
//            else cnt = cnt +1;    //분주기
                        
//            if(cnt < pwm_period[17:1]) pwm_freqX512=0; //나누기 2 -> shift로 표현 
//            else pwm_freqX512 = 1;   
//        end
//    end
        //39us * 512 = 20ms 
      reg [20:0] cnt_duty; //2000_000
  
     always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            cnt_duty = 0; 
            pwm_512 = 0;        
        end
        else begin  
            if(cnt_duty >= pwm_period -1 ) cnt_duty =0; 
            else cnt_duty = cnt_duty +1;  //cnt_duty = 256 단계      
               
             if(cnt_duty< duty)pwm_512=1;          // duty-input ex) if duty=90, 
             else pwm_512 =0;                      //when 100-duty(90) = 0 출력 
         end       
     end   

endmodule

//I2C 통신 master기준 only송신 
module I2C_master( //아이스퀘어씨라고 읽엉 
    input clk, reset_p,     //마스터로 송신만 할것임 
    input rd_wr, //read_write = 0: write 
    input [6:0] addr,//주소 7bit
    input [7:0] data, //보낼 data 8bit
    input valid,    //IDLE -> START로 넘어가기 위해 사용자가 데이터보내라고 할 때의 명령 
    output reg sda,  //test_lcd에다가 보내기만 할 것 ( 쓰기만 할것) 만일 읽기도 하려면 sda를 inout으로 잡아야함 
    output reg scl  ); 
    //통신 -> 순서가 있음 -> FSM 사용 
    parameter IDLE =        7'b000_0001;        //scl=1 , sda =1 인 상태 
    parameter COMM_START =  7'b000_0010;        //통신 start 
    parameter SND_ADDR =    7'b000_0100;        //address send
    parameter RD_ACK =      7'b000_1000;        //slave's ack(응답신호) - master -read
    parameter SND_DATA =    7'b001_0000;       //data send 
    parameter SCL_STOP =    7'b010_0000;       //clk stop 
    parameter COMM_STOP =   7'b100_0000;
    
    wire [7:0] addr_rw; 
    assign addr_rw = {addr, rd_wr}; //address는 7bit , 바로 뒤에 rd_wr나옴 
    
    wire clk_usec; // 1usec -> clk speed : Mhz *10개 -> 100Khz // 너무 빨라서 천천히 돌아가게 끔 만들어준 것 ( LCD패널 자체가 느리다) 
    clock_usec usec_clk( clk, reset_p, clk_usec);
    
    reg [2:0] count_usec5; 
    reg scl_toggle_e;   //10usec짜리 clk을 만들기 위해 5usec에서 toggle되는 클럭 만들기 위함 
    //scl_toggle_e : 10usec짜리 clk을 만들기 위해 클럭 셀거야! 말거야! 
    
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            count_usec5 =0; 
            scl = 1; 
        end
        else if(scl_toggle_e)begin
            if(clk_usec)begin 
                if(count_usec5  >= 4)begin  //1usec짜리 10분주기를 사용해서 5에서 토글되는 10usec의 1clk을 만듦 
                    count_usec5 =0; 
                    scl = ~scl; 
                end
               else  count_usec5 = count_usec5 +1; 
             end
        end
        else if(scl_toggle_e ==0) count_usec5 = 0 ; 
    end
    
    //rising edge - next_state 바꾸기 , polling edge - state 바꾸기 
    wire scl_nedge, scl_pedge;
    edge_detector_n ed_scl(.clk( clk), .reset_p(reset_p), .cp(scl), .n_edge(scl_nedge), .p_edge(scl_pedge)); 
    
  wire valid_pedge; //IDLE -> START로 넘어가기 위해 사용자가 데이터보내라고 할 때의 명령 
    edge_detector_n ed_valid(.clk( clk), .reset_p(reset_p), .cp(valid), .p_edge(valid_pedge));
    
    reg [6:0] state, next_state; 
    always @(negedge clk or posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end
    
    reg [2:0] cnt_bit; // 데이터 받을 때 최상위비트먼저 받아야함 8bit카운트 하는 것 
    reg stop_data;  //ack다음에 어떤 state가 와야하는지 결정 
    //stop_data = 1 ;ack다음 state: stop state, stop_data =0  :ack 다음 state : SND_DATA 
    always @(posedge clk, posedge reset_p) begin
        if(reset_p)begin
             sda= 1;    //초깃값 high
             next_state = IDLE; 
             scl_toggle_e =0; 
             cnt_bit =7; //MSB 카운트 비트 7부터 시작 
             stop_data =0; 
        end
        else begin
            case(state)
                IDLE:begin
                    if(valid_pedge) next_state = COMM_START; 
                end
                COMM_START : begin
                    sda =0;     //sda의 초깃값 = 1 * 1->0 으로 넘어갈 수 있게한 부분 
                    scl_toggle_e =1; //clk을 주기 시작 
                    next_state = SND_ADDR;
                end            
                SND_ADDR : begin
                    if(scl_nedge) //low에서 바꿈 sda 
                    sda = addr_rw[cnt_bit]; //MSB부터 보내야함 
                    else if(scl_pedge) begin
                        if(cnt_bit ==0) begin
                            cnt_bit = 7;    //다음 데이터 받을 수 있게 초기화 
                            next_state = RD_ACK;
                        end               
                        else cnt_bit = cnt_bit -1; // 7,6,5,4,3,2,1,0 보내기 그리고 ack보내기 위해 다음 state로 가기 
                   end
                end
                RD_ACK : begin  //원래 sda읽어와서 1인지 0인지 처리 but그냥 우린 기다려 알아서 잘 했거니 생각하자~ 
                    if(scl_nedge) sda = 'bz;        //zzzzzz전부 z    //한 클럭 버림 
                    else if(scl_pedge) begin
                         if(stop_data)begin 
                              stop_data=0; //초기화 
                              next_state = SCL_STOP;
                          end
                         else begin  
                            next_state = SND_DATA;
                            // stop_data =1; 여기에 안 넣고 SND_DATA에 넣어줌 
                         end  
                    end         
                end
                SND_DATA : begin 
                    if(scl_nedge) //low에서 바꿈 sda 
                        sda = data[cnt_bit]; //MSB부터 보내야함 
                    else if(scl_pedge) begin
                        if(cnt_bit ==0) begin
                            cnt_bit = 7; 
                            next_state = RD_ACK;
                            stop_data =1; 

                        end                      
                        else cnt_bit = cnt_bit -1; // 7,6,5,4,3,2,1,0 보내기 그리고 ack보내기 위해 다음 state로 가기 
                     end             
                end
                SCL_STOP :begin
                    if(scl_nedge)begin
                        sda =0; 
                    end
                    else if(scl_pedge)begin
                        next_state = COMM_STOP; 
                    end
                end
                COMM_STOP : begin   //통신 stop (stop) 
                    if(count_usec5 >=3) begin   //조금 기다려줬다가 
                        sda =1; //rising 만들어줌 // low-> hgih:stop 
                        scl_toggle_e =0;        //clk멈춤 
                        next_state = IDLE; 
                    end
                end              
             endcase
        end 
    end
endmodule
////-------------------------------------------------------------------------------------------//
//교수님 코드 
////-------------------------------------------------------------------------------------------//
module i2c_lcd_send_byte(
    input clk, reset_p,
    input [6:0] addr, 
    input [7:0] send_buffer,
    input send, rs,
    output scl, sda,
    output reg busy);
    
    
    parameter IDLE                      = 6'b00_0001;
    parameter SEND_HIGH_NIBBLE_DISABLE  = 6'b00_0010;
    parameter SEND_HIGH_NIBBLE_ENABLE   = 6'b00_0100;
    parameter SEND_LOW_NIBBLE_DISABLE   = 6'b00_1000;
    parameter SEND_LOW_NIBBLE_ENABLE    = 6'b01_0000;
    parameter SEND_DISABLE              = 6'b10_0000;
    
    reg [7:0] data;
    reg valid;
    
    wire send_pedge;
    edge_detector_n ed_send(.clk(clk), .reset_p(reset_p), 
                .cp(send), .p_edge(send_pedge));
    
    reg [21:0] count_usec;
    reg count_usec_e;
    wire clk_usec;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec = 0;
        end
        else begin
            if(clk_usec && count_usec_e)count_usec = count_usec + 1;
            else if(!count_usec_e)count_usec = 0;
        end
    end
    
    reg [5:0] state, next_state;
    always @(negedge clk or posedge reset_p)begin
        if(reset_p)state = IDLE;
        else state = next_state;
    end
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            next_state = IDLE;
            busy = 0;
        end
        else begin
            case(state)
                IDLE:begin
                    if(send_pedge)begin
                        next_state = SEND_HIGH_NIBBLE_DISABLE;
                        busy = 1;
                    end
                end
                SEND_HIGH_NIBBLE_DISABLE:begin
                    if(count_usec <= 22'd200)begin
                        data = {send_buffer[7:4], 3'b100, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_HIGH_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_HIGH_NIBBLE_ENABLE:begin
                    if(count_usec <= 22'd200)begin
                        data = {send_buffer[7:4], 3'b110, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_DISABLE:begin
                    if(count_usec <= 22'd200)begin
                        data = {send_buffer[3:0], 3'b100, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_LOW_NIBBLE_ENABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_LOW_NIBBLE_ENABLE:begin
                    if(count_usec <= 22'd200)begin
                        data = {send_buffer[3:0], 3'b110, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = SEND_DISABLE;
                        count_usec_e = 0;
                        valid = 0;
                    end
                end
                SEND_DISABLE:begin
                    if(count_usec <= 22'd200)begin
                        data = {send_buffer[3:0], 3'b100, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
                        valid = 1;
                        count_usec_e = 1;
                    end
                    else begin
                        next_state = IDLE;
                        count_usec_e = 0;
                        valid = 0;
                        busy = 0;
                    end
                end
            endcase
        end
    end
    
    I2C_master master(.clk(clk), .reset_p(reset_p),
        .rd_wr(0), .addr(7'h27), .data(data), .valid(valid), 
        .sda(sda), .scl(scl));

endmodule






////-------------------------------------------------------------------------------------------//
////내코드
//////-------------------------------------------------------------------------------------------//
//////i2c모듈을 4bit씩 나눠서 4번 보내는 과정 
//module i2c_lcd_send_byte(
//    input clk, reset_p,
//    input [6:0] addr, 
//    input [7:0] send_buffer,
//    input send, rs,  //send에서 보내라는 신호가 오면 다음 state로 보낸다. (보내기 시작해라!) 
//    output scl, sda,
//    output reg busy);
//     //NIBBLE = 4bit , BYTE = 8bit
//    parameter IDLE                       = 6'b00_0001;
//    parameter SEND_HIGH_NIBBLE_DISABLE   = 6'b00_0010;   
//    parameter SEND_HIGH_NIBBLE_ENABLE    = 6'b00_0100;    
//    parameter SEND_LOW_NIBBLE_DISABLE    = 6'b00_1000;    
//    parameter SEND_LOW_NIBBLE_ENABLE     = 6'b01_0000;    
//    parameter SEND_DISABLE               = 6'b10_0000;    

//    reg [7:0] data;
//    reg valid; 
  
//   wire send_pedge; 
//   edge_detector_n ed_send(.clk( clk), .reset_p(reset_p), .cp(send), .p_edge(send_pedge));
   
//    reg [21:0] count_usec; 
//    reg count_usec_e; 
//    wire clk_usec; 
//    clock_usec usec_clk(clk, reset_p, clk_usec);
    
//    //usec counter 기준 클럭 만들기 
//    always @(negedge clk , posedge reset_p) begin
//        if(reset_p) begin
//            count_usec =0; 
//        end
//        else  begin
//            if(clk_usec && count_usec_e) count_usec = count_usec + 1; 
//            else if(!count_usec_e) count_usec = 0; 
//        end
//    end 
   
//    reg [5:0] state, next_state; 
//    always @(negedge clk, posedge reset_p) begin
//        if(reset_p) state = IDLE; 
//        else state = next_state; 
//    end
    
//    always @(posedge clk , posedge reset_p) begin
//        if(reset_p)begin
//            next_state = IDLE; 
//            busy =0; 
//        end
//        else begin
//            case(state) 
//                IDLE:begin 
//                    if(send_pedge) begin 
//                        next_state = SEND_HIGH_NIBBLE_DISABLE;    
//                         busy =1;                                                                                                                                                                                                                                            //busy가 1인지 0인지를 보고 send를 하도록 
//                        //busy가 0일 때 send를 보냄 //통신선 사용중이라는 것 의미       
//                    end                       
//                 end 
//                SEND_HIGH_NIBBLE_DISABLE : begin 
//                    if(count_usec <= 22'd200) begin
//                         //200usec되기 전까지 밑에 data유지 
//                        data = {send_buffer [7:4], 3'b100, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                        valid =1;
//                        count_usec_e =1; 
//                    end
//                    else begin //200usec넘어서 들어왔을 때 
//                        next_state = SEND_HIGH_NIBBLE_ENABLE;
//                        count_usec_e = 0; 
//                        valid =0;
//                    end               
//                end
//                SEND_HIGH_NIBBLE_ENABLE : begin //enable 만 1로 바뀜 
//                    if(count_usec <= 22'd200) begin   //4.1ms 
//                         //200usec되기 전까지 밑에 data유지 
//                        data = {send_buffer [7:4], 3'b110, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                        valid =1;
//                        count_usec_e =1; 
//                    end
//                    else begin //200usec넘어서 들어왔을 때 
//                        next_state = SEND_LOW_NIBBLE_DISABLE;
//                        count_usec_e = 0; 
//                        valid =0;
//                    end               
//                end               
//                SEND_LOW_NIBBLE_DISABLE :begin
//                  if(count_usec <= 22'd200) begin
//                             //200usec되기 전까지 밑에 data유지 
//                            data = {send_buffer [3:0], 3'b100, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                            valid =1;
//                            count_usec_e =1; 
//                        end
//                        else begin //200usec넘어서 들어왔을 때 
//                            next_state = SEND_LOW_NIBBLE_ENABLE;
//                            count_usec_e = 0; 
//                            valid =0;
//                        end               
//                    end    
//                  SEND_LOW_NIBBLE_ENABLE: begin  
//                    if(count_usec <= 22'd200) begin
//                             //200usec되기 전까지 밑에 data유지 
//                            data = {send_buffer [3:0], 3'b110, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                            valid =1;
//                            count_usec_e =1; 
//                        end
//                        else begin //200usec넘어서 들어왔을 때 
//                            next_state = SEND_DISABLE;
//                            count_usec_e = 0; 
//                            valid =0;
//                        end               
//                    end                                
//                   SEND_DISABLE: begin             //마지막 data는 enable만 visiable주면됨 enable은 0을 유지해야해 내가 쓰고 싶을 때만 
//                     if(count_usec <= 22'd200) begin
//                             //200usec되기 전까지 밑에 data유지 
//                            data = {send_buffer [3:0], 3'b100, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                            valid =1;
//                            count_usec_e =1; 
//                        end
//                        else begin //200usec넘어서 들어왔을 때 
//                            next_state = IDLE;
//                            count_usec_e = 0; 
//                            valid =0;
//                            busy =0; 
//                        end               
//                    end                       
//            endcase
//         end
//    end
      
//       I2C_master mater( .clk(clk), .reset_p(reset_p), .rd_wr(0), .addr(7'h27), .data(data),
//     .valid(valid), .sda(sda), .scl(scl)); 
// endmodule 
 ////////////////////////////
 module dht11(   
    input clk, reset_p,
    inout dht11_data,   // 선 하나로 송수신 다 함. 
    output reg [7:0] humidity, temperature, 
    output wire [7:0] led_bar    
);

    parameter S_IDLE        = 6'b000001;
    parameter S_LOW_18MS    = 6'b000010;
    parameter S_HIGH_20US   = 6'b000100;
    parameter S_LOW_80US    = 6'b001000;
    parameter S_HIGH_80US   = 6'b010000;
    parameter S_READ_DATA   = 6'b100000;

//-----------
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    
    reg [21:0] count_usec;
    wire clk_usec;  
    reg count_usec_e;
    clock_usec usec_clk(clk, reset_p, clk_usec);
    
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end

    wire dht_pedge, dht_nedge;
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data), .p_edge(dht_pedge), .n_edge(dht_nedge)); 

    reg [5:0] state, next_state;
    reg [1:0] read_state;   //40번 왔다 갔다 할 상태
    
    assign led_bar[5:0] = state;
    
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = S_IDLE;
        else state = next_state;
    end
      
    reg [39:0] temp_data;  
    reg [5:0] data_count;

    reg dht11_buffer;
    assign dht11_data = dht11_buffer;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;     
            dht11_buffer = 1'bz;            
            read_state = S_WAIT_PEDGE;
            data_count = 0;            
        end

        else begin
            case(state)
                S_IDLE : begin
                    if(count_usec < 22'd3_000_000)begin 
                        count_usec_e = 1;
                        dht11_buffer = 1'bz; 
                    end
                    else begin
                        next_state = S_LOW_18MS;
                        count_usec_e = 0;   
                    end
                end
                
                S_LOW_18MS : begin
                    if(count_usec < 22'd20_000)begin 
                       count_usec_e = 1;
                       dht11_buffer = 0; 
                    end
                    else begin
                        count_usec_e = 0;
                        next_state = S_HIGH_20US;
                        dht11_buffer = 1'bz;
                    end
                end
                
                S_HIGH_20US : begin
                        count_usec_e = 1;
                        if(dht_nedge)begin
                            next_state = S_LOW_80US;    
                            count_usec_e = 0;
                        end
//                            if(dht_nedge) begin
//                                next_state = S_IDLE;
//                            end
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;    
                    end
                end
                                  
                S_LOW_80US : begin
                    count_usec_e = 1;
                    if(dht_pedge)begin
                        next_state = S_HIGH_80US;
                        count_usec_e = 0;
                    end
                    
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;    
                    end
                end             
                S_HIGH_80US : begin
                    count_usec_e = 1;
                    if(dht_nedge)begin
                        next_state = S_READ_DATA;
                    end
                    
                    if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;    
                    end
                end
    //---------------------------------            
                S_READ_DATA : begin
                    case(read_state)
                        S_WAIT_PEDGE : begin
                            if(dht_pedge)begin
                                read_state = S_WAIT_NEDGE; 
                            end
                            count_usec_e = 0;
                        end
                        
                        S_WAIT_NEDGE : begin
                            if(dht_nedge)begin
                                if(count_usec < 45)begin
                                    temp_data = {temp_data[38:0], 1'b0};
                                end
                                else begin
                                    temp_data = {temp_data[38:0], 1'b1};
                                end
                                data_count =  data_count + 1;
                                read_state =  S_WAIT_PEDGE;
                            end
                            else begin
                                count_usec_e = 1;
                            end
                        end 
                    endcase      
                    if(data_count >= 40)begin
                        data_count = 0;
                        next_state = S_IDLE;
                        humidity = temp_data[39:32];
                        temperature = temp_data[23:16];
                    end
                    if(count_usec > 22'd50_000)begin
                        data_count = 0;
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                
                default : next_state = S_IDLE;                
                
            endcase
        end
    end                            
endmodule
 //////////////////////////// //////////////////////////// //////////////////////////// ////////////////////////////

 module led_3(
 input clk,
 input reset_p,
 input [6:0]r_in,
 inout [6:0]g_in,
 input [6:0]b_in,
 output r_out, b_out, g_out);
 
 
  pwm_128step pwm_led_r(.clk(clk), .reset_p(reset_p),.duty(r_in),.pwm_freq(10_000), .pwm_128(r_out));
  pwm_128step pwm_led_g(.clk(clk), .reset_p(reset_p),.duty(g_in),.pwm_freq(10_000), .pwm_128(g_out));
  pwm_128step pwm_led_b(.clk(clk), .reset_p(reset_p),.duty(b_in),.pwm_freq(10_000), .pwm_128(b_out));
 
 endmodule






