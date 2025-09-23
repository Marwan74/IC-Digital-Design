// =================================================================================
// Module: transmiter
// Description: Transmitter module responsible for converting parallel data (8-bit)
//              to serial data according to the UART protocol.
// =================================================================================
module transmiter(clk,rst,s_tick,tx_data,tx_start,tx_done_stick,tx_out);

 // --- Parameters ---
 parameter DATA_BIT = 8 ;      // Number of data bits to be transmitted
 // State definitions for the Finite State Machine (FSM)
 parameter IDLE = 2'b00 ;      // Idle state, waiting for a new transmission to start
 parameter START = 2'b01 ;     // State for sending the Start Bit
 parameter SHIFT = 2'b10 ;     // State for sending the Data Bits
 parameter DONE = 2'b11 ;      // State for sending the Stop Bit

 // --- Ports ---
 input clk,rst,s_tick,tx_start;          // Inputs: Clock, Reset, Sample Tick, Transmit Start signal
 input [DATA_BIT-1:0] tx_data;           // Parallel data (8-bit) to be transmitted
 output reg tx_out,tx_done_stick;        // Outputs: Serial transmission line, Transmit Done pulse

 // --- Internal Registers ---
 (* fsm_encoding = "one_hot" *)
 reg [1:0] cs,ns;          // Registers for Current State and Next State
 reg [7:0] tx_shift_reg;   // 8-bit shift register to hold the data being sent
 reg [2:0] bit_counter;    // Counter to track the number of data bits sent (0-7)
 reg [3:0] tick_count;     // Counter for sample ticks (s_tick) to time one bit period (0-15)


 // --------------------------------------------------
 // BLOCK 1: State Register - Updates the current state on each clock edge
 // --------------------------------------------------
 always @(posedge clk or posedge rst) begin
  if(rst) begin
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
     // If the start signal is asserted, go to START state
     if(tx_start) begin
       ns = START;
      end
     else begin
       ns = IDLE; // Else, remain in IDLE state
      end
  end

    START : begin
     // After one full bit period (16 ticks), transition to SHIFT state
     if(s_tick && tick_count == 15) begin
       ns = SHIFT;
      end
     else begin
       ns = START;
      end
  end

    SHIFT : begin
     // After the last data bit is sent (when counter is 7), transition to DONE
     if (s_tick && (bit_counter == DATA_BIT-1) && (tick_count == 15)) begin
       ns = DONE;
      end
     else begin
       ns = SHIFT;
      end
  end

    DONE : begin
     // After one full bit period, return to IDLE state
     if(s_tick && tick_count == 15) begin
       ns = IDLE;
      end
     else begin
       ns = DONE;
      end
  end
 endcase 
end

 // --------------------------------------------------
 // BLOCK 3: Output Logic - Sets output values and updates registers based on the current state
 // --------------------------------------------------
 always @(posedge clk or posedge rst) begin
  if (rst) begin
   // Reset all values
   tx_out <= 1'b1;
   tx_done_stick <= 1'b0;
   tx_shift_reg <= 0;
   bit_counter <= 0;
   tick_count <= 0;
  end
  else begin
    // By default, the transmit done pulse is low
    tx_done_stick <= 1'b0;

    // Tick counter: increments continuously as long as not in reset
    if(s_tick) begin
     if(tick_count == 15) begin
       tick_count <= 0; // Resets every 16 ticks
      end
     else begin
      tick_count <= tick_count + 1;
      end
    end

   case (cs)
    IDLE : begin
    // In IDLE state, the transmission line is high
     tx_out <= 1'b1;
    // Reset counters in preparation for a new transmission
    tick_count <= 0;
    if(tx_start) begin
    // When transmission starts, reset the bit counter
     bit_counter <= 0;
    end
  end
    
    START : begin
    // In START state, pull the transmission line low (Start Bit)
    tx_out <= 1'b0;
    // Load data into the shift register during this time
    tx_shift_reg <= tx_data;
  end

    SHIFT : begin
    // In SHIFT state, output the Least Significant Bit (LSB) on the tx line
    tx_out <= tx_shift_reg[0];
    // At the end of each bit period
    if (s_tick && (tick_count == 15)) begin
    // Keep shifting as long as not all bits have been sent
      if(bit_counter < DATA_BIT) begin
       // Shift the register right to prepare the next bit
       tx_shift_reg <= tx_shift_reg >> 1;
      // Increment the bit counter
      bit_counter <= bit_counter + 1;
     end
   end
  end

    DONE : begin
    // In DONE state, pull the transmission line high (Stop Bit)
    tx_out <= 1'b1;
    // At the end of the stop bit period
    if (s_tick && (tick_count == 15)) begin
     // Assert the transmit done signal for one clock cycle
      tx_done_stick <= 1'b1;
    end
  end
endcase
end
end
endmodule