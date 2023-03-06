module video_graphics_array(  input wire pix_clk                                     ,
                              input wire reset                                       ,
                              input wire [7:0] input_vga_red                         ,
           
                              output reg hsync                                       ,
                              output reg vsync                                       ,
                              output reg [7:0] output_vga_red                        ,
                              output reg output_data_valid      
                          )                                                          ;
// Horizantal Parameters
parameter HACT = 640                                                                 ; // horizantal active pixel area
parameter HFP  = 16                                                                  ; // horizantal front porch (blankings)
parameter HSW  = 96                                                                  ; // horizantal sync width
parameter HBP  = 48                                                                  ; // horizantal back porch  (blankings)

// Vertical Parameters
parameter VACT = 480                                                                 ; // vertical activce pixel area
parameter VFP  = 10                                                                  ; // vertical front porch (blankings)
parameter VSW  = 2                                                                   ; // vertical sync width
parameter VBP  = 33                                                                  ; // vertical back porch (blankings)
reg [9:0]x_coordinate                                                                ;
reg [9:0]y_coordinate                                                                ;
reg [1:0]count                                                                       ;

wire [9:0] hsync_1                                                                   ;
wire [9:0] hsync_2                                                                   ;
wire [9:0] hsync_3                                                                   ;
wire hsync_flag                                                                      ;

wire [9:0] vsync_1                                                                   ;
wire [9:0] vsync_2                                                                   ;
wire [9:0] vsync_3                                                                   ;
wire vsync_flag                                                                      ;

assign hsync_1 = HACT+HFP                                                            ;
assign hsync_2 = HACT+HFP+HSW                                                        ;
assign hsync_3 = HACT+HFP+HSW+HBP                                                    ;

assign hsync_flag = ((x_coordinate >= (HACT+HFP)) && (x_coordinate < (HACT+HFP+HSW)));

assign vsync_1 = HACT+HFP                                                            ;
assign vsync_2 = HACT+HFP+HSW                                                        ;
assign vsync_3 = HACT+HFP+HSW+HBP                                                    ;

assign vsync_flag = ((y_coordinate > (VACT+VFP)) && (y_coordinate <=(VACT+VFP+VSW))) ;

integer n                                                                            ;
integer k                                                                            ; 

always @(posedge pix_clk) begin
    if(reset == 1'b1) begin
        output_vga_red      <= 24'b0                                                 ;
        output_data_valid   <= 1'b0                                                  ;
        
        x_coordinate        <= 10'b1                                                 ;
        y_coordinate        <= 10'b1                                                 ; 
        count               <= 2'b1                                                  ;
    end
    else begin  // reset == 1'b0 condition
         if( x_coordinate == hsync_3 ) begin 
             x_coordinate     <= 10'b0                                               ;
             if( y_coordinate  == vsync_3) begin
                y_coordinate  <= 10'b0                                               ;    
             end
             else begin
                y_coordinate  <= y_coordinate + 10'b1                                ;
             end
        end
        else begin
            if(count == 2'b1) begin
                x_coordinate <= x_coordinate                                         ;
                count<=2'b0                                                          ;
            end
            else begin
               x_coordinate <= x_coordinate + 10'b1                                  ;
            end
        end
    end
    // displaying active active pixels
    for( k = 0 ;k < 480; k = k + 1'b1 ) begin
             if( (x_coordinate >= 0) && (x_coordinate < HACT) ) begin
                output_data_valid <= 1'b1                                            ;
                output_vga_red    <= input_vga_red                                   ;
             end  
             else if( (x_coordinate > HACT) && (x_coordinate < hsync_1) )begin
                output_data_valid <= 1'b0                                            ;
                output_vga_red    <= 7'b0                                            ;
             end
             else begin
                output_data_valid <= 1'b0                                            ;
                output_vga_red    <= 24'b0                                           ;
             end
        end
end  
always @(posedge pix_clk) begin
    if(reset == 1'b1) begin
        hsync               <= 1'b1                                                  ;
        vsync               <= 1'b1                                                  ;
    end  
    else begin 
        // hsync and vsync - active low logic
        if( hsync_flag ) begin // 752 - 656 = 
            hsync   <= 1'b0                                                          ;
        end
        else begin
            hsync   <= 1'b1                                                          ;
        end 
        if( vsync_flag  ) begin
            vsync   <= 1'b0                                                          ;
        end
        else begin
            vsync   <= 1'b1                                                          ;
        end   
    end
end    
endmodule //end
