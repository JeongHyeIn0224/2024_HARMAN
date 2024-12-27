//`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////////
//// Company: 
//// Engineer: 
//// 
//// Create Date: 2024/05/14 19:07:33
//// Design Name: 
//// Module Name: multy_fan_project_top
//// Project Name: 
//// Target Devices: 
//// Tool Versions: 
//// Description: 
//// 
//// Dependencies: 
//// 
//// Revision:
//// Revision 0.01 - File Created
//// Additional Comments:
//// 
////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

//module load_count_ud_N #(parameter N = 10 )(
//     input clk, reset_p,
//     input clk_up,
//     input clk_dn,
//     input data_load,
//     input [3:0] set_value,
//     output reg [3:0] digit,
//     output reg clk_over_flow,
//     output reg clk_under_flow);

//     always @(posedge clk, posedge reset_p) begin
//         if (reset_p) begin
//             digit = 0;
//             clk_over_flow = 0;
//             clk_under_flow = 0;
//         end
//         else begin
//             if (data_load) begin
//                 digit = set_value;
//             end
//             else if (clk_up) begin
//                 if (digit >= (N-1)) begin 
//                     digit = 0; 
//                     clk_over_flow = 1;
//                 end
//                 else begin digit = digit + 1;
//                 end
//             end
//             else if (clk_dn) begin
//                 digit = digit - 1;
//                 if (digit > (N-1)) begin
//                     digit = (N-1);
//                     clk_under_flow = 1;
//                 end
//             end
//             else begin 
//                 clk_over_flow = 0;
//                 clk_under_flow = 0;
//             end
//         end
//     end
// endmodule

//module down_counter_sb (
//    input clk, reset_p, 
//    input btn,  //0 start/pause, 1 set_sec, 0 set_min, 3 reset
//    input state_led, 
//    output [2:0] led_signal,
//    output [3:0] com,
//    output [7:0] seg_7,
//    output reg finish
//    );

//    parameter IDLE    =   7'b0000001;
//    parameter R_MODE1 =   7'b0000010;
//    parameter R_MODE2 =   7'b0000100;
//    parameter R_MODE3 =   7'b0001000;
//    parameter R_START =   7'b0010000;
//    parameter R_MOD_ACT = 7'b0100000;
//    parameter R_USER_M =  7'b1000000;
    
//    reg [6:0]state, next_state;

//    assign led_signal[0] = state[1];
//    assign led_signal[1] = state[2];
//    assign led_signal[2] = state[3];

    
//    button_cntr btn_cntr_0 (clk, reset_p, btn, btn_pedge); // 

//    reg [31:0] msec_cnt;
//    reg reserve_flag, msec_reset;

//    always @(negedge clk, posedge reset_p)
//        if(reset_p) state = IDLE;
//        else state = next_state;
   
//    wire [3:0] sec1, sec10, min1, min10;
//    wire [15:0] value, timer;
//    wire clk_start;
   
    
//    reg [3:0] set_value;
//    reg [2:0] cnt_pulse;
//    reg load;
//    always @(posedge clk, posedge reset_p)
//        if(reset_p) begin next_state = IDLE; msec_reset = 0;  load = 0; end
//        else 
//            case(state)
//                IDLE      : begin load = 0; finish = 0; if(btn_pedge) begin next_state = R_MODE1; msec_reset = 1; end end 
//                R_MODE1   : begin 
//                      set_value = 1;
//                      msec_reset = 0; 
//                     if(msec_cnt==0)  begin 
//                         next_state = R_START; 
//                         msec_reset = 1; 
//                     end 
//                     else if(btn_pedge) begin 
//                         next_state = R_MODE2; 
//                         msec_reset = 1; end 
//                 end // 1
//                R_MODE2 : begin 
//                    set_value = 3; 
//                    msec_reset = 0; 
//                    if(msec_cnt==0) begin 
//                        next_state = R_START; 
//                        msec_reset = 1; end 
//                     else if(btn_pedge) begin
//                         next_state = R_MODE3; 
//                         msec_reset = 1; 
//                      end 
//                  end // 3
//                R_MODE3   : begin 
//                    set_value = 5; 
//                    msec_reset = 0; 
//                    if(msec_cnt==0) begin 
//                        next_state = R_START; 
//                        msec_reset = 1; end 
//                    else if(btn_pedge) begin 
//                        next_state = R_USER_M;
//                        msec_reset = 1; 
//                        set_value = 0; 
//                     end 
//                 end    // 5        
//                R_START   : begin 
//                    load = 1; 
//                    next_state = R_MOD_ACT; 
//                end
//                R_MOD_ACT : begin 
//                    load = 0; 
//                    if(state_led) next_state = IDLE; 
//                    else if(btn_pedge) next_state = IDLE; 
//                    else if(value == 0) begin 
//                        next_state = IDLE; 
//                        finish = 1; 
//                   end  
//                 end
//                R_USER_M  : begin 
//                    msec_reset = 0; 
//                     if(msec_cnt==0) begin 
//                         if(set_value == 0) 
//                            next_state = IDLE; 
//                         else next_state = R_START; 
//                     end 
//                     else if(btn_pedge) begin 
//                        if(set_value == 9) set_value = 0; 
//                        else 
//                               set_value = set_value + 1; 
//                              msec_reset = 1; 
//                     end 
//                 end
//            endcase


//    wire clk_usec, clk_msec, clk_sec;
//    clock_usec     clk_us (clk, reset_p, clk_usec);                   // sysclk -> 1us
//    clock_div_1000 clk_ms (clk, reset_p, clk_usec, clk_msec);         // 1us -> 1ms
//    clock_div_1000 clk_s  (clk, reset_p, clk_msec, clk_sec);    // 1ms -> 1s

//    always @(posedge clk, posedge reset_p)
//        if(reset_p) msec_cnt = 0;
//        else if(msec_reset) msec_cnt = 500;
//        else if(msec_cnt == 0) msec_cnt = 0;
//        else if(clk_msec) msec_cnt = msec_cnt - 1;
    


//    load_count_ud_N #(10) sec_1 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), .set_value(0), .clk_dn(clk_sec), .digit(sec1), .clk_over_flow(), .clk_under_flow(under_sec1) );
//    load_count_ud_N #(6) sec_10 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), .set_value(0), .clk_dn(under_sec1), .digit(sec10), .clk_over_flow(), .clk_under_flow(under_sec10) );
//    load_count_ud_N #(10) min_1 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), .set_value(set_value), .clk_dn(under_sec10), .digit(min1), .clk_over_flow(over_min), .clk_under_flow(under_min1) );
//    load_count_ud_N #(10) min_10 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), .set_value(0), .clk_dn(under_min1), .digit(min10), .clk_over_flow(), .clk_under_flow() );


//    assign value = state[5] ? {min10, min1, sec10, sec1} :
//                   state[0] ? {15'b0} :
//                   state[6] ? {4'd12, set_value, 4'b0, 4'b0} 
//                            : {4'b0, set_value, 4'b0, 4'b0} ;
//    assign clk_start = state[5] ? clk : 0;
    
//    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));

//endmodule


//module servo_motor_cntr_sb(
//    input clk, reset_p, btn, state_led,
//    output pwm_smotor,
//    output [3:0] led
//);

//    parameter MOTOR_START   = 4'b0001;
//    parameter MOTOR_STOP    = 4'b0010;
//    parameter DUTY_SETUP    = 4'b0100;
    
//    reg [3:0] state, next_state;
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p) state = MOTOR_STOP;
//        else state = next_state;
//    end
    
//    assign led = state;
    
//    reg [21:0] duty;
//    reg up_down;
       
//    reg [31:0] clk_div, duty_max, duty_min;
//    always @(posedge clk) clk_div = clk_div + 1;
    
//    wire clk_div_pedge;
//    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[8]), .p_edge(clk_div_pedge));
    
//    reg [10:0] msec_cnt;
//    reg cnt_reset;
//    always @(posedge clk, posedge reset_p)
//        if(reset_p) msec_cnt = 0;
//        else if(clk_msec) msec_cnt = msec_cnt - 1;
//        else if(cnt_reset) msec_cnt = 700;
          
    
//    always @(posedge clk, posedge reset_p)begin
//        if(reset_p)begin
//            next_state = MOTOR_STOP; 
//            duty = 58_000;
//            up_down = 1;
//            duty_max = 256000;
//            duty_min = 58000;
//        end  
//        else begin
//            case(state)
//                MOTOR_START : begin
//                    if(btn_pedge)begin
//                       next_state = DUTY_SETUP;
//                       cnt_reset = 1;    
//                    end
//                    else if(clk_div_pedge) begin
//                            if(duty > duty_max) up_down = 0;
//                            else if(duty <= duty_min) up_down = 1;
            
//                            if(state_led) duty= duty; 
//                            else if(up_down) duty = duty + 1; 
//                            else duty = duty - 1;
//                    end
//                end
//                MOTOR_STOP : begin
//                    if(btn_pedge)begin
//                        next_state = MOTOR_START;                  
//                    end
//                    duty = duty;
//                end
//               DUTY_SETUP : begin
//                       cnt_reset = 0;
//                       if(msec_cnt == 0) begin next_state = MOTOR_STOP; end
//                       else if(btn_pedge)begin
//                                  case(up_down)
//                                    1: begin duty_max = duty; next_state = MOTOR_START; end
//                                    0: begin duty_min = duty; next_state = MOTOR_START; end
//                                  endcase
//                      end 
//               end                
//            endcase          
//        end
//     end       
    

//    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));
//    clock_usec     clk_us (clk, reset_p, clk_usec);                   // sysclk -> 1us
//    clock_div_1000 clk_ms (clk, reset_p, clk_usec, clk_msec);         // 1us -> 1ms    
//    pwm_test_sb pwm_led(.clk(clk), .reset_p(reset_p), .duty(duty), .Tus(2_000_000), .pwm(pwm_smotor));
    
//endmodule


//module multy_fan_scale_cntr_sb( //주파수 100만 100hz
//    input clk, reset_p,
//    input btn, finish, us_sig, sw, 
//    input [3:0] over_temp,
//    output state_led, 
//    output reg [2:0] status_led,
//    output pwm
//    );
//    parameter IDLE  =  7'b0000001;
//    parameter STEP_1 = 7'b0000010;
//    parameter STEP_2 = 7'b0000100;
//    parameter STEP_3 = 7'b0001000;
//    parameter MODSEL = 7'b0010000;
//    parameter MODSET = 7'b0100000;
//    parameter C_MODE = 7'b1000000;
////    parameter STOP =     10000;
//    reg [6:0] state, next_state;
//    wire  btn_pedge;
//    reg [31:0] duty;
//    pwm_test_sb pwm_led(.clk(clk), .reset_p(reset_p), .duty(duty), .Tus(1000_000), .pwm(pwm));
//    button_cntr start(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge) );
//    reg [15:0] msec_cnt;
//    reg cnt_reset_10s, cnt_reset;
//    assign state_led = state[0];
    
//    always @(posedge clk, posedge reset_p)
//    if(reset_p) begin msec_cnt = 0; end
//    else if(cnt_reset_10s) msec_cnt = 10000;
//    else if(cnt_reset) msec_cnt = 500;
//    else if(clk_msec) msec_cnt = msec_cnt - 1;
//    else if(msec_cnt == 0) msec_cnt = 0;
//    //state만드는 레지스터
//    always @(negedge clk, posedge reset_p) begin //negedge
//        if(reset_p) state = IDLE;
//        else if(sw) state = {3'b0, over_temp};
//        else state = next_state;
//    end
//    assign debugled= state;
//    reg [31:0] c_duty;
//     always @(posedge clk or posedge reset_p) begin
//        if(reset_p) begin
//            next_state = IDLE;
//            duty =0;
//            c_duty = 0;
//        end
//        else if(us_sig) duty = 0;
//        else begin
//            case(state)
//                IDLE : begin
//                        if(btn_pedge)begin next_state = MODSEL; cnt_reset = 1; end
//                          duty = 0;
//                          status_led = 0;
//                end
//                STEP_1 : begin
//                        if(btn_pedge) next_state = STEP_2;
//                        else if(finish) next_state = IDLE;
//                         duty =300_000; status_led = 1;
//                end
//                STEP_2 : begin
//                        if(btn_pedge) next_state = STEP_3;
//                        else if(finish) next_state = IDLE;
//                         duty = 500_000; status_led = 2;
//                end
//                STEP_3 : begin
//                        if(btn_pedge) next_state = IDLE;
//                        else if(finish) next_state = IDLE;
//                         duty =800_000;  status_led = 4;
//                end
//                MODSEL : begin
//                         cnt_reset = 0;
//                        if(msec_cnt == 0) if(btn == 1) next_state = C_MODE; else next_state = STEP_1;
//                        else if(btn_pedge) begin next_state = MODSET; cnt_reset_10s = 1; end
//                end
//                MODSET : begin
//                          cnt_reset_10s = 0;
//                          if(msec_cnt > 9500) begin if(btn == 0) next_state = STEP_2; else if(btn_pedge) next_state = C_MODE; end
//                          else if(clk_msec) c_duty = c_duty + 10000;
//                          else if(msec_cnt == 0) next_state = C_MODE;
//                          else if(btn == 0) next_state = C_MODE;
//                          else duty = c_duty;
//                end
//                C_MODE : begin
//                        duty = c_duty;
//                        if(btn_pedge) next_state = IDLE;
//                        else if(finish) next_state = IDLE;
//                         status_led = 7;
//                end
//             endcase
//       end
//    end
    
//    clock_usec     clk_us (clk, reset_p, clk_usec);                   // sysclk -> 1us
//    clock_div_1000 clk_ms (clk, reset_p, clk_usec, clk_msec);         // 1us -> 1ms    
//    endmodule
    
    
    
//module ultrasonic_top_sb (
//    input clk, reset_p, 
//    input echo, 
//    output trigger, 
//    output reg us_sig);
   
//    wire [11:0] distance; //bin_to_dec의 bindl 12bit라 맞춰주기 위함 

//    always @(posedge clk, posedge reset_p)
//        if(reset_p) us_sig = 0;
//        else if(distance<=5) us_sig = 1; //동작안해 ㅎㅎ;
//        else us_sig = 0; //동작
              
//    ultrasonic us( clk, reset_p,  echo,  trigger, distance, led_bar);    //ultrasonic_jj
    
// endmodule
 
 
// module I2C_txtlcd_top_2_sb(
//    input clk, reset_p,
//    input [7:0] data,
//    input write_start, line_to_0, line_to_1,
//    output scl, sda);

//    parameter IDLE = 6'b00_0001;
//    parameter INIT = 6'b00_0010;
//    parameter SEND = 6'b00_0100;
//    parameter MOVE_CURSOR = 6'b00_1000;
//    parameter SHFIT_DISPLAY = 6'b01_0000;
//    parameter MOVE_CURSOR2 = 6'b10_0000;

//    parameter SAMPLE_DATA = "A";


//    reg [7:0] send_buffer;
//    reg send_e, rs;
//    wire busy;
    
//    I2C_lcd_send_byte_sb send_byte(.clk(clk), .reset_p(reset_p), .addr(7'h27), .send_buffer(send_buffer), .send(send_e), .rs(rs), .scl(scl), .sda(sda), .busy(busy));
    
//    reg [21:0] count_usec;
//    reg count_usec_e;
//    wire clk_usec;
//    clock_usec usec_clk(clk, reset_p, clk_usec);
    
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p)begin
//            count_usec = 0;
//        end
//        else begin
//            if(clk_usec && count_usec_e)count_usec = count_usec + 1;
//            else if(!count_usec_e)count_usec = 0;
//        end
//    end
    
//    reg [7:0] cnt_data;
//    reg [5:0] state, next_state;
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p)state = IDLE;
//        else state = next_state;
//    end
    
//    reg init_flag;
//    always @(posedge clk or posedge reset_p)begin
//        if(reset_p)begin
//            next_state = IDLE;
//            send_buffer = 0;
//            rs = 0;
//            send_e = 0;
//            init_flag = 0;
//            cnt_data = 0;
//        end
//        else begin
//            case(state)
//                IDLE:begin
//                    if(init_flag)begin
//                        if(write_start)next_state = SEND;
//                        if(line_to_0)next_state = MOVE_CURSOR;
//                        if(line_to_1)next_state = MOVE_CURSOR2;
//                    end
//                    else begin
//                        if(count_usec <= 22'd80_000)begin
//                            count_usec_e = 1;
//                        end
//                        else begin
//                            next_state = INIT;
//                            count_usec_e = 0;
//                        end
//                    end
//                end
//                INIT:begin
//                    if(count_usec <= 22'd1000)begin
//                        send_buffer = 8'h33;
//                        send_e = 1;
//                        count_usec_e = 1;
//                    end
//                    else if(count_usec <= 22'd1010)send_e = 0;
//                    else if(count_usec <= 22'd2010)begin
//                        send_buffer = 8'h32;
//                        send_e = 1;
//                        count_usec_e = 1;
//                    end
//                    else if(count_usec <= 22'd2020)send_e = 0;
//                    else if(count_usec <= 22'd3020)begin
//                        send_buffer = 8'h28;
//                        send_e = 1;
//                        count_usec_e = 1;
//                    end
//                    else if(count_usec <= 22'd3030)send_e = 0;
//                    else if(count_usec <= 22'd4030)begin
//                        send_buffer = 8'h0f;
//                        send_e = 1;
//                        count_usec_e = 1;
//                    end
//                    else if(count_usec <= 22'd4040)send_e = 0;
//                    else if(count_usec <= 22'd5040)begin
//                        send_buffer = 8'h01;
//                        send_e = 1;
//                        count_usec_e = 1;
//                    end
//                    else if(count_usec <= 22'd5050)send_e = 0;
//                    else if(count_usec <= 22'd6050)begin
//                        send_buffer = 8'h06;
//                        send_e = 1;
//                        count_usec_e = 1;
//                    end
//                    else if(count_usec <= 22'd6060)send_e = 0;
//                    else begin
//                        next_state = IDLE;
//                        init_flag = 1;
//                        count_usec_e = 0;
//                    end
//                end
//                SEND:begin
//                    if(busy)begin
//                        next_state = IDLE;
//                        send_e = 0;
//                    end
//                    else begin
//                        send_buffer = data;
//                        rs = 1;
//                        send_e = 1;
//                    end
//                end
//                MOVE_CURSOR : begin
//                    if(busy) begin next_state = IDLE; send_e = 0; end
//                    else begin send_buffer= 8'hc0; rs = 0; send_e = 1; end
//                end
//                SHFIT_DISPLAY : begin
//                    if(busy) begin next_state = IDLE; send_e = 0; end
//                    else begin send_buffer= 8'h1c; rs = 0; send_e = 1; end
//                end
//                MOVE_CURSOR2 : begin
//                    if(busy) begin next_state = IDLE; send_e = 0; end
//                    else begin send_buffer= 8'b1000_0000; rs = 0; send_e = 1; end
//                end
//            endcase
//        end
//    end

//  edge_detector_n ed (.clk(clk), .reset_p(reset_p), .cp(busy), .p_edge(busy_pedge), .n_edge(busy_nedge) );

//endmodule



//module lcd_dht_sb(
//  input clk, reset_p, 
//  inout dht, 
//  output sda, scl,
//  output reg [3:0] over_temp 
//);
//  parameter RESET_LCD_0 = "T";
//  parameter RESET_LCD_1 = "E";
//  parameter RESET_LCD_2 = "M";
//  parameter RESET_LCD_3 = "P";
//  parameter RESET_LCD_4 = "E";
//  parameter RESET_LCD_5 = "R";
//  parameter RESET_LCD_6 = "A";
//  parameter RESET_LCD_7 = "T";
//  parameter RESET_LCD_8 = "U";
//  parameter RESET_LCD_9 = "R";
//  parameter RESET_LCD_10 = "E";
//  parameter RESET_LCD_11 = " ";
//  reg [7:0] RESET_LCD_12; 
//  reg [7:0] RESET_LCD_13;
//  parameter RESET_LCD_14 = 8'b1101_1111;
//  parameter RESET_LCD_15 = "C";
  
//  parameter RESET_LCD1_0 = "H";
//  parameter RESET_LCD1_1 = "U";
//  parameter RESET_LCD1_2 = "M";
//  parameter RESET_LCD1_3 = "I";
//  parameter RESET_LCD1_4 = "D";
//  parameter RESET_LCD1_5 = "I";
//  parameter RESET_LCD1_6 = "T";
//  parameter RESET_LCD1_7 = "Y";
//  parameter RESET_LCD1_8 = " ";
//  parameter RESET_LCD1_9 = " ";
//  parameter RESET_LCD1_10 = " ";
//  parameter RESET_LCD1_11 = " ";
//  reg [7:0] RESET_LCD1_12;
//  reg [7:0] RESET_LCD1_13;
//  parameter RESET_LCD1_14 = " ";
//  parameter RESET_LCD1_15 = 8'b0010_0101;
  
  
//  parameter WAIT_LCD  =   5'b00001;
//  parameter LINE_TO_0 =   5'b00010;
//  parameter LCD_LINE1 =   5'b00100;
//  parameter LINE_TO_1 =   5'b01000;
//  parameter LCD_LINE2 =   5'b10000;
  
  
//  reg [7:0] data;

//  reg [7:0] lcd_data;
//  reg [10:0] msec_cnt;
//  reg lcd_start, cnt_data_e, reset_msec, line_to_0, line_to_1;
   
//  reg [4:0] cnt_data;
//  reg line;
  

//  always @(posedge clk, posedge reset_p)
//    if(reset_p) begin cnt_data = 0; end
//    else if(lcd_start&&cnt_data_e) cnt_data = cnt_data + 1;
//    else if(cnt_data_e == 0) cnt_data = 0;

//  reg [4:0] state, next_state;

//  always @(negedge clk, posedge reset_p)
//    if(reset_p) msec_cnt = 0;
//    else if(clk_msec) msec_cnt = msec_cnt + 1;
//    else if(reset_msec) msec_cnt = 0;
    
    

//  always @(negedge clk, posedge reset_p)
//    if(reset_p) state = WAIT_LCD;
//    else state = next_state;
    
//  always @(posedge clk, posedge reset_p)
//  begin
//    if(reset_p) begin next_state = WAIT_LCD; reset_msec = 0; line = 0; line_to_0 = 0; line_to_1 = 0; lcd_start = 0; end
//    else 
//      case(state)
//        WAIT_LCD    : begin reset_msec = 0; if(msec_cnt == 150) begin next_state = LCD_LINE1; reset_msec = 1; end end
//        LINE_TO_0   : begin
//                      reset_msec = 0;
//                      if(msec_cnt == 10) begin line_to_1 = 1; next_state = LCD_LINE1; reset_msec = 1; end
//                      end
//        LCD_LINE1   : begin 
//                      reset_msec = 0; lcd_start = 0; cnt_data_e = 1; line = 0; line_to_1 = 0;
//                      if(msec_cnt == 5) begin lcd_start = 1; reset_msec = 1;  end
//                      else if (cnt_data == 5'b10000) begin reset_msec = 1; next_state = LINE_TO_1; cnt_data_e = 0;end
//                      end
//        LINE_TO_1 : begin
//                      reset_msec = 0;
//                      if(msec_cnt == 10) begin line_to_0 = 1; next_state = LCD_LINE2; reset_msec = 1; end
//                      end
//        LCD_LINE2   : begin 
//                      reset_msec = 0; lcd_start = 0; cnt_data_e = 1; line = 1; line_to_0 = 0;
//                      if(msec_cnt == 5) begin lcd_start = 1; reset_msec = 1; end
//                      else if (cnt_data == 5'b10000) begin reset_msec = 1; next_state = LINE_TO_0; cnt_data_e = 0;end
//                      end
                      
//      endcase
//    end  
        

//  always @(negedge clk, posedge reset_p)
//    if(reset_p) begin data = RESET_LCD_0; end
//    else if(!line)
//      case(cnt_data)
//        5'b00001 : data = RESET_LCD_0;
//        5'b00010 : data = RESET_LCD_1;
//        5'b00011 : data = RESET_LCD_2;
//        5'b00100 : data = RESET_LCD_3;
//        5'b00101 : data = RESET_LCD_4;
//        5'b00110 : data = RESET_LCD_5;
//        5'b00111 : data = RESET_LCD_6;
//        5'b01000 : data = RESET_LCD_7;
//        5'b01001 : data = RESET_LCD_8;
//        5'b01010 : data = RESET_LCD_9;
//        5'b01011 : data = RESET_LCD_10;
//        5'b01100 : data = RESET_LCD_11;
//        5'b01101 : data = RESET_LCD_12;
//        5'b01110 : data = RESET_LCD_13;
//        5'b01111 : data = RESET_LCD_14;        
//        5'b10000 : data = RESET_LCD_15;
//      endcase
//  else if(line)
//        case(cnt_data)
//        5'b00001 : data = RESET_LCD1_0;
//        5'b00010 : data = RESET_LCD1_1;
//        5'b00011 : data = RESET_LCD1_2;
//        5'b00100 : data = RESET_LCD1_3;
//        5'b00101 : data = RESET_LCD1_4;
//        5'b00110 : data = RESET_LCD1_5;
//        5'b00111 : data = RESET_LCD1_6;
//        5'b01000 : data = RESET_LCD1_7;
//        5'b01001 : data = RESET_LCD1_8;
//        5'b01010 : data = RESET_LCD1_9;
//        5'b01011 : data = RESET_LCD1_10;
//        5'b01100 : data = RESET_LCD1_11;
//        5'b01101 : data = RESET_LCD1_12;
//        5'b01110 : data = RESET_LCD1_13;
//        5'b01111 : data = RESET_LCD1_14;
//        5'b10000 : data = RESET_LCD1_15;
//      endcase


//  wire [2:0] rst_lcd;
//  wire [7:0] humidity, temperature;
//  wire [15:0] t_value, h_value, distance;
//  wire [7:0] t_value_1, t_value_10, h_value_1, h_value_10;
//  wire [11:0] abc;

//  I2C_txtlcd_top_2_sb lcd( clk, reset_p, data, lcd_start, line_to_0, line_to_1, scl, sda );
//  clock_usec usec_clk(clk, reset_p, clk_usec);
//  clock_div_1000 clk_ms(clk, reset, clk_usec, clk_msec); // 1us -> 1ms
//  dht dht11( clk, reset_p, dht, humidity, temperature, abc);
//  bin_to_dec btd0 (.bin({4'b0000, temperature}), .bcd(t_value)); // duty값 1024(1000으로 나누어 출력)
//  bin_to_dec btd1 (.bin({4'b0000, humidity}), .bcd(h_value)); // duty값 1024(1000으로 나누어 출력)
//  fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(distance), .seg_7_an(seg_7), .com(com));


//  assign t_value_1  = {4'b0, t_value[3:0]};
//  assign t_value_10 = {4'b0, t_value[7:4]};
//  assign h_value_1  = {4'b0, h_value[3:0]};
//  assign h_value_10 = {4'b0, h_value[7:4]};

//  always @(posedge clk, posedge reset_p)
//    if(reset_p) begin RESET_LCD_12 = 0; RESET_LCD_13 = 0; RESET_LCD1_12 = 0; RESET_LCD1_13 = 0; end
//    else if(msec_cnt == 2) begin RESET_LCD_12 = t_value_10 + 48; RESET_LCD_13 = t_value_1 + 48; RESET_LCD1_12 = h_value_10 + 48; RESET_LCD1_13 = h_value_1 + 48; end

   
//  always @(posedge clk, posedge reset_p)
//    if(reset_p) over_temp = 0;
//    else if(temperature >= 30) over_temp = 4'b1000;
//    else if(temperature >= 27) over_temp = 4'b0100;
//    else if(temperature >= 25) over_temp = 4'b0010;
//    else over_temp = 4'b0001;


//endmodule


//module I2C_lcd_send_byte_sb(          // I2C 통신을 이용해서 LCD 에 8bit(1Byte)를 보내는 모듈 
//  input clk, reset_p,
//  input [6:0] addr,                 // 통신할 슬레이브의 주소
//  input [7:0] send_buffer,
//  input send, rs,                   // 
//  output scl, sda,
//  output reg busy_out
// );

//  parameter IDLE                     = 6'b00_0001;
//  parameter SEND_HIGH_NIBBLE_DISABLE = 6'b00_0010;
//  parameter SEND_HIGH_NIBBLE_ENABLE  = 6'b00_0100;
//  parameter SEND_LOW_NIBBLE_DISABLE  = 6'b00_1000;
//  parameter SEND_LOW_NIBBLE_ENABLE   = 6'b01_0000;
//  parameter SEND_DISABLE             = 6'b10_0000;

//  reg [7:0] data;
//  reg valid;

//  reg count_usec_e;
//  reg [21:0] count_usec;
//  wire clk_usec, send_pedge, send_nedge;

//  clock_usec usec_clk(clk, reset_p, clk_usec);
//  edge_detector_n ed0 (.clk(clk), .reset_p(reset_p), .cp(send), .p_edge(send_pedge), .n_edge(send_nedge));


//  always @(negedge clk, posedge reset_p)
//    begin
//      if(reset_p) count_usec = 0;
//      else if(count_usec_e && count_usec) count_usec = count_usec + 1;
//      else if(count_usec_e == 0) count_usec = 0;
//    end

//  reg [5:0] state, next_state;

//  always @(negedge clk, posedge reset_p)
//    if(reset_p) begin state = IDLE; busy_out = 0; end
//    else state = next_state;

//  always @(posedge clk, posedge reset_p)
//    begin
//      if(reset_p) next_state = IDLE;
//      else 
//        begin
//          case(state)
//            IDLE                     : begin if(send_pedge) begin busy_out = 1; next_state = SEND_HIGH_NIBBLE_DISABLE; end end
//            SEND_HIGH_NIBBLE_DISABLE : begin 
//                                          if(count_usec <= 200) begin data = {send_buffer[7:4], 3'b100, rs}; valid = 1; count_usec_e = 1; end    //{ d7, d6, d5, d4, BL, EN, RW, RS}
//                                          else begin next_state = SEND_HIGH_NIBBLE_ENABLE; count_usec_e = 0; valid = 0; end
//                                        end
//            SEND_HIGH_NIBBLE_ENABLE  : begin  
//                                          if(count_usec <= 200) begin data = {send_buffer[7:4], 3'b110, rs}; valid = 1; count_usec_e = 1; end    //{ d7, d6, d5, d4, BL, EN, RW, RS}
//                                          else begin next_state = SEND_LOW_NIBBLE_ENABLE; count_usec_e = 0; valid = 0; end
//                                       end
//            SEND_LOW_NIBBLE_DISABLE  : begin  
//                                          if(count_usec <= 200) begin data = {send_buffer[3:0], 3'b100, rs}; valid = 1; count_usec_e = 1; end    //{ d3, d2, d1, d0, BL, EN, RW, RS}
//                                          else begin next_state = SEND_LOW_NIBBLE_ENABLE; count_usec_e = 0; valid = 0; end
//                                       end
//            SEND_LOW_NIBBLE_ENABLE   : begin  
//                                          if(count_usec <= 200) begin data = {send_buffer[3:0], 3'b110, rs}; valid = 1; count_usec_e = 1; end    //{ d3, d2, d1, d0, BL, EN, RW, RS}
//                                          else begin next_state = SEND_DISABLE; count_usec_e = 0; valid = 0; end
//                                       end
//            SEND_DISABLE             : begin  
//                                          if(count_usec <= 200) begin data = {send_buffer[3:0], 3'b100, rs}; valid = 1; count_usec_e = 1; end    //{ d3, d2, d1, d0, BL, EN, RW, RS}
//                                          else begin next_state = IDLE; count_usec_e = 0; valid = 0; busy_out = 0; end
//                                       end
//          endcase
//        end
//    end

//  I2C_master_sb i2c( .clk(clk), .reset_p(reset_p), .rd_wr(0), .addr(7'h27), .valid(valid), .data(data), .scl(scl),  .sda(sda), .led(led) );

//endmodule

//module I2C_master_sb(
//    input clk, reset_p,
//    input rd_wr,
//    input [6:0] addr,
//    input [7:0] data,
//    input valid,
//    output reg scl,
//    output reg sda,
//    output [6:0] led );
    
//    parameter IDLE = 7'b000_0001;
//    parameter COMM_START = 7'b000_0010;
//    parameter SND_ADDR = 7'b000_0100;
//    parameter RD_ACK = 7'b000_1000;
//    parameter SND_DATA = 7'b001_0000;
//    parameter SCL_STOP = 7'b010_0000;
//    parameter COMM_STOP = 7'b100_0000;
    
//    assign led = state;
    
//    wire [7:0] addr_rw;   // slave 주소
//    assign addr_rw = {addr, rd_wr}; // 여기에 ack 까지 합치면 1패킷
    
//    wire clk_usec;
//    clock_usec usec_clk(clk, reset_p, clk_usec);
    
//    reg [2:0] count_usec5;
//    reg scl_toggle_e;    
//    always @(posedge clk, posedge reset_p) begin
//        if(reset_p) begin
//           count_usec5 = 0;
//           scl = 1;   //idle상태에서는 clk은 1                    
//        end
//        else if(scl_toggle_e) begin
//            if(clk_usec) begin
//                if(count_usec5 >= 4)begin
//                    count_usec5 = 0;
//                    scl = ~scl;
//                end
//                else count_usec5 = count_usec5 + 1;
//            end
//        end
//        else if(scl_toggle_e == 0) count_usec5 = 0;
//    end
    
//    wire scl_pedge, scl_nedge;
//    edge_detector_n ed_scl(.clk(clk), .reset_p(reset_p), .cp(scl),
//            .p_edge(scl_pedge) ,.n_edge(scl_nedge));
    
//    wire valid_pedge;
//    edge_detector_n ed_valid(.clk(clk), .reset_p(reset_p), .cp(valid),
//            .p_edge(valid_pedge));
    
//    reg [6:0] state, next_state;
//    always @(negedge clk, posedge reset_p) begin //NEGATIVE EDGE
//        if(reset_p) state = IDLE;
//        else state = next_state;
        
//    end 
//    reg [2:0] cnt_bit;
//    reg stop_data;
//    always @(posedge clk, posedge reset_p) begin
//        if(reset_p) begin
//            sda = 1;
//            next_state = IDLE;
//            scl_toggle_e = 0;
//            cnt_bit = 7;
//            stop_data = 0;
//        end
//        else begin
//            case(state)
//                IDLE:begin
//                    if(valid_pedge) next_state = COMM_START;
//                end
//                COMM_START: begin
//                    sda = 0;
//                    scl_toggle_e = 1;
//                    next_state = SND_ADDR;
//                end
//                SND_ADDR: begin
//                    if(scl_nedge) sda = addr_rw[cnt_bit];
//                    else if(scl_pedge) begin
//                        if(cnt_bit == 0) begin
//                            cnt_bit = 7; //안써줘도 언더플로우때문에 자동으로7됨, 가독성위해 쓰는게 좋다
//                            next_state = RD_ACK;
//                        end 
//                        else cnt_bit = cnt_bit - 1;
//                    end
//                end
//                RD_ACK: begin
//                    if(scl_nedge) sda = 'bz;
//                    else if(scl_pedge) begin                    
//                        if(stop_data)begin
//                            stop_data = 0;
//                            next_state = SCL_STOP;
//                        end
//                        else begin
//                            next_state = SND_DATA;
//                        end
//                    end
//                end
////                sda = 5'b1 = 00001 
////                sda = 5'bz = zzzzz
//                SND_DATA: begin
//                    if(scl_nedge) sda = data[cnt_bit];
//                    else if(scl_pedge) begin
//                        if(cnt_bit == 0) begin
//                            cnt_bit = 7; //안써줘도 언더플로우때문에 자동으로7됨, 가독성위해 쓰는게 좋다
//                            next_state = RD_ACK;
//                            stop_data = 1;                            
//                        end 
//                        else cnt_bit = cnt_bit - 1;
//                    end
//                end
//                SCL_STOP: begin
//                    if(scl_nedge) begin
//                        sda = 0;
//                    end
//                    else if(scl_pedge) begin
//                        next_state = COMM_STOP;
//                    end
//                end
//                COMM_STOP:begin
//                    if(count_usec5 >= 3) begin
//                        sda = 1;
//                        scl_toggle_e = 0;
//                        next_state = IDLE;
//                    end
//                end
//            endcase
//        end
//    end
    
// endmodule

//module led_fsm_sb(
//    input clk, reset_p, btn,
//    output pwm
//);
    
//    reg [31:0] led;
    
//    parameter BTN_INPUT_1 = 4'b0001; // led 밝기 1
//    parameter BTN_INPUT_2 = 4'b0010; // led 밝기 2
//    parameter BTN_INPUT_3 = 4'b0100; // led 밝기 3
//    parameter BTN_INPUT_4 = 4'b1000; // led off
    
//    reg [3:0] state, next_state;
             
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p) state = BTN_INPUT_4;
//        else state = next_state;
//    end

//    always @(posedge clk, posedge reset_p)
//        if(reset_p) next_state = BTN_INPUT_4;
//        else begin
//            case(state)
//                BTN_INPUT_4 : begin
//                    led = 0; 
//                    if(btn_pedge) next_state = BTN_INPUT_1;
//                end
//                BTN_INPUT_1 : begin
//                    led = 3300; 
//                    if(btn_pedge) next_state = BTN_INPUT_2;
//                end
//                BTN_INPUT_2 : begin
//                    led = 6600; 
//                    if(btn_pedge) next_state = BTN_INPUT_3;
//                end
//                BTN_INPUT_3 : begin
//                    led = 9900; 
//                    if(btn_pedge) next_state = BTN_INPUT_4;
//                end     
//            endcase       
//        end
    
//    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));
    
//    pwm_test_sb pwm_led(.clk(clk), .reset_p(reset_p), .duty(led), .Tus(10_000), .pwm(pwm));

//endmodule

//module dht(   // 입출력 선언부에는 input, output, inout 이렇게  세 가지가 들어감. 
//    input clk, reset_p,
//    inout dht11_data,   // 선 하나로 송수신 다 함. // inout은 reg선언이 안 됨. input이 reg 선언 안 되니까. 근데 always문안에서 건드리려면 ..
//    output reg [7:0] humidity, temperature, // 온도 습도 출력.
//    output wire [7:0] led_bar    //  디버깅을 위해서 led 출력을 만들어둠.
//);

//    parameter S_IDLE        = 6'b000001;
//    parameter S_LOW_18MS    = 6'b000010;
//    parameter S_HIGH_20US   = 6'b000100;
//    parameter S_LOW_80US    = 6'b001000;
//    parameter S_HIGH_80US   = 6'b010000;
//    parameter S_READ_DATA   = 6'b100000;


////-----------
//    parameter S_WAIT_PEDGE = 2'b01;
//    parameter S_WAIT_NEDGE = 2'b10;
    
   
//    reg [21:0] count_usec;
//    wire clk_usec;  
//    reg count_usec_e;
//    clock_usec usec_clk(clk, reset_p, clk_usec);
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p) count_usec = 0;
//        else begin
//            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
//            else if(!count_usec_e) count_usec = 0;
//        end
//    end
    
    
//    wire dht_pedge, dht_nedge;
//    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(dht11_data), .p_edge(dht_pedge), .n_edge(dht_nedge)); 
    
    
//    reg [5:0] state, next_state;
//    reg [1:0] read_state;   //40번 왔다 갔다 할 상태
    
//    assign led_bar[5:0] = state;
    
    
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p) state = S_IDLE;
//        else state = next_state;
//    end
 
//    reg [39:0] temp_data;  
//    reg [5:0] data_count; 
                                                 
//    // input은 reg 안 되니까 이런 식으로 값을 넘겨줌 
//    reg dht11_buffer;
//    assign dht11_data = dht11_buffer;
    
//    always @(posedge clk or posedge reset_p)begin
//        if(reset_p)begin
//            count_usec_e = 0;
//            next_state = S_IDLE;
//            dht11_buffer = 1'bz;    //dht11_data = 1'bz;
            
//            read_state = S_WAIT_PEDGE;
//            data_count = 0;            
//        end

//        else begin
//            case(state)
            
//                S_IDLE : begin
//                    if(count_usec < 22'd3_000_000)begin 
//                        count_usec_e = 1;
//                        dht11_buffer = 1'bz; 
//                    end
//                    else begin
//                        next_state = S_LOW_18MS;
//                        count_usec_e = 0;   
//                    end
//                end
                
//                S_LOW_18MS : begin
//                    if(count_usec < 22'd20_000)begin //최소 22'd18_000 이상 주면 됨.
//                       count_usec_e = 1;
//                       dht11_buffer = 0; 
//                    end
//                    else begin
//                        count_usec_e = 0;
//                        next_state = S_HIGH_20US;
//                        dht11_buffer = 1'bz;
//                    end
//                end
                
//                S_HIGH_20US : begin
//                        count_usec_e = 1;
//                        if(dht_nedge)begin
//                            next_state = S_LOW_80US;    
//                            count_usec_e = 0;
//                        end
////                            if(dht_nedge) begin
////                                next_state = S_IDLE;
////                            end
//                    if(count_usec > 22'd20_000)begin
//                        next_state = S_IDLE;
//                        count_usec_e = 0;    
//                    end
//                end
                                  
//                S_LOW_80US : begin
//                    count_usec_e = 1;
//                    if(dht_pedge)begin
//                        next_state = S_HIGH_80US;
//                        count_usec_e = 0;
//                    end
                    
//                    if(count_usec > 22'd20_000)begin
//                        next_state = S_IDLE;
//                        count_usec_e = 0;    
//                    end
                    
                    
//                end
                
//                S_HIGH_80US : begin
//                    count_usec_e = 1;
//                    if(dht_nedge)begin
//                        next_state = S_READ_DATA;
//                    end
                    
//                    if(count_usec > 22'd20_000)begin
//                        next_state = S_IDLE;
//                        count_usec_e = 0;    
//                    end
//                end
//    //---------------------------------            
//                S_READ_DATA : begin
//                    case(read_state)
//                        S_WAIT_PEDGE : begin
//                            if(dht_pedge)begin
//                                read_state = S_WAIT_NEDGE; 
//                            end
//                            count_usec_e = 0;
//                        end
                        
//                        S_WAIT_NEDGE : begin
//                            if(dht_nedge)begin
//                                if(count_usec < 45)begin
//                                    temp_data = {temp_data[38:0], 1'b0};
//                                end
//                                else begin
//                                    temp_data = {temp_data[38:0], 1'b1};
//                                end
//                                data_count =  data_count + 1;
//                                read_state =  S_WAIT_PEDGE;
//                            end
//                            else begin
//                                count_usec_e = 1;
//                            end
//                        end
                        
//                    endcase
                    
//                    if(data_count >= 40)begin
//                        data_count = 0;
//                        next_state = S_IDLE;
//                        humidity = temp_data[39:32];
//                        temperature = temp_data[23:16];
//                    end
//                    if(count_usec > 22'd50_000)begin
//                        data_count = 0;
//                        next_state = S_IDLE;
//                        count_usec_e = 0;
//                    end
//                end
                
//                default : next_state = S_IDLE;                
                
//            endcase
//        end
//    end         

//endmodule


//////-------------------------------------------------------------------------------------------//
//module i2c_lcd_send_byte_sb(
//    input clk, reset_p,
//    input [6:0] addr, 
//    input [7:0] send_buffer,
//    input send, rs,
//    output scl, sda,
//    output reg busy);
    
    
//    parameter IDLE                      = 6'b00_0001;
//    parameter SEND_HIGH_NIBBLE_DISABLE  = 6'b00_0010;
//    parameter SEND_HIGH_NIBBLE_ENABLE   = 6'b00_0100;
//    parameter SEND_LOW_NIBBLE_DISABLE   = 6'b00_1000;
//    parameter SEND_LOW_NIBBLE_ENABLE    = 6'b01_0000;
//    parameter SEND_DISABLE              = 6'b10_0000;
    
//    reg [7:0] data;
//    reg valid;
    
//    wire send_pedge;
//    edge_detector_n ed_send(.clk(clk), .reset_p(reset_p), 
//                .cp(send), .p_edge(send_pedge));
    
//    reg [21:0] count_usec;
//    reg count_usec_e;
//    wire clk_usec;
//    clock_usec usec_clk(clk, reset_p, clk_usec);
    
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p)begin
//            count_usec = 0;
//        end
//        else begin
//            if(clk_usec && count_usec_e)count_usec = count_usec + 1;
//            else if(!count_usec_e)count_usec = 0;
//        end
//    end
    
//    reg [5:0] state, next_state;
//    always @(negedge clk or posedge reset_p)begin
//        if(reset_p)state = IDLE;
//        else state = next_state;
//    end
    
//    always @(posedge clk or posedge reset_p)begin
//        if(reset_p)begin
//            next_state = IDLE;
//            busy = 0;
//        end
//        else begin
//            case(state)
//                IDLE:begin
//                    if(send_pedge)begin
//                        next_state = SEND_HIGH_NIBBLE_DISABLE;
//                        busy = 1;
//                    end
//                end
//                SEND_HIGH_NIBBLE_DISABLE:begin
//                    if(count_usec <= 22'd200)begin
//                        data = {send_buffer[7:4], 3'b100, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
//                        valid = 1;
//                        count_usec_e = 1;
//                    end
//                    else begin
//                        next_state = SEND_HIGH_NIBBLE_ENABLE;
//                        count_usec_e = 0;
//                        valid = 0;
//                    end
//                end
//                SEND_HIGH_NIBBLE_ENABLE:begin
//                    if(count_usec <= 22'd200)begin
//                        data = {send_buffer[7:4], 3'b110, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
//                        valid = 1;
//                        count_usec_e = 1;
//                    end
//                    else begin
//                        next_state = SEND_LOW_NIBBLE_DISABLE;
//                        count_usec_e = 0;
//                        valid = 0;
//                    end
//                end
//                SEND_LOW_NIBBLE_DISABLE:begin
//                    if(count_usec <= 22'd200)begin
//                        data = {send_buffer[3:0], 3'b100, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
//                        valid = 1;
//                        count_usec_e = 1;
//                    end
//                    else begin
//                        next_state = SEND_LOW_NIBBLE_ENABLE;
//                        count_usec_e = 0;
//                        valid = 0;
//                    end
//                end
//                SEND_LOW_NIBBLE_ENABLE:begin
//                    if(count_usec <= 22'd200)begin
//                        data = {send_buffer[3:0], 3'b110, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
//                        valid = 1;
//                        count_usec_e = 1;
//                    end
//                    else begin
//                        next_state = SEND_DISABLE;
//                        count_usec_e = 0;
//                        valid = 0;
//                    end
//                end
//                SEND_DISABLE:begin
//                    if(count_usec <= 22'd200)begin
//                        data = {send_buffer[3:0], 3'b100, rs}; //[d7 d6 d5 d4] [BL EN RW] RS
//                        valid = 1;
//                        count_usec_e = 1;
//                    end
//                    else begin
//                        next_state = IDLE;
//                        count_usec_e = 0;
//                        valid = 0;
//                        busy = 0;
//                    end
//                end
//            endcase
//        end
//    end
    
//    I2C_master_sb master(.clk(clk), .reset_p(reset_p),
//        .rd_wr(0), .addr(7'h27), .data(data), .valid(valid), 
//        .sda(sda), .scl(scl));

//endmodule

module pwm_test_sb(
    input clk, reset_p,
    input [31:0] duty,
    input [31:0] Tus,
    output reg pwm
);
    
    reg [31:0] duty_cnt;
     
    always @(posedge clk, posedge reset_p)
      begin
        if(reset_p)
            pwm = 0;
            else if(duty_cnt < duty) pwm = 1;
            else pwm = 0;        
      end
    
    always  @(posedge clk, posedge reset_p)
    if (reset_p)
        duty_cnt = 0;
    else if (duty_cnt == Tus)
        duty_cnt = 1;
    else duty_cnt = duty_cnt + 1;
   
endmodule

//module multy_fab_scale_cntr_top(
//    input clk, reset_p, echo, 
//    input [1:0] sw,
//    inout dht,
//    input [3:0] btn,
//    output sda, scl, trigger, us_sig,
//    output  [2:0] status_led, 
//    output [3:0] com, 
//    output wire [3:0] over_temp,
//    output [7:0] seg_7,
//    output pwm_smotor, led_pwm, motor_pwm
//    );
    
 
//  lcd_dht_sb lcd_dht( clk, reset_p, dht, sda, scl, over_temp );  
//  multy_fan_scale_cntr_sb fan( clk, reset_p, btn[0], finish, 0, sw[0], over_temp, state_led, status_led, motor_pwm );  
//  servo_motor_cntr_sb servo( clk, reset_p, btn[1], state_led , pwm_smotor, led  );
//  led_fsm_sb ledfsm( clk, reset_p, btn[2], led_pwm );
//  down_counter_sb dcnt(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .state_led(state_led), .com(com), .seg_7(seg_7), .finish(finish));
  
////  ultrasonic_top_sb ( clk, reset_p,  echo,  trigger, us_sig);
  
//  endmodule

////----------------------------------------------------------------------------------------------------------------------------------------------------///////////
////----------------------------------------------------------------------------------------------------------------------------------------------------///////////
////----------------------------------------------------------------------------------------------------------------------------------------------------///////////
////----------------------------------------------------------------------------------------------------------------------------------------------------///////////
//혠 선풍기 
/////선풍기 기본 모듈 //////////////////
//LED 밝기 조절 
module led_over(
    input clk, reset_p, btn,
    output pwm
);

    reg [31:0] led;

    always @(posedge clk, posedge reset_p)
        if(reset_p) led = 0;
        else if(btn_pedge) begin
            if(led >= 9900) led = 0;     
            else led = led + 3300;
        end
          
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));

    pwm_test pwm_led(.clk(clk), .reset_p(reset_p), .duty(led), .Tus(10_000), .pwm(pwm));
    
endmodule


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 //////////////////////////////ultrasonic_5cm미만이면 모터 일시정지, 5cm이상이면 모터 모터+초음파센서 연결한 부분 ////////////////////////////////////////////////////
module multy_fan_ultrasonic_top (
    input clk, reset_p, 
    input echo, 
    input btn,
    output trigger,
    output [3:0] com,
    output [7:0] seg_7,
    output [2:0] debugled,
    output pwm_duty_t);
   
    wire [11:0] distance; //bin_to_dec의 bindl 12bit라 맞춰주기 위함 
    wire [15:0] bcd_dist; //bcd가 16bit라 맞춰주기 위함 
     bin_to_dec dis(.bin(distance), .bcd(bcd_dist));
     fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_dist), .seg_7_an(seg_7), .com(com));
    wire pwm_duty;    
    reg us_sig;
        
           
 always @ (posedge clk , posedge reset_p)begin
        if(reset_p) begin
            us_sig=0; 
        end
        else begin 
            if( distance<5) us_sig=0; //0이면 멈춤 
            else if(distance >=5) us_sig=1; //1이면 동작 
        end
    end         
    assign pwm_duty_t = us_sig ? pwm_duty : 0 ; 
    ultrasonic ultra(clk, reset_p, echo, trigger, distance, led_bar);
    multy_fan_scale_cntr fan(.clk(clk), .reset_p(reset_p), .btn(btn), .motor_pwm(pwm_duty), .debugled(debugled));
endmodule

//////////////////////////////선풍기 팬 듀티제어///////////////////////////////////////////////////
 module multy_fan_scale_cntr(
    input clk, reset_p,
    input btn, 
    output motor_pwm,
    output [3:0] debugled

    );
    
    parameter IDLE  =  4'b0001;
    parameter STEP_1 = 4'b0010; 
    parameter STEP_2 = 4'b0100; 
    parameter STEP_3 = 4'b1000; 
//    parameter STOP =     10000;
    reg [3:0] state, next_state;
    
    wire  btn_pedge;     
    reg [6:0] duty; 
    pwm_128step pwm(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(100), .pwm_128(motor_pwm)); 

    button_cntr start(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));

    //state만드는 레지스터 
    always @(negedge clk, posedge reset_p) begin //negedge
        if(reset_p ) state = IDLE; 
        else state = next_state; 
    end  
    
    assign debugled= state; 
    
     always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin 
            next_state = IDLE; 
            duty =0; 
        end
        else begin
            case(state) 
                IDLE : begin   
                        if(btn_pedge) next_state =STEP_1;
                          duty = 0;                       
                end
               STEP_1 : begin 
                        if(btn_pedge) next_state = STEP_2; 
                         duty =30;  
                        
                end
                STEP_2 : begin 
                        if(btn_pedge) next_state = STEP_3; 
                         duty = 60; 

                end
                STEP_3 : begin 
                        if(btn_pedge) next_state = IDLE; 
                         duty =100;  
                end
                default: next_state = IDLE;
             endcase                  
       end
    end
endmodule

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//멀티팬 컨트롤러  타이머 모듈 //
//module multy_fantimer( 
//    input clk, reset_p, 
//    input btn_pedge, btn_nedge,
//    output [15:0] value,
//    output [2:0] debugled
// );
 
// parameter IDLE = 4'b0001; 
// parameter STEP_1 = 4'b0010; 
// parameter STEP_3 = 4'b0100; 
// parameter STEP_5 = 4'b1000; 

//    wire [3:0] set_sec1, set_sec10,set_min1, set_min10; 
//    reg [3:0] setting_min;  
//   assign  set_min1 = setting_min;  
    
//    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; 
//    wire load_enable, dec_clk; //clk_start : start했을 때만 클럭이 나오도록 함 
//    reg start_stop;  
//    wire [15:0] cur_time, set_time;       
//    wire timeout_pedge;
//    reg time_out;  
    
//     clock_instance divide(.clk(clk_start), .reset_p(reset_p), .clk_msec(clk_msec), .clk_sec(clk_sec), .clk_min(clk_min));

//     always @ (posedge clk or posedge reset_p)begin 
//        if(reset_p) start_stop = 0; //stop
//        else begin 
//            if(btn_pedge) start_stop =0; //start = 1
//            else if(btn_nedge) start_stop = 1; 
//            else if(timeout_pedge) begin start_stop =0;   end        
//        end
//     end

//     assign clk_start = start_stop ?  clk : 0; //start(1) ->clk, stop(0) -> 0
  
//    always @(posedge clk or posedge reset_p) begin //시간이 완료되었을 때 time_out을 이용해서 멈춤 
//        if(reset_p) time_out =0; 
//        else begin                                  //time_out =0 //0000초 
//            if(start_stop &&clk_msec && cur_time ==0) time_out = 1; //start_stop 1, cut_time 0 이 되면 1msec 후에 time_out이 1이됨 그 엣지가지고 start_stop이 0이됨
//            else  time_out = 0; //1msec에 한번씩 time_out을 0으로 clear 
//        end
//    end 

//    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));  //timeout되었을 때 
  
  
//  edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 

 
////    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); 
//    loadable_down_counter_dec_60 cur_sec(clk, reset_p ,clk_sec ,load_enable ,4'b0000,4'b0000 ,cur_sec1,cur_sec10 ,dec_clk);   
//    loadable_down_counter_dec_60 cur_min(clk, reset_p ,dec_clk ,load_enable ,setting_min,4'b0000 ,cur_min1,cur_min10 ); 

//    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1}; //현재 시간 
//    assign set_time ={set_min10, set_min1, set_sec10, set_sec1};
//    assign value = start_stop ? cur_time : set_time; 
    
//     reg [3:0] mode,next_mode;
//    assign debugled[0] = mode[1];   
//    assign debugled[1] = mode[2];   
//    assign debugled[2] = mode[3];   

//    always @(negedge clk, posedge reset_p) begin //negedge
//        if(reset_p ) mode = IDLE; 
//        else mode = next_mode; 
//    end 
   
//   always @(posedge clk, posedge reset_p) begin
//    if(reset_p) begin
//        setting_min = 4'b0000;   
//        next_mode = IDLE;
//      end
//    else begin
//            case(mode) 
//            IDLE : begin            
//                setting_min = 4'b0000; 
//                if(btn_pedge)    
//                     next_mode = STEP_1;  
//             end 
            
//            STEP_1 : begin    
//                setting_min = 4'b0001; 
//                if(btn_pedge)    
//                      next_mode = STEP_3; 
//             end  
//            STEP_3 : begin
//                 setting_min = 4'b0011;
//                 if(btn_pedge) 
//                     next_mode = STEP_5; 
//            end 
//            STEP_5 : begin 
//                setting_min = 4'b0101; 
//                if(btn_pedge) 
//                      next_mode = IDLE; 
//            end 
//            default :  next_mode = IDLE;  
//            endcase
//         end
//     end  
// endmodule  


//멀티팬 컨트롤러  타이머 모듈 //
module multy_fantimer_cntr_min( 
    input clk, reset_p, 
    input btn_pedge,btn_nedge,
    output [15:0] value,
    output [2:0] debugled
 );
 
 parameter IDLE = 4'b0001; 
 parameter STEP_1 = 4'b0010; 
 parameter STEP_3 = 4'b0100; 
 parameter STEP_5 = 4'b1000; 

    wire [3:0] set_sec1, set_sec10,set_min1, set_min10; 
    reg [3:0] setting_min;  
   assign  set_min1 = setting_min;  
    
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; 
    wire load_enable, dec_clk; //clk_start : start했을 때만 클럭이 나오도록 함 
    reg start_stop;  
    wire [15:0] cur_time, set_time;       
    wire timeout_pedge;
    reg time_out;  
    
     clock_instance divide(.clk(clk_start), .reset_p(reset_p), .clk_msec(clk_msec), .clk_sec(clk_sec), .clk_min(clk_min));

     always @ (posedge clk or posedge reset_p)begin 
        if(reset_p) start_stop = 0; //stop
        else begin 
            if(btn_pedge) start_stop =0; //start = 1
            else if(btn_nedge) start_stop = 1; 
            else if(timeout_pedge) start_stop =0; 
        end
     end
     assign clk_start = start_stop ?  clk : 0; //start(1) ->clk, stop(0) -> 0
  
    always @(posedge clk or posedge reset_p) begin //시간이 완료되었을 때 time_out을 이용해서 멈춤 
        if(reset_p) time_out =0; 
        else begin                                  //time_out =0 //0000초 
            if(start_stop &&clk_msec && cur_time ==0) time_out = 1; //start_stop 1, cut_time 0 이 되면 1msec 후에 time_out이 1이됨 그 엣지가지고 start_stop이 0이됨
            else  time_out = 0; //1msec에 한번씩 time_out을 0으로 clear 
        end
    end 

    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));  //timeout되었을 때 
  
  
  edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 

 
//    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); 
    loadable_down_counter_dec_60 cur_sec(clk, reset_p ,clk_sec ,load_enable ,4'b0000,4'b0000 ,cur_sec1,cur_sec10 ,dec_clk);   
    loadable_down_counter_dec_60 cur_min(clk, reset_p ,dec_clk ,load_enable ,setting_min,4'b0000 ,cur_min1,cur_min10 ); 

    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1}; //현재 시간 
    assign set_time ={set_min10, set_min1, set_sec10, set_sec1};
    assign value = start_stop ? cur_time : set_time; 
    
     reg [3:0] mode,next_mode;
    assign debugled[0] = mode[1];   
    assign debugled[1] = mode[2];   
    assign debugled[2] = mode[3];   

    always @(negedge clk, posedge reset_p) begin //negedge
        if(reset_p ) mode = IDLE; 
        else mode = next_mode; 
    end 
   
   always @(posedge clk, posedge reset_p) begin
    if(reset_p) begin
        setting_min = 4'b0000;   
        next_mode = IDLE;
      end
    else begin
            case(mode) 
            IDLE : begin            
                setting_min = 4'b0000; 
                if(btn_pedge)    
                     next_mode = STEP_1;  
             end 
            
            STEP_1 : begin    
                setting_min = 4'b0001; 
                if(btn_pedge)    
                      next_mode = STEP_3; 
             end  
            STEP_3 : begin
                 setting_min = 4'b0011;
                 if(btn_pedge) 
                     next_mode = STEP_5; 
            end 
            STEP_5 : begin 
                setting_min = 4'b0101; 
                if(btn_pedge) 
                      next_mode = IDLE; 
            end 
            default :  next_mode = IDLE;  
            endcase
         end
     end  
 endmodule  

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////// /////////////////////////////
module multy_fan_timer_top(
    input clk, reset_p, 
    input  [1:0]btn,
    output [3:0] com, 
    output [7:0] seg_7,
    output [2:0] debugled);
    
     wire [15:0] value;
     wire  btn_pedge,btn_nedge;

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com)); 
    button_cntr start(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_pe(btn_pedge), .btn_ne(btn_nedge));

  multy_fantimer_cntr_min min( .clk(clk), .reset_p(reset_p), .btn_pedge(btn_pedge), .btn_nedge(btn_nedge), .value(value), .debugled(debugled)); 
  
  
endmodule
 
 // 선풍기 회전
module servo_motor_cntr_t(
    input clk, reset_p,
    input btn,
    output pwm_smotor,
    output [1:0] debugled
);

    parameter MOTOR_START   = 2'b01;
    parameter MOTOR_STOP    = 2'b10;
    
    reg [1:0] state, next_state;
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = MOTOR_STOP;
        else state = next_state;
    end
    
    assign led = state;
    
    reg [21:0] duty;
    reg up_down;
       
    reg [31:0] clk_div;
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_pedge;
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[8]), .p_edge(clk_div_pedge));
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            next_state = MOTOR_STOP; 
            duty = 58_000;
            up_down = 1;
        end  
        else begin
            case(state)
                MOTOR_START : begin
                    if(btn_pedge)begin
                        next_state = MOTOR_STOP;    
                    end
                    else if(clk_div_pedge) begin
                            if(duty > 256_000) up_down = 0;
                            else if(duty <= 58_000) up_down = 1;
            
                            if(up_down) duty = duty + 1;   
                            else duty = duty - 1;
                    end
                end
                MOTOR_STOP : begin
                    if(btn_pedge)begin
                        next_state = MOTOR_START;                  
                    end
                end
            endcase          
        end
     end       
          
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));
    
    pwm_128step pwm(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_128(pwm_smotor));
// pwm_test_sb pwm_led(.clk(clk), .reset_p(reset_p), .duty(duty), .Tus(2_000_000), .pwm(pwm_smotor));

endmodule
 



module servo_motor_cntr_s(
    input clk, reset_p, btn,
    output pwm_smotor,
    output [3:0] debugled
);

    parameter MOTOR_START   = 4'b0001;
    parameter MOTOR_STOP    = 4'b0010;
    parameter DUTY_SETUP    = 4'b0100;
    
    reg [3:0] state, next_state;
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = MOTOR_STOP;
        else state = next_state;
    end
    
    assign led = state;
    
    reg [21:0] duty;
    reg up_down;
       
    reg [31:0] clk_div, duty_max, duty_min;
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_pedge;
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[8]), .p_edge(clk_div_pedge));
    
    reg [10:0] msec_cnt;
    reg cnt_reset;
    always @(posedge clk, posedge reset_p)
        if(reset_p) msec_cnt = 0;
        else if(clk_msec) msec_cnt = msec_cnt - 1;
        else if(cnt_reset) msec_cnt = 700;
          
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            next_state = MOTOR_STOP; 
            duty = 58_000;
            up_down = 1;
            duty_max = 256000;
            duty_min = 58000;
        end  
        else begin
            case(state)
                MOTOR_START : begin
                    if(btn_pedge)begin
                       next_state = DUTY_SETUP;
                       cnt_reset = 1;    
                    end
                    else if(clk_div_pedge) begin
                            if(duty > duty_max) up_down = 0;
                            else if(duty <= duty_min) up_down = 1;
            
                            if(up_down) duty = duty + 1;   
                            else duty = duty - 1;
                    end
                end
                MOTOR_STOP : begin
                    if(btn_pedge)begin
                        next_state = MOTOR_START;                  
                    end
                    duty = duty;
                end
               DUTY_SETUP : begin
                       cnt_reset = 0;
                       if(msec_cnt == 0) begin next_state = MOTOR_STOP; end
                       else if(btn_pedge)begin
                                  case(up_down)
                                    1: begin duty_max = duty; next_state = MOTOR_START; end
                                    0: begin duty_min = duty; next_state = MOTOR_START; end
                                  endcase
                      end 
               end                
            endcase          
        end
     end       
    

    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));
    clock_usec     clk_us (clk, reset_p, clk_usec);                   // sysclk -> 1us
    clock_div_1000 clk_ms (clk, reset_p, clk_usec, clk_msec);         // 1us -> 1ms    
//    pwm_test_sb pwm_led(.clk(clk), .reset_p(reset_p), .duty(duty), .Tus(2_000_000), .pwm(pwm_smotor));
    
    
    pwm_128step pwm(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_128(pwm_smotor));
    
endmodule




module multy_fan_scale_cntr_hyen(
    input clk, reset_p,
    input time_off, 
    input btn, 
    output motor_pwm,
    output [3:0] debugled
    );
    
    parameter IDLE  =  4'b0001;
    parameter STEP_1 = 4'b0010; 
    parameter STEP_2 = 4'b0100; 
    parameter STEP_3 = 4'b1000; 
//    parameter STOP =     10000;
    reg [3:0] state, next_state;
    
    wire  btn_pedge;     
    reg [6:0] duty; 
    pwm_128step pwm(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(100), .pwm_128(motor_pwm)); 

    button_cntr start(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));

    //state만드는 레지스터 
    always @(negedge clk, posedge reset_p) begin //negedge
        if(reset_p ) state = IDLE; 
        else state = next_state; 
    end  
    
    assign debugled= state; 
    
     always @(posedge clk or posedge reset_p) begin 
        if(reset_p) begin 
            next_state = IDLE; 
            duty =0; 
        end
        else begin
            case(state) 
                IDLE : begin   
                        duty = 0;                       
                        if(btn_pedge) next_state =STEP_1;
                end
               STEP_1 : begin 
                         duty =30;  
                        if(time_off) next_state = IDLE; 
                        else if(btn_pedge) next_state = STEP_2; 
                        
                end
                STEP_2 : begin 
                         duty = 60; 
                        if(time_off) next_state = IDLE; 
                        else if(btn_pedge) next_state = STEP_3; 

                end
                STEP_3 : begin 
                        duty =100;  
                        if(time_off) next_state = IDLE; 
                        else if(btn_pedge) next_state = IDLE; 
                end
                default: next_state = IDLE;
             endcase                  
       end
    end
endmodule




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//멀티팬 컨트롤러  타이머 모듈 //
module multy_fantimer_hyen( 
    input clk, reset_p, 
    input btn,
    output [7:0] seg_7,
    output [3:0] com, 
    output [2:0] debugled
//    output reg time_off
 );
 reg time_off;
 
 parameter IDLE = 4'b0001; 
 parameter STEP_1 = 4'b0010; 
 parameter STEP_3 = 4'b0100; 
 parameter STEP_5 = 4'b1000; 

    wire [3:0] set_sec1, set_sec10,set_min1, set_min10; 
    reg [3:0] setting_min;  
   assign  set_min1 = setting_min;  
    
    wire [3:0] cur_sec1, cur_sec10, cur_min1, cur_min10; 
    wire load_enable, dec_clk; //clk_start : start했을 때만 클럭이 나오도록 함 
    reg start_stop;  
    wire [15:0] cur_time, set_time;       
    wire timeout_pedge;
    reg time_out;  
    wire [15:0]  value; 
     clock_instance divide(.clk(clk_start), .reset_p(reset_p), .clk_msec(clk_msec), .clk_sec(clk_sec), .clk_min(clk_min));

     always @ (posedge clk or posedge reset_p)begin 
        if(reset_p) begin 
            start_stop = 0; //stop
            time_off =1; //꺼져인  
         end
        else begin 
            if(btn_pedge) start_stop =0; //start = 1
            else if(btn_nedge) begin 
                start_stop = 1; 
                time_off =0; 
             end
            else if(timeout_pedge) begin start_stop =0; time_off =1;    end 
            
        end
     end

     assign clk_start = start_stop ?  clk : 0; //start(1) ->clk, stop(0) -> 0
  
    always @(posedge clk or posedge reset_p) begin //시간이 완료되었을 때 time_out을 이용해서 멈춤 
        if(reset_p) time_out =0; 
        else begin                                  //time_out =0 //0000초 
            if(start_stop &&clk_msec && cur_time ==0) time_out = 1; //start_stop 1, cut_time 0 이 되면 1msec 후에 time_out이 1이됨 그 엣지가지고 start_stop이 0이됨
            else  time_out = 0; //1msec에 한번씩 time_out을 0으로 clear 
        end
    end 

    edge_detector_n ed_timeout(.clk(clk), .reset_p(reset_p), .cp(time_out), .p_edge(timeout_pedge));  //timeout되었을 때 
    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); //t-ff나올 때니까 posedge일 때 잡아야함 button이 아니니까 nedge잡으면 안됨 

    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com)); 
    button_cntr start(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));

 
//    edge_detector_n ed(.clk(clk), .reset_p(reset_p), .cp(start_stop), .p_edge(load_enable)); 
    loadable_down_counter_dec_60 cur_sec(clk, reset_p ,clk_sec ,load_enable ,4'b0000,4'b0000 ,cur_sec1,cur_sec10 ,dec_clk);   
    loadable_down_counter_dec_60 cur_min(clk, reset_p ,dec_clk ,load_enable ,setting_min,4'b0000 ,cur_min1,cur_min10 ); 

    assign cur_time = {cur_min10, cur_min1, cur_sec10, cur_sec1}; //현재 시간 
    assign set_time ={set_min10, set_min1, set_sec10, set_sec1};
    assign value = start_stop ? cur_time : set_time; 
    
    reg [3:0] mode,next_mode;
    assign debugled[0] = mode[1];   
    assign debugled[1] = mode[2];   
    assign debugled[2] = mode[3];   

    always @(negedge clk, posedge reset_p) begin //negedge
        if(reset_p ) mode = IDLE; 
        else mode = next_mode; 
    end 
   
   always @(posedge clk, posedge reset_p) begin
    if(reset_p) begin
        setting_min = 4'b0000;   
        next_mode = IDLE;
      end
    else begin
            case(mode) 
            IDLE : begin            
                setting_min = 4'b0000; 
                if(btn_pedge)    
                     next_mode = STEP_1;  
             end 
            
            STEP_1 : begin    
                setting_min = 4'b0001; 
                if(btn_pedge)    
                      next_mode = STEP_3; 
             end  
            STEP_3 : begin
                 setting_min = 4'b0011;
                 if(btn_pedge) 
                     next_mode = STEP_5; 
            end 
            STEP_5 : begin 
                setting_min = 4'b0101; 
                if(btn_pedge) 
                      next_mode = IDLE; 
            end 
            default :  next_mode = IDLE;  
            endcase
         end
     end  
 endmodule


module multy_fan_timer_and_dc_motor_top_hyen(
    input clk, reset_p, 
    input [1:0] btn,
//    output motor_pwm,
    output [3:0] com, 
    output [7:0] seg_7,
    output [2:0] debugled );
//    , output [3:0] led);
    
//wire time_off ; 
multy_fantimer_hyen min( .clk(clk), .reset_p(reset_p), .btn(btn[0]), .seg_7(seg_7), .com(com), .debugled(debugled) /*, .time_off(time_off)*/);
  
// multy_fan_scale_cntr_hyen dc(.clk(clk), .reset_p(reset_p), .time_off(time_off), .btn(btn[1]), .motor_pwm(motor_pwm), .debugled(led));
     
endmodule



module servo_motor_cntr_hyen(
    input clk, reset_p, btn,
    output pwm_smotor,
    output [1:0] led
);

    parameter MOTOR_START   = 2'b01;
    parameter MOTOR_STOP    = 2'b10;
    
    reg [1:0] state, next_state;
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = MOTOR_STOP;
        else state = next_state;
    end
    
    assign led = state;
    
    reg [21:0] duty;
    reg up_down;
       
    reg [31:0] clk_div;
    always @(posedge clk) clk_div = clk_div + 1;
    
    wire clk_div_pedge;
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[24]), .p_edge(clk_div_pedge));
    
    always @(posedge clk, posedge reset_p)begin
        if(reset_p)begin
            next_state = MOTOR_STOP; 
            duty = 14;
            up_down = 1;
        end  
        else begin
            case(state)
                MOTOR_START : begin
                    if(btn_pedge)begin
                        next_state = MOTOR_STOP;    
                    end
                    else if(clk_div_pedge) begin
                            if(duty > 64) up_down = 0;
                            else if(duty <= 14) up_down = 1;
            
                            if(up_down) duty = duty + 1;   
                            else duty = duty - 1;
                    end
                end
                MOTOR_STOP : begin
                    if(btn_pedge)begin
                        next_state = MOTOR_START;                  
                    end
                    duty = duty;
                end
            endcase          
        end
     end       
          
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge));
    pwm_512step servo(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_512(pwm_smotor));

//    pwm_128step pwm(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_freq(50), .pwm_128(pwm_smotor));
    
    
endmodule