module HeartRom(
    input wire [9:0] i_addr,    //(9:0) or 2^10 = 1024, need 24x24 = 576
    input wire i_pix_clk, // 25MHz pixel clock
    output reg [7:0] o_data    //8 bit value from Undertale.mem
    );
    
    (*ROM_STYLE="block"*) reg [7:0] memory_array [0:575];   //8 bit value for 576 pixels of Heart (24x24)
    initial begin
        $readmemh("Undertale.mem", memory_array);
    end
    
    always @ (posedge i_pix_clk)
        o_data <= memory_array[i_addr];
endmodule