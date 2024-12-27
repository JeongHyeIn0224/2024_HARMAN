`timescale 1ns / 1ps
//���� �����͸� �ٸ� ��⿡�� �ҷ��� �ٷ� ����� �� �ֵ��� ����� ������ 
module button_cntr(
    input clk, reset_p,
    input btn,
    output btn_pe,btn_ne);
        
     reg [16:0] clk_div ; //���ֱ� ����� 
     wire clk_div_16; 
     reg [3 :0] debounced_btn;
            
    always @(posedge clk) clk_div = clk_div +1; //clk�� ���� �����ϴ� ���ֱ� 
             
    edge_detector_n ed1(.clk( clk) , 
                    .reset_p(reset_p),
                    .cp(clk_div[16]), 
                    .p_edge(clk_div_16));    
                 
     always @(posedge clk, posedge reset_p) begin //ä�͸� �����ϱ� ���� ���ֱ�� 1ms�� �ֱ⸦ �ٲ� 
                if(reset_p) debounced_btn = 0; 
                else if (clk_div_16) debounced_btn = btn;
     end
                         
     edge_detector_n ed2(.clk( clk) , 
                     .reset_p(reset_p),
                     .cp(debounced_btn),
                     .p_edge(btn_pe), //��ư���� �� ���� ��Ŵ ���� �� ���� ���� ���� �ð� ������ ��Ű�Է� 
                     .n_edge(btn_ne)); //��ư �� �� ���� ��Ŵ n_edge�ϱ� 
endmodule


//////////////////////////////////////////////////////////////////////////////
//fnd��Ʈ�ѷ� 
module fnd_4digit_cntr(
    input clk,reset_p,
    input [15:0] value,//value 16bit���� ���� 
    output [7:0] seg_7_an, seg_7_ca, //an(�ֳ��Ÿ��)-0�϶�����, ca(ĳ�ҵ�Ÿ��)-1�� ������ 
    output [3:0] com);

    reg [3:0] hex_value;
      
     ring_counter_fnd rc (.clk(clk), .reset_p(reset_p), .com(com));
    
   
    always @(posedge clk) begin  //��� ���,��µǴ� �ֱ� �� ���� 
        case(com)
        4'b0111 : hex_value = value[15:12];   //value�� 4��Ʈ��(0~f)���� ����� �� �ֵ��� �� 
        4'b1011 : hex_value = value[11:8];  //value�� ���� hex_value�� �־ �Һ� ��� 
        4'b1101 : hex_value = value[7:4];  //hex_value = �Һ� 
        4'b1110 : hex_value = value[3:0];   
        endcase
    end

//�� ����� �ٸ� ���� �ν��Ͻ� �ҰŴϱ� 0�϶��� 1�϶��� ��� ���� �� �ֵ��� �ڵ带 ������� 
    decoder_7seg fnd(.hex_value(hex_value), .seg_7(seg_7_an)); //�ֳ�� Ÿ�� �ޱ� - 0�� �� ���� 
    assign seg_7_ca = ~seg_7_an; //ĳ�ҵ� Ÿ�� �ޱ� - 1�� �� ���� 
    
endmodule

//Ű�е� ��Ʈ�ѷ� 
module key_pad_cntr(
    input clk, reset_p,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value, //key 16���� ǥ���ϱ� ���� ->4bit����� 
    output reg key_valid //key���� �ٲ�� 1 �ȴ����� 0      //0������ 0 1�̸� 1 �ƹ��͵� �ȴ����� �� ��ȣ �ޱ� ����

    );  
    //ring counter ���� �� �� clk_div
    reg  [19:0] clk_div; //8ms �� ���дµ� �ɸ��� �ð�  4�� �дµ� �� �ɸ��� �ð� :32ms
    
    always @ (posedge clk) clk_div = clk_div+1; 
  
    wire clk_8msec_p,clk_8msec_n; //8msec�� �� ���� ���� 
    
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[19]), .p_edge(clk_8msec_p), .n_edge(clk_8msec_n));
    
   always @ (posedge clk or posedge reset_p) begin 
        if(reset_p) col = 4'b0001; 
        else if(clk_8msec_p && !key_valid)begin //key_valid�� 1�� �ƴ� ��(0�� ��-�ƹ� �͵� �ȴ����� �� ) col�� �ٲ� 
                case(col) //valid= 0 ineable, valid =1 visiable 
                    4'b0001 :col = 4'b0010;// clk_8msec_p Ŭ���� ���� ������ ��ī���� ó�� �ٲ��. 
                    4'b0010 :col = 4'b0100;
                     4'b0100:col = 4'b1000;
                    4'b1000 :col = 4'b0001;
                    default: col = 4'b0001;
             endcase
        end            
   end
   
   always @(posedge clk, posedge reset_p) begin
    if(reset_p) begin //reset������ 0
        key_value = 0;  
        key_valid = 0;    
        
    end
    else begin //Ű�� 0000�̸� �ƹ����� �ȵ��� ���� �ϳ��� 1������ �ű⿡ �� ���� �� 
        if(clk_8msec_n) begin // ���� �̰� ������ . 
            if(row ) begin  //row���� 0�� �ƴ� �� ��� �� �ϳ� 1������ Ű�� �ϳ� �����ٴ� �� 
                key_valid = 1; 
                case({col,row}) //� Ű�� ���ȳĿ� ���� key_value�� ���� 
                    8'b0001_0001 : key_value = 4'h7; // 4��Ʈ ��� ������ 0 
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
            else begin //row �� 0�̸� Ű �Է��� ���ٴ� �� 
                key_valid = 0;  //key_valid�ٲٴ� �� 8mec�� �� ���� 
                key_value = 0; 
    //0�� Ű ������ �� key_value�ȹٲ� 0��Ű ���ȴ��� �ȴ��ȴ����� key_valid������ 
              end
          end
   end
end
endmodule

//���ѻ��¸ӽŸ���� 
//1������ count+1, 2������ count -1 �ǰ� �� 
module keypad_cntr_FSM(
    input clk,reset_p,
    input [3:0] row,
    output reg [3:0] col,
    output reg [3:0] key_value,
    output reg key_valid);

//parameter ����: ��� ���� ���̻� �� �ٲ��� ����  
    parameter SCAN_0 = 1; 
    parameter SCAN_1 = 2; //5'b00010
    parameter SCAN_2 = 3; //5'b00100; 
    parameter SCAN_3 = 4; 
    parameter KEY_PROCESS = 5; 
    
    reg [2:0] state, next_state; //state�� 0~7����(2^3) ����� �� ���� 3��Ʈ 
                                //5'b00010�Ǹ� reg [4:0] �� �Ǿ���� 5bit 
  //FSM case������ ��Ÿ���� 
  //����õ�� ���� = only row(Ű�� ���ȳ� �ȴ��ȳ�)   
  //���� ȸ�� �տ� �� 
    always @* begin
        case(state)
            SCAN_0 : begin 
                if(row==0) next_state =  SCAN_1;//next_state�� 2�� 
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
  //state �� next_state �� ���� 
  //�ø��÷� ���ʿ� ���� 
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) state = SCAN_0; 
        else if(clk_8msec) state = next_state; 
    end
     
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) begin 
            key_value = 0; //key_value �ʱ�ȭ 
            key_valid = 0; 
            col = 4'b0001; 
        end
        else begin 
            case(state) 
                SCAN_0 : begin col = 4'b0001; key_valid = 0; end //SCAN0�� �ӹ��µ��� key_valid�� 0�� 
                SCAN_1 : begin col = 4'b0010; key_valid = 0; end 
                SCAN_2 : begin col = 4'b0100; key_valid = 0; end 
                SCAN_3 : begin col = 4'b1000; key_valid = 0; end 
                KEY_PROCESS :begin
                   key_valid = 1;
                   case({col,row}) //� Ű�� ���ȳĿ� ���� key_value�� ���� 
                    8'b0001_0001 : key_value = 4'h7; // 4��Ʈ ��� ������ 0 
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


///////////////////////FSM �½��� ���� ////////////////////////////////
module dht11_mine( //���ڵ� 
    input clk, reset_p,
    inout dht11_data,//  �� �ϳ������� ��ǲ�� �ǰ� �ƿ�ǲ�� �Ǿ���� signal �� �� �ϳ��� ���� 
    output reg [7:0] humidity, temperature, // data40bit������ �� �߿��� �ӵ��� �µ��� �����Ұž�
    output [7:0]led_bar); //������� ���� led����� ����� ����   
   
   parameter S_IDLE      = 6'b000001;
   parameter S_LOW_18MS  = 6'b000010; 
   parameter S_HIGH_20US = 6'b000100;
   parameter S_LOW_80US  = 6'b001000; //�����Ʈ 
   parameter S_HIGH_80US = 6'b010000; //�����Ʈ 
   parameter S_READ_DATA = 6'b100000;               //�Է¼��� �����޾Ƽ� ��� 
   
  parameter S_WAIT_PEDGE = 2'b01; //read data�ٲ� ���� ������ low->high 40�� �Դٰ��� �ؾ��� 
  parameter S_WAIT_NEDGE = 2'b10;
   
  reg [21:0] count_usec;
  wire clk_usec; 
  reg count_usec_e;
  clock_usec usec_clk(clk, reset_p, clk_usec);
   
 always @(negedge clk or posedge reset_p)begin 
// ó���� useccout�� �︸������ �Ǹ� ���� ���·� �Ѿ 
    if(reset_p) count_usec = 0; 
    else begin 
        if(clk_usec && count_usec_e) count_usec = count_usec +1;  // 1�Ǿ��� ������ 1cycle pusle�� ���� 
        else if( !count_usec_e) count_usec = 0; 
        //�ο��̺� 1�̸� ����ũ�μ�ũ ī�솥 1�� ���� 0���ָ� 0���� ���µ�  
    end  
 end 
 
    wire dht_pedge, dht_nedge; 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data), .p_edge(dht_pedge), .n_edge(dht_nedge)); //t-ff���� ���ϱ� posedge�� �� ��ƾ��� button�� �ƴϴϱ� nedge������ �ȵ� 

    reg [5:0] state, next_state; 
    reg [1:0] read_state; 
    
    ////////////////�߰� �� �κ� 
    assign led_bar [5:0] = state; 

     always @(negedge clk or posedge reset_p) begin 
        if(reset_p) state = S_IDLE; 
        else state = next_state; 
    end
   
   
   reg [39:0] temp_data; //data�ϳ� �� �о ����ٰ� ������ ���� 
   reg [5:0] data_count; //data 40�� �������ؼ� 6bit��� ������ 40�� ������ ����� ���� 
   
   reg dht11_buffer;
   assign dht11_data = dht11_buffer;
   
    always @(posedge clk or posedge reset_p) begin 
         if(reset_p) begin 
            count_usec_e = 0; //�ο��̺��� 0���� 
            next_state = S_IDLE; 
            dht11_buffer = 1'bz;//data���� ó���� ���Ǵ��� ��� 
            read_state = S_WAIT_PEDGE; 
            data_count = 0; //datacount�� ó������ 0 ���� �ϳ��� �ȹ��� 
       end 
       else begin //else�������� state�� ������ 
           case(state) 
                S_IDLE: begin 
                    if(count_usec < 22'd3 ) begin //���� : 3_000_000  simul: 3 
                        count_usec_e = 1;  //����ũ�� ī��Ʈ�� 3�ʺ��� ������ 1�� �����ϵ��� 
                        dht11_buffer = 1'bz; //�ܺο��� ������ 1�̵� 0�̵� 
                    end
                    else begin //3�ʰ� ������ ���� ���·� �Ѿ���� , ����ũ�μ�ũ ī��Ʈ Ŭ���� 
                        next_state = S_LOW_18MS;
                        count_usec_e = 0; //�ο��̺� (ī��Ʈ) clear( �ٽ� 18Ms������) 
                    end
                 end
                S_LOW_18MS: begin   
                    if(count_usec < 22'd20_000) begin //10������ 20msǥ�� 20ms���� �������� �� 
                        count_usec_e = 1; //ī��Ʈ ���� 
                        dht11_buffer = 0; // 0������� low�� ����߸� 
                    end
                    else begin //18ms ������ �� 
                        count_usec_e = 0; //countŬ���� 
                        next_state = S_HIGH_20US; //����������Ʈ�� �Ѿ 
                        dht11_buffer = 1'bz; // ���ۿ� ���Ǵ��� �༭ ������ ��������� 
                    end
                end     
                S_HIGH_20US : begin //high�� �������� ��ٸ�   
                        count_usec_e = 1; 
                        if(dht_nedge) begin //neg������ ������ �Ѿ 
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
                   if(dht_pedge) begin //neg������ ������ �Ѿ //neg���� ��ٸ� = level�� high�� 
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
                      if(dht_nedge)begin //pedge�߸� ���� �ٲ�ϱ� �� ��� 
                        next_state = S_READ_DATA;
                        count_usec_e = 0;
                     end
                     
                  if(count_usec > 22'd20_000)begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                  end
               end            
                S_READ_DATA : begin //wait posedge, wait nedge dataī��Ʈ `1�� ������Ű�� ������ 40�� �Ǹ� �׶� ����õ�̰� idle�� ����� 
                    case(read_state)
                        S_WAIT_PEDGE : begin //pedge��ٸ��� ���� �ð�count�ʿ���� pedge�� ��ٸ��� �� 
                            if(dht_pedge)begin
                            read_state = S_WAIT_NEDGE;
                            end
                            count_usec_e = 0; //���� �߱� �������� 0                            
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
                                count_usec_e = 1; //nedge���¿����� ī��Ʈ �ʿ� ī��Ʈ ���ڴ�.
                            end
                        end
                    endcase  
                    if(data_count >= 40) begin //==���� >=�� �� ������ //data40�� �� �޾��� 
                        data_count = 0; 
                        next_state = S_IDLE;
                        humidity = temp_data [39:32];
                        temperature = temp_data[23:16];
                    end                         
                if(count_usec > 22'd50_000)begin
                        data_count =0; //���߿� �߰��� �ڵ� 
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
    wire clk_usec;  //us���� one cycle �޽��� ����
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
    
    //�ǵ帱 �ֵ��� �� always�� �ȿ��� Ŭ���� ����� ��. ���� ���� ��.
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
                    if(count_usec < 22'd100_000)begin  //tb ���� ���� 22'd10������ �ٿ���.
                        count_usec_e = 1; 
                         //trig = 0; �ܺο��� ������ 1�̵� 0�̵� 
                        //distance = 0;
                    end
                    else begin  //3�ʰ� ������ ���� ���·� �Ѿ���� , ����ũ�μ�ũ ī��Ʈ Ŭ����
                        next_state = TRI_10US;
                        count_usec_e = 0;   //�ο��̺� (ī��Ʈ) clear( �ٽ� 18Ms������) 
                    end
                end
                TRI_10US:begin 
                    if(count_usec <= 22'd10)begin 
                        count_usec_e = 1;  //ī��Ʈ ���� 
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
//////////////���ļ� ����, �޽� ��(��Ƽ ��) ��� ���� LED ��� ���� ////////////////
module pwm_100pc (
    input clk, reset_p, 
    input [6:0] duty,        //sign in 100%
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_100pc );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX100;        //for % ����100 count / duty:10% -> 10: 1, 90: 0 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX100 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >= sys_clk_freq / pwm_freq /100 -1)   cnt =0;  // ������ 2�� ����� ���� //100�� �ϱ� ���� 
            else cnt = cnt +1;    //���ֱ�
//                pwm_freqX100 = ~pwm_freqX100;                     //Ŭ���� ¦���� ��� ���ļ� ��Ȯ�� ���� �Ұ� 
                        
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
            if(pwm_freqX100_nedge)begin //100������ �� Ŭ���� �������� 
                if(cnt_duty >=99) cnt_duty = 0;         //cnt_duty clear 
                else cnt_duty = cnt_duty +1;             //cnt_duty <99 
             
                if(cnt_duty< duty)pwm_100pc=1;          // duty-input ex) if duty=90, 
                else pwm_100pc =0;                      //when 100-duty(90) = 0 ��� 
             end
             else begin
             
             end   
                  
        end   
    end 

endmodule

//-------------------------------------------------------------------------//
////////////128�ܰ��� ��������   ////////////////
module pwm_128step (
    input clk, reset_p, 
    input [6:0] duty,        //sign in 100%
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_128 ); //pc�߰�

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX128;        //for % ����100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhzǥ�� 
    assign temp = sys_clk_freq / pwm_freq; //temp��ü�� clk�� ������ ���� ������ (����ȸ��) ���� ���ֱ� ���� �ʿ� ���� 
    
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
            if(cnt >=temp[26:7] -1)   cnt =0;       //������ �ϱ� ���� 7��Ʈ ����Ʈ //sts_clk/pwm_freq/128 -1 
            else cnt = cnt +1;    //���ֱ�
//                pwm_freqX100 = ~pwm_freqX100;                     //Ŭ���� ¦���� ��� ���ļ� ��Ȯ�� ���� �Ұ� 
                        
            if(cnt < temp[26:8]) pwm_freqX128=0; //������ 256 //sts_clk/pwm_freq/128 /2
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
            if(pwm_freqX128_nedge)begin //100������ �� Ŭ���� �������� 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 128 �ܰ�      
             
                if(cnt_duty< duty)pwm_128=1;          // duty-input ex) if duty=90, 
                else pwm_128 =0;                      //when 100-duty(90) = 0 ��� 
             end
             else begin
             
             end   
                  
        end   
    end 

endmodule


//-------------------------------------------------------------------------//
////////////////256�ܰ��� ��������   ////////////////
//module pwm_256step_servormoter (
//    input clk, reset_p, 
//    input [9:0] duty,        //sign in 100%
//    input [13:0] pwm_freq,  //setting frequency 
//    output reg pwm_256 );

//    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
//    //100_000_000
//    integer cnt; 
//    //reg [26:0] cnt; //count 
//    reg pwm_freqX256;        //for % ����100 count / duty:10% -> 10: 1, 90: 0 
    
//    wire [26:0] temp; //100Mhzǥ�� 
//    assign temp = sys_clk_freq / pwm_freq; //temp��ü�� clk�� ������ ���� ������ (����ȸ��) ���� ���ֱ� ���� �ʿ� ���� 
        
//    always @(posedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            pwm_freqX256 =0; 
//            cnt =0; 
//        end
//        else begin
//            if(cnt >=temp[26:8] -1)   cnt =0;       //������ �ϱ� ���� 8��Ʈ ����Ʈ //sts_clk/pwm_freq/256 -1 
//            else cnt = cnt +1;    //���ֱ�
////                pwm_freqX100 = ~pwm_freqX100;                     //Ŭ���� ¦���� ��� ���ļ� ��Ȯ�� ���� �Ұ� 
                        
//            if(cnt < temp[26:9]) pwm_freqX256=0; //������ 512 //sts_clk/pwm_freq/256 /2
//            else pwm_freqX256 = 1;   
//        end
//    end
    
//      wire pwm_freqX256_nedge;
//     edge_detector_n echo_ed(.clk(clk), .reset_p(reset_p), .cp(pwm_freqX256), .n_edge(pwm_freqX256_nedge));
//    reg [7:0] cnt_duty; //count 256
   
////   reg down_up ; 
////   down_up = 
////  always @(posedge clk or posege reset_p) begin 
////     if(!down_up) count = 0;   //if~else�� mux 
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
//            if(pwm_freqX256_nedge)begin //100������ �� Ŭ���� �������� 
             
//                cnt_duty = cnt_duty +1;  //cnt_duty = 256 �ܰ�      
             
//                if(cnt_duty< duty)pwm_256=1;          // duty-input ex) if duty=90, 
//                else pwm_256 =0;                      //when 100-duty(90) = 0 ��� 
//             end
         
//        end   
//    end 

//endmodule
//////////////256�ܰ��� ��������   ////////////////��ver
module pwm_256step_servomotor (
    input clk, reset_p, 
    input [7:0] duty,        //sign in 100%
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_256 );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX256;        //for % ����100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhzǥ�� 
    assign temp = sys_clk_freq / pwm_freq; //temp��ü�� clk�� ������ ���� ������ (����ȸ��) ���� ���ֱ� ���� �ʿ� ���� 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX256 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >=temp[26:8] -1)   cnt =0;       //������ �ϱ� ���� 8��Ʈ ����Ʈ //sts_clk/pwm_freq/256 -1 
            else cnt = cnt +1;    //���ֱ�
//                pwm_freqX100 = ~pwm_freqX100;                     //Ŭ���� ¦���� ��� ���ļ� ��Ȯ�� ���� �Ұ� 
                        
            if(cnt < temp[26:9]) pwm_freqX256=0; //������ 512 //sts_clk/pwm_freq/256 /2
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
            if(pwm_freqX256_nedge)begin //100������ �� Ŭ���� �������� 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 256 �ܰ�      
             
                if(cnt_duty< duty)pwm_256=1;          // duty-input ex) if duty=90, 
                else pwm_256 =0;                      //when 100-duty(90) = 0 ��� 
             end
         
        end   
    end 

endmodule

//ver.professor
//////////////256�ܰ��� ��������   ////////////////
module pwm_256step (
    input clk, reset_p, 
    input [7:0] duty,        //32���� 5:0 �������Ϳ����� �� �� �ƴϹǷ�  count cnt_duty�� ��Ʈ �� ��������� 
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_256 );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX256;        //for % ����100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhzǥ�� 
    assign temp = sys_clk_freq / pwm_freq; //temp��ü�� clk�� ������ ���� ������ (����ȸ��) ���� ���ֱ� ���� �ʿ� ���� 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX256 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >=temp[26:8] -1)   cnt =0;       //������ �ϱ� ���� 8��Ʈ ����Ʈ //sts_clk/pwm_freq/256 -1 
            else cnt = cnt +1;    //���ֱ�
//                pwm_freqX100 = ~pwm_freqX100;                     //Ŭ���� ¦���� ��� ���ļ� ��Ȯ�� ���� �Ұ� 
                        
            if(cnt < temp[26:9]) pwm_freqX256=0; //������ 512 //sts_clk/pwm_freq/256 /2
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
            if(pwm_freqX256_nedge)begin //100������ �� Ŭ���� �������� 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 256 �ܰ�      
             
                if(cnt_duty< duty)pwm_256=1;          // duty-input ex) if duty=90, 
                else pwm_256 =0;                      //when 100-duty(90) = 0 ��� 
             end
         
        end   
    end 
endmodule


///////////////////////////////////////////////////////
//ver.professor
//////////////256�ܰ��� ��������   ////////////////
module pwm_512step (
    input clk, reset_p, 
    input [8:0] duty,        //64 ���� �ʿ� but''duty�� cnt_duty �����ֱ� ���� 
    input [13:0] pwm_freq,  //setting frequency 
    output reg pwm_512 );

    parameter sys_clk_freq = 100_000_000 ; //basys:100Mhz, cora:125Mhz
    //100_000_000
    integer cnt; 
    //reg [26:0] cnt; //count 
    reg pwm_freqX512;        //for % ����100 count / duty:10% -> 10: 1, 90: 0 
    
    wire [26:0] temp; //100Mhzǥ�� 
    assign temp = sys_clk_freq / pwm_freq; //temp��ü�� clk�� ������ ���� ������ (����ȸ��) ���� ���ֱ� ���� �ʿ� ���� 
    
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            pwm_freqX512 =0; 
            cnt =0; 
        end
        else begin
            if(cnt >=temp[26:9] -1)   cnt =0;       //������ �ϱ� ���� 8��Ʈ ����Ʈ //sts_clk/pwm_freq/256 -1 
            else cnt = cnt +1;    //���ֱ�
//                pwm_freqX100 = ~pwm_freqX100;                     //Ŭ���� ¦���� ��� ���ļ� ��Ȯ�� ���� �Ұ� 
                        
            if(cnt < temp[26:10]) pwm_freqX512=0; //������ 512 //sts_clk/pwm_freq/256 /2
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
            if(pwm_freqX512_nedge)begin //100������ �� Ŭ���� �������� 
             
                cnt_duty = cnt_duty +1;  //cnt_duty = 256 �ܰ�      
             
                if(cnt_duty< duty)pwm_512=1;          // duty-input ex) if duty=90, 
                else pwm_512 =0;                      //when 100-duty(90) = 0 ��� 
             end
         
        end   
    end 
endmodule

//�����⸦ ���� �ʱ� ���ؼ� ���ļ��� �޴� ���� �ƴ϶� �ֱ⸦ ���� 
module pwm_512_period(
    input clk, reset_p,
    input [20:0] duty, //count 512
    input [20:0] pwm_period, //2000_000
    output reg pwm_512 );

//nedge�� �츮�� ī��Ʈ�� ������ �� ���� ������ 
//��ǲ���� ���� �ֱ⿡ �� ���� ī��Ʈ ������ų ���� 
//    integer cnt; 
//    reg pwm_freqX512; 
    
//    always @(posedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            pwm_freqX512 =0; 
//            cnt =0; 
//        end
//        else begin
//            if(cnt >=pwm_period -1)   cnt =0;       ///sts_clk/pwm_freq
//            else cnt = cnt +1;    //���ֱ�
                        
//            if(cnt < pwm_period[17:1]) pwm_freqX512=0; //������ 2 -> shift�� ǥ�� 
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
            else cnt_duty = cnt_duty +1;  //cnt_duty = 256 �ܰ�      
               
             if(cnt_duty< duty)pwm_512=1;          // duty-input ex) if duty=90, 
             else pwm_512 =0;                      //when 100-duty(90) = 0 ��� 
         end       
     end   

endmodule

//I2C ��� master���� only�۽� 
module I2C_master( //���̽������� �о� 
    input clk, reset_p,     //�����ͷ� �۽Ÿ� �Ұ��� 
    input rd_wr, //read_write = 0: write 
    input [6:0] addr,//�ּ� 7bit
    input [7:0] data, //���� data 8bit
    input valid,    //IDLE -> START�� �Ѿ�� ���� ����ڰ� �����ͺ������ �� ���� ��� 
    output reg sda,  //test_lcd���ٰ� �����⸸ �� �� ( ���⸸ �Ұ�) ���� �б⵵ �Ϸ��� sda�� inout���� ��ƾ��� 
    output reg scl  ); 
    //��� -> ������ ���� -> FSM ��� 
    parameter IDLE =        7'b000_0001;        //scl=1 , sda =1 �� ���� 
    parameter COMM_START =  7'b000_0010;        //��� start 
    parameter SND_ADDR =    7'b000_0100;        //address send
    parameter RD_ACK =      7'b000_1000;        //slave's ack(�����ȣ) - master -read
    parameter SND_DATA =    7'b001_0000;       //data send 
    parameter SCL_STOP =    7'b010_0000;       //clk stop 
    parameter COMM_STOP =   7'b100_0000;
    
    wire [7:0] addr_rw; 
    assign addr_rw = {addr, rd_wr}; //address�� 7bit , �ٷ� �ڿ� rd_wr���� 
    
    wire clk_usec; // 1usec -> clk speed : Mhz *10�� -> 100Khz // �ʹ� ���� õõ�� ���ư��� �� ������� �� ( LCD�г� ��ü�� ������) 
    clock_usec usec_clk( clk, reset_p, clk_usec);
    
    reg [2:0] count_usec5; 
    reg scl_toggle_e;   //10usec¥�� clk�� ����� ���� 5usec���� toggle�Ǵ� Ŭ�� ����� ���� 
    //scl_toggle_e : 10usec¥�� clk�� ����� ���� Ŭ�� ���ž�! ���ž�! 
    
    always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin
            count_usec5 =0; 
            scl = 1; 
        end
        else if(scl_toggle_e)begin
            if(clk_usec)begin 
                if(count_usec5  >= 4)begin  //1usec¥�� 10���ֱ⸦ ����ؼ� 5���� ��۵Ǵ� 10usec�� 1clk�� ���� 
                    count_usec5 =0; 
                    scl = ~scl; 
                end
               else  count_usec5 = count_usec5 +1; 
             end
        end
        else if(scl_toggle_e ==0) count_usec5 = 0 ; 
    end
    
    //rising edge - next_state �ٲٱ� , polling edge - state �ٲٱ� 
    wire scl_nedge, scl_pedge;
    edge_detector_n ed_scl(.clk( clk), .reset_p(reset_p), .cp(scl), .n_edge(scl_nedge), .p_edge(scl_pedge)); 
    
  wire valid_pedge; //IDLE -> START�� �Ѿ�� ���� ����ڰ� �����ͺ������ �� ���� ��� 
    edge_detector_n ed_valid(.clk( clk), .reset_p(reset_p), .cp(valid), .p_edge(valid_pedge));
    
    reg [6:0] state, next_state; 
    always @(negedge clk or posedge reset_p) begin
        if(reset_p) state = IDLE; 
        else state = next_state; 
    end
    
    reg [2:0] cnt_bit; // ������ ���� �� �ֻ�����Ʈ���� �޾ƾ��� 8bitī��Ʈ �ϴ� �� 
    reg stop_data;  //ack������ � state�� �;��ϴ��� ���� 
    //stop_data = 1 ;ack���� state: stop state, stop_data =0  :ack ���� state : SND_DATA 
    always @(posedge clk, posedge reset_p) begin
        if(reset_p)begin
             sda= 1;    //�ʱ갪 high
             next_state = IDLE; 
             scl_toggle_e =0; 
             cnt_bit =7; //MSB ī��Ʈ ��Ʈ 7���� ���� 
             stop_data =0; 
        end
        else begin
            case(state)
                IDLE:begin
                    if(valid_pedge) next_state = COMM_START; 
                end
                COMM_START : begin
                    sda =0;     //sda�� �ʱ갪 = 1 * 1->0 ���� �Ѿ �� �ְ��� �κ� 
                    scl_toggle_e =1; //clk�� �ֱ� ���� 
                    next_state = SND_ADDR;
                end            
                SND_ADDR : begin
                    if(scl_nedge) //low���� �ٲ� sda 
                    sda = addr_rw[cnt_bit]; //MSB���� �������� 
                    else if(scl_pedge) begin
                        if(cnt_bit ==0) begin
                            cnt_bit = 7;    //���� ������ ���� �� �ְ� �ʱ�ȭ 
                            next_state = RD_ACK;
                        end               
                        else cnt_bit = cnt_bit -1; // 7,6,5,4,3,2,1,0 ������ �׸��� ack������ ���� ���� state�� ���� 
                   end
                end
                RD_ACK : begin  //���� sda�о�ͼ� 1���� 0���� ó�� but�׳� �츰 ��ٷ� �˾Ƽ� �� �߰Ŵ� ��������~ 
                    if(scl_nedge) sda = 'bz;        //zzzzzz���� z    //�� Ŭ�� ���� 
                    else if(scl_pedge) begin
                         if(stop_data)begin 
                              stop_data=0; //�ʱ�ȭ 
                              next_state = SCL_STOP;
                          end
                         else begin  
                            next_state = SND_DATA;
                            // stop_data =1; ���⿡ �� �ְ� SND_DATA�� �־��� 
                         end  
                    end         
                end
                SND_DATA : begin 
                    if(scl_nedge) //low���� �ٲ� sda 
                        sda = data[cnt_bit]; //MSB���� �������� 
                    else if(scl_pedge) begin
                        if(cnt_bit ==0) begin
                            cnt_bit = 7; 
                            next_state = RD_ACK;
                            stop_data =1; 

                        end                      
                        else cnt_bit = cnt_bit -1; // 7,6,5,4,3,2,1,0 ������ �׸��� ack������ ���� ���� state�� ���� 
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
                COMM_STOP : begin   //��� stop (stop) 
                    if(count_usec5 >=3) begin   //���� ��ٷ���ٰ� 
                        sda =1; //rising ������� // low-> hgih:stop 
                        scl_toggle_e =0;        //clk���� 
                        next_state = IDLE; 
                    end
                end              
             endcase
        end 
    end
endmodule
////-------------------------------------------------------------------------------------------//
//������ �ڵ� 
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
////���ڵ�
//////-------------------------------------------------------------------------------------------//
//////i2c����� 4bit�� ������ 4�� ������ ���� 
//module i2c_lcd_send_byte(
//    input clk, reset_p,
//    input [6:0] addr, 
//    input [7:0] send_buffer,
//    input send, rs,  //send���� ������� ��ȣ�� ���� ���� state�� ������. (������ �����ض�!) 
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
    
//    //usec counter ���� Ŭ�� ����� 
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
//                         busy =1;                                                                                                                                                                                                                                            //busy�� 1���� 0������ ���� send�� �ϵ��� 
//                        //busy�� 0�� �� send�� ���� //��ż� ������̶�� �� �ǹ�       
//                    end                       
//                 end 
//                SEND_HIGH_NIBBLE_DISABLE : begin 
//                    if(count_usec <= 22'd200) begin
//                         //200usec�Ǳ� ������ �ؿ� data���� 
//                        data = {send_buffer [7:4], 3'b100, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                        valid =1;
//                        count_usec_e =1; 
//                    end
//                    else begin //200usec�Ѿ ������ �� 
//                        next_state = SEND_HIGH_NIBBLE_ENABLE;
//                        count_usec_e = 0; 
//                        valid =0;
//                    end               
//                end
//                SEND_HIGH_NIBBLE_ENABLE : begin //enable �� 1�� �ٲ� 
//                    if(count_usec <= 22'd200) begin   //4.1ms 
//                         //200usec�Ǳ� ������ �ؿ� data���� 
//                        data = {send_buffer [7:4], 3'b110, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                        valid =1;
//                        count_usec_e =1; 
//                    end
//                    else begin //200usec�Ѿ ������ �� 
//                        next_state = SEND_LOW_NIBBLE_DISABLE;
//                        count_usec_e = 0; 
//                        valid =0;
//                    end               
//                end               
//                SEND_LOW_NIBBLE_DISABLE :begin
//                  if(count_usec <= 22'd200) begin
//                             //200usec�Ǳ� ������ �ؿ� data���� 
//                            data = {send_buffer [3:0], 3'b100, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                            valid =1;
//                            count_usec_e =1; 
//                        end
//                        else begin //200usec�Ѿ ������ �� 
//                            next_state = SEND_LOW_NIBBLE_ENABLE;
//                            count_usec_e = 0; 
//                            valid =0;
//                        end               
//                    end    
//                  SEND_LOW_NIBBLE_ENABLE: begin  
//                    if(count_usec <= 22'd200) begin
//                             //200usec�Ǳ� ������ �ؿ� data���� 
//                            data = {send_buffer [3:0], 3'b110, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                            valid =1;
//                            count_usec_e =1; 
//                        end
//                        else begin //200usec�Ѿ ������ �� 
//                            next_state = SEND_DISABLE;
//                            count_usec_e = 0; 
//                            valid =0;
//                        end               
//                    end                                
//                   SEND_DISABLE: begin             //������ data�� enable�� visiable�ָ�� enable�� 0�� �����ؾ��� ���� ���� ���� ���� 
//                     if(count_usec <= 22'd200) begin
//                             //200usec�Ǳ� ������ �ؿ� data���� 
//                            data = {send_buffer [3:0], 3'b100, rs};//[d7 d6 d5 d4 ] [BL EN RW] RS
//                            valid =1;
//                            count_usec_e =1; 
//                        end
//                        else begin //200usec�Ѿ ������ �� 
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
    inout dht11_data,   // �� �ϳ��� �ۼ��� �� ��. 
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
    reg [1:0] read_state;   //40�� �Դ� ���� �� ����
    
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






