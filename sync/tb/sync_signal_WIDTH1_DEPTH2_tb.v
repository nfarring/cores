/*
Copyright 2011, The Regents of the University of California.
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.

   2. Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE REGENTS OF THE UNIVERSITY OF CALIFORNIA ''AS
IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE REGENTS OF THE UNIVERSITY OF CALIFORNIA OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE.

The views and conclusions contained in the software and documentation are those
of the authors and should not be interpreted as representing official policies,
either expressed or implied, of The Regents of the University of California.
*/

// Language: Verilog-2001

`timescale 1 ns / 1 ps

module sync_signal_WIDTH1_DEPTH2_tb;

// Inputs
reg clk;
reg in;

// Outputs
wire out;

// 125MHz clock
always begin
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
end

// Stimulus and assertions
initial begin
   in = 1'b0;
   #100; // wait for Xilinx GSR
   @(negedge clk); // test 1: assert exactly at negative edge
   in = 1'b1;
   #32;
   in = 1'b0;
   #32;
   @(posedge clk); // test 2: assert exactly at positive edge, violating setup/hold times
   in = 1'b1;
   #32;
   in = 1'b0;
   #32;
   $stop;
end

// Unit-under-test
sync_signal_WIDTH1_DEPTH2
UUT (
    .clk(clk),
    .in(in),
    .out(out));

endmodule
