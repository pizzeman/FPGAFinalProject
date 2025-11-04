module SOC (
    input  CLK,        // system clock 
    input  SW1,      // reset button
    output LED1,
    output LED2,
    output LED3,
    output LED4, // system LEDs
    output S2_A,
    output S2_B,
    output S2_C,
    output S2_D,
    output S2_E,
    output S2_F,
    output S2_G,
    output S1_A,
    output S1_B,
    output S1_C,
    output S1_D,
    output S1_E,
    output S1_F,
    output S1_G
);

   wire    clk;
   wire    resetn;

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

   Processor CPU(
      .clk(clk),
      .resetn(resetn),		 
      .mem_addr(mem_addr),
      .mem_rdata(mem_rdata),
      .mem_rstrb(mem_rstrb),
      .x1(x1)		 
   );
   assign LED1 = x1[0];
   assign LED2 = x1[1];
   assign LED3 = x1[2];
   assign LED4 = x1[3];

   // Gearbox and reset circuitry.
   Clockworks #(
     .SLOW(19) // Divide clock frequency by 2^19
   )CW(
     .CLK(CLK),
     .RESET(SW1),
     .clk(clk),
     .resetn(resetn)
   );

   hexConverter Hex(
    .bitin(mem_addr),
    .a_output(S2_A),
    .b_output(S2_B),
    .c_output(S2_C),
    .d_output(S2_D),
    .e_output(S2_E),
    .f_output(S2_F),
    .g_output(S2_G)
   );

      hexConverter HexB(
    .bitin(mem_rdata),
    .a_output(S1_A),
    .b_output(S1_B),
    .c_output(S1_C),
    .d_output(S1_D),
    .e_output(S1_E),
    .f_output(S1_F),
    .g_output(S1_G)
   );
   
endmodule