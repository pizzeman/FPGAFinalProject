`timescale 1 ns / 1 ns

module testbench;

   reg CLK;
   reg reset;

   // Device Under Test (DUT)
   Processor dut (
        .clk(CLK),
        .resetn(reset)
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
      $dumpvars(0,testbench);
   end

endmodule
