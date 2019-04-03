// -----------------------------------------------------------------------------
// 'i2s_core_regmap' Register Definitions
// Revision: 13
// -----------------------------------------------------------------------------
// Generated on 2019-04-01 at 07:30 (UTC) by airhdl version 2019.02.1
// -----------------------------------------------------------------------------
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
// POSSIBILITY OF SUCH DAMAGE.
// -----------------------------------------------------------------------------

package i2s_core_regmap_regs_pkg;

    // Revision number of the 'i2s_core_regmap' register map
    localparam I2S_CORE_REGMAP_REVISION = 13;

    // Default base address of the 'i2s_core_regmap' register map 
    localparam logic [31:0] I2S_CORE_REGMAP_DEFAULT_BASEADDR = 32'h00000000;
    
    // Register 'ctrl_reg'
    localparam logic [31:0] CTRL_REG_OFFSET = 32'h00000000; // address offset of the 'ctrl_reg' register
    localparam CTRL_REG_EN_BIT_OFFSET = 0; // bit offset of the 'en' field
    localparam CTRL_REG_EN_BIT_WIDTH = 1; // bit width of the 'en' field
    localparam logic [0:0] CTRL_REG_EN_RESET = 1'b0; // reset value of the 'en' field
    localparam CTRL_REG_INT_EN_BIT_OFFSET = 1; // bit offset of the 'int_en' field
    localparam CTRL_REG_INT_EN_BIT_WIDTH = 1; // bit width of the 'int_en' field
    localparam logic [1:1] CTRL_REG_INT_EN_RESET = 1'b0; // reset value of the 'int_en' field
    localparam CTRL_REG_CH_SWAP_BIT_OFFSET = 2; // bit offset of the 'ch_swap' field
    localparam CTRL_REG_CH_SWAP_BIT_WIDTH = 1; // bit width of the 'ch_swap' field
    localparam logic [2:2] CTRL_REG_CH_SWAP_RESET = 1'b0; // reset value of the 'ch_swap' field
    localparam CTRL_REG_MLSBF_BIT_OFFSET = 3; // bit offset of the 'mlsbf' field
    localparam CTRL_REG_MLSBF_BIT_WIDTH = 1; // bit width of the 'mlsbf' field
    localparam logic [3:3] CTRL_REG_MLSBF_RESET = 1'b0; // reset value of the 'mlsbf' field
    localparam CTRL_REG_MHSBF_BIT_OFFSET = 4; // bit offset of the 'mhsbf' field
    localparam CTRL_REG_MHSBF_BIT_WIDTH = 1; // bit width of the 'mhsbf' field
    localparam logic [4:4] CTRL_REG_MHSBF_RESET = 1'b0; // reset value of the 'mhsbf' field
    localparam CTRL_REG_SAMP_RES_BIT_OFFSET = 5; // bit offset of the 'samp_res' field
    localparam CTRL_REG_SAMP_RES_BIT_WIDTH = 6; // bit width of the 'samp_res' field
    localparam logic [10:5] CTRL_REG_SAMP_RES_RESET = 6'b000000; // reset value of the 'samp_res' field
    localparam CTRL_REG_FREQ_RATIO_BIT_OFFSET = 11; // bit offset of the 'freq_ratio' field
    localparam CTRL_REG_FREQ_RATIO_BIT_WIDTH = 5; // bit width of the 'freq_ratio' field
    localparam logic [15:11] CTRL_REG_FREQ_RATIO_RESET = 5'b00000; // reset value of the 'freq_ratio' field

endpackage: i2s_core_regmap_regs_pkg

