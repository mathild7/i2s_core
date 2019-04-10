/////////////////////////////////////////////////////////////////////////////
//ATG module to generate 48Khz audio clock and 3.072MHz clock
//Input clock is 12.288MHz
/////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module atg_module(
    input clock_in,
    input reset_n,
    input core_clk_in,
    input core_rst_n,
    output reg clock_0_0048,
    output reg clock_3_072,
    output wire clock_12_288,
    output reg latcher_pulse
    );
    assign clock_12_288 = clock_in;
    reg [4:0] count48;
    reg count3_072;
    reg latcher_clk_dl;
    wire latcher_clk;
    bits_sync
    #(.BUS_WIDTH (1))
     bits_sync_1 (
        .i_clk_b (core_clk_in),
        .i_data_a(clock_0_0048),
        .o_data_b(latcher_clk));
       always @(posedge core_clk_in) begin
        if(!core_rst_n) begin
            latcher_clk_dl <= 0;
        end
        else begin
            latcher_clk_dl <= latcher_clk;
            if(latcher_clk && !latcher_clk_dl) begin
                latcher_pulse <= 1;
            end
            else begin
                latcher_pulse <= 0;
            end
        end
       end 
    always @(negedge clock_3_072 or negedge reset_n)  
        begin
           if (!reset_n)
            begin
                clock_0_0048 <= 1'b0;
             end
           else if (count48 == 5'd31)
 	          begin
	             clock_0_0048 <= ~clock_0_0048;
	           end 
	       else 
                clock_0_0048 <= clock_0_0048;
        end
        
        
     always @(posedge clock_in or negedge reset_n)  
            begin
               if (!reset_n)
                begin
                    clock_3_072 <= 1'b0;
                 end
               else if (count3_072 == 1)
                   begin
                     clock_3_072 <= ~clock_3_072;
                   end 
               else 
                    clock_3_072 <= clock_3_072;
            end
   always @(negedge clock_3_072 or negedge reset_n)
                begin
                    if (!reset_n)
                     begin
                         count48 <= 5'd0;
                     end
                    else
                     begin
                         count48 <= count48 + 5'b1;
                     end 
               end    
   always @(posedge clock_in or negedge reset_n)
       begin
           if (!reset_n)
            begin
                count3_072 <= 2'd0;
            end
           else
            begin
                count3_072 <= count3_072 + 1'b1;
            end 
      end      
endmodule

