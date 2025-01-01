//adc를 이용한 flame_sensor 제어  

module adc_top (
    input clk, reset_p,
    input vauxp6, vauxn6,
    output [3:0] com,
    output [7:0] seg_7,
    output [15:0] bcd_value);
   
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
            adc_value ={2'b0, do_out[15:6] } ; //정밀도 10bit 0~1023 
     end
     
   
    bin_to_dec adc_bcd(.bin(adc_value), .bcd(bcd_value)); //12bit표현 
    fnd_4digit_cntr fnd(.clk(clk), .reset_p(reset_p), .value(bcd_value), .seg_7_an(seg_7), .com(com)); 

endmodule