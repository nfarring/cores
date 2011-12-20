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
 * A SPI master controller using an external SPI clock input. The SPI clock is
 * synchronous to clk. The MSB is transmitted first. Data is clocked on the
 * rising edge of spi_clk.
 *
 * Ref: https://en.wikipedia.org/wiki/Serial_Peripheral_Interface_Bus
 */
module spi_master (
    output wire busy,
    input wire clk,
    input wire [WIDTH-1:0] din,
    output wire [WIDTH-1:0] dout,
    input wire miso,
    output wire mosi,
    input wire spi_clk_in,
    input wire spi_clk_in_negedge,
    input wire spi_clk_in_posedge,
    output wire spi_clk_out,
    input wire strobe
);

////////////////////////////////////////////////////////////////////////////
// PARAMETERS AND CONSTANTS
////////////////////////////////////////////////////////////////////////////

function integer log2;
    input integer value;
    begin
        value = value-1;
        for (log2=0; value>0; log2=log2+1)
            value = value>>1;
    end
endfunction

parameter WIDTH=32; // length of a SPI word
localparam BIT_COUNTER_WIDTH=log2(WIDTH)+1; // for Xilinx XST compatibility

// bit 2 is busy
localparam [2:0]
    STATE_IDLE = 3'b000,
    STATE_WAIT_SPI_CLK_HIGH = 3'b101,
    STATE_WAIT_SPI_CLK_LOW = 3'b110,
    STATE_TRANSMITTING = 3'b111;

////////////////////////////////////////////////////////////////////////////
// REGISTERS
////////////////////////////////////////////////////////////////////////////

reg [BIT_COUNTER_WIDTH-1:0] bit_counter_reg = 0, bit_counter_next;
reg [WIDTH-1:0] data_reg = 0, data_next;
reg miso_reg = 1'b0;
reg spi_clk_out_reg = 1'b0;
reg [2:0] state_reg = STATE_IDLE, state_next;

////////////////////////////////////////////////////////////////////////////
// WIRES and WIRE REGS (wires that are assigned inside of an always block)
////////////////////////////////////////////////////////////////////////////

wire miso_next = (state_reg == STATE_TRANSMITTING & spi_clk_in_posedge) ? miso : miso_reg;
wire spi_clk_out_next = (state_reg == STATE_TRANSMITTING) ? spi_clk_in : 1'b0;

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ASSIGN STATEMENTS
////////////////////////////////////////////////////////////////////////////

assign busy = state_reg[2];
assign dout = data_reg;
assign mosi = data_reg[WIDTH-1]; // transmit MSB first
assign spi_clk_out = spi_clk_out_reg;

////////////////////////////////////////////////////////////////////////////
// COMBINATIONAL ALWAYS STATEMENTS (always @* begin ... end)
////////////////////////////////////////////////////////////////////////////

always @* begin
    bit_counter_next = bit_counter_reg;
    case (state_reg)
        STATE_IDLE:
            if (strobe)
                bit_counter_next = WIDTH;
        STATE_TRANSMITTING:
            if (bit_counter_reg != 0 & spi_clk_in_negedge)
                bit_counter_next = bit_counter_reg - 1;
    endcase
end

always @* begin
    data_next = data_reg;
    case (state_reg)
        STATE_IDLE:
            if (strobe)
                data_next = din;
        STATE_TRANSMITTING:
            if (bit_counter_reg != 0 & spi_clk_in_negedge)
                data_next = {data_reg[WIDTH-2:0], miso_reg};
    endcase
end

always @* begin
    state_next = state_reg;
    case (state_reg)
        STATE_IDLE:
            if (strobe)
                state_next = (spi_clk_in) ? STATE_WAIT_SPI_CLK_LOW: STATE_WAIT_SPI_CLK_HIGH;
        STATE_WAIT_SPI_CLK_HIGH:
            if (spi_clk_in_posedge)
                state_next = STATE_WAIT_SPI_CLK_LOW;
        STATE_WAIT_SPI_CLK_LOW:
            if (spi_clk_in_negedge)
                state_next = STATE_TRANSMITTING;
        STATE_TRANSMITTING:
            if (bit_counter_reg == 1 & spi_clk_in_negedge)
                state_next = STATE_IDLE;
        default: state_next = STATE_IDLE;
    endcase
end

////////////////////////////////////////////////////////////////////////////
// SEQUENTIAL ALWAYS STATEMENTS (always @(posedge clk) begin ... end)
////////////////////////////////////////////////////////////////////////////

always @(posedge clk) begin
    bit_counter_reg <= bit_counter_next;
    data_reg <= data_next;
    miso_reg <= miso_next;
    spi_clk_out_reg <= spi_clk_out_next;
    state_reg <= state_next;
end

endmodule
