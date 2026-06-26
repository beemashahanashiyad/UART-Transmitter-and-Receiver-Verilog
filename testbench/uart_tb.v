`timescale 1ns/1ps

module uart_tb;

parameter CLOCK_FREQ = 160;
parameter BAUD_RATE  = 10;

parameter PARITY_NONE = 2'd0;
parameter PARITY_EVEN = 2'd1;
parameter PARITY_ODD  = 2'd2;

parameter PARITY_MODE = PARITY_NONE;
parameter STOP_BITS   = 1;

reg clk;
reg rst;

reg tx_start;
reg [7:0] data_in;

reg [7:0] random_data;  
  
wire tx;
wire busy;

wire [7:0] data_out;
wire done;

wire parity_error;
wire framing_error;  

integer tests_run;
integer tests_passed;
integer tests_failed;
integer i;
  
always #5 clk = ~clk;
  
uart_top #(

    .CLOCK_FREQ(CLOCK_FREQ),
    .BAUD_RATE(BAUD_RATE),

    .PARITY_MODE(PARITY_MODE),
    .STOP_BITS(STOP_BITS)

) dut (

    .clk(clk),
    .rst(rst),

    .tx_start(tx_start),
    .data_in(data_in),

    .tx(tx),
    .busy(busy),

    .data_out(data_out),
    .done(done),

    .parity_error(parity_error),
    .framing_error(framing_error)

);
  

task print_test_header;

    input [255:0] test_name;

    begin

        $display("");
        $display("========================================");
        $display("%s", test_name);
        $display("========================================");

    end

endtask
  

task send_byte;

    input [7:0] tx_data;

    begin
      
        wait(!busy);

        @(posedge clk);

        data_in  = tx_data;
        tx_start = 1'b1;

        @(posedge clk);

        tx_start = 1'b0;

    end

endtask
  

task check_byte;

    input [7:0] expected;
    input integer idle_cycles;

    begin

        tests_run = tests_run + 1;

        wait(done);

        if(data_out == expected &&
           !parity_error &&
           !framing_error)
        begin

            tests_passed = tests_passed + 1;

            $display("PASS : %h", expected);

        end
        else
        begin

            tests_failed = tests_failed + 1;

            $display("FAIL");

            $display("Expected      : %h", expected);
            $display("Received      : %h", data_out);
            $display("Parity Error  : %b", parity_error);
            $display("Framing Error : %b", framing_error);

        end

        repeat(idle_cycles) @(posedge clk);

    end

endtask
  

task check_busy;

    begin

        wait(busy);

        $display("PASS : Busy asserted");

        wait(!busy);

        $display("PASS : Busy deasserted");

    end

endtask
  

task print_summary;

    begin

        $display("");
        $display("========================================");
        $display("UART Verification Summary");
        $display("========================================");

        $display("Tests Run    : %0d", tests_run);
        $display("Tests Passed : %0d", tests_passed);
        $display("Tests Failed : %0d", tests_failed);

        if(tests_failed == 0)
            $display("Overall Result : PASS");
        else
            $display("Overall Result : FAIL");

        $display("========================================");

    end

endtask
  

initial begin

    $dumpfile("uart_system.vcd");
    $dumpvars(0, uart_tb);

    clk = 0;
    rst = 1;

    tx_start = 0;
    data_in = 8'd0;

    tests_run = 0;
    tests_passed = 0;
    tests_failed = 0;

    repeat(5) @(posedge clk);

    rst = 0;

  
print_test_header("Test 1 : Basic Communication");

send_byte(8'h41);
check_byte(8'h41, 20);

send_byte(8'h42);
check_byte(8'h42, 20);

send_byte(8'h43);
check_byte(8'h43, 20);

send_byte(8'h00);
check_byte(8'h00, 20);

send_byte(8'hFF);
check_byte(8'hFF, 20);

send_byte(8'h55);
check_byte(8'h55, 20);

send_byte(8'hAA);
check_byte(8'hAA, 20);
  
  
print_test_header("Test 2 : Busy Signal");

fork
    begin
        send_byte(8'h5A);
    end

    begin
        check_busy();
    end
join
  

print_test_header("Test 3 : Back-to-Back Frames");

send_byte(8'h10);
check_byte(8'h10, 0);

send_byte(8'h20);
check_byte(8'h20, 0);

send_byte(8'h30);
check_byte(8'h30, 0);

send_byte(8'h40);
check_byte(8'h40, 0);

send_byte(8'h50);
check_byte(8'h50, 0);

send_byte(8'h60);
check_byte(8'h60, 0);

send_byte(8'h70);
check_byte(8'h70, 0);

  
print_test_header("Test 4 : Random Stress Test");

for(i = 0; i < 10; i = i + 1)
begin

    random_data = $random;

    send_byte(random_data);

    check_byte(random_data, 0);

end

    #100;

    print_summary();

    $finish;

end
endmodule
