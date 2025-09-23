// =================================================================================
// Module: Receiver
// Description: Receives serial data according to the UART protocol and converts
//              it back to parallel data.
// =================================================================================
module Receiver(clk,rst,rx_data,s_tick,rx_done_tick,dout,framing_error);
 // --- Parameters ---
 parameter DATA_BIT = 8 ;      // Number of data bits to be received
  // State definitions for the Finite State Machine (FSM)
 parameter IDLE = 2'b00 ;      // Idle state, waiting for a start bit
 parameter START = 2'b01 ;     // State for verifying the start bit
 parameter DATA = 2'b10 ;      // State for receiving data bits
 parameter STOP = 2'b11 ;      // State for checking the stop bit

 // --- Ports ---
 input clk,rst,rx_data,s_tick;               // Inputs: Clock, Reset, Serial Data In, Sample Tick
 output reg rx_done_tick,framing_error;      // Outputs: Receive Done pulse, Framing Error flag
 output reg [DATA_BIT-1:0] dout;             // Output for the received parallel data

 // --- Internal Registers ---
 (* fsm_encoding = "one_hot" *)
 reg [1:0] cs,ns;          // Registers for Current State and Next State
 reg [3:0] sample_counter; // 4-bit counter for oversampling ticks (0-15)
 reg [3:0] Bit_counter;    // 4-bit counter for data bits
 reg [7:0] rx_shift_reg;   // 8-bit shift register to assemble the received data


 // --------------------------------------------------
 // BLOCK 1: State Register - Updates the current state on each clock edge
 // --------------------------------------------------
 always @(posedge clk or posedge rst) begin
  if (rst) begin
   cs <= IDLE; // On reset, start from the IDLE state
  end
  else begin
   cs <= ns;   // Otherwise, go to the determined next state
  end
 end

 // --------------------------------------------------
 // BLOCK 2: Next-State Logic - Determines the next state based on current state and inputs
 // --------------------------------------------------
 always @(*) begin
  case (cs)
  IDLE : begin
      // If a start condition is detected (line goes low), go to START
   if (~rx_data) begin
    ns = START;
   end
   else begin
    ns = IDLE;
   end
  end

  START : begin
      // After half a bit period (8 ticks), transition to DATA
   if (s_tick && sample_counter== 7) begin
    ns = DATA;
   end
   else begin
    ns = START;
   end
  end

  DATA : begin
      // After the last data bit is sampled, transition to STOP
   if (Bit_counter == (DATA_BIT-1) && sample_counter == 15 && s_tick) begin
    ns = STOP;
   end
   else begin
    ns = DATA;
   end
  end

  STOP : begin
      // After one full bit period, return to IDLE
   if(s_tick && sample_counter == 15) begin
    ns = IDLE;
   end
   else begin
    ns = STOP;
   end
  end
 endcase 
 end
 
 // --------------------------------------------------
 // BLOCK 3: Output Logic - Sets outputs and updates registers based on the current state
 // --------------------------------------------------
 always @(posedge clk or posedge rst) begin
  if(rst) begin
      // Reset all values
   sample_counter <= 4'd0;
   Bit_counter <= 3'd0;
   rx_shift_reg <= 8'd0;
   rx_done_tick <= 1'b0;
   dout <= 0;
   framing_error <= 1'b0;
  end
  else begin
   rx_done_tick <= 1'b0; // By default, the receive done pulse is low
   framing_error<= 1'b0; // By default, the framing error flag is low

      // The sample counter increments on every s_tick when not in reset
   if (s_tick) sample_counter <= sample_counter + 1;

   case (cs)
    IDLE : begin
          // Continuously reset sample_counter while in IDLE
     sample_counter <= 0;
          // When a start condition is detected, reset the data bit counter
     if(~rx_data) begin
      Bit_counter <= 0;
     end
    end

    START : begin
          // At the halfway point of the start bit
     if(s_tick && sample_counter == 7) begin
            // Verify that the line is still low
      if(~rx_data) begin
              // If it is, reset the sample counter for the upcoming DATA state
       sample_counter <= 0;
      end
     end
    end

    DATA : begin
          // At the end of a full bit period (sampling point)
     if (s_tick && sample_counter == 15) begin
      sample_counter <= 0; // reset for the next bit
            // Guard condition to sample only the required number of data bits
      if(Bit_counter < DATA_BIT) begin
              // Shift the new received bit in from the MSB side
       rx_shift_reg <= {rx_data,rx_shift_reg[7:1]};
              // Increment the data bit counter
       Bit_counter <= Bit_counter + 1;
      end
     end
    end

    STOP : begin
          // At the end of the stop bit period
     if(s_tick && sample_counter == 15) begin
            // Check for a valid stop bit (line should be high)
      if(rx_data == 1'b1) begin
              // If valid, output the assembled data and pulse the done tick
       dout <= rx_shift_reg;
       rx_done_tick <= 1'b1;
      end
      else begin
              // If invalid, signal a framing error
       framing_error <= 1'b1;
      end
     end
    end
   endcase
  end
 end
endmodule