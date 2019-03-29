//-----------------------------------------------------------------
//                           I2S Master
//                              V0.1
//                        Ultra-Embedded.com
//                          Copyright 2012
//
//                 Email: admin@ultra-embedded.com
//
//                         License: GPL
// If you would like a version with a more permissive license for
// use in closed source commercial applications please contact me
// for details.
//-----------------------------------------------------------------
//
// This file is open source HDL; you can redistribute it and/or 
// modify it under the terms of the GNU General Public License as 
// published by the Free Software Foundation; either version 2 of 
// the License, or (at your option) any later version.
//
// This file is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public 
// License along with this file; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA
//-----------------------------------------------------------------
module i2s_wrapper
(
    // Main clock (min 2x audio_clk_i)
    input           clk_i,
    input           rst_i,

    // Audio clock (MCLK x 2):
    // For 44.1KHz: 22.5792MHz
    // For 48KHz:   24.576MHz
    input           audio_clk_i,
    input           audio_rst_i,
    
    // I2S DAC Interface
    output          i2s_mclk_o,
    output          i2s_bclk_o,
    output          i2s_ws_o,
    output          i2s_data_o
);


i2s i2s_core(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .audio_clk_i (audio_clk_i),
    .audio_rst_i (audio_rst_i),
    .i2s_mclk_o  (i2s_mclk_o),
    .i2s_bclk_o  (i2s_bclk_o),
    .i2s_ws_o    (i2s_ws_o),
    .i2s_data_o  (i2s_data_o),
    .sample_i    (32'b0),
    .sample_req_o(1'b0)
);


endmodule
