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

module spi_master_model (
    input wire clk,
    input wire spi_clk_in,
    input wire spi_clk_in_negedge,
    input wire spi_clk_in_posedge,
    /*
     * Testbench control signals
     */
    output reg done,
    input wire en,
    /*
     * SPI interface
     */
    output wire mosi,
    input wire miso,
    output wire spi_clk,
    output wire spi_cs_n
);

////////////////////////////////////////////////////////////////////////////
// DOCUMENTATION
////////////////////////////////////////////////////////////////////////////

/*

This verification module connects to a SPI slave under test, feeds it inputs as
fast as possible, and verifies the outputs. The stimulus and response vectors
come frome files, generated with an external Python script. The done output is
asserted when the last response vector has been checked. The enable input
delays the transmission of stimulus vectors until asserted.

*/

////////////////////////////////////////////////////////////////////////////
// PARAMETERS AND CONSTANTS
////////////////////////////////////////////////////////////////////////////

parameter N = 1; // length of stimulus and response files
parameter STIMULUS_FILE = "spi_master_model.stimulus.txt";
parameter RESPONSE_FILE = "spi_master_model.response.txt";
parameter WIDTH=32;

////////////////////////////////////////////////////////////////////////////
// MEMORIES
////////////////////////////////////////////////////////////////////////////

reg [WIDTH-1:0] stimulus_mem [1:N];
reg [WIDTH-1:0] response_mem [1:N];

////////////////////////////////////////////////////////////////////////////
// WIRES and WIRE REGS (wires that are assigned inside of an always block)
////////////////////////////////////////////////////////////////////////////

integer stimulus_index = 0;
integer response_index = -1;

reg rst = 1'b0; // it doesn't make sense to reset this module

reg [WIDTH-1:0] din = 0;
reg strobe = 1'b0;

wire busy;
wire [WIDTH-1:0] dout;
wire spi_clk_out;

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ASSIGNMENTS
////////////////////////////////////////////////////////////////////////////

assign spi_clk = spi_clk_out;

////////////////////////////////////////////////////////////////////////////
// STIMULUS / RESPONSE
////////////////////////////////////////////////////////////////////////////

/*
 * Transmit the stimulus vector.
 */
task stimulus();
begin
    stimulus_index = stimulus_index + 1'b1;
    @(negedge clk);
    din = stimulus_mem[stimulus_index];
    strobe = 1'b1; 
    @(negedge clk);
    din = 0;
    strobe = 1'b0; 
    @(negedge clk);
end
endtask

/*
 * Read the expected response vector and verify that it matches the
 * actual response.
 */
task response();
begin
    response_index = response_index + 1'b1;
    wait (~busy);
    if (response_index != 0 && dout != response_mem[response_index]) begin
        $display("spi_master_model: expected_response=%08h, actual_response=%08h",
            response_mem[response_index], dout);
        $stop(2);
    end
end
endtask

initial begin : stimulus_response
    done = 1'b0;
    $readmemh(STIMULUS_FILE, stimulus_mem);
    $readmemh(RESPONSE_FILE, response_mem);
    wait (en);
    repeat (N) begin
        stimulus();
        response();
    end
    done = 1'b1;
end

////////////////////////////////////////////////////////////////////////////
// COMPONENT INSTANTIATIONS
////////////////////////////////////////////////////////////////////////////

spi_master #(
    .WIDTH(WIDTH)
)
spi_master_inst (
    .clk(clk),
    .rst(rst),
    /*
     * Inputs
     */
    .din(din),
    .miso(miso),
    .spi_clk_in(spi_clk_in),
    .spi_clk_in_negedge(spi_clk_in_negedge),
    .spi_clk_in_posedge(spi_clk_in_posedge),
    .strobe(strobe),
    /*
     * Outputs
     */
    .busy(busy),
    .dout(dout),
    .mosi(mosi),
    .spi_clk_out(spi_clk_out),
    .spi_cs_n(spi_cs_n)
);

endmodule
