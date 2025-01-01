//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
//Date        : Thu May 30 16:01:46 2024
//Host        : Digital-21 running 64-bit major release  (build 9200)
//Command     : generate_target flame_led_buzz_dht11_wrapper.bd
//Design      : flame_led_buzz_dht11_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module flame_led_buzz_dht11_wrapper
   (b_out_0,
    btn_3bit_tri_i,
    buzz_1bit_tri_o,
    com_0,
    dht11_data_0,
    g_out_0,
    iic_cntr_scl_io,
    iic_cntr_sda_io,
    iic_state_scl_io,
    iic_state_sda_io,
    r_out_0,
    reset,
    seg_7_0,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd,
    vauxn6_0,
    vauxp6_0);
  output b_out_0;
  input [2:0]btn_3bit_tri_i;
  output [0:0]buzz_1bit_tri_o;
  output [3:0]com_0;
  inout dht11_data_0;
  output g_out_0;
  inout iic_cntr_scl_io;
  inout iic_cntr_sda_io;
  inout iic_state_scl_io;
  inout iic_state_sda_io;
  output r_out_0;
  input reset;
  output [7:0]seg_7_0;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;
  input vauxn6_0;
  input vauxp6_0;

  wire b_out_0;
  wire [2:0]btn_3bit_tri_i;
  wire [0:0]buzz_1bit_tri_o;
  wire [3:0]com_0;
  wire dht11_data_0;
  wire g_out_0;
  wire iic_cntr_scl_i;
  wire iic_cntr_scl_io;
  wire iic_cntr_scl_o;
  wire iic_cntr_scl_t;
  wire iic_cntr_sda_i;
  wire iic_cntr_sda_io;
  wire iic_cntr_sda_o;
  wire iic_cntr_sda_t;
  wire iic_state_scl_i;
  wire iic_state_scl_io;
  wire iic_state_scl_o;
  wire iic_state_scl_t;
  wire iic_state_sda_i;
  wire iic_state_sda_io;
  wire iic_state_sda_o;
  wire iic_state_sda_t;
  wire r_out_0;
  wire reset;
  wire [7:0]seg_7_0;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;
  wire vauxn6_0;
  wire vauxp6_0;

  flame_led_buzz_dht11 flame_led_buzz_dht11_i
       (.b_out_0(b_out_0),
        .btn_3bit_tri_i(btn_3bit_tri_i),
        .buzz_1bit_tri_o(buzz_1bit_tri_o),
        .com_0(com_0),
        .dht11_data_0(dht11_data_0),
        .g_out_0(g_out_0),
        .iic_cntr_scl_i(iic_cntr_scl_i),
        .iic_cntr_scl_o(iic_cntr_scl_o),
        .iic_cntr_scl_t(iic_cntr_scl_t),
        .iic_cntr_sda_i(iic_cntr_sda_i),
        .iic_cntr_sda_o(iic_cntr_sda_o),
        .iic_cntr_sda_t(iic_cntr_sda_t),
        .iic_state_scl_i(iic_state_scl_i),
        .iic_state_scl_o(iic_state_scl_o),
        .iic_state_scl_t(iic_state_scl_t),
        .iic_state_sda_i(iic_state_sda_i),
        .iic_state_sda_o(iic_state_sda_o),
        .iic_state_sda_t(iic_state_sda_t),
        .r_out_0(r_out_0),
        .reset(reset),
        .seg_7_0(seg_7_0),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd),
        .vauxn6_0(vauxn6_0),
        .vauxp6_0(vauxp6_0));
  IOBUF iic_cntr_scl_iobuf
       (.I(iic_cntr_scl_o),
        .IO(iic_cntr_scl_io),
        .O(iic_cntr_scl_i),
        .T(iic_cntr_scl_t));
  IOBUF iic_cntr_sda_iobuf
       (.I(iic_cntr_sda_o),
        .IO(iic_cntr_sda_io),
        .O(iic_cntr_sda_i),
        .T(iic_cntr_sda_t));
  IOBUF iic_state_scl_iobuf
       (.I(iic_state_scl_o),
        .IO(iic_state_scl_io),
        .O(iic_state_scl_i),
        .T(iic_state_scl_t));
  IOBUF iic_state_sda_iobuf
       (.I(iic_state_sda_o),
        .IO(iic_state_sda_io),
        .O(iic_state_sda_i),
        .T(iic_state_sda_t));
endmodule
