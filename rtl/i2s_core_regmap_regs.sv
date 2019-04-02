// -----------------------------------------------------------------------------
// 'i2s_core_regmap' Register Component
// Revision: 13
// -----------------------------------------------------------------------------
// Generated on 2019-04-01 at 07:32 (UTC) by airhdl version 2019.02.1
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

`default_nettype none

module i2s_core_regmap_regs #(
    parameter AXI_ADDR_WIDTH = 32, // width of the AXI address bus
    parameter logic [31:0] BASEADDR = 32'h00000000 // the register file's system base address 
    ) (
    // Clock and Reset
    input  wire                      axi_aclk,
    input  wire                      axi_aresetn,
                                     
    // AXI Write Address Channel     
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_awaddr,
    input  wire [2:0]                s_axi_awprot,
    input  wire                      s_axi_awvalid,
    output wire                      s_axi_awready,
                                     
    // AXI Write Data Channel        
    input  wire [31:0]               s_axi_wdata,
    input  wire [3:0]                s_axi_wstrb,
    input  wire                      s_axi_wvalid,
    output wire                      s_axi_wready,
                                     
    // AXI Read Address Channel      
    input  wire [AXI_ADDR_WIDTH-1:0] s_axi_araddr,
    input  wire [2:0]                s_axi_arprot,
    input  wire                      s_axi_arvalid,
    output wire                      s_axi_arready,
                                     
    // AXI Read Data Channel         
    output wire [31:0]               s_axi_rdata,
    output wire [1:0]                s_axi_rresp,
    output wire                      s_axi_rvalid,
    input  wire                      s_axi_rready,
                                     
    // AXI Write Response Channel    
    output wire [1:0]                s_axi_bresp,
    output wire                      s_axi_bvalid,
    input  wire                      s_axi_bready,
    
    // User Ports          
    output wire ctrl_reg_strobe, // Strobe logic for register 'ctrl_reg' (pulsed when the register is written from the bus)
    output wire [0:0] ctrl_reg_en, // Value of register 'ctrl_reg', field 'en'
    output wire [0:0] ctrl_reg_int_en, // Value of register 'ctrl_reg', field 'int_en'
    output wire [0:0] ctrl_reg_ch_swap, // Value of register 'ctrl_reg', field 'ch_swap'
    output wire [0:0] ctrl_reg_mlsbf, // Value of register 'ctrl_reg', field 'mlsbf'
    output wire [0:0] ctrl_reg_mhsbf, // Value of register 'ctrl_reg', field 'mhsbf'
    output wire [5:0] ctrl_reg_samp_res, // Value of register 'ctrl_reg', field 'samp_res'
    output wire [4:0] ctrl_reg_freq_ratio // Value of register 'ctrl_reg', field 'freq_ratio'
    );

    // Constants
    localparam logic [1:0]                      AXI_OKAY        = 2'b00;
    localparam logic [1:0]                      AXI_DECERR      = 2'b11;

    // Registered signals
    logic                                       s_axi_awready_r;
    logic                                       s_axi_wready_r;
    logic [$bits(s_axi_awaddr)-1:0]             s_axi_awaddr_reg_r;
    logic                                       s_axi_bvalid_r;
    logic [$bits(s_axi_bresp)-1:0]              s_axi_bresp_r;
    logic                                       s_axi_arready_r;
    logic [$bits(s_axi_araddr)-1:0]             s_axi_araddr_reg_r;
    logic                                       s_axi_rvalid_r;
    logic [$bits(s_axi_rresp)-1:0]              s_axi_rresp_r;
    logic [$bits(s_axi_wdata)-1:0]              s_axi_wdata_reg_r;
    logic [$bits(s_axi_wstrb)-1:0]              s_axi_wstrb_reg_r;
    logic [$bits(s_axi_rdata)-1:0]              s_axi_rdata_r;

    // User-defined registers
    logic s_ctrl_reg_strobe_r;
    logic [0:0] s_reg_ctrl_reg_en_r;
    logic [0:0] s_reg_ctrl_reg_int_en_r;
    logic [0:0] s_reg_ctrl_reg_ch_swap_r;
    logic [0:0] s_reg_ctrl_reg_mlsbf_r;
    logic [0:0] s_reg_ctrl_reg_mhsbf_r;
    logic [5:0] s_reg_ctrl_reg_samp_res_r;
    logic [4:0] s_reg_ctrl_reg_freq_ratio_r;

    //--------------------------------------------------------------------------
    // Inputs
    //

    //--------------------------------------------------------------------------
    // Read-transaction FSM
    //    
    localparam MEM_WAIT_COUNT = 2;

    typedef enum {
        READ_IDLE,
        READ_REGISTER,
        WAIT_MEMORY_RDATA,
        READ_RESPONSE,
        READ_DONE
    } read_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: read_fsm
        // registered state variables
        read_state_t v_state_r;
        logic [31:0] v_rdata_r;
        logic [1:0] v_rresp_r;
        int v_mem_wait_count_r;
        // combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r          <= READ_IDLE;
            v_rdata_r          <= '0;
            v_rresp_r          <= '0;
            v_mem_wait_count_r <= 0;            
            s_axi_arready_r    <= '0;
            s_axi_rvalid_r     <= '0;
            s_axi_rresp_r      <= '0;
            s_axi_araddr_reg_r <= '0;
            s_axi_rdata_r      <= '0;
        end else begin
            // Default values:
            s_axi_arready_r <= 1'b0;

            case (v_state_r)

                // Wait for the start of a read transaction, which is 
                // initiated by the assertion of ARVALID
                READ_IDLE: begin
                    v_mem_wait_count_r <= 0;
                    if (s_axi_arvalid) begin
                        s_axi_araddr_reg_r <= s_axi_araddr;     // save the read address
                        s_axi_arready_r    <= 1'b1;             // acknowledge the read-address
                        v_state_r          <= READ_REGISTER;
                    end
                end

                // Read from the actual storage element
                READ_REGISTER: begin
                    // defaults:
                    v_addr_hit = 1'b0;
                    v_rdata_r  <= '0;
                    
                    // register 'ctrl_reg' at address offset 0x0
                    if (s_axi_araddr_reg_r == BASEADDR + i2s_core_regmap_regs_pkg::CTRL_REG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        v_rdata_r[0:0] <= s_reg_ctrl_reg_en_r;
                        v_rdata_r[1:1] <= s_reg_ctrl_reg_int_en_r;
                        v_rdata_r[2:2] <= s_reg_ctrl_reg_ch_swap_r;
                        v_rdata_r[3:3] <= s_reg_ctrl_reg_mlsbf_r;
                        v_rdata_r[4:4] <= s_reg_ctrl_reg_mhsbf_r;
                        v_rdata_r[10:5] <= s_reg_ctrl_reg_samp_res_r;
                        v_rdata_r[15:11] <= s_reg_ctrl_reg_freq_ratio_r;
                        v_state_r <= READ_RESPONSE;
                    end
                    if (v_addr_hit) begin
                        v_rresp_r <= AXI_OKAY;
                    end else begin
                        v_rresp_r <= AXI_DECERR;
                        // pragma translate_off
                        $warning("ARADDR decode error");
                        // pragma translate_on
                        v_state_r <= READ_RESPONSE;
                    end
                end
                
                // Wait for memory read data
                WAIT_MEMORY_RDATA: begin
                    if (v_mem_wait_count_r == MEM_WAIT_COUNT-1) begin
                        v_state_r <= READ_RESPONSE;
                    end else begin
                        v_mem_wait_count_r <= v_mem_wait_count_r + 1;
                    end
                end

                // Generate read response
                READ_RESPONSE: begin
                    s_axi_rvalid_r <= 1'b1;
                    s_axi_rresp_r  <= v_rresp_r;
                    s_axi_rdata_r  <= v_rdata_r;
                    v_state_r      <= READ_DONE;
                end

                // Write transaction completed, wait for master RREADY to proceed
                READ_DONE: begin
                    if (s_axi_rready) begin
                        s_axi_rvalid_r <= 1'b0;
                        s_axi_rdata_r  <= '0;
                        v_state_r      <= READ_IDLE;
                    end
                end        
                                    
            endcase
        end
    end: read_fsm

    //--------------------------------------------------------------------------
    // Write-transaction FSM
    //    

    typedef enum {
        WRITE_IDLE,
        WRITE_ADDR_FIRST,
        WRITE_DATA_FIRST,
        WRITE_UPDATE_REGISTER,
        WRITE_DONE
    } write_state_t;

    always_ff@(posedge axi_aclk or negedge axi_aresetn) begin: write_fsm
        // registered state variables
        write_state_t v_state_r;
        // combinatorial helper variables
        logic v_addr_hit;
        logic [AXI_ADDR_WIDTH-1:0] v_mem_addr;
        if (~axi_aresetn) begin
            v_state_r                   <= WRITE_IDLE;
            s_axi_awready_r             <= 1'b0;
            s_axi_wready_r              <= 1'b0;
            s_axi_awaddr_reg_r          <= '0;
            s_axi_wdata_reg_r           <= '0;
            s_axi_wstrb_reg_r           <= '0;
            s_axi_bvalid_r              <= 1'b0;
            s_axi_bresp_r               <= '0;
                        
            s_ctrl_reg_strobe_r <= '0;
            s_reg_ctrl_reg_en_r <= 1'b0;
            s_reg_ctrl_reg_int_en_r <= 1'b0;
            s_reg_ctrl_reg_ch_swap_r <= 1'b0;
            s_reg_ctrl_reg_mlsbf_r <= 1'b0;
            s_reg_ctrl_reg_mhsbf_r <= 1'b0;
            s_reg_ctrl_reg_samp_res_r <= 6'b000000;
            s_reg_ctrl_reg_freq_ratio_r <= 5'b00000;

        end else begin
            // Default values:
            s_axi_awready_r <= 1'b0;
            s_axi_wready_r  <= 1'b0;
            s_ctrl_reg_strobe_r <= '0;
            v_addr_hit = 1'b0;

            case (v_state_r)

                // Wait for the start of a write transaction, which may be 
                // initiated by either of the following conditions:
                //   * assertion of both AWVALID and WVALID
                //   * assertion of AWVALID
                //   * assertion of WVALID
                WRITE_IDLE: begin
                    if (s_axi_awvalid && s_axi_wvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address 
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        s_axi_wdata_reg_r  <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r  <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r     <= 1'b1; // acknowledge the write-data
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end else if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address 
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_ADDR_FIRST;
                    end else if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_DATA_FIRST;
                    end
                end

                // Address-first write transaction: wait for the write-data
                WRITE_ADDR_FIRST: begin
                    if (s_axi_wvalid) begin
                        s_axi_wdata_reg_r <= s_axi_wdata; // save the write-data
                        s_axi_wstrb_reg_r <= s_axi_wstrb; // save the write-strobe
                        s_axi_wready_r    <= 1'b1; // acknowledge the write-data
                        v_state_r         <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Data-first write transaction: wait for the write-address
                WRITE_DATA_FIRST: begin
                    if (s_axi_awvalid) begin
                        s_axi_awaddr_reg_r <= s_axi_awaddr; // save the write-address 
                        s_axi_awready_r    <= 1'b1; // acknowledge the write-address
                        v_state_r          <= WRITE_UPDATE_REGISTER;
                    end
                end

                // Update the actual storage element
                WRITE_UPDATE_REGISTER: begin
                    s_axi_bresp_r  <= AXI_OKAY; // default value, may be overriden in case of decode error
                    s_axi_bvalid_r <= 1'b1;

                    // register 'ctrl_reg' at address offset 0x0
                    if (s_axi_awaddr_reg_r == BASEADDR + i2s_core_regmap_regs_pkg::CTRL_REG_OFFSET) begin
                        v_addr_hit = 1'b1;
                        s_ctrl_reg_strobe_r <= 1'b1;
                        // field 'en':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_en_r[0] <= s_axi_wdata_reg_r[0]; // en[0]
                        end
                        // field 'int_en':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_int_en_r[0] <= s_axi_wdata_reg_r[1]; // int_en[0]
                        end
                        // field 'ch_swap':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_ch_swap_r[0] <= s_axi_wdata_reg_r[2]; // ch_swap[0]
                        end
                        // field 'mlsbf':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_mlsbf_r[0] <= s_axi_wdata_reg_r[3]; // mlsbf[0]
                        end
                        // field 'mhsbf':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_mhsbf_r[0] <= s_axi_wdata_reg_r[4]; // mhsbf[0]
                        end
                        // field 'samp_res':
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_samp_res_r[0] <= s_axi_wdata_reg_r[5]; // samp_res[0]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_samp_res_r[1] <= s_axi_wdata_reg_r[6]; // samp_res[1]
                        end
                        if (s_axi_wstrb_reg_r[0]) begin
                            s_reg_ctrl_reg_samp_res_r[2] <= s_axi_wdata_reg_r[7]; // samp_res[2]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_samp_res_r[3] <= s_axi_wdata_reg_r[8]; // samp_res[3]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_samp_res_r[4] <= s_axi_wdata_reg_r[9]; // samp_res[4]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_samp_res_r[5] <= s_axi_wdata_reg_r[10]; // samp_res[5]
                        end
                        // field 'freq_ratio':
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_freq_ratio_r[0] <= s_axi_wdata_reg_r[11]; // freq_ratio[0]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_freq_ratio_r[1] <= s_axi_wdata_reg_r[12]; // freq_ratio[1]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_freq_ratio_r[2] <= s_axi_wdata_reg_r[13]; // freq_ratio[2]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_freq_ratio_r[3] <= s_axi_wdata_reg_r[14]; // freq_ratio[3]
                        end
                        if (s_axi_wstrb_reg_r[1]) begin
                            s_reg_ctrl_reg_freq_ratio_r[4] <= s_axi_wdata_reg_r[15]; // freq_ratio[4]
                        end
                    end

                    if (!v_addr_hit) begin
                        s_axi_bresp_r   <= AXI_DECERR;
                        // pragma translate_off
                        $warning("AWADDR decode error");
                        // pragma translate_on
                    end
                    v_state_r <= WRITE_DONE;
                end

                // Write transaction completed, wait for master BREADY to proceed
                WRITE_DONE: begin
                    if (s_axi_bready) begin
                        s_axi_bvalid_r <= 1'b0;
                        v_state_r      <= WRITE_IDLE;
                    end
                end
            endcase


        end
    end: write_fsm

    //--------------------------------------------------------------------------
    // Outputs
    //
    assign s_axi_awready = s_axi_awready_r;
    assign s_axi_wready  = s_axi_wready_r;
    assign s_axi_bvalid  = s_axi_bvalid_r;
    assign s_axi_bresp   = s_axi_bresp_r;
    assign s_axi_arready = s_axi_arready_r;
    assign s_axi_rvalid  = s_axi_rvalid_r;
    assign s_axi_rresp   = s_axi_rresp_r;
    assign s_axi_rdata   = s_axi_rdata_r;
    
    assign ctrl_reg_strobe = s_ctrl_reg_strobe_r;
    assign ctrl_reg_en = s_reg_ctrl_reg_en_r;
    assign ctrl_reg_int_en = s_reg_ctrl_reg_int_en_r;
    assign ctrl_reg_ch_swap = s_reg_ctrl_reg_ch_swap_r;
    assign ctrl_reg_mlsbf = s_reg_ctrl_reg_mlsbf_r;
    assign ctrl_reg_mhsbf = s_reg_ctrl_reg_mhsbf_r;
    assign ctrl_reg_samp_res = s_reg_ctrl_reg_samp_res_r;
    assign ctrl_reg_freq_ratio = s_reg_ctrl_reg_freq_ratio_r;

endmodule: i2s_core_regmap_regs

`resetall

