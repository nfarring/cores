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

/*
 * Adapted from source code from the following website:
 *      http://www.fpga4fun.com/SPI2.html
 *      http://www.fpga4fun.com/SiteInformation.html
 * This original design is copyrighted by KNHN, LLC.
 */

module spi_slave (
    input wire clk,
    input wire rst,
    /*
     * Inputs
     */
    input wire [WIDTH-1:0] din,
    input wire spi_clk,
    input wire spi_cs_n,
    input wire mosi,
    /*
     * Outputs
     */
    output wire [WIDTH-1:0] dout,
    output wire miso,
    output wire miso_tri,
    output wire valid
);

`include "log2.vh"

////////////////////////////////////////////////////////////////////////////
// PARAMETERS AND CONSTANTS
////////////////////////////////////////////////////////////////////////////

parameter WIDTH=32; // length of a SPI word
localparam BIT_COUNTER_WIDTH=log2(WIDTH)+1; // for Xilinx XST compatibility

localparam [BIT_COUNTER_WIDTH-1:0] BIT_COUNTER_INIT = 0;
localparam [WIDTH-1:0] DATA_RECEIVED_INIT = 0;
localparam VALID_INIT = 1'b0;
localparam [WIDTH-1:0] DATA_SENT_INIT = 0;

////////////////////////////////////////////////////////////////////////////
// REGISTERS
////////////////////////////////////////////////////////////////////////////

/*
 * Keep a count of the number of bits received so we know when we are done.
 */
reg [BIT_COUNTER_WIDTH-1:0] bit_counter_reg = BIT_COUNTER_INIT, bit_counter_next;
/*
 * Incomming data goes here. 
 */
reg [WIDTH-1:0] data_received_reg = DATA_RECEIVED_INIT, data_received_next;
/*
 * Outgoing data comes from here.
 */
reg [WIDTH-1:0] data_sent_reg = DATA_SENT_INIT, data_sent_next;
/*
 * Asserted when dout is valid.
 */
reg valid_reg = VALID_INIT;

////////////////////////////////////////////////////////////////////////////
// WIRES and WIRE REGS (wires that are assigned inside of an always block)
////////////////////////////////////////////////////////////////////////////

wire spi_clk_risingedge;
wire spi_clk_fallingedge;
/*
 * spi_cs_n is active low.
 */
wire spi_cs_n_active = ~spi_cs_n;
/*
 * Since spi_cs_n is active low, messages begin with the falling edge and end
 * with rising edge.
 */
wire spi_cs_n_startmessage;
wire spi_cs_n_endmessage;
/*
 * The output is valid on the rising edge of the SPI clock when we have
 * received WIDTH bits and when our chip select is active.
 */
wire valid_next = spi_cs_n_active & spi_clk_risingedge & (bit_counter_reg==(WIDTH-1));

////////////////////////////////////////////////////////////////////////////
// COMPONENT INSTANTIATIONS
////////////////////////////////////////////////////////////////////////////

edge_detector
edge_detector0_inst (
    .clk(clk),
    .in(spi_clk),
    .negedge_out(spi_clk_fallingedge),
    .posedge_out(spi_clk_risingedge)
);

edge_detector
edge_detector1_inst (
    .clk(clk),
    .in(spi_cs_n),
    .negedge_out(spi_cs_n_startmessage),
    .posedge_out(spi_cs_n_endmessage)
);

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ASSIGN STATEMENTS
////////////////////////////////////////////////////////////////////////////

assign dout = data_received_reg;
/*
 * Send MSB first.
 */
assign miso = data_sent_reg[WIDTH-1];
/*
 * Tri-state the output when chip-select is not active.
 */
assign miso_tri = ~spi_cs_n_active;

assign valid = valid_reg;

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ALWAYS STATEMENTS (always @* begin ... end)
////////////////////////////////////////////////////////////////////////////

always @* begin : combinational
    bit_counter_next = bit_counter_reg;
    data_received_next = data_received_reg;
    data_sent_next = data_sent_reg;
    /*
     * If we are not sending or receiving data,
     *      1. then clear the bit counter registers
     */
    if (~spi_cs_n_active)
        bit_counter_next = BIT_COUNTER_INIT;
    /*
     * If we are sending and receiving data . . .
     */
    else begin
        /*
         * and if this is a rising clock edge, then
         *      1. increment the bit counter register,
         *      2. shift the mosi bit left into the data received register
         */
        if (spi_clk_risingedge) begin
            bit_counter_next = bit_counter_reg + 1'b1;
            data_received_next = {data_received_reg[WIDTH-2:0], mosi};
        end
        /*
         * and if this is the start of a message,
         *      1. then latch the din input
         */
        if (spi_cs_n_startmessage)
            data_sent_next = din;
        /* 
         * but if this is not the start of a message . . .
         */
        else
            /*
             * and if this is the falling edge of the SPI clock, then
             *      1. transmit the next bit
             */
            if (spi_clk_fallingedge)
                data_sent_next = {data_sent_reg[WIDTH-2:0], 1'b0};
    end
end

////////////////////////////////////////////////////////////////////////////
// SEQUENTIAL ALWAYS STATEMENTS (always @(posedge clk) begin ... end)
////////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin : sequential
    if (rst) begin
        bit_counter_reg <= BIT_COUNTER_INIT;
        data_received_reg <= DATA_RECEIVED_INIT;
        valid_reg <= VALID_INIT;
        data_sent_reg <= DATA_SENT_INIT;
    end
    else begin
        bit_counter_reg <= bit_counter_next;
        data_received_reg <= data_received_next;
        valid_reg <= valid_next;
        data_sent_reg <= data_sent_next;
    end
end

endmodule
