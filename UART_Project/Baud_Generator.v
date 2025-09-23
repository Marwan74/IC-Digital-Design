module Baud_Generator(clk,rst,sample_tick);
 parameter CLK_FREQ = 50000000 ;
 parameter BAUD_RATE = 19200 ;
 parameter OVERSAMPLING_FACTOR = 16 ;

 parameter SAMPLE_TICK_DIVISOR = CLK_FREQ / (BAUD_RATE * OVERSAMPLING_FACTOR);

 input clk,rst;
 output reg sample_tick;

 reg [8:0] sample_counter;

 always @(posedge clk or posedge rst) begin
    if (rst) begin
      sample_tick <= 0;
      sample_counter <= 0;
    end
    else begin
      // sample tick Generator  (receiver)
      if (sample_counter == SAMPLE_TICK_DIVISOR -1) begin
        sample_counter <= 1'b0;
        sample_tick <= 1'b1;
      end
      else begin
        sample_counter <= sample_counter + 1;
        sample_tick <= 1'b0;
      end
    end
 end
endmodule