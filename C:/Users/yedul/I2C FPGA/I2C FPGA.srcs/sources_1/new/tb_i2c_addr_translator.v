`timescale 1us/1ns

// -----------------------------------------------------------------------------
// Simple testbench for I2C Address Translator
// Generates a fake I2C transaction to observe translation behavior.
// -----------------------------------------------------------------------------

module tb_i2c_addr_translator;

    reg clk = 0;
    reg rst_n = 0;
    reg sda_in = 1;
    reg scl_in = 1;
    wire sda_out;
    wire sda_to_dev, scl_to_dev;
    reg  sda_from_dev = 1;

    i2c_addr_translator uut (
        .clk(clk),
        .rst_n(rst_n),
        .sda_in(sda_in),
        .scl_in(scl_in),
        .sda_out(sda_out),
        .sda_to_dev(sda_to_dev),
        .scl_to_dev(scl_to_dev),
        .sda_from_dev(sda_from_dev)
    );

    // Simple clock
    always #0.5 clk = ~clk;

    initial begin
        $dumpfile("i2c_wave.vcd");
        $dumpvars(0, tb_i2c_addr_translator);

        rst_n = 0;
        #5 rst_n = 1;

        // Fake start condition
        #2 sda_in = 0; scl_in = 1;

        // Send 7-bit address + RW bit
        repeat (8) begin
            #1 scl_in = 0;
            sda_in = $random;
            #1 scl_in = 1;
        end

        // Stop condition
        #5 scl_in = 1; sda_in = 1;

        #10 $finish;
    end

endmodule
