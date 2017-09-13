module LBP(clk, rst, gray_addr, gray_req, gray_ready, gray_data, lbp_addr, lbp_valid, lbp_data, finish);
input clk;
input rst;
output [13:0] gray_addr;
output gray_req;
input gray_ready;
input [7:0] gray_data;
output [13:0] lbp_addr;
output lbp_valid;
output [7:0] lbp_data;
output finish;

parameter STATE_INPUT = 2'd0;
parameter STATE_CAL = 2'd1;
parameter STATE_OUTPUT = 2'd2;
parameter STATE_IDLE = 2'd3;

reg [13:0] gray_addr;
reg gray_req;
reg [13:0] lbp_addr, next_lbp_addr;
reg lbp_valid;
reg [7:0] lbp_data, next_lbp_data;
reg finish;
reg [1:0] state, next_state;
reg [3:0] pixal_filled; 
reg [7:0] pixal_1, pixal_2, pixal_3;
reg [7:0] pixal_4, pixal_c, pixal_5;
reg [7:0] pixal_6, pixal_7, pixal_8;

always @(posedge clk or posedge rst) begin
	if(rst) begin
		state <= STATE_INPUT;
	end
	else begin
		state <= next_state;
	end
end

always @(*) begin
	case(state)
		STATE_INPUT: begin
			if(pixal_filled == 4'd8)
				next_state = STATE_CAL;
			else
				next_state = STATE_INPUT;
		end
		STATE_CAL: begin
			next_state = STATE_OUTPUT;
		end
		STATE_OUTPUT: begin
			next_state = STATE_INPUT;
		end
		STATE_IDLE: begin
			next_state = STATE_IDLE;
		end
		default: next_state = STATE_IDLE;
	endcase
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		gray_req <= 0;
	end
	else begin
		if(gray_ready) begin
			gray_req <= 1;
		end
		else begin
			gray_req <= 0;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pixal_filled <= 4'd0;
	end
	else if(gray_ready) begin
		if(pixal_filled == 4'd8) begin
			if(gray_addr[6] & gray_addr[5] & gray_addr[4] & gray_addr[3] & gray_addr[2] & gray_addr[1] & gray_addr[0]) begin
				pixal_filled <= 4'd0;
			end
			else begin
				pixal_filled <= 4'd6;
			end
		end
		else begin
			pixal_filled <= pixal_filled + 4'd1;
		end
	end
	else begin
		pixal_filled <= pixal_filled;
	end
end
 
always @(posedge clk or posedge rst) begin
	if(rst) begin
		gray_addr <= 14'd129;
	end
	else if(gray_ready) begin
		if(pixal_filled == 4'd0) begin
			if(gray_addr[6] & gray_addr[5] & gray_addr[4] & gray_addr[3] & gray_addr[2] & gray_addr[1] & gray_addr[0]) begin
				gray_addr <= gray_addr - 14'd127;
			end
			else begin
				gray_addr <= gray_addr - 14'd129;
			end
		end
		else if(pixal_filled == 4'd1) begin
			gray_addr <= gray_addr + 14'd256;
		end
		else if(pixal_filled == 4'd2) begin
			gray_addr <= gray_addr - 14'd128;
		end
		else if(pixal_filled == 4'd3) begin
			gray_addr <= gray_addr - 14'd127;
		end
		else if(pixal_filled == 4'd4) begin
			gray_addr <= gray_addr + 14'd256;
		end
		else if(pixal_filled == 4'd5) begin
			gray_addr <= gray_addr - 14'd128;
		end
		else if(pixal_filled == 4'd6) begin
			gray_addr <= gray_addr - 14'd127;
		end
		else if(pixal_filled == 4'd7) begin
			gray_addr <= gray_addr + 14'd256;
		end
		else if(pixal_filled == 4'd8) begin
			gray_addr <= gray_addr - 14'd128;
		end
	end
	else begin
		gray_addr <= gray_addr;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		lbp_data <= 8'd0;
	end
	else begin
		lbp_data <= next_lbp_data;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		lbp_addr <= 14'd129;
	end
	else begin
		lbp_addr <= next_lbp_addr;
	end
end

always @(*) begin
	if(lbp_valid) begin
		if(lbp_addr[6] & lbp_addr[5] & lbp_addr[4] & lbp_addr[3] & lbp_addr[2] & lbp_addr[1]) begin
			next_lbp_addr = lbp_addr + 14'd3;
		end
		else begin
			next_lbp_addr = lbp_addr + 14'd1;
		end
	end
	else begin
		next_lbp_addr = lbp_addr;
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		lbp_valid <= 1'b0;
	end
	else begin
		if(state == STATE_OUTPUT) begin
			lbp_valid <= 1'b1;
		end
		else begin
			lbp_valid <= 1'b0;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		finish <= 1'b0;
	end
	else begin
		if(lbp_addr == 14'd16254) begin
			finish <= 1'b1;
		end
		else begin
			finish <= 1'b0;
		end
	end
end

always @(posedge clk or posedge rst) begin
	if(rst) begin
		pixal_1 <= 8'd0;
		pixal_2 <= 8'd0;
		pixal_3 <= 8'd0;
		pixal_4 <= 8'd0;
		pixal_c <= 8'd0;
		pixal_5 <= 8'd0;
		pixal_6 <= 8'd0;
		pixal_7 <= 8'd0;
		pixal_8 <= 8'd0;
	end
	else begin
		pixal_1 <= pixal_6;
		pixal_2 <= pixal_7;
		pixal_3 <= pixal_8;
		pixal_4 <= pixal_2;
		pixal_c <= pixal_3;
		pixal_5 <= gray_data;
		pixal_6 <= pixal_4;
		pixal_7 <= pixal_c;
		pixal_8 <= pixal_5;		
	end
end

always @(*) begin
	if(pixal_1 < pixal_c) begin
		next_lbp_data[0] = 0;
	end
	else begin
		next_lbp_data[0] = 1;
	end
	if(pixal_2 < pixal_c) begin
		next_lbp_data[1] = 0;
	end
	else begin
		next_lbp_data[1] = 1;
	end
	if(pixal_3 < pixal_c) begin
		next_lbp_data[2] = 0;
	end
	else begin
		next_lbp_data[2] = 1;
	end
	if(pixal_4 < pixal_c) begin
		next_lbp_data[3] = 0;
	end
	else begin
		next_lbp_data[3] = 1;
	end
	if(pixal_5 < pixal_c) begin
		next_lbp_data[4] = 0;
	end
	else begin
		next_lbp_data[4] = 1;
	end
	if(pixal_6 < pixal_c) begin
		next_lbp_data[5] = 0;
	end
	else begin
		next_lbp_data[5] = 1;
	end
	if(pixal_7 < pixal_c) begin
		next_lbp_data[6] = 0;
	end
	else begin
		next_lbp_data[6] = 1;
	end
	if(pixal_8 < pixal_c) begin
		next_lbp_data[7] = 0;
	end
	else begin
		next_lbp_data[7] = 1;
	end
end
endmodule