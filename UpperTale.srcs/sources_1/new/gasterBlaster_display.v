module gaster_blaster(
    input wire        i_pix_clk,
    input wire [9:0]  pixel_x,
    input wire [9:0]  pixel_y,
    input wire [2:0]  six_counter,
    output reg        o_sprite_on,
    output wire [7:0] o_data
    );

    localparam W = 30;
    localparam H = 40;

    // Border
    localparam LEFT   = 110;
    localparam RIGHT  = 510;
    localparam TOP    = 251;
    localparam BOTTOM = 391;
    localparam THICK  = 6;

    // Play area
    localparam PLAY_LEFT   = LEFT   + THICK;
    localparam PLAY_RIGHT  = RIGHT  - THICK;
    localparam PLAY_TOP    = TOP    + THICK;
    localparam PLAY_BOTTOM = BOTTOM - THICK;

    // Spawn points (left side and right side)
    localparam SPAWN_LEFT  = LEFT - W;     // 130 - 30 = 100
    localparam SPAWN_RIGHT = RIGHT + THICK; // 506 + 6 = 512

    // vertical spawn rows
    localparam ROW1 = 258;
    localparam ROW2 = 304;
    localparam ROW3 = 355;

    reg [9:0] gx;
    reg [9:0] gy;
    reg is_left_glance;

    always @(*) begin
        case (six_counter)
            1: begin gy = ROW1; gx = SPAWN_LEFT; is_left_glance = 0;  end
            2: begin gy = ROW2; gx = SPAWN_LEFT; is_left_glance = 0;  end
            3: begin gy = ROW3; gx = SPAWN_LEFT; is_left_glance = 0;  end
            4: begin gy = ROW1; gx = SPAWN_RIGHT; is_left_glance = 1; end
            5: begin gy = ROW2; gx = SPAWN_RIGHT; is_left_glance = 1; end
            6: begin gy = ROW3; gx = SPAWN_RIGHT; is_left_glance = 1; end
            default: begin gx = 0; gy = 0; end
        endcase
    end

    // detect draw
    wire inside = (pixel_x >= gx && pixel_x < gx + H &&
                       pixel_y >= gy && pixel_y < gy + W);;
   

    // compute address to ROM
    reg [11:0] address;
    reg [11:0] lx, ly;
    
//    = (pixel_y - gy) * W + (pixel_x - gx);

    always @(*) begin
        lx = pixel_x - gx;
        ly = pixel_y - gy;
    
        if (is_left_glance) begin
            // +90° rotate
            address <= (H-1-lx)*W + ly;
        end else begin
            // -90° rotate
            address <= (lx)*W + ly;
        end
    end
    
    // output "on/off"
    always @(*) begin
        o_sprite_on = inside && (o_data != 8'h00); 
        // if ROM pixel = 0 ? transparent
    end

    // instantiate ROM
    GasterBlasterRom Grom (
        .i_addr(address),
        .i_pix_clk(i_pix_clk),
        .o_data(o_data)
    );

endmodule
