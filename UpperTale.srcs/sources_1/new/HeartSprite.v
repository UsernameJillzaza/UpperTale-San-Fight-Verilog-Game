module HeartSprite(
    input wire i_pix_clk,  // 25MHz pixel clock
    input wire i_rst,
    input wire [9:0] i_x,  // VGA pixel X
    input wire [9:0] i_y,  // VGA pixel Y
    input wire i_active,
    input wire i_btn_l,
    input wire i_btn_r,
    input wire i_btn_u,
    input wire i_btn_d,
    output reg o_sprite_on, // 1=on, 0=off
    output [7:0] o_data
);

    // Heart ROM
    reg [9:0] address; // 24x24 = 576 pixels
    HeartRom heart_rom (
        .i_addr(address),
        .i_pix_clk(i_pix_clk),
        .o_data(o_data)
    );

    // Heart position and size
    localparam HEART_WIDTH = 24;
    localparam HEART_HEIGHT = 24;
    reg [9:0] heart_x = 320 - HEART_WIDTH/2;
    reg [8:0] heart_y = 240 - HEART_HEIGHT/2;

    // Movement logic (pixel clock)
    localparam H_SPEED = 10; // Horizontal
    localparam V_SPEED = 10; // Vertical
    always @(posedge i_pix_clk or posedge i_rst) begin
        // Ensure that it update once per frame
        if (i_x == 639 && i_y == 479) begin
            if (i_rst) begin
                heart_x <= 320 - HEART_WIDTH/2;
                heart_y <= 240 - HEART_HEIGHT/2;
            end else begin
                // Horizontal
                if (i_btn_l && heart_x >= H_SPEED)
                    heart_x <= heart_x - H_SPEED;
                else if (i_btn_l)
                    heart_x <= 0;
                
                if (i_btn_r && heart_x <= (640 - HEART_WIDTH - H_SPEED))
                    heart_x <= heart_x + H_SPEED;
                else if (i_btn_r)
                    heart_x <= 640 - HEART_WIDTH;
                
                // Vertical
                if (i_btn_u && heart_y >= V_SPEED)
                    heart_y <= heart_y - V_SPEED;
                else if (i_btn_u)
                    heart_y <= 0;
                
                if (i_btn_d && heart_y <= (480 - HEART_HEIGHT - V_SPEED))
                    heart_y <= heart_y + V_SPEED;
                else if (i_btn_d)
                    heart_y <= 480 - HEART_HEIGHT;
                    
                if(~i_btn_u && heart_y <= (480 - HEART_HEIGHT - 5))
                    heart_y <= heart_y + 2;
            end
        end
    end

    // Draw heart at current position
    always @(posedge i_pix_clk) begin
        if (i_active) begin
            if (i_x >= heart_x && i_x < heart_x + HEART_WIDTH &&
                i_y >= heart_y && i_y < heart_y + HEART_HEIGHT) begin
                address <= (i_x - heart_x) + ((i_y - heart_y) * HEART_WIDTH);
                o_sprite_on <= 1;
            end else
                o_sprite_on <= 0;
        end else
            o_sprite_on <= 0;
    end

endmodule
