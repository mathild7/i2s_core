//----------------------------------------------------------------------
//-- >>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<
//----------------------------------------------------------------------
//----                                                              ----
//---- WISHBONE SPDIF IP Core                                       ----
//----                                                              ----
//---- This file is part of the SPDIF project                       ----
//---- http://www.opencores.org/cores/spdif_interface/              ----
//----                                                              ----
//---- Description                                                  ----
//---- Generic event register.                                      ----
//----                                                              ----
//----                                                              ----
//---- To Do:                                                       ----
//---- -                                                            ----
//----                                                              ----
//---- Author(s):                                                   ----
//---- - Geir Drange, gedra@opencores.org                           ----
//----                                                              ----
//----------------------------------------------------------------------
//----                                                              ----
//---- Copyright (C) 2004 Authors and OPENCORES.ORG                 ----
//----                                                              ----
//---- This source file may be used and distributed without         ----
//---- restriction provided that this copyright statement is not    ----
//---- removed from the file and that any derivative work contains  ----
//---- the original copyright notice and the associated disclaimer. ----
//----                                                              ----
//---- This source file is free software; you can redistribute it   ----
//---- and/or modify it under the terms of the GNU Lesser General   ----
//---- Public License as published by the Free Software Foundation; ----
//---- either version 2.1 of the License, or (at your option) any   ----
//---- later version.                                               ----
//----                                                              ----
//---- This source is distributed in the hope that it will be       ----
//---- useful, but WITHOUT ANY WARRANTY; without even the implied   ----
//---- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ----
//---- PURPOSE. See the GNU Lesser General Public License for more  ----
//---- details.                                                     ----
//----                                                              ----
//---- You should have received a copy of the GNU Lesser General    ----
//---- Public License along with this source; if not, download it   ----
//---- from http://www.opencores.org/lgpl.shtml                     ----
//----                                                              ----
//----------------------------------------------------------------------
//--
//   Copyright (c) 2013 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
//   --------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
//   --------------------------------------------------------------------
//
//-- CVS Revision History
//--
//-- $Log: RD#RD1101#source#verilog#i2s_topm.v,v $
//-- Revision 1.1  2013-07-04 19:38:23-07  lsccad
//-- ...No comments entered during checkin...
//--
//-- Revision 1.6  2007/10/11 19:14:43  gedra
//-- Code beautification
//--
//-- Revision 1.5  2004/07/12 17:06:41  gedra
//-- Fixed bug with lock event generation.
//--
//-- Revision 1.4  2004/07/11 16:19:50  gedra
//-- Bug-fix.
//--
//-- Revision 1.3  2004/06/06 15:42:20  gedra
//-- Cleaned up lint warnings.
//--
//-- Revision 1.2  2004/06/04 15:55:07  gedra
//-- Cleaned up lint warnings.
//--
//-- Revision 1.1  2004/06/03 17:49:26  gedra
//-- Generic event register. Used in both receiver and transmitter.
//--
//---------------------------------------------------------------------------
//-- Code Revision History (LSC) :
//---------------------------------------------------------------------------
//-- Ver: | Author	|Mod. Date	|Changes Made:
//-- V1.0 | JT		  |9/2010     || Initial ver for verilog                      
//---------------------------------------------------------------------------

`timescale 1ns / 10ps

module i2s_topm	#( 
                   parameter  DATA_WIDTH=16,          
                   parameter  ADDR_WIDTH=6,
                   parameter  IS_RECEIVER=0
                 )
                 (
                 
  /*
   * Core clocks
   */ 
  input wire i_wclk,
  input wire i_bclk,
    
                 
 /*
  * Input/output to codec
  */
 input  wire i2s_sd_i,     //   --I2S data input for receiver
 output wire i2s_sck_o,    //   -- I2S clock out
 output wire i2s_mclk_o,
 output wire i2s_ws_o,     //   -- I2S word select out
 output wire i2s_sd_o,     //   -- I2S data output for transmitter

     /*
      * axi4 transmitter streaming interface *INPUT*
      */
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,
    input  wire                   s_axis_tlast,
    input  wire [ID_WIDTH-1:0]    s_axis_tid,
    input  wire [DEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [USER_WIDTH-1:0]  s_axis_tuser,

     /*
      * axi4 reciever streaming interface *OUTPUT*
      */
    output wire [DATA_WIDTH-1:0]  m_axis_tdata,
    output wire [KEEP_WIDTH-1:0]  m_axis_tkeep,
    output wire                   m_axis_tvalid,
    input  wire                   m_axis_tready,
    output wire                   m_axis_tlast,
    output wire [ID_WIDTH-1:0]    m_axis_tid,
    output wire [DEST_WIDTH-1:0]  m_axis_tdest,
    output wire [USER_WIDTH-1:0]  m_axis_tuser,
 
/*
 * Memory mapped axi4 slave
 */ 
input         axi_aclk,
input         axi_aresetn,

//AXI Write Address Channel
input [AXI_ADDR_WIDTH-1:0] mms_axi_awaddr,
input [2:0]   mms_axi_awprot,
input         mms_axi_awvalid,
output        mms_axi_awready,

//AXI Write Data Channel
input [31:0]  mms_axi_wdata,
input [3:0]   mms_axi_wstrb,
input         mms_axi_wvalid,
output        mms_axi_wready,

//AXI Read Address Channel
input [AXI_ADDR_WIDTH-1:0] mms_axi_araddr,
input [2:0]   mms_axi_arprot,
input         mms_axi_arvalid,
output        mms_axi_arready,

//Axi Read Data Channel
output [31:0] mms_axi_rdata,
output [1:0]  mms_axi_rresp,
output        mms_axi_rvalid,
input         mms_axi_rready,

//AXI Write Resp channel
output [1:0]  mms_axi_bresp,
output        mms_axi_bvalid,
input         mms_axi_bready);
 
  wire[DATA_WIDTH - 1 : 0] data_out;
  wire config_rd, config_wr;
  wire[DATA_WIDTH - 1 : 0] config_dout;
  wire[DATA_WIDTH - 1 : 0] config_bits;
  wire[DATA_WIDTH - 1 : 0] intmask_bits;
  wire[DATA_WIDTH - 1 : 0] intstat_events;
  wire[DATA_WIDTH - 1 : 0] intstat_dout;
  wire intstat_rd, intstat_wr;
  wire evt_hsbf, evt_lsbf;
  wire mem_wr_receiver, mem_rd_receiver;
  wire[ADDR_WIDTH - 2 : 0] sbuf_rd_adr, sbuf_wr_adr;
  wire[DATA_WIDTH - 1 : 0] sbuf_dout, sbuf_din, zeros;
  wire[5 : 0] conf_res;
  wire[4 : 0] conf_ratio;
  wire conf_swap, conf_inten, conf_en;
  
  wire[ADDR_WIDTH - 2 : 0] sample_addr;
  wire[DATA_WIDTH - 1 : 0] sample_data;
  wire zero;
  wire mem_wr_transmitter, mem_rd_transmitter;
//-- TxConfig - Configuration register
module i2s_core_regmap_regs #(
    .AXI_ADDR_WIDTH(),
    .ASEADDR()) (

.axi_aclk(axi_aclk),
.axi_aresetn(axi_aresetn),
.s_axi_awaddr(mms_axi_araddr),//Write is only necessary for CPU
.s_axi_awprot(mms_axi_awprot),
.s_axi_awvalid(mms_axi_awvalid),
.s_axi_awready(mms_axi_awready),
.s_axi_wdata(mms_axi_wdata),
.s_axi_wstrb(mms_axi_wstrb),
.s_axi_wvalid(mms_axi_wvalid),
.s_axi_wready(mms_axi_wready),
.s_axi_araddr(mms_axi_araddr),
.s_axi_arprot(mms_axi_arprot),
.s_axi_arvalid(mms_axi_arvalid),
.s_axi_arready(mms_axi_arready),
.s_axi_rdata(mms_axi_rdata),
.s_axi_rresp(mms_axi_rresp),
.s_axi_rvalid(mms_axi_rvalid),
.s_axi_rready(mms_axi_rready),
.s_axi_bresp(mms_axi_bresp),
.s_axi_bvalid(mms_axi_bvalid),
.s_axi_bready(mms_axi_bready),         
.ctrl_reg_strobe(), // Strobe logic for register 'ctrl_reg' (pulsed when the register is written from the bus)
.ctrl_reg_en(conf_en), // Value of register 'ctrl_reg'(), field 'en'
.ctrl_reg_int_en(conf_inten), // Value of register 'ctrl_reg'(), field 'int_en'
.ctrl_reg_ch_swapconf_swap(), // Value of register 'ctrl_reg'(), field 'ch_swap'
.ctrl_reg_mlsbf(), // Value of register 'ctrl_reg'(), field 'mlsbf'
.ctrl_reg_mhsbf(), // Value of register 'ctrl_reg'(), field 'mhsbf'
.ctrl_reg_samp_res(conf_res), // Value of register 'ctrl_reg'(), field 'samp_res'
.ctrl_reg_freq_ratio(conf_ratio));  



     /*
      * axi4 transmitter streaming interface *INPUT*
      */
    input  wire [DATA_WIDTH-1:0]  s_axis_tdata,
    input  wire [KEEP_WIDTH-1:0]  s_axis_tkeep,
    input  wire                   s_axis_tvalid,
    output wire                   s_axis_tready,
    input  wire                   s_axis_tlast,
    input  wire [ID_WIDTH-1:0]    s_axis_tid,
    input  wire [DEST_WIDTH-1:0]  s_axis_tdest,
    input  wire [USER_WIDTH-1:0]  s_axis_tuser,
    
    
    generate 
    if (IS_RECEIVER==1)
      dpram #(
         .DATA_WIDTH(DATA_WIDTH),
         .RAM_WIDTH (ADDR_WIDTH - 1)
      )
      RECEIVER_MEM(
         .clk     (wb_clk_i),
         .rst     (wb_rst_i),
         .din     (sbuf_din),
         .wr_en   (mem_wr_receiver),
         .rd_en   (mem_rd_receiver),
         .wr_addr (sbuf_wr_adr),
         .rd_addr (sbuf_rd_adr),
         .dout    (sbuf_dout)
      );
   else
      dpram #(
         .DATA_WIDTH(DATA_WIDTH),
         .RAM_WIDTH (ADDR_WIDTH - 1)
      )
      TRANSMITTER_MEM(
         .clk    (wb_clk_i),
         .rst    (wb_rst_i),
         .din    (s_axis_tdata),
         .wr_en  (mem_wr_transmitter),
         .rd_en  (mem_rd_transmitter),
         .wr_addr(wb_adr_i[ADDR_WIDTH - 2 : 0]),
         .rd_addr(sample_addr),
         .dout   (sample_data)
      );
   endgenerate        
   
assign zero=0;
assign zeros=0;   
   
    generate 
   if (IS_RECEIVER==1)
     i2s_codec #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IS_RECEIVER(1)
     )
     RECEIVER_DEC(
         .axi_clk      (axi_aclk),
         .axi_reset_n  (axi_aresetn),
         .conf_res     (conf_res),
         .conf_ratio   (conf_ratio),
         .conf_swap    (conf_swap),
         .conf_en      (conf_en),
         .i2s_sd_i     (i2s_sd_i),         
         .sample_dat_i (zeros),
         .sample_dat_o (sbuf_din),
         .mem_rdwr     (mem_wr_receiver),
         .sample_addr  (sbuf_wr_adr),
         .evt_hsbf     (evt_hsbf),
         .evt_lsbf     (evt_lsbf),
         .i2s_sd_o     (),
         .i2s_sck_o    (i2s_sck_o),
         .i2s_ws_o     (i2s_ws_o)
    );   
   else
     i2s_codec #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .IS_RECEIVER(0)
     )
     TRANSMITTER_DEC(
         .wb_clk_i     (wb_clk_i),
         .conf_res     (conf_res),
         .conf_ratio   (conf_ratio),
         .conf_swap    (conf_swap),
         .conf_en      (conf_en),
         .i2s_sd_i     (zero),         
         .sample_dat_i (sample_data),
         .sample_dat_o (),
         .mem_rdwr     (mem_rd_transmitter),
         .sample_addr  (sample_addr),
         .evt_hsbf     (evt_hsbf),
         .evt_lsbf     (evt_lsbf),
         .i2s_sd_o     (i2s_sd_o),
         .i2s_sck_o    (i2s_sck_o),
         .i2s_ws_o     (i2s_ws_o)
     ); 
   endgenerate        
endmodule    