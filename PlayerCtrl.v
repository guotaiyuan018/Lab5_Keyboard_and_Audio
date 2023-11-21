//
//
//
//

module PlayerCtrl (
	input clk,
	input reset,
	input dir,
	output reg [7:0] ibeat
);
parameter BEATLEAGTH = 29; // C4~C8(0~28)

always @(posedge clk, posedge reset) begin
	if (reset)	ibeat <= 0;
		
    else if(dir == 1'b1) begin  // ascend
        if(ibeat < BEATLEAGTH)  ibeat <= ibeat + 1;
        else                    ibeat <= ibeat;
    
    end else begin              //descend
		if(ibeat > 1)           ibeat <= ibeat - 1;
        else                    ibeat <= ibeat;
    end
end
endmodule