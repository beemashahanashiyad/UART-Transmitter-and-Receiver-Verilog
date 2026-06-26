`timescale 1ns/1ps

module uart_top #(

    parameter CLOCK_FREQ = 50_000_000,
    parameter BAUD_RATE  = 115200,

    parameter PARITY_NONE = 2'd0,
    parameter PARITY_EVEN = 2'd1,
    parameter PARITY_ODD  = 2'd2,

    parameter PARITY_MODE = PARITY_NONE,
    parameter STOP_BITS   = 1

)(

    input  wire       clk,
    input  wire       rst,

    input  wire       tx_start,
    input  wire [7:0] data_in,

    output wire       tx,
    output wire       busy,

    output wire [7:0] data_out,
    output wire       done,

    output wire       parity_error,
    output wire       framing_error

);


    wire baud_tick;

    baud_generator #(

        .CLOCK_FREQ(CLOCK_FREQ),
        .BAUD_RATE(BAUD_RATE)

    ) baud_gen (

        .clk(clk),
        .rst(rst),

        .baud_tick(baud_tick)

    );

   
    uart_tx #(

        .PARITY_MODE(PARITY_MODE),
        .STOP_BITS(STOP_BITS)

    ) transmitter (

        .clk(clk),
        .rst(rst),

        .baud_tick(baud_tick),

        .tx_start(tx_start),
        .data_in(data_in),

        .tx(tx),
        .busy(busy)

    );

   
    uart_rx #(

        .PARITY_MODE(PARITY_MODE),
        .STOP_BITS(STOP_BITS)

    ) receiver (

        .clk(clk),
        .rst(rst),

        .baud_tick(baud_tick),

        .rx(tx),

        .data_out(data_out),
        .done(done),

        .parity_error(parity_error),
        .framing_error(framing_error)

    );

endmodule
