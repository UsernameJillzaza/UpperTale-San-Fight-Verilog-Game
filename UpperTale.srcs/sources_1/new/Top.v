`timescale 1ns / 1ps

module Top(
    input wire CLK, // Onboard clock 100MHz : INPUT Pin W5
    input wire RESET, // Reset button : INPUT Pin U18
    output wire HSYNC, // VGA horizontal sync : OUTPUT Pin P19
    output wire VSYNC, // VGA vertical sync : OUTPUT Pin R19    
    output reg [3:0] RED, // 4-bit VGA Red : OUTPUT Pin G19, Pin H19, Pin J19, Pin N19
    output reg [3:0] GREEN, // 4-bit VGA Green : OUTPUT Pin J17, Pin H17, Pin G17, Pin D17
    output reg [3:0] BLUE, // 4-bit VGA Blue : OUTPUT Pin N18, Pin L18, Pin K18, Pin J18/ 4-bit VGA Blue : OUTPUT Pin N18, Pin L18, Pin K18, Pin J18
    input btn_l, // Button left
    input btn_r, // Button right
    input btn_u, // Button up
    input btn_d // Button down
    );

 // instantiate vga640x480 code
    wire [9:0] x; // pixel x position: 10-bit value: 0-1023 : only need 800
    wire [9:0] y; // pixel y position: 10-bit value: 0-1023 : only need 525
    wire active; // high during active pixel drawing
    wire pix_clk; // 25MHz pixel clock
    vga640x480 display (
        .i_clk(CLK),
        .i_rst(RESET),
        .o_hsync(HSYNC),
        .o_vsync(VSYNC),
        .o_x(x),
        .o_y(y),
        .o_active(active),
        .o_pix_clk(pix_clk)
    );

    // instantiate BeeSprite
//    wire bee_sprite_on; // 1=on, 0=off
//    wire [7:0] bee_data; // pixel value from Bee.mem
//    BeeSprite bee_display (
//        .i_clk(CLK),
//        .i_rst(RESET),
//        .i_x(x),
//        .i_y(y),
//        .i_active(active),
//        .o_sprite_on(bee_sprite_on),
//        .o_data(bee_data)
//    );
    wire ground_sprite_on; // 1=on, 0=off
    
    wire gaster_on;//
    
    // Instantiate HeartSprite
    wire heart_sprite_on; // 1=on, 0=off
    wire [7:0] heart_data;  // pixel value from Undertale.mem (index in palette)
    
    //get heart position
    wire [9:0] heart_posX;
    wire [8:0] heart_posY;
    wire onGround_on;
    
    //gasterblaster
    wire gaster_sprite_on;
        
    wire gaster_on;
    wire [7:0] gaster_data;
    HeartSprite heart_display (
        .i_pix_clk(pix_clk),
        .i_rst(RESET),
        .i_x(x),
        .i_y(y),
        .i_active(active),
        .o_sprite_on(heart_sprite_on),
        .o_data(heart_data),
        .i_btn_l(btn_l),
        .i_btn_r(btn_r),
        .i_btn_u(btn_u),
        .i_btn_d(btn_d),
        .heart_x(heart_posX)
    );
    
    gaster_blaster GasterDisplay (
            .i_pix_clk(pix_clk),
            .pixel_x(x),
            .pixel_y(y),
            .six_counter(six_counter),
            .o_sprite_on(gaster_on),
            .o_data(gaster_data)
        );
        
    level_display leve1_Sprite(
            //input
        .pixel_x(x),
        .pixel_y(y),
            //output
//        .OnGround(onGround_on),
        .o_sprite_on(ground_sprite_on)
        );
 // load colour palette
    reg [7:0] palette [0:191]; // 8 bit values from the 192 hex entries in the colour palette
    reg [7:0] COL = 0; // background colour palette value
    reg [7:0]  GROUND = 63;
    initial begin
        $readmemh("pal24bit.mem", palette); // load 192 hex values into "palette"
    end
    
    // draw on the active area of the screen
    always @ (posedge pix_clk) begin
        if (active) begin   
            if (gaster_on) begin
                RED   <= (palette[gaster_data*3])>>4;
                GREEN <= (palette[gaster_data*3+1])>>4;
                BLUE  <= (palette[gaster_data*3+2])>>4;
            end
            // Ground (???) render
            else if (ground_sprite_on) begin
                RED <= (palette[GROUND*3+2])>>4;
                GREEN <= (palette[GROUND*3+1])>>4;
                BLUE <= (palette[GROUND*3+2])>>4;
            end
            // Heart (Player) render
            else if (heart_sprite_on == 1) begin
                RED <= (palette[(heart_data*3)])>>4;
                GREEN <= (palette[(heart_data*3)+1])>>4;
                BLUE <= (palette[(heart_data*3)+2])>>4;   
            end
            
            // Background Render
            else begin
                RED <= (palette[(COL*3)])>>4; // RED bits(7:4) from colour palette
                GREEN <= (palette[(COL*3)+1])>>4; // GREEN bits(7:4) from colour palette
                BLUE <= (palette[(COL*3)+2])>>4; // BLUE bits(7:4) from colour palette
            end
            
        end
        
        // Blank Screen (Defualt Display Requairemt)
        else begin
            RED <= 0; // set RED, GREEN & BLUE
            GREEN <= 0; // to "0" when x,y outside of
            BLUE <= 0; // the active display area
        end
    end
    
    wire clk_sec;
    wire [2:0] six_counter;
    
    //100MHz to 1
    clk_div_player_control cts(
    .rst_ni(RESET),
    .clk_i(CLK),
    .clk_o(clk_sec)
    );
    
//    always @(posedge clk_sec) begin
//        cal <= cal*7 % (cal%13 + 10);
//        six_counter <= cal%6 + 1;
//    end
    
    prime_random_gen random_generator (
        .clk(pix_clk),
        .rst(RESET),
        .enable(clk_sec),  // generate new random every second
        .rand_out(six_counter)
    );
    
    
    
    
    
endmodule
