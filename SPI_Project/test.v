module spii_test();
  reg clk,rst_n,SS_n,MOSI;
  wire MISO;
  Spi_Wrapper dut (clk,rst_n,MISO,MOSI,SS_n);

  initial begin
    clk = 0;
    forever begin
        #1 clk = ~clk;
    end
  end

  initial begin
    $readmemh("mem.dat",dut.ram.mem);
    rst_n = 0;
    MOSI = 0;
    SS_n = 1;
    @(negedge clk);
    rst_n = 1;
    SS_n = 0;
    // write address
    @(negedge clk);
    MOSI = 0;
    @(negedge clk);
    MOSI = 0;
    @(negedge clk);
    MOSI = 0;
    @(negedge clk);
    repeat(8) begin
      MOSI = $random;
      @(negedge clk);
    end
    SS_n = 1;
    
    // write data 
    @(negedge clk);
    SS_n = 0;
    @(negedge clk)
    MOSI = 0;
    @(negedge clk);
    MOSI = 0;
    @(negedge clk);
    MOSI = 1;
    @(negedge clk);
    repeat(8) begin
      MOSI = $random;
      @(negedge clk);
    end
    SS_n = 1;

    // read address 
    @(negedge clk);
    SS_n = 0;
    @(negedge clk)
    MOSI = 1;
    @(negedge clk);
    MOSI = 1;
    @(negedge clk);
    MOSI = 0;
    @(negedge clk);
    repeat(8) begin
      MOSI = $random;
      @(negedge clk);
    end
    SS_n = 1;

    // read data 
    @(negedge clk);
    SS_n = 0;
    @(negedge clk)
    MOSI = 1;
    @(negedge clk);
    MOSI = 1;
    @(negedge clk);
    MOSI = 1;
    @(negedge clk);
    repeat(8) begin
      MOSI = $random;
      @(negedge clk);
    end
    repeat(8) @(negedge clk);
    SS_n = 1;
    @(negedge clk);
  $stop;
  end
endmodule