`timescale 1 ns / 1 ns

module testbench;

   reg CLK;
   reg reset;
   reg sel;

   wire       LFSR_Done;

   // Reset values for XOR and XNOR implementations.
   parameter RESET_XOR3 = (2**3)-1;
   parameter RESET_XNOR3 = 0;

   reg [31:0] MEM [0:255]; 
  reg [31:0] mem_rdata;

`include "riscv_assembly.vh"
   integer L0_=8;
   initial begin
                  ADD(x1,x0,x0);      
      //             ADDI(x2,x0,31);
      // Label(L0_); ADDI(x1,x1,1); 
      //             BNE(x1, x2, LabelRef(L0_));
      //             EBREAK();
      // endASM();
   end

   always @(posedge CLK) begin
         mem_rdata <= MEM[0];
   end

   // Device Under Test (DUT)
   Processor dut (
        .clk(CLK),
        .resetn(reset),
        .mem_rdata(mem_rdata)
     );
   
   // clock generation
   always
     begin
	CLK <= 0;
	#20; // Period of 25 MHz clock
	CLK <= 1;
	#20;
     end

   initial begin
      reset = 1;
      #100;
      reset = 0;
      #1000;
      $finish;
   end

    initial begin
      $dumpfile("testbench_tb.vcd");
      $dumpvars(0,testbench);
   end

endmodule
