`timescale 1ps / 1ps

//========================================================================================================================
//                                                     Description
//========================================================================================================================
/*

Engineer   : HammerMeow
Date       : 07.07.2025 | 23:17

Description: lorem ipsum

*/
//========================================================================================================================

module test_module_tb;

//========================================================================================================================
//                                                  Parameters of UUT
//========================================================================================================================

parameter DATA_W = 8;

//========================================================================================================================
//                                                        Inputs
//========================================================================================================================

reg                     clk_in;
reg                     reset_in;

reg [(DATA_W-1):0]      data_in;

wire [(DATA_W-1):0]     out_0;
wire                    out_valid_0;
wire [(DATA_W-1):0]     out_1;
wire                    out_valid_1;
wire [(DATA_W-1):0]     out_2;
wire                    out_valid_2;
wire [(DATA_W-1):0]     out_3;
wire                    out_valid_3;

//========================================================================================================================
//                                                       Outputs
//========================================================================================================================



//========================================================================================================================
//                                              Parameters for simulation
//========================================================================================================================

parameter PERIOD = 10000;
parameter DATA_FROM_EXAMPLE = 6;

//========================================================================================================================
//                                               Vars and genvar signals
//========================================================================================================================

integer en_display = 0;
integer cnt = 0;

reg [7:0] shift_reg [3:0];
reg [7:0] shift_reg_delay [3:0];
reg flag_faild = 0;

integer i, j, k;
integer cycle;
integer get_num_repetitions;
integer found_idx = 0;
integer faild_cnt = 0;

reg [(DATA_W-1):0] out_0_v;
reg [(DATA_W-1):0] out_1_v;
reg [(DATA_W-1):0] out_2_v;
reg [(DATA_W-1):0] out_3_v;

//========================================================================================================================
//                                                       Includes
//========================================================================================================================



//========================================================================================================================
//                                                         UUT
//========================================================================================================================

test_module
#(
    .DATA_W(DATA_W)
) uut (
    .clk_in(clk_in),
    .reset_in(reset_in),
    .data_in(data_in),
    .out_0(out_0),
    .out_valid_0(out_valid_0),
    .out_1(out_1),
    .out_valid_1(out_valid_1),
    .out_2(out_2),
    .out_valid_2(out_valid_2),
    .out_3(out_3),
    .out_valid_3(out_valid_3)
);

//========================================================================================================================
//                                                       Initial
//========================================================================================================================

initial begin
    clk_in   = 0;
    data_in  = 0;
    reset_in = 1;

    for (j = 0; j < 4; j = j + 1) begin
        shift_reg[j] = 8'hxx;
        shift_reg_delay[j] = 8'hxx;
    end

    #(PERIOD*15);

    // #(PERIOD/2);
    // #(PERIOD/2);
    
    repeat(1) @(posedge clk_in);
    reset_in <= 0;

    // user code
    if (DATA_FROM_EXAMPLE == 1) begin
        en_display = 1;
        send_value(8'd1);
        send_value(8'd2);
        send_value(8'd1);
        send_value(8'd2);
        send_value(8'd1);
        send_value(8'd2);
        send_value(8'd1);
        en_display = 0;
    end

    if (DATA_FROM_EXAMPLE == 2) begin
        en_display = 1;
        send_value(8'd1);
        send_value(8'd2);
        send_value(8'd3);
        send_value(8'd4);
        send_value(8'd3);
        send_value(8'd2);
        send_value(8'd3);
        send_value(8'd4);
        send_value(8'd3);
        send_value(8'd4);
        en_display = 0;
    end

    if (DATA_FROM_EXAMPLE == 3) begin
        en_display = 1;
        send_value(8'd1);
        send_value(8'd1);
        send_value(8'd1);
        send_value(8'd1);
        send_value(8'd1);
        send_value(8'd1);
        send_value(8'd1);
        en_display = 0;
    end

    if (DATA_FROM_EXAMPLE == 4) begin
        en_display = 1;
        send_value(8'd0);
        send_value(8'd0);
        send_value(8'd0);
        send_value(8'd0);
        send_value(8'd0);
        send_value(8'd0);
        send_value(8'd0);
        en_display = 0;
    end

    if (DATA_FROM_EXAMPLE == 5) begin
        en_display = 1;
        send_value(8'd0);
        send_value(8'd1);
        send_value(8'd0);
        send_value(8'd0);
        send_value(8'd0);
        send_value(8'd6);
        send_value(8'd1);
        send_value(8'd0);
        send_value(8'd0);
        en_display = 0;
    end

    if (DATA_FROM_EXAMPLE == 6) begin
        get_num_repetitions = 0;

        for (cycle = 0; cycle < 25; cycle = cycle + 1) begin
            for (i = 0; i < 100000; i = i + 1) begin
                if (i == 0) begin
                    data_in <= 0;
                end else begin
                    data_in <= $random % 256;
                end

                if (i == 3) begin
                    en_display = 1;
                end

                found_idx = -1;
                for (k = 0; k < 4; k = k + 1)
                    if (shift_reg[k] == data_in)
                        found_idx = k;

                if (found_idx != -1) begin
                    get_num_repetitions = get_num_repetitions + 1;

                    for (k = found_idx; k > 0; k = k - 1)
                        shift_reg[k] = shift_reg[k-1];
                end else begin
                    for (k = 3; k > 0; k = k - 1)
                        shift_reg[k] = shift_reg[k-1];
                end

                shift_reg[0] = data_in;

                repeat(1) @(posedge clk_in);
                shift_reg_delay[0] <= shift_reg[0];
                shift_reg_delay[1] <= shift_reg[1];
                shift_reg_delay[2] <= shift_reg[2];
                shift_reg_delay[3] <= shift_reg[3];
            end

            repeat(1) @(posedge clk_in);
            reset_in <= 1;
            data_in <= 0;

            for (j = 0; j < 4; j = j + 1) begin
                shift_reg[j] = 8'hxx;
                shift_reg_delay[j] = 8'hxx;
            end

            repeat(100) @(posedge clk_in);
            reset_in <= 0;
        end
    end
end

//========================================================================================================================
//                                                    Support logic
//========================================================================================================================

always @(posedge clk_in) begin
    if (DATA_FROM_EXAMPLE == 6) begin
        if ((en_display == 1)&(~reset_in)&(out_valid_0|out_valid_1|out_valid_2|out_valid_3)) begin
            out_0_v = out_valid_0?out_0:8'hxx;
            out_1_v = out_valid_1?out_1:8'hxx;
            out_2_v = out_valid_2?out_2:8'hxx;
            out_3_v = out_valid_3?out_3:8'hxx;

            flag_faild = (out_0_v !== shift_reg_delay[0])|(out_1_v !== shift_reg_delay[1])|(out_2_v !== shift_reg_delay[2])|(out_3_v !== shift_reg_delay[3]);

            cnt = cnt + 1;

            if (flag_faild) begin
                $display("cnt: %d", cnt);
                $display("Shift register: %d %d %d %d", shift_reg_delay[0], shift_reg_delay[1], shift_reg_delay[2], shift_reg_delay[3]);
                $display("Data out      : %d %d %d %d", out_0_v, out_1_v, out_2_v, out_3_v);

                faild_cnt = faild_cnt + 1;

                if (faild_cnt == 10) begin
                    $display("get_num_repetitions: %d", get_num_repetitions);
                    $stop();
                end
            end
        end
    end else begin
        if (en_display == 1) begin
            $display("num %d: out_0 = %h | out_1 = %h | out_2 = %h | out_3 = %h;", cnt, out_0, out_1, out_2, out_3);
            cnt = cnt + 1;
        end
    end
end

always #(PERIOD/2) clk_in = ~clk_in;

//========================================================================================================================
//                                                     Local tasks
//========================================================================================================================

task send_value(input [7:0] value);
    begin
        data_in = value;
        repeat(1) @(posedge clk_in);
    end
endtask

endmodule
