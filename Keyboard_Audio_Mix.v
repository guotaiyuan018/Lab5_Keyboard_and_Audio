module Keyboard_Audio_Mix(
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input wire clk,
    input wire rst_n,
    output pmod_1,
    output pmod_2,
    output pmod_4
    );

    parameter [8:0] KEY_CODES_w = 9'b0_0001_1101;
    parameter [8:0] KEY_CODES_s = 9'b0_0001_1011;
    parameter [8:0] KEY_CODES_r = 9'b0_0010_1101;
    parameter [8:0] KEY_CODES_enter = 9'b0_0101_1010;
    
    reg [9:0] last_key;

    reg rst = 1'b0;
    reg dir = 1'b1;
    reg [1:0] speed = 2'd1;
    reg next_dir = 1'b1;
    reg [1:0] next_speed = 2'd1;
    wire one_pulse_rst_n;
    
    wire [511:0] key_down;
    wire [8:0] last_change;
    wire been_ready;

    OnePulse op0(
        .clock(clk),
        .signal(rst_n),
        .signal_single_pulse(one_pulse_rst_n)
    );

    Music_Box_TOP mbt0 (
        .clk(clk),
        .reset(rst),
        .dir(dir),
        .speed(speed),
        .pmod_1(pmod_1),
        .pmod_2(pmod_2),
        .pmod_4(pmod_4)
    );
        
    KeyboardDecoder key_de (
        .key_down(key_down),
        .last_change(last_change),
        .key_valid(been_ready),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(one_pulse_rst_n),
        .clk(clk)
    );

    always @ (posedge clk) begin
        if (one_pulse_rst_n ) begin
            dir <= 1'b1;
            speed <= 2'b01;
        end
        else if (rst) begin
            dir <= 1'b1;
            speed <= 2'b01;
        end
        else begin
            dir <= next_dir;
            speed <= next_speed;
        end
    end

    always @ (*) begin
        next_speed = speed;
        next_dir = dir;
        rst = 1'b0;
        if (been_ready && key_down[last_change] == 1'b1) begin
            case (last_change)
                KEY_CODES_w: begin
                    rst = 1'b0;
                    if(dir ==1'b0) next_dir = 1'b1;
                    else next_dir = next_dir;
                    next_speed = next_speed;
                end
                KEY_CODES_s:begin
                    rst = 1'b0;
                    if(dir ==1'b1) next_dir = 1'b0;
                    else next_dir = next_dir;
                    next_speed = next_speed;
                end
                KEY_CODES_r:begin
                    rst = 1'b0;
                    if (speed == 2'd1) next_speed = 2'd2;
                    else next_speed = 2'd1;
                    next_dir = next_dir;
                end
                KEY_CODES_enter:begin
                    rst = 1'b1;
                    next_speed = 2'd1;
                    next_dir = 1'b1;
                end
                default: begin
                    next_speed = next_speed;
                    next_dir = next_dir;
                end
            endcase
        end else begin
            rst = rst;
            next_speed = next_speed;
            next_dir = next_dir;
        end;
    end
    
endmodule
