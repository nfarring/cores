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

/*
 * Synchronizes an asyncronous signal to a given clock.
 */
module sync_signal (
    input wire clk,
    input wire [WIDTH-1:0] in,
    output wire [WIDTH-1:0] out
);

parameter WIDTH=1; // width of the input and output signals
parameter DEPTH=2; // number of synchronizing registers

reg [WIDTH-1:0] sync_reg [DEPTH-1:0];

/*
 * The synchronized output is the last register in the pipeline.
 */
assign out = sync_reg[DEPTH-1];

generate
    /*
     * Initialize the registers to 0.
     */
    genvar i;
    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin : init_zero
            sync_reg[i] = {WIDTH{1'b0}};
        end
    end
    /*
     * Build a pipeline of registers.
     */
    genvar j;
    always @(posedge clk) begin
        for (j = DEPTH-1; j > 0; j = j - 1) begin : pipeline
            sync_reg[j] <= sync_reg[j-1];
        end
        sync_reg[0] <= in;
    end
endgenerate

endmodule
