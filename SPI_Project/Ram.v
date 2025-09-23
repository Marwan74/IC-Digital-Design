module Ram(clk,rst_n,din,rx_valid,dout,tx_valid);

// parmeter and signal declaration
 parameter MEM_DEPTH = 256 ;
 parameter ADDR_SIZE = 8 ;
 input clk,rst_n,rx_valid;
 input [9:0] din;
 output reg tx_valid;
 output reg [7:0] dout;

// wires
 reg [ADDR_SIZE-1:0] mem [MEM_DEPTH-1:0];
 reg [ADDR_SIZE-1:0] addr;

// block logic
 always @(posedge clk) begin
    if (!rst_n) begin
      dout <= 0;
      tx_valid <= 0;
      addr <= 0;
    end
    else begin
        if (rx_valid) begin
          case (din[9:8])
            2'b00 :begin
              addr <= din[7:0];
              tx_valid <= 0;
            end 
            2'b01 : begin
              mem[addr] <= din[7:0];
              tx_valid <= 0;
            end 
            2'b10 : begin
              addr <= din[7:0];
              tx_valid <= 0;
            end  
            2'b11 : begin
              dout <= mem[addr];
              tx_valid <= 1'b1;
            end 
          endcase
        end
    end
 end
endmodule