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
 * A simple timer that expires after a specified number of clock ticks.
 */
module timer (
    input wire clk,
    input wire rst,
    input wire arm,
    input wire en,
    output wire fire
);

`include "log2.vh"

////////////////////////////////////////////////////////////////////////////
// PARAMETERS AND CONSTANTS
////////////////////////////////////////////////////////////////////////////

parameter TIMER_PERIOD_NS=80; // how long until the timer fires
parameter CLOCK_PERIOD_NS=8;  // period of the common clock
parameter NTICKS=TIMER_PERIOD_NS/CLOCK_PERIOD_NS; // overridable if necessary
localparam NBITS=log2(NTICKS); // size of state register

localparam FIRE_INIT = 1'b0;
localparam [NBITS-1:0] STATE_INIT = 0;

////////////////////////////////////////////////////////////////////////////
// REGISTERS
////////////////////////////////////////////////////////////////////////////

reg fire_reg = FIRE_INIT;
reg [NBITS-1:0] state_reg = STATE_INIT, state_next;

////////////////////////////////////////////////////////////////////////////
// WIRES and WIRE REGS (wires that are assigned inside of an always block)
////////////////////////////////////////////////////////////////////////////

wire fire_next = ~arm & en & ~(|state_reg);

////////////////////////////////////////////////////////////////////////////
// COMPONENT INSTANTIATIONS
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ASSIGN STATEMENTS
////////////////////////////////////////////////////////////////////////////

assign fire = fire_reg;

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ALWAYS STATEMENTS (always @* begin ... end)
////////////////////////////////////////////////////////////////////////////

always @* begin: combinational_logic
    state_next = state_reg;
    if (arm)
        state_next = NTICKS - 1'b1;
    else if (en & state_reg != 0)
        state_next = state_reg - 1'b1;
end

////////////////////////////////////////////////////////////////////////////
// SEQUENTIAL ALWAYS STATEMENTS (always @(posedge clk) begin ... end)
////////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin : sequential_logic
   if (rst) begin
       fire_reg <= FIRE_INIT;
       state_reg <= STATE_INIT;
   end
   else begin
       fire_reg <= fire_next;
       state_reg <= state_next;
    end
end

endmodule
