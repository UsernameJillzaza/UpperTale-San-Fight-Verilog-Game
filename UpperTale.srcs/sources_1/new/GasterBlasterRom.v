module GasterBlasterRom(
    input  wire [11:0] i_addr, // 30×40 = 1200 = needs 11 bits
    input  wire i_pix_clk,
    output reg [7:0] o_data
    );

    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:1119];
    initial begin
        $readmemh("gasterBlasterTransparent.mem", memory_array);
    end

    always @(posedge i_pix_clk)
        o_data <= memory_array[i_addr];
endmodule


