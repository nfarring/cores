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
 * Allows messages to be passed synchronously from a master to a slave by
 * using an alternating sequence of request (req) and acknowledgement (ack)
 * levels.
 *
 * State 1: (~req,~ack) Master writes data to associated data bus
 * State 2: ( req,~ack) Master asserts req
 * State 3: ( req, ack) Slave reads data from associated data bus
 * State 4: (~req, ack) Master deasserts req
 *
 * Ref: http://www.cl.cam.ac.uk/~djg11/wwwhpr/fourphase/fourphase.html
 */
module sync_4phase_handshake_slave (
    output wire ack,
    input wire clear,
    input wire clk,
    output wire flag,
    input wire req
);

/*
 * The outputs are encoded in the state register.
 */
localparam [1:0]
    STATE_0 = 2'b00,
    STATE_1 = 2'b01,
    STATE_2 = 2'b10;
reg [1:0] state_reg = STATE_0, state_next;
always @* begin
    state_next = state_reg;
    case (state_reg)
        STATE_0: if (req) state_next = STATE_1;
        STATE_1: if (clear) state_next = STATE_2;
        STATE_2: if (~req) state_next = STATE_0;
        default: state_next = STATE_0; // should not happen
    endcase
end
always @(posedge clk) state_reg <= state_next;

assign ack = state_reg[1];
assign flag = state_reg[0];

endmodule
