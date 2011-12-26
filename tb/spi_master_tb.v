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

module spi_master_tb;

localparam WIDTH=4;

wire busy;
reg clk;
reg [WIDTH-1:0] din;
wire [WIDTH-1:0] dout;
reg miso;
wire mosi;
reg spi_clk_in;
reg spi_clk_in_negedge;
reg spi_clk_in_posedge;
wire spi_clk_out;
reg strobe;

// 125MHz common clock
// 12.5MHz SPI clock
always begin
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

initial begin
   din = 4'hF; // test 1: write F, read 0
   miso = 1'b0;
   strobe = 1'b0;
   #100; // wait for Xilinx GSR
   @(negedge clk);
   strobe = 1'b1;
   @(negedge clk);
   strobe = 1'b0;
   @(negedge busy);
   if (dout != 4'h0) begin
      $display("ASSERTION FAILED: dout expected == 4'h0, actual == 4'h%H", dout);
      $stop;
   end
   #80;
   @(negedge clk);
   din = 4'h0; // test 2: write 0, read F (524ns)
   miso = 1'b1;
   strobe = 1'b1;
   @(negedge clk);
   strobe = 1'b0;
   @(negedge busy);
   if (dout != 4'hF) begin
      $display("ASSERTION FAILED: dout expected == 4'hF, actual == 4'h%H", dout);
      $stop;
   end
   #80;
   @(negedge clk);
   $stop; // (1004ns)
end

spi_master #(.WIDTH(WIDTH))
UUT (
    .busy(busy),                             // output
    .clk(clk),                               // input
    .din(din),                               // input [WIDTH-1:0]
    .dout(dout),                             // output [WIDTH-1:0]
    .miso(miso),                             // input
    .mosi(mosi),                             // output
    .spi_clk_in(spi_clk_in),                 // input
    .spi_clk_in_negedge(spi_clk_in_negedge), // input
    .spi_clk_in_posedge(spi_clk_in_posedge), // input
    .spi_clk_out(spi_clk_out),               // output
    .strobe(strobe)                          // input
);

endmodule
