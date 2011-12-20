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

module async_4phase_handshake_slave_tb;

// Inputs
reg clear;
reg req;
reg reset;

// Outputs
wire ack;
wire flag;

task assertion;
input [255:0] variable_name;
input actual;
input expected;
begin
    if (actual != expected) begin
        $display("ASSERTION FAILED: actual == 1'b%H, expected == 1'b%H: %s",
            actual, expected, variable_name);
        $stop;
    end
end
endtask

// Stimulus and assertions
initial begin
    clear = 1'b0;
    req = 1'b0;
    reset = 1'b1;
    #100; // wait for Xilinx GSR
    reset = 1'b0;
    // test 1: proper state transition
    req = 1'b0; #1; assertion("ack",ack,1'b0); assertion("flag",flag,1'b0);
    req = 1'b1; #1; assertion("ack",ack,1'b0); assertion("flag",flag,1'b1);
    clear = 1'b1; #1; assertion("ack",ack,1'b1); assertion("flag",flag,1'b0);
    clear = 1'b0; #1; assertion("ack",ack,1'b1); assertion("flag",flag,1'b0);
    req = 1'b0; #1; assertion("ack",ack,1'b0); assertion("flag",flag,1'b0);
    // test 2: keep clear asserted longer than we should
    req = 1'b0; #1; assertion("ack",ack,1'b0); assertion("flag",flag,1'b0);
    req = 1'b1; #1; assertion("ack",ack,1'b0); assertion("flag",flag,1'b1);
    clear = 1'b1; #1; assertion("ack",ack,1'b1); assertion("flag",flag,1'b0);
    req = 1'b0; #1; assertion("ack",ack,1'b0); assertion("flag",flag,1'b0);
    clear = 1'b0; #1; assertion("ack",ack,1'b0); assertion("flag",flag,1'b0);
    $stop;
end

// Unit-under-test
async_4phase_handshake_slave
UUT (
    .ack(ack),     // output
    .clear(clear), // input
    .flag(flag),   // output
    .req(req),     // input
    .reset(reset)  // input
);

endmodule
