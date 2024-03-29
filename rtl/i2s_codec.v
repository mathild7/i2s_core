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
//-- $Log: RD#RD1101#source#verilog#i2s_codec.v,v $
//-- Revision 1.1  2013-07-04 19:38:26-07  lsccad
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

module i2s_codec #(
   parameter DATA_WIDTH  = 32,
   parameter ADDR_WIDTH  = 6,
   parameter IS_RECEIVER = 0)
   (
      input wire i_bclk      ,
      input wire i_ws_clk    ,
      //Config options
      input wire [5:0] conf_res    ,
      input wire [4:0] conf_ratio  ,
      input wire conf_swap   ,
      input wire conf_en     ,
    /*
     * axi4 transmitter streaming interface *INPUT*
     */
     input wire [DATA_WIDTH-1:0] s_axis_tdata,
     input wire s_axis_tvalid,
     output reg s_axis_tready,
     input wire s_axis_tlast,
    /*
     * axi4 reciever streaming interface *OUTPUT*
     */
      output [DATA_WIDTH-1:0]  m_axis_tdata,
      output m_axis_tvalid,
      input m_axis_tready,
      output m_axis_tlast,
      
      output reg  tx_data,
      input wire rx_data,
      output wire ws_clk_ret
   );      

parameter IDLE=0;
parameter WAIT_CLK=1;
parameter TRX_DATA=2;
parameter RX_WRITE=3;
parameter SYNC=4;
parameter TX_DATA_CH0 = 1;
parameter TX_DATA_CH1 = 2;

reg[8:0] temp_data=2**(ADDR_WIDTH-1);

 reg i2s_clk_en;
 reg [4:0] clk_cnt;
 reg [7:0] adr_cnt;// integer range 0 to 2**(ADDR_WIDTH - 1) - 1; so the max value of ADDR_WIDTH is 9
 reg [4:0] sd_ctrl;
 reg[5:0] bit_cnt, bits_to_trx; //integer range 0 to 63;
 reg toggle,neg_edge, ws_pos_edge,ws_neg_edge;
 reg[DATA_WIDTH - 1 : 0] data_in;// (DATA_WIDTH - 1 downto 0);
 reg i2s_ws, new_word;
 reg imem_rdwr;
 wire receiver;
 reg[4:0] ws_cnt; // integer range 0 to 31;
 reg tx_ws_clk;
 reg [2:0] codec_state;
 reg [31:0] samp_data;
   
assign receiver = (IS_RECEIVER==1)?1'b1:1'b0;
//-- Logic to generate clock signal, master mode
assign i2s_sck_o = toggle;

//-- Process to receive data on i2s_sd_i, or transmit data on i2s_sd_o
assign  sample_addr  = adr_cnt[ADDR_WIDTH - 2:0];
assign  mem_rdwr     = imem_rdwr;
assign  sample_dat_o = data_in;

assign ws_clk_ret = IS_RECEIVER?i_ws_clk:tx_ws_clk;


generate if(IS_RECEIVER) begin
always@(posedge i_bclk) begin
    if(!conf_en) begin
    
    end
    else begin
    
    end
end
end
//Transmitter
else begin
always@(negedge i_bclk) begin
    //Reset condition
    if(!conf_en) begin
        codec_state   <= 0;
        samp_data     <= 0;
        s_axis_tready <= 0;
        tx_ws_clk     <= 0;
    end
    else begin
        s_axis_tready <= 0;
        case(codec_state)
        IDLE: begin
            if(i_ws_clk) begin
                samp_data <= s_axis_tdata;
                codec_state   <= TX_DATA_CH0;
                bit_cnt <= DATA_WIDTH-1;
            end
            else begin
                
            end
         end
         TX_DATA_CH0: begin
            tx_ws_clk     <= 1;
            if(bit_cnt > DATA_WIDTH-conf_res) begin
                tx_data <= samp_data[bit_cnt];
            end
            else begin
                tx_data <= 0;
            end
            
            if(bit_cnt == 0) begin
                s_axis_tready <= 1;
                codec_state <= TX_DATA_CH1;
                bit_cnt = DATA_WIDTH-1;
                //samp_data <= s_axis_tdata;
            end
            else begin
                bit_cnt <= bit_cnt - 1;
            end
         end
         TX_DATA_CH1: begin
            tx_ws_clk     <= 0;
            if(bit_cnt > DATA_WIDTH-conf_res) begin
                tx_data <= samp_data[bit_cnt];
            end
            else begin
                tx_data <= 0;
            end
            
            if(bit_cnt == 0) begin
                codec_state <= TX_DATA_CH0;
                bit_cnt = DATA_WIDTH-1;
                samp_data <= s_axis_tdata;
            end
            else begin
                bit_cnt <= bit_cnt - 1;
            end
         end
         default: bit_cnt <= DATA_WIDTH;
        endcase
    end
    end

end endgenerate
endmodule