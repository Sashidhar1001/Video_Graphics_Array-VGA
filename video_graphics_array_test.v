module video_graphics_array_test()                                             ;
      reg pix_clk                                                              ;
      reg reset                                                                ;
      reg [7:0] input_vga_red                                                  ;
           
      wire hsync                                                               ;
      wire vsync                                                               ;
      wire [7:0] output_vga_red                                                ;
      wire output_data_valid                                                   ;
      
      integer i = 0                                                            ;
      integer j = 0                                                            ;
      
      video_graphics_array test(     .pix_clk(pix_clk)                         ,
                                     .reset(reset)                             ,
                                     .input_vga_red(input_vga_red)             ,
                                    
                                     .hsync(hsync)                             ,
                                     .vsync(vsync)                             ,
                                     .output_vga_red(output_vga_red)           ,
                                     .output_data_valid(output_data_valid)     
                               )                                               ;
     initial pix_clk <= 1'b1                                                   ;
     always #20 pix_clk <= ~pix_clk                                            ;
     initial begin
         reset = 1'b1                                                          ;
         input_vga_red <= 7'b0                                                 ;
         
         repeat(3) @(posedge pix_clk)                                          ;
         reset = 1'b0                                                          ;
         
         for( j =0 ; j < 480; j = j + 1'b1) begin
             for(i = 0; i < 640 ; i = i + 1'b1) begin
                input_vga_red <= $urandom_range(255,0)                         ;
                #40 ;    
             end    
             #6400;
         end
     end  
endmodule // end