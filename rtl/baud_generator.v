`timescale 1ns/1ps

module baud_generator #(
    parameter CLOCK_FREQ = 50_000_000,   // System clock frequency (Hz)
    parameter BAUD_RATE  = 115200         // UART baud rate (bps)
)(
    input  wire clk,
    input  wire rst,

    output reg baud_tick
);

    // Number of clock cycles per baud period
    localparam integer BAUD_DIV = CLOCK_FREQ / (BAUD_RATE * 16);

    // Counter width (works for any BAUD_DIV)
    localparam integer COUNTER_WIDTH = $clog2(BAUD_DIV);

    reg [COUNTER_WIDTH-1:0] counter;

    always @(posedge clk) begin

        if (rst) begin
            counter   <= 0;
            baud_tick <= 0;
        end
        else begin

            if (counter == BAUD_DIV-1) begin
                counter   <= 0;
                baud_tick <= 1'b1;     // One-clock pulse
            end
            else begin
                counter   <= counter + 1'b1;
                baud_tick <= 1'b0;
            end

        end

    end

endmodule
