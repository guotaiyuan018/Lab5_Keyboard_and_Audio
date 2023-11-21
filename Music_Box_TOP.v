// *******************************
// lab_SPEAKER_TOP
//
// ********************************

module Music_Box_TOP (
    input clk,
	input reset,
	input dir,
	input [1:0] speed,
	output pmod_1,
	output pmod_2,
	output pmod_4
);

parameter DUTY_BEST = 10'd512;	//duty cycle=50%

wire BEAT_FREQ = 32'd2 / speed;	//one beat=(0.5*speed)sec
wire [31:0] freq;
wire [7:0] ibeatNum;
wire beatFreq;

assign pmod_2 = 1'd1;	//no gain(6dB)
assign pmod_4 = 1'd1;	//turn-on

    // get speed and dir

//Generate beat speed
PWM_gen btSpeedGen ( .clk(clk), 
					 .reset(reset),
					 .freq(BEAT_FREQ),
					 .duty(DUTY_BEST), 
					 .PWM(beatFreq)
);
	
//manipulate beat
PlayerCtrl playerCtrl_00 ( .clk(beatFreq),
                           .dir(dir),
						   .reset(reset),
						   .ibeat(ibeatNum)
);	
	
//Generate variant freq. of tones
Music music00 ( .ibeatNum(ibeatNum),
				.tone(freq)
);

// Generate particular freq. signal
PWM_gen toneGen ( .clk(clk), 
				  .reset(reset), 
				  .freq(freq),
				  .duty(DUTY_BEST), 
				  .PWM(pmod_1)
);
endmodule