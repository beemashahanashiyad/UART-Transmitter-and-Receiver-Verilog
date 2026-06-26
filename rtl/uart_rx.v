`timescale 1ns/1ps

module uart_rx #(

    parameter PARITY_NONE = 2'd0,
    parameter PARITY_EVEN = 2'd1,
    parameter PARITY_ODD  = 2'd2,

    parameter PARITY_MODE = PARITY_NONE,
    parameter STOP_BITS   = 1

)(

    input wire clk,
    input wire rst,

    input wire baud_tick,

    input wire rx,

    output reg [7:0] data_out,

    output reg done,

    output reg parity_error,

    output reg framing_error

);
  
localparam IDLE    = 3'd0;
localparam START   = 3'd1;
localparam DATA    = 3'd2;
localparam PARITY  = 3'd3;
localparam STOP    = 3'd4;
localparam DONE    = 3'd5;

reg [2:0] state;

reg [3:0] tick_count;

reg [2:0] bit_count;

reg [1:0] stop_count;

reg [7:0] rx_shift;

reg received_parity;
reg expected_parity;

reg [2:0] next_state;

reg [3:0] tick_count_next;

reg [2:0] bit_count_next;

reg [1:0] stop_count_next;

reg [7:0] rx_shift_next;

reg received_parity_next;
reg expected_parity_next;

reg [7:0] data_out_next;

reg done_next;

reg parity_error_next;
reg framing_error_next;

always @(posedge clk) begin

    if (rst) begin

        state <= IDLE;

        tick_count <= 4'd0;
        bit_count  <= 3'd0;
        stop_count <= 2'd0;

        rx_shift <= 8'd0;

        received_parity <= 1'b0;
        expected_parity <= 1'b0;

        data_out <= 8'd0;

        done <= 1'b0;

        parity_error <= 1'b0;
        framing_error <= 1'b0;

    end

    else begin

        state <= next_state;

        tick_count <= tick_count_next;
        bit_count  <= bit_count_next;
        stop_count <= stop_count_next;

        rx_shift <= rx_shift_next;

        received_parity <= received_parity_next;
        expected_parity <= expected_parity_next;

        data_out <= data_out_next;

        done <= done_next;

        parity_error <= parity_error_next;
        framing_error <= framing_error_next;

    end

end

always @(*) begin

    next_state = state;

    tick_count_next = tick_count;
    bit_count_next  = bit_count;
    stop_count_next = stop_count;

    rx_shift_next = rx_shift;

    received_parity_next = received_parity;
    expected_parity_next = expected_parity;

    data_out_next = data_out;

    done_next = 1'b0;

    parity_error_next = parity_error;
    framing_error_next = framing_error;

case(state)
 
      IDLE:
begin

    tick_count_next = 4'd0;
    bit_count_next  = 3'd0;
    stop_count_next = 2'd0;

    parity_error_next = 1'b0;
    framing_error_next = 1'b0;

    if(rx == 1'b0)
    begin
        next_state = START;
    end

end

      START:
begin

    if(baud_tick)
    begin

        if(tick_count == 4'd7)
        begin

            tick_count_next = 4'd0;
          
            if(rx == 1'b0)
                next_state = DATA;
            else
                next_state = IDLE;

        end
        else
            tick_count_next = tick_count + 1'b1;

    end

end
    DATA:
begin

    if(baud_tick)
    begin

        if(tick_count == 4'd15)
        begin

            tick_count_next = 4'd0;

            rx_shift_next = rx_shift;
            rx_shift_next[bit_count] = rx;

            if(bit_count == 3'd7)
            begin

                bit_count_next = 3'd0;

                case(PARITY_MODE)

                    PARITY_NONE:
                    begin
                        expected_parity_next = 1'b0;
                        next_state = STOP;
                    end

                    PARITY_EVEN:
                    begin
                        expected_parity_next = ^rx_shift_next;
                        next_state = PARITY;
                    end

                    PARITY_ODD:
                    begin
                        expected_parity_next = ~(^rx_shift_next);
                        next_state = PARITY;
                    end

                endcase

            end
            else
                bit_count_next = bit_count + 1'b1;

        end
        else
            tick_count_next = tick_count + 1'b1;

    end

end
      PARITY:
begin

    if (baud_tick)
    begin

        if (tick_count == 4'd15)
        begin

            tick_count_next = 4'd0;

            received_parity_next = rx;

            if (rx != expected_parity)
                parity_error_next = 1'b1;
            else
                parity_error_next = 1'b0;

            next_state = STOP;

        end
        else
            tick_count_next = tick_count + 1'b1;

    end

end
      STOP:
begin

    if (baud_tick)
    begin

        if (tick_count == 4'd15)
        begin

            tick_count_next = 4'd0;

            if (rx != 1'b1)
                framing_error_next = 1'b1;
            else
                framing_error_next = 1'b0;

            if (stop_count == STOP_BITS - 1)
            begin

                stop_count_next = 2'd0;
                next_state = DONE;

            end
            else
                stop_count_next = stop_count + 1'b1;

        end
        else
            tick_count_next = tick_count + 1'b1;

    end

end
      DONE:
begin

    data_out_next = rx_shift;

    done_next = 1'b1;

    next_state = IDLE;

end
      
    endcase

end
endmodule
