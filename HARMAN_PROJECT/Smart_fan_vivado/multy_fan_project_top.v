`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/07/11 09:42:27
// Design Name: 
// Module Name: mul_fan_project
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mul_fan_project(
    input clk, reset_p, 
    input sw, //자동, 수동 모드 
    input [3:0] btn,
    output  [2:0] status_led, //fan scale 상태 led
    output [3:0] com,  
    output [7:0] seg_7,
    output pwm_smotor, led_pwm, motor_pwm); // 회전모드 servo motor, 무드등 기능 led, 선풍기 fan 
    
    wire [3:0] over_temp;
    
    multy_fan_scale_cntr_fan scale( clk, reset_p, btn[0], finish, sw, over_temp, state_led, status_led, motor_pwm );  
    servo_motor_cntr_fan servo( clk, reset_p, btn[1], state_led , pwm_smotor, led);
    led_fsm_fan light( clk, reset_p, btn[2], led_pwm );
    down_counter_fan dcnt( clk, reset_p, state_led, btn[3], com, seg_7, finish );
    
endmodule
 
 module down_counter_fan (
    input clk, reset_p, state_led,
    input btn,  //0 start/pause, 1 set_sec, 0 set_min, 3 reset
    output [3:0] com,
    output [7:0] seg_7,
    output reg finish);

    parameter IDLE    =   7'b0000001;
    parameter R_MODE1 =   7'b0000010;
    parameter R_MODE2 =   7'b0000100;
    parameter R_MODE3 =   7'b0001000;
    parameter R_START =   7'b0010000;
    parameter R_MOD_ACT = 7'b0100000;
    parameter R_USER_M =  7'b1000000;
    
    button_cntr btn_cntr_0 (clk, reset_p, btn, btn_pedge);  
    reg [31:0] msec_cnt;
    reg reserve_flag, msec_reset;
    reg [3:0] set_value;
    reg load;
    reg [6:0]state, next_state;
    always @(negedge clk, posedge reset_p)
        if(reset_p) state = IDLE;
        else state = next_state;
   
    wire [3:0] sec1, sec10, min1, min10;
    wire [15:0] value, timer;
    wire clk_start;
    
      always @(posedge clk, posedge reset_p)
        if(reset_p) msec_cnt = 0;
        else if(msec_reset) msec_cnt = 500;
        else if(msec_cnt == 0) msec_cnt = 0;
        else if(clk_msec) msec_cnt = msec_cnt - 1;
  
    always @(posedge clk, posedge reset_p)
        if(reset_p) begin 
            next_state = IDLE; 
            msec_reset = 0;  
            load = 0; 
            finish = 0; 
        end
        else 
            case(state)
                IDLE      : begin 
                    load = 0; 
                    finish = 0; 
                    if(btn_pedge) begin 
                        next_state = R_MODE1;
                        msec_reset = 1;  //msec_cnt = 500 
                    end 
                end         
                R_MODE1   : begin 
                    set_value = 1; 
                    msec_reset = 0; 
                    if(msec_cnt==0) begin
                         next_state = R_START; 
                         msec_reset = 1; 
                     end 
                     else if(btn_pedge) begin
                        next_state = R_MODE2; 
                        msec_reset = 1; 
                    end 
                end // 1
                R_MODE2   : begin 
                    set_value = 3; 
                    msec_reset = 0; 
                    if(msec_cnt==0) begin 
                        next_state = R_START; 
                        msec_reset = 1; 
                    end 
                    else if(btn_pedge) begin 
                        next_state = R_MODE3; 
                        msec_reset = 1; 
                    end 
                end // 3
                R_MODE3   : begin 
                    set_value = 5; 
                    msec_reset = 0; 
                    if(msec_cnt==0) begin 
                        next_state = R_START; 
                        msec_reset = 1; 
                    end 
                    else if(btn_pedge) begin 
                        next_state = R_USER_M; 
                        msec_reset = 1; 
                        set_value = 0; 
                    end 
                end    // 5        
                R_START   : begin 
                    load = 1; 
                    next_state = R_MOD_ACT; 
                end
                R_MOD_ACT : begin 
                    load = 0; 
                    if(state_led) next_state = IDLE; 
                    else if(btn_pedge) next_state = IDLE; 
                    else if(value == 0) begin 
                        next_state = IDLE; 
                        finish = 1; 
                    end  
                end
                R_USER_M  : begin 
                    msec_reset = 0; 
                    if(msec_cnt==0) begin 
                        if(set_value == 0) next_state = IDLE; 
                        else next_state = R_START; 
                    end 
                    else if(btn_pedge) begin 
                        if(set_value == 9) set_value = 0; 
                        else set_value = set_value + 1; msec_reset = 1; 
                    end 
                end
            endcase

    wire clk_usec, clk_msec, clk_sec;
    clock_usec     clk_us (clk, reset_p, clk_usec);                   // sysclk -> 1us
    clock_div_1000 clk_ms (clk, reset_p, clk_usec, clk_msec);         // 1us -> 1ms
    clock_div_1000 clk_s  (clk, reset_p, clk_msec, clk_sec);    // 1ms -> 1s

    load_count_ud_N #(10) sec_1 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), 
                            .set_value(0), .clk_dn(clk_sec), .digit(sec1), .clk_over_flow(), .clk_under_flow(under_sec1) );
    load_count_ud_N #(6) sec_10 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), 
                            .set_value(0), .clk_dn(under_sec1), .digit(sec10), .clk_over_flow(), .clk_under_flow(under_sec10) );
    load_count_ud_N #(10) min_1 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), 
                            .set_value(set_value), .clk_dn(under_sec10), .digit(min1), .clk_over_flow(over_min), .clk_under_flow(under_min1) );
    load_count_ud_N #(10) min_10 (.clk(clk_start), .reset_p(reset_p), .clk_up(), .data_load(load), 
                            .set_value(0), .clk_dn(under_min1), .digit(min10), .clk_over_flow(), .clk_under_flow() );

    assign value = state[5] ? {min10, min1, sec10, sec1} :
                   state[0] ? {15'b0} :
                   state[6] ? {4'd12, set_value, 4'b0, 4'b0} 
                            : {4'b0, set_value, 4'b0, 4'b0} ;
    assign clk_start = state[5] ? clk : 0;
    
    fnd_4digit_cntr fnd (.clk(clk), .reset_p(reset_p), .value(value), .seg_7_an(seg_7), .com(com));

endmodule


module multy_fan_scale_cntr_fan( //주파수 100만 100hz
//cnt_reset(msec_cnt)를 사용한 이유 : 더블탭 시 필요한 시간을 계산하기 위해 사용 
    input clk, reset_p,
    input btn, finish, sw, 
    input [3:0] over_temp,
    output state_led, 
    output reg [2:0] status_led,
    output pwm );
    
    parameter IDLE  =  7'b0000001;
    parameter STEP_1 = 7'b0000010;
    parameter STEP_2 = 7'b0000100;
    parameter STEP_3 = 7'b0001000;
    parameter MODSEL = 7'b0010000;
    parameter MODSET = 7'b0100000;
    parameter C_MODE = 7'b1000000;
    
    reg [6:0] state, next_state;
    wire  btn_pedge;
    reg [31:0] duty;
    pwm_test pwm_led(.clk(clk), .reset_p(reset_p), .duty(duty), .Tus(1000_000), .pwm(pwm));
    button_cntr start(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge) );
  
    reg [15:0] msec_cnt;
    reg cnt_reset_10s, cnt_reset;
    assign state_led = state[0];
    
    always @(posedge clk, posedge reset_p)
        if(reset_p) begin msec_cnt = 0; end
        else if(cnt_reset_10s) msec_cnt = 10000;
        else if(cnt_reset) msec_cnt = 500; //1msec마다 -1
        else if(clk_msec) msec_cnt = msec_cnt - 1;
        else if(msec_cnt == 0) msec_cnt = 0;
   
    //state만드는 레지스터
    always @(negedge clk, posedge reset_p) begin //negedge
        if(reset_p) state = IDLE;
        else if(sw) state = {3'b0, over_temp};
        else state = next_state;
    end
    reg [31:0] c_duty;
     always @(posedge clk or posedge reset_p) begin
        if(reset_p) begin
            next_state = IDLE;
            duty =0;
            c_duty = 0;
        end
        
        else begin
            case(state)
                IDLE : begin
                    if(btn_pedge) begin //만약 IDLE 상태에서 버튼 입력(single)이 들어오면 
                        next_state = MODSEL; // MODSEL로 이동 
                        cnt_reset = 1; // msec_cnt = 500; , msec마다 1씩 감소 
                    end
                   duty = 0;
                   status_led = 0;
                end
                STEP_1 : begin
                    if(btn_pedge) next_state = STEP_2; // 만약 약풍 상태에서 버튼 입력(single)이 들어오면 
                    else if(finish) next_state = IDLE;
                    duty = 300_000; 
                    status_led = 1;
                end
                STEP_2 : begin
                    if(btn_pedge) next_state = STEP_3;
                    else if(finish) next_state = IDLE;
                    duty = 500_000; 
                    status_led = 2;
                end
                STEP_3 : begin
                    if(btn_pedge) next_state = IDLE;
                    else if(finish) next_state = IDLE;
                    duty = 800_000;  
                    status_led = 4;
                end
                MODSEL : begin
                        cnt_reset = 0; //cnt_reset 다시 사용할 수 있도록 수 초기화 msec_cnt = msec_cnt - 1;  //500부터 -1씩 빠지는 중 
                        if(msec_cnt == 0) begin  //msec_cnt = 0;
                            if(btn == 1) next_state = C_MODE; // 500ms 지난 후에 버튼이 눌린 상태면 C_MODE로 이동 
                            else next_state = STEP_1;  // 500ms 안에 버튼이 들어오지 않으면 step1로 감 . msec_cnt이 0이 될 때까지 버튼 입력이 들어오지 않음. 즉, IDLE 상태에서 버튼이 한 번만 눌린 거니까 약풍 모드로 감 
                        end
                        else if(btn_pedge) begin 
                            next_state = MODSET; // 여기까지 왔다면 IDLE 상태에서 버튼 입력이 더블탭으로 들어온 것
                            cnt_reset_10s = 1; //msec_cnt = 10000;
                        end
                end
                MODSET : begin
                      cnt_reset_10s = 0; //msec_cnt = 10000; -> 1msec마다 1씩계속 감소 중 (카운터니까) 
                      if(msec_cnt > 9500) begin   //들어갈 수 없음 
                        if(btn == 0) next_state = STEP_2; // 500ms 안에 버튼이 안눌려 있으면 중풍으로 이동
                        else if(btn_pedge) next_state = C_MODE;  //pedge가 눌리려면 버튼이 떼지고 나서 눌러야 하므로 이 조건이 성립할 수 없음 
                      end
                      else if(clk_msec) c_duty = c_duty + 10000; //msec_cnt = msec_cnt - 1;
                      else if(msec_cnt == 0) next_state = C_MODE; //msec_cnt = 0;
                      else if(btn == 0) next_state = C_MODE;
                      else duty = c_duty;
                end
                C_MODE : begin
                    duty = c_duty; //duty라는 공간에 현재 duty 값을 저장함 
                    if(btn_pedge) next_state = IDLE; // 커스텀 모드 중에 버튼 입력(single)이 감지되면 선풍기 off  
                    else if(finish) next_state = IDLE; //down counter로부터 들어오는 finish 
                    status_led = 7;
                end
             endcase
       end
    end
    
    clock_usec     clk_us (clk, reset_p, clk_usec);                   // sysclk -> 1us
    clock_div_1000 clk_ms (clk, reset_p, clk_usec, clk_msec);         // 1us -> 1ms
    
endmodule

module servo_motor_cntr_fan(
    input clk, reset_p, btn, state_led,
    output pwm_smotor,
    output [3:0] led
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
    edge_detector_n ed1(.clk(clk), .reset_p(reset_p), .cp(clk_div[10]), .p_edge(clk_div_pedge));
    
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
                       cnt_reset = 1;    //msec_cnt = 700, (clk_msec,즉, 1msec마다 )msec_cnt = msec_cnt-1 
                    end
                    else if(clk_div_pedge) begin
                            if(duty > duty_max) up_down = 0;
                            else if(duty <= duty_min) up_down = 1;
            
                            if(state_led) duty= duty; 
                            else if(up_down) duty = duty + 1; 
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
                       cnt_reset = 0; //msec_cnt =700, 700msec마다 -1
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
    pwm_test pwm_led(.clk(clk), .reset_p(reset_p), .duty(duty), .Tus(2_000_000), .pwm(pwm_smotor));
    
endmodule


module led_fsm_fan(
    input clk, reset_p, btn,
    output pwm
);
    reg [31:0] led;
    
    parameter BTN_INPUT_1 = 4'b0001; // led 밝기 1
    parameter BTN_INPUT_2 = 4'b0010; // led 밝기 2
    parameter BTN_INPUT_3 = 4'b0100; // led 밝기 3
    parameter BTN_INPUT_4 = 4'b1000; // led off
    
    reg [3:0] state, next_state;
             
    always @(negedge clk or posedge reset_p)begin
        if(reset_p) state = BTN_INPUT_4;
        else state = next_state;
    end

    always @(posedge clk, posedge reset_p)
        if(reset_p) next_state = BTN_INPUT_4;
        else begin
            case(state)
                BTN_INPUT_4 : begin
                    led = 0; 
                    if(btn_pedge) next_state = BTN_INPUT_1;
                end
                BTN_INPUT_1 : begin
                    led = 3300; 
                    if(btn_pedge) next_state = BTN_INPUT_2;
                end
                BTN_INPUT_2 : begin
                    led = 6600; 
                    if(btn_pedge) next_state = BTN_INPUT_3;
                end
                BTN_INPUT_3 : begin
                    led = 9900; 
                    if(btn_pedge) next_state = BTN_INPUT_4;
                end     
            endcase       
        end
    
    button_cntr btn_cntr0(.clk(clk), .reset_p(reset_p), .btn(btn), .btn_pe(btn_pedge), .btn_ne(btn_nedge));
    
    pwm_test pwm_led(.clk(clk), .reset_p(reset_p), .duty(led), .Tus(10_000), .pwm(pwm));

endmodule

module pwm_test(
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


module load_count_ud_N #(
     parameter N = 10 )(
     input clk, reset_p,
     input clk_up,
     input clk_dn,
     input data_load,
     input [3:0] set_value,
     output reg [3:0] digit,
     output reg clk_over_flow,
     output reg clk_under_flow);

     always @(posedge clk, posedge reset_p) begin
         if (reset_p) begin
             digit = 0;
             clk_over_flow = 0;
             clk_under_flow = 0;
         end
         else begin
             if (data_load) begin
                 digit = set_value;
             end
             else if (clk_up) begin
                 if (digit >= (N-1)) begin 
                     digit = 0; 
                     clk_over_flow = 1;
                 end
                 else begin digit = digit + 1;
                 end
             end
             else if (clk_dn) begin
                 digit = digit - 1;
                 if (digit > (N-1)) begin
                     digit = (N-1);
                     clk_under_flow = 1;
                 end
             end
             else begin 
                 clk_over_flow = 0;
                 clk_under_flow = 0;
             end
         end
     end
 endmodule
