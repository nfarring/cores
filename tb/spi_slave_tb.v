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

module spi_slave_tb;

////////////////////////////////////////////////////////////////////////////
// DOCUMENTATION
////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////
// PARAMETERS AND CONSTANTS
////////////////////////////////////////////////////////////////////////////

localparam N = 100;
localparam STIMULUS_FILE = "spi_master_model.100random32.txt";
localparam RESPONSE_FILE = "spi_master_model.100random32.txt";
localparam WIDTH=32;

////////////////////////////////////////////////////////////////////////////
// WIRES and WIRE REGS (wires that are assigned inside of an always block)
////////////////////////////////////////////////////////////////////////////

/*
 * Testbench
 */
reg clk = 1'b1; // 125MHz clock
reg rst = 1'b0;
reg spi_clk_in = 1'b1; // 12.5MHz clock
reg spi_clk_in_negedge = 1'b0;
reg spi_clk_in_posedge = 1'b1;
wire done;
reg en = 1'b0;

/*
 * Wires
 */
wire [WIDTH-1:0] din = dout; // loopback
wire [WIDTH-1:0] dout;
wire mosi;
wire miso;
wire miso_tri;
wire spi_clk;
wire spi_cs_n;
wire valid;

////////////////////////////////////////////////////////////////////////////
// CLOCKS
////////////////////////////////////////////////////////////////////////////

always begin : clocks
   spi_clk_in = 1'b1;
   spi_clk_in_negedge = 1'b0;
   spi_clk_in_posedge = 1'b1;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   spi_clk_in_posedge = 1'b0;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   spi_clk_in = 1'b0;
   spi_clk_in_negedge = 1'b1;
   spi_clk_in_posedge = 1'b0;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   spi_clk_in_negedge = 1'b0;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
   clk = 1'b1;
   #4;
   clk = 1'b0;
   #4;
end

////////////////////////////////////////////////////////////////////////////
// RESETS
////////////////////////////////////////////////////////////////////////////

initial begin : reset
     #100;
     @(negedge clk);
     en = 1'b1;
end

////////////////////////////////////////////////////////////////////////////
// TEST
////////////////////////////////////////////////////////////////////////////

initial begin : test
     wait(done);
     $stop;
end

////////////////////////////////////////////////////////////////////////////
// COMPONENT INSTANTIATIONS
////////////////////////////////////////////////////////////////////////////

spi_master_model #(
    .N(100),
    .STIMULUS_FILE(STIMULUS_FILE),
    .RESPONSE_FILE(RESPONSE_FILE),
    .WIDTH(WIDTH)
)
TESTFIXTURE (
    .clk(clk),                               // IN(1)
    .spi_clk_in(spi_clk_in),                 // IN(1)
    .spi_clk_in_negedge(spi_clk_in_negedge), // IN(1)
    .spi_clk_in_posedge(spi_clk_in_posedge), // IN(1)
    /*
     * Testbench control signals
     */
    .done(done),                             // OUT(1)
    .en(en),                                 // IN(1)
    /*
     * SPI interface
     */
    .mosi(mosi),                             // OUT(1)
    .miso(miso),                             // IN(1)
    .spi_clk(spi_clk),                       // OUT(1)
    .spi_cs_n(spi_cs_n)                      // OUT(1)
);

spi_slave #(
    .WIDTH(WIDTH)
)
UUT (
    .clk(clk),           // IN(1)
    .rst(rst),           // IN(1)
    /*
     * Inputs
     */
    .din(din),           // IN(WIDTH)
    .spi_clk(spi_clk),   // IN(1)
    .spi_cs_n(spi_cs_n), // IN(1)
    .mosi(mosi),         // OUT(1)
    /*
     * Outputs
     */
    .dout(dout),         // OUT(WIDTH)
    .miso(miso),         // OUT(1)
    .miso_tri(miso_tri), // OUT(1)
    .valid(valid)        // OUT(1)
);

endmodule
