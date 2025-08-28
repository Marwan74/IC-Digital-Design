module DSP_tb ();
reg [17:0] A,B,D,BCIN;   
reg [47:0] C,PCIN;
reg [7:0] OPMODE;
reg CLK,CARRYIN;
reg CEA,CEB,CEC,CED,CEM,CEP,CEOPMODE,CECARRYIN;
reg RSTA,RSTB,RSTC,RSTD,RSTP,RSTM,RSTCARRYIN,RSTOPMODE;

wire  CARRYOUT,CARRYOUTF;
wire  [47:0] P,PCOUT;
wire  [17:0] BCOUT;
wire  [35:0] M;

dsp DUT(.*);
initial begin
  CLK =0;
  forever
#1 CLK = ~ CLK;
end

integer i = 0;

initial begin
  // reset check 
  RSTA = 1'b1; RSTB = 1'b1; RSTM = 1'b1; RSTP = 1'b1; RSTC = 1'b1; RSTD = 1'b1; RSTCARRYIN = 1'b1; RSTOPMODE = 1'b1;
  CEA = 1'b1; CEB = 1'b1; CEM = 1'b1; CEP = 1'b1; CEC = 1'b1; CED = 1'b1; CECARRYIN = 1'b1; CEOPMODE = 1'b1;
  PCIN = 48'b1; BCIN = 18'b1; OPMODE = 8'b1; CARRYIN = 1'b1;
  A = 18'b1; B = 18'b1; D = 18'b1; C = 48'b1;
  @ (negedge CLK)
  RSTA = 1'b0; RSTB = 1'b0; RSTM = 1'b0; RSTP = 1'b0; RSTC = 1'b0; RSTD = 1'b0; RSTCARRYIN = 1'b0; RSTOPMODE = 1'b0;
  if ((BCOUT !== 0) || (PCOUT !== 0) || (P !== 0) || (M !== 0) || (CARRYOUT !== 0) || (CARRYOUTF !== 0))
    begin
      $display ("Error - Incorrect output");
      $stop;
    end
  // opmode =  8'b00000001 
  A = 18'd5; B = 18'd3; C = 18'd10; D = 18'd4;
  OPMODE = 8'b00000001; 
  repeat (3) @ (negedge CLK);
  if ((PCOUT !== (B * A)) || (P !== (B * A)) || (M !== (B * A)) || (CARRYOUT !== 0) || (CARRYOUTF !== 0) || (BCOUT !== B))
    begin
      $display ("Error - Incorrect output");
      $stop;
    end
  // opmode = 8'b00000100
  OPMODE = 8'b00000100;
  repeat (3) @(negedge CLK);
  if ((PCOUT !== PCIN) || (P !== PCIN) || (M !== (B * A)) || (CARRYOUT !== 0) || (CARRYOUTF !== 0) || (BCOUT !== B))
    begin
      $display ("Error - Incorrect output");
      $stop;
    end
    // OPMODE = 8'b00001000
    A = 18'd12; B = 18'd5; C = 18'd5; D = 18'd7;
    OPMODE = 8'b00001000;
    repeat (3) @(negedge CLK);
    if ((PCOUT !== P) || (P !== P) || (M !== (B * A)) || (CARRYOUT !== 0) || (CARRYOUTF !== 0) || (BCOUT !== B))
    begin
      $display ("Error - Incorrect output");
      $stop;
    end
    // OPMODE = 8'b00010000
    OPMODE = 8'b00010000;
    repeat (3) @(negedge CLK);
    if ((PCOUT !== 0) || (P !== 0) || (M !== ((B + D)*A)) || (CARRYOUT !== 0) || (CARRYOUTF !== 0) || (BCOUT !== (B + D)))
    begin
      $display ("Error - Incorrect output");
      $stop;
    end
    // OPMODE = 8'b11110101
    A = 18'd10; B = 18'd10; C = 18'd5; D = 18'd20; PCIN = 48'd200;
    OPMODE = 8'b11110101;
    repeat (4) @(negedge CLK);
    if ((P !== (PCIN-(((D - B) * A) + OPMODE[5]))) || (PCOUT !== P) || (M !== ((D - B) * A)) || (CARRYOUT !== 0) || (CARRYOUTF !== 0) || (BCOUT !== (D - B)))
    begin
      $display ("Error - Incorrect output");
      $stop;
    end

    // OPMODE = 8'b11111111
    A = 18'd10; B = 18'd10; C = 18'd300; D = 18'd20; PCIN = 48'd200;
    OPMODE = 8'b11111111;
    repeat (4) @(negedge CLK);
    if ((P !== (C - ( {D[11 : 0], A, B}+ OPMODE[5]))) || (PCOUT !== P) || (M !== ((D - B) * A)) || (BCOUT !== (D - B)))
    begin
      $display ("Error - Incorrect output");
      $stop;
    end
    $stop;
end
initial begin
  $monitor ("%t :OPMODE = %0d , A = %0d , B = %0d , C = %0d , D = %0d , P = %0d , 
                 PCOUT = %0d , M = %0d , BCOUT = %0d , CARRYOUT = %0d , CARRYOUTF = %0d",
                  $time, OPMODE, A, B, C, D, P , PCOUT, M, BCOUT, CARRYOUT, CARRYOUTF);
end
endmodule //DSP_tb