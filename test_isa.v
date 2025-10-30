`default_nettype none

module SOC (
    input  CLK,        // system clock 
    input  SW1,      // reset button
    output LED1,
    output LED2,
    output LED3,
    output LED4,
    output S2_A,
    output S2_B,
    output S2_C,
    output S2_D,
    output S2_E,
    output S2_F,
    output S2_G
);

    wire clk;    // internal clock
    wire resetn; // internal reset signal, goes low on reset

    Memory RAM(
        .clk(clk),
        .mem_addr(mem_addr),
        .mem_rdata(mem_rdata),
        .mem_rstrb(mem_rstrb)
    );

    wire [31:0] mem_addr;
    wire [31:0] mem_rdata;
    wire mem_rstrb;
    wire [31:0] x1;
    wire [31:0] inter_pc;

    Processor CPU(
    .clk(clk),
    .resetn(resetn),		 
    .mem_addr(mem_addr),
    .mem_rdata(mem_rdata),
    .mem_rstrb(mem_rstrb),
    .inter_pc(inter_pc),
    .x1(x1)		 
    );
    assign LED1 = x1[0];
    assign LED2 = x1[1];
    assign LED3 = x1[2];
    assign LED4 = inter_pc;

    
    hexConverter hex_value_data(
        .bitin(x1),
        .a_output(S2_A),
        .b_output(S2_B),
        .c_output(S2_C),
        .d_output(S2_D),
        .e_output(S2_E),
        .f_output(S2_F),
        .g_output(S2_G)
    );

    // Gearbox and reset circuitry.
    Clockworks #(
        .SLOW(21) // Divide clock frequency by 2^21
    )CW(
        .CLK(CLK),
        .RESET(SW1),
        .clk(clk),
        .resetn(resetn)
    );
   
endmodule