module i2c_addr_translator(
    input  wire clk,          // FPGA system clock
    input  wire rst_n,        // Asynchronous active-low reset

    // Upstream I2C (master side)
    input  wire sda_in,
    input  wire scl_in,
    output reg  sda_out,

    // Downstream I2C (device side)
    output reg  sda_to_dev,
    output reg  scl_to_dev,
    input  wire sda_from_dev
);

    // -------------------------------------------------------------------------
    // Parameters
    // -------------------------------------------------------------------------
    parameter [6:0] VISIBLE_ADDR = 7'h54;  // Address visible to main I2C master
    parameter [6:0] ACTUAL_ADDR  = 7'h60;  // Real address of device

    // -------------------------------------------------------------------------
    // Internal Registers and Signals
    // -------------------------------------------------------------------------
    reg [7:0] shift_reg;
    reg [2:0] bit_counter;
    reg start_flag, stop_flag;

    // FSM state encoding
    reg [2:0] curr_state, next_state;
    localparam IDLE        = 3'd0,
               ADDR        = 3'd1,
               CHECK       = 3'd2,
               PASS_WRITE  = 3'd3,
               PASS_READ   = 3'd4,
               WAIT_STOP   = 3'd5;

    // -------------------------------------------------------------------------
    // START and STOP condition detection
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            start_flag <= 1'b0;
            stop_flag  <= 1'b0;
        end else begin
            // Simplified detection logic
            if (scl_in && (sda_in == 1'b0))
                start_flag <= 1'b1;
            else
                start_flag <= 1'b0;

            if (scl_in && (sda_in == 1'b1))
                stop_flag <= 1'b1;
            else
                stop_flag <= 1'b0;
        end
    end

    // -------------------------------------------------------------------------
    // FSM state transition
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end

    always @(*) begin
        next_state = curr_state;
        case (curr_state)
            IDLE:
                if (start_flag)
                    next_state = ADDR;

            ADDR:
                if (bit_counter == 3'd7)
                    next_state = CHECK;

            CHECK:
                if (shift_reg[7:1] == VISIBLE_ADDR)
                    next_state = PASS_WRITE;
                else
                    next_state = WAIT_STOP;

            PASS_WRITE:
                if (stop_flag)
                    next_state = IDLE;

            PASS_READ:
                if (stop_flag)
                    next_state = IDLE;

            WAIT_STOP:
                if (stop_flag)
                    next_state = IDLE;

            default:
                next_state = IDLE;
        endcase
    end

    // -------------------------------------------------------------------------
    // Address Shift and Replacement
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg   <= 8'h00;
            bit_counter <= 3'd0;
        end else begin
            case (curr_state)
                ADDR: begin
                    shift_reg   <= {shift_reg[6:0], sda_in};
                    bit_counter <= bit_counter + 1'b1;
                end

                CHECK: begin
                    if (shift_reg[7:1] == VISIBLE_ADDR)
                        shift_reg[7:1] <= ACTUAL_ADDR;
                end

                default: begin
                    bit_counter <= 3'd0;
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Forward I2C Lines (simplified simulation version)
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sda_out    <= 1'b1;
            sda_to_dev <= 1'b1;
            scl_to_dev <= 1'b1;
        end else begin
            scl_to_dev <= scl_in; // Forward clock directly

            case (curr_state)
                PASS_WRITE: begin
                    sda_to_dev <= sda_in;
                    sda_out    <= 1'b1; // release bus
                end

                PASS_READ: begin
                    sda_out    <= sda_from_dev;
                    sda_to_dev <= 1'b1;
                end

                default: begin
                    sda_to_dev <= 1'b1;
                    sda_out    <= 1'b1;
                end
            endcase
        end
    end

endmodule
