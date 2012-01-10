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

////////////////////////////////////////////////////////////////////////////
// DOCUMENTATION
////////////////////////////////////////////////////////////////////////////

localparam TIMER_PERIOD_NS=80;
localparam CLOCK_PERIOD_NS=8;

////////////////////////////////////////////////////////////////////////////
// PARAMETERS AND CONSTANTS
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// WIRES and WIRE REGS (wires that are assigned inside of an always block)
////////////////////////////////////////////////////////////////////////////

integer test = 0;

reg clk = 1'b1;
reg rst = 1'b0;
/*
 * Inputs
 */
reg arm = 1'b0;
reg en = 1'b0;
/*
 * Outputs
 */
wire fire;

////////////////////////////////////////////////////////////////////////////
// CLOCKS
////////////////////////////////////////////////////////////////////////////

always begin : clock125MHz
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
end

////////////////////////////////////////////////////////////////////////////
// RESETS
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// STIMULUS
////////////////////////////////////////////////////////////////////////////

initial begin : stimulus
    #100; @(negedge clk); // wait for Xilinx GSR
    // Test 1: normal behavior
    test = 1;
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
    test = 0;
    repeat(9) @(negedge clk);
    // Test 2: enable/disable
    test = 2;
                           @(negedge clk); ASSERT(fire,0);
                en = 1'b1; @(negedge clk); ASSERT(fire,1);
                en = 1'b0; @(negedge clk); ASSERT(fire,0);
    // Test 3: asserting arm
    test = 3;
    arm = 1'b1; en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
                en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
                en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
                en = 1'b1; @(negedge clk); ASSERT(fire,0); // 9
    // Test 4: countdown/fire
    test = 4;
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
    test = 0;
    $stop;
end

////////////////////////////////////////////////////////////////////////////
// RESPONSE
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// COMPONENT INSTANTIATIONS
////////////////////////////////////////////////////////////////////////////

timer #(
    .TIMER_PERIOD_NS(TIMER_PERIOD_NS),
    .CLOCK_PERIOD_NS(CLOCK_PERIOD_NS))
UUT (
    .clk(clk),  // IN(1)
    .rst(rst),  // IN(1)
    .arm(arm),  // IN(1)
    .en(en),    // IN(1)
    .fire(fire) // OUT(1)
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
