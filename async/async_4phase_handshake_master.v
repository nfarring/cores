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
 * Allows messages to be passed asynchronously from a master to a slave by
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
module async_4phase_handshake_master (
    input wire ack,
    output wire busy,
    output wire req,
    input wire reset,
    input wire strobe
);

assign busy = ack | req;

/*
 * The implementation is a very simple SR latch.
 *
 *      S (strobe)   R (ack)        Q (req)
 *      -----------------------------------
 *               0         0      No Change
 *               0         1              0
 *               1         0              1
 *               1         1  Scary Badness
 *
 * Note: The scary badness should not happen due to proper combinational logic.
 */
wire s = ~r & strobe; // block the strobe signal if we are in reset or if ack is asserted
wire r = reset | ack; // IMPORTANT: the reset puts the SR latch into a known state
wire q_n = ~(q | s);
wire q = ~(q_n | r);
assign req = q;

endmodule
