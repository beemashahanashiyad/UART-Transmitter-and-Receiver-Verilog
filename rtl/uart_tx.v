`timescale 1ns/1ps

module uart_tx #(

    parameter PARITY_NONE = 2'd0,
    parameter PARITY_EVEN = 2'd1,
    parameter PARITY_ODD  = 2'd2,

    parameter PARITY_MODE = PARITY_NONE,
    parameter STOP_BITS   = 1

)(

    input wire clk,
    input wire rst,

    input wire baud_tick,

    input wire tx_start,

    input wire [7:0] data_in,

    output reg tx,

    output reg busy

);

localparam IDLE    = 3'd0;
localparam START   = 3'd1;
localparam DATA    = 3'd2;
localparam PARITY  = 3'd3;
localparam STOP    = 3'd4;

reg [2:0] state;
reg [2:0] next_state;

reg [3:0] tick_count;
reg [3:0] tick_count_next;

reg [2:0] bit_count;
reg [2:0] bit_count_next;

reg [1:0] stop_count;
reg [1:0] stop_count_next;

reg [7:0] tx_shift;
reg [7:0] tx_shift_next;

reg parity_bit;
reg parity_bit_next;

reg tx_next;

reg busy_next;

always @(posedge clk) begin

    if (rst) begin

        state      <= IDLE;

        tick_count <= 0;
        bit_count  <= 0;
        stop_count <= 0;

        tx_shift   <= 8'd0;
        parity_bit <= 1'b0;

        tx         <= 1'b1;
        busy       <= 1'b0;

    end

    else begin

        state      <= next_state;

        tick_count <= tick_count_next;
        bit_count  <= bit_count_next;
        stop_count <= stop_count_next;

        tx_shift   <= tx_shift_next;
        parity_bit <= parity_bit_next;

        tx         <= tx_next;
        busy       <= busy_next;

    end

end

always @(*) begin

    next_state      = state;

    tick_count_next = tick_count;
    bit_count_next  = bit_count;
    stop_count_next = stop_count;

    tx_shift_next   = tx_shift;
    parity_bit_next = parity_bit;

    tx_next         = tx;
    busy_next       = busy;
   
case (state)

        IDLE:
begin

    tx_next   = 1'b1;
    busy_next = 1'b0;

    tick_count_next = 0;
    bit_count_next  = 0;
    stop_count_next = 0;

    if (tx_start) begin

      tick_count_next = 0;
      bit_count_next  = 0;
      stop_count_next = 0;
      
        tx_shift_next = data_in;

        case (PARITY_MODE)

            PARITY_NONE:
                parity_bit_next = 1'b0;

            PARITY_EVEN:
                parity_bit_next = ^data_in;

            PARITY_ODD:
                parity_bit_next = ~(^data_in);

        endcase

        busy_next  = 1'b1;
        next_state = START;

    end

end
   
      START:
begin

    tx_next   = 1'b0;
    busy_next = 1'b1;

    if (baud_tick) begin

        if (tick_count == 4'd15) begin

            tick_count_next = 0;
            next_state      = DATA;

        end
        else
            tick_count_next = tick_count + 1;

    end

end
      DATA:
begin

    tx_next   = tx_shift[0];
    busy_next = 1'b1;

    if (baud_tick) begin

        if (tick_count == 4'd15) begin

            tick_count_next = 0;

            tx_shift_next = tx_shift >> 1;

            if (bit_count == 3'd7) begin

                bit_count_next = 0;

                if (PARITY_MODE == PARITY_NONE)
                    next_state = STOP;
                else
                    next_state = PARITY;

            end
            else
                bit_count_next = bit_count + 1;

        end
        else
            tick_count_next = tick_count + 1;

    end

end
      PARITY:
begin

    tx_next   = parity_bit;
    busy_next = 1'b1;

    if (baud_tick) begin

        if (tick_count == 4'd15) begin

            tick_count_next = 0;
            next_state      = STOP;

        end
        else
            tick_count_next = tick_count + 1;

    end

end
      STOP:
begin

    tx_next   = 1'b1;
    busy_next = 1'b1;

    if (baud_tick) begin

        if (tick_count == 4'd15) begin

            tick_count_next = 0;

            if (stop_count == STOP_BITS - 1) begin

                stop_count_next = 0;
                busy_next       = 1'b0;
                next_state      = IDLE;

            end
            else
                stop_count_next = stop_count + 1;

        end
        else
            tick_count_next = tick_count + 1;

    end

end
      default:
        begin
            next_state = IDLE;
        end
      
    endcase

end
endmodule
