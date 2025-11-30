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
    output [7:0] o_data,
    output reg [9:0] heart_x,
    output reg [8:0] heart_y
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
    
    initial begin
        heart_x = 320 - HEART_WIDTH/2;
        heart_y = 240 - HEART_HEIGHT/2;
    end

    // Movement logic (pixel clock)
    localparam H_SPEED = 10; // Horizontal
    localparam V_SPEED = 10; // Vertical
    localparam LEFT   = 130;
    localparam RIGHT  = 506;
    localparam TOP    = 251;
    localparam BOTTOM = 391;
    localparam THICK  = 6;
    
    // INNER playable area
    localparam PLAY_LEFT   = LEFT   + THICK;
    localparam PLAY_RIGHT  = RIGHT  - THICK;
    localparam PLAY_TOP    = TOP    + THICK;
    localparam PLAY_BOTTOM = BOTTOM - THICK;

    always @(posedge i_pix_clk or posedge i_rst) begin
    if (i_rst) begin
        heart_x <= PLAY_LEFT + ((PLAY_RIGHT-PLAY_LEFT) - HEART_WIDTH)/2;
        heart_y <= PLAY_TOP  + ((PLAY_BOTTOM-PLAY_TOP) - HEART_HEIGHT)/2;
    end 
    else if (i_x == 639 && i_y == 479) begin

        // LEFT
        if (i_btn_l) begin
            if (heart_x >= PLAY_LEFT + H_SPEED)
                heart_x <= heart_x - H_SPEED;
            else
                heart_x <= PLAY_LEFT;
        end

        // RIGHT
        if (i_btn_r) begin
            if (heart_x <= (PLAY_RIGHT - HEART_WIDTH - H_SPEED))
                heart_x <= heart_x + H_SPEED;
            else
                heart_x <= (PLAY_RIGHT - HEART_WIDTH);
        end

        // UP
        if (i_btn_u) begin
            if (heart_y >= PLAY_TOP + V_SPEED)
                heart_y <= heart_y - V_SPEED;
            else
                heart_y <= PLAY_TOP;
        end

        // DOWN
        if (i_btn_d) begin
            if (heart_y <= (PLAY_BOTTOM - HEART_HEIGHT - V_SPEED))
                heart_y <= heart_y + V_SPEED;
            else
                heart_y <= (PLAY_BOTTOM - HEART_HEIGHT);
        end

        // Gravity
        if (~i_btn_u && heart_y <= (PLAY_BOTTOM - HEART_HEIGHT - 5))
            heart_y <= heart_y + 2;

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
