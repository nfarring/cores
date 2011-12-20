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

module sync_4phase_handshake_slave_tb;

// Inputs
reg clear = 1'b0;
reg clk;
reg req = 1'b0;

// Outputs
wire ack;
wire flag;

always begin : clock_125MHz
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
end

initial begin : stimulus
    #100; // wait for Xilinx GSR
    // test 1: proper usage
    clear = 1'b0; req = 1'b0; @(negedge clk); ASSERT(ack,0,flag,0);
                  req = 1'b1; @(negedge clk); ASSERT(ack,0,flag,1);
    clear = 1'b1;             @(negedge clk); ASSERT(ack,1,flag,0);
    clear = 1'b0;             @(negedge clk); ASSERT(ack,1,flag,0);
                  req = 1'b0; @(negedge clk); ASSERT(ack,0,flag,0);
    $stop;
end

// Unit-under-test
sync_4phase_handshake_slave
UUT (
    .ack(ack),
    .clear(clear),
    .clk(clk),
    .flag(flag),
    .req(req)
);

//////////////////////////////////////////////////////////////////////////////
// ASSERTIONS
//////////////////////////////////////////////////////////////////////////////

`include "../../testbench_common.vh"

task ASSERT;
input ack_actual;
input ack_expected;
input flag_actual;
input flag_expected;
begin
    Assertion("ack",ack_actual,ack_expected);
    Assertion("flag",flag_actual,flag_expected);
end
endtask

endmodule
