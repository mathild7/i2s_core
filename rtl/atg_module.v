/////////////////////////////////////////////////////////////////////////////
//ATG module to generate 48Khz audio clock and 3.072MHz clock
//Input clock is 12.288MHz
/////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module atg_module(
    input clock_in,
    input reset_n,
    output reg clk_0_0048,
    output reg clk_3_072,
    output wire clk_12_288
    );
    assign clk_12_288 = clock_in;
    reg [7:0] count48;
    reg [1:0] count3_072;
       
    always @(posedge clock_in or negedge reset_n)  
        begin
           if (!reset_n)
            begin
                clk_0_0048 <= 1'b0;
             end
           else if (count48 == 8'd127)
 	          begin
	             clk_0_0048 <= ~clk_0_0048;
	           end 
	       else 
                clk_0_0048 <= clk_0_0048;
        end
        
        
     always @(posedge clock_in or negedge reset_n)  
            begin
               if (!reset_n)
                begin
                    clk_3_072 <= 1'b0;
                 end
               else if (count3_072 == 2'd1)
                   begin
                     clk_3_072 <= ~clk_3_072;
                   end 
               else 
                    clk_3_072 <= clk_3_072;
            end
        
   always @(posedge clock_in or negedge reset_n)
       begin
           if (!reset_n)
            begin
                count48 <= 8'd0;
                count3_072 <= 2'd0;
            end
           else
            begin
                count48 <= count48 + 1'b1;
                count3_072 <= count3_072 + 1'b1;
            end 
      end      
endmodule

