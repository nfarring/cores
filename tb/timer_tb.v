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

// Language: Verilog 2001

`timescale 1 ns / 1 ps

module timer_tb;

localparam TIMER_PERIOD_NS=80;
localparam CLOCK_PERIOD_NS=8;

reg arm = 1'b0;
reg clk;
reg en = 1'b0;
wire fire;

always begin : clock_125MHz
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
end

initial begin : stimulus
    #100; @(negedge clk); // wait for Xilinx GSR
    // normal behavior
    arm = 1'b1; en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
    arm = 1'b0;            @(negedge clk); ASSERT(fire,0); // 8
                           @(negedge clk); ASSERT(fire,0); // 7
                           @(negedge clk); ASSERT(fire,0); // 6
                           @(negedge clk); ASSERT(fire,0); // 5
                           @(negedge clk); ASSERT(fire,0); // 4
                           @(negedge clk); ASSERT(fire,0); // 3
                           @(negedge clk); ASSERT(fire,0); // 2
                           @(negedge clk); ASSERT(fire,0); // 1
                           @(negedge clk); ASSERT(fire,0); // 0
                           @(negedge clk); ASSERT(fire,1); // 0
                en = 1'b0; @(negedge clk); ASSERT(fire,0); // 0
    repeat(9) @(negedge clk);
    // test 1: enable/disable
                           @(negedge clk); ASSERT(fire,0);
                en = 1'b1; @(negedge clk); ASSERT(fire,1);
                en = 1'b0; @(negedge clk); ASSERT(fire,0);
    // test 2: asserting arm
    arm = 1'b1; en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
                en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
                en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
                en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
    // test 3: countdown/fire
    arm = 1'b0;            @(negedge clk); ASSERT(fire,0); // 8
                           @(negedge clk); ASSERT(fire,0); // 7
                           @(negedge clk); ASSERT(fire,0); // 6
                           @(negedge clk); ASSERT(fire,0); // 5
                           @(negedge clk); ASSERT(fire,0); // 4
                           @(negedge clk); ASSERT(fire,0); // 3
                           @(negedge clk); ASSERT(fire,0); // 2
                           @(negedge clk); ASSERT(fire,0); // 1
                           @(negedge clk); ASSERT(fire,0); // 0
                           @(negedge clk); ASSERT(fire,1); // 0
                           @(negedge clk); ASSERT(fire,1); // 0
                           @(negedge clk); ASSERT(fire,1); // 0
    $stop;
end

timer #(
    .TIMER_PERIOD_NS(TIMER_PERIOD_NS),
    .CLOCK_PERIOD_NS(CLOCK_PERIOD_NS))
UUT (
    .arm(arm),  // input
    .clk(clk),  // input
    .en(en),    // input
    .fire(fire) // output
);

//////////////////////////////////////////////////////////////////////////////
// ASSERTIONS
//////////////////////////////////////////////////////////////////////////////

`include "assertion.vh"

task ASSERT;
input fire_actual;
input fire_expected;
begin
    Assertion("fire",fire_actual,fire_expected);
end
endtask

endmodule
