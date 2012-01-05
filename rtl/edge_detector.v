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

/*
 * Detects positive and negative edges of a signal.
 */
module edge_detector (
    input clk,
    input in,
    output negedge_out,
    output negedge_comb_out,
    output posedge_out,
    output posedge_comb_out
);

////////////////////////////////////////////////////////////////////////////
// PARAMETERS AND CONSTANTS
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// REGISTERS
////////////////////////////////////////////////////////////////////////////

reg in_reg = 1'b0;
reg negedge_reg = 1'b0;
reg posedge_reg = 1'b0;

////////////////////////////////////////////////////////////////////////////
// WIRES and WIRE REGS (wires that are assigned inside of an always block)
////////////////////////////////////////////////////////////////////////////

wire in_next = in;
wire negedge_next = ({in_reg,in} == 2'b10);
wire posedge_next = ({in_reg,in} == 2'b01);

////////////////////////////////////////////////////////////////////////////
// COMPONENT INSTANTIATIONS
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ASSIGN STATEMENTS
////////////////////////////////////////////////////////////////////////////

assign negedge_out = negedge_reg;
assign negedge_comb_out = negedge_next;
assign posedge_out = posedge_reg;
assign posedge_comb_out = posedge_next;

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ALWAYS STATEMENTS (always @* begin ... end)
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// SEQUENTIAL ALWAYS STATEMENTS (always @(posedge clk) begin ... end)
////////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin : sequential
    in_reg <= in_next;
    negedge_reg <= negedge_next;
    posedge_reg <= posedge_next;
end

endmodule
