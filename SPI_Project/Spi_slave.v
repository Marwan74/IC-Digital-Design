module spi_slave(clk,rst_n,SS_n,MOSI,tx_valid,tx_data,MISO,rx_valid,rx_data);

// parameters declaration
 parameter IDLE = 3'b000 ;
 parameter CHK_CMD = 3'b001 ;
 parameter WRITE = 3'b010 ;
 parameter READ_ADD = 3'b011 ;
 parameter READ_DATA = 3'b100 ;
// signal declaration
 input clk,rst_n,MOSI,SS_n,tx_valid;
 input [7:0] tx_data;
 output reg MISO;
 output rx_valid;
 output reg [9:0] rx_data;

 // wire declaration

 (* fsm_encoding = "gray" *)
 reg [2:0] cs,ns;
 reg [3:0] counter_1; // counter for serial in parallel out 
 reg [3:0] counter_2; // counter for parallel in serial out
 reg ckh_read_address; // to check read address or read data

 // state memory 
 always @(posedge clk) begin
    if(!rst_n) begin
      cs <= IDLE;
    end
    else begin
      cs <= ns;
    end
 end

 // next state logic 
 always @(*) begin
    case (cs)
        IDLE : begin
          if(SS_n == 0) 
           ns = CHK_CMD;
          else 
           ns = IDLE; 
        end

        CHK_CMD : begin
          if (SS_n == 0 && MOSI == 0) begin
            ns = WRITE;
          end
          else if (SS_n == 0 && MOSI == 1 && ckh_read_address == 0) begin
            ns = READ_ADD;
          end
          else if (SS_n == 0 && MOSI == 1 && ckh_read_address == 1) begin
            ns = READ_DATA;
          end
          else begin
            ns = IDLE;
          end
        end

        WRITE : begin
          if (SS_n) begin
            ns = IDLE;
          end
          else begin
            ns = WRITE;
          end
        end

        READ_ADD : begin
          if (SS_n) begin
            ns = IDLE;
          end
          else begin
            ns = READ_ADD;
          end
        end

        READ_DATA : begin
          if (SS_n) begin
            ns = IDLE;
          end
          else begin
            ns = READ_DATA;
          end
        end

        default : ns = IDLE;
    endcase
 end

 // output logic

always @(posedge clk) begin
    if (!rst_n) begin
      rx_data <= 0;
      counter_1 <= 0;
      counter_2 <= 4'b1000;
      MISO <= 0;
      ckh_read_address <= 0;
    end
    else begin
    case (cs)
        IDLE : begin
          rx_data <= 0;
          counter_1 <= 0;
          counter_2 <= 4'b1000;
          MISO <= 0;
        end

        CHK_CMD : begin
          rx_data <= 0;
          counter_1 <= 0;
          counter_2 <= 4'b1000;
          MISO <= 0;
        end

        WRITE : begin
          if (counter_1 < 10) begin
            rx_data[9-counter_1] <= MOSI;
            counter_1 <= counter_1 + 1;
          end
        end

        READ_ADD : begin
          if (counter_1 < 10) begin
            ckh_read_address <= 1;
            rx_data[9-counter_1] <= MOSI;
            counter_1 <= counter_1 + 1;
          end
        end

        READ_DATA : begin
          if (counter_1 < 10) begin
            rx_data[9-counter_1] <= MOSI;
            counter_1 <= counter_1 + 1;
          end
          if (tx_valid) begin
            if(counter_2 > 0) begin
              MISO <= tx_data[counter_2-1];
              counter_2 <= counter_2 - 1;
              ckh_read_address <= 0;
            end
            else begin
              MISO <= 0;
            end
          end
        end
        default : begin
          counter_1 <= 0;
          counter_2 <= 8;
          rx_data <= 0;
          MISO <= 0;
        end
    endcase
    end
end

assign rx_valid = ((cs == WRITE || cs == READ_DATA || cs == READ_ADD) && counter_1 == 10) ? 1 : 0;

endmodule