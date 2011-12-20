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

module async_muller_c_element_tb;

parameter WIDTH=2;

// Inputs
reg [1:0] in;

// Outputs
wire out;

task assert_one;
begin
    if (out != 1'b1) begin
        $display("ASSERTION FAILED: out expected == 1'b1, actual == 1'b%H", out);
        $stop;
    end
end
endtask

task assert_zero;
begin
    if (out != 1'b0) begin
        $display("ASSERTION FAILED: out expected == 1'b0, actual == 1'b%H", out);
        $stop;
    end
end
endtask

// Stimulus and assertions
initial begin
    in = 2'b00;
    #100; // wait for Xilinx GSR
    // test 1: make sure output is zero
    in = 2'b00; #1; assert_zero;
    in = 2'b01; #1; assert_zero;
    in = 2'b10; #1; assert_zero;
    in = 2'b11; #1; assert_one;
    // test 1: make sure output is one
    in = 2'b11; #1; assert_one;
    in = 2'b10; #1; assert_one;
    in = 2'b01; #1; assert_one;
    in = 2'b00; #1; assert_zero;
    $stop;
end

// Unit-under-test
async_muller_c_element #(.WIDTH(WIDTH))
UUT (
    .in(in),
    .out(out));

endmodule
