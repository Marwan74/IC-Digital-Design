module dsp (A,B,C,D,PCIN,BCIN,CARRYIN,CLK,OPMODE,CEA,CEB,CEC,CED,CEM,CEP,CEOPMODE,CECARRYIN,RSTA,
            RSTB,RSTC,RSTD,RSTP,RSTM,RSTCARRYIN,RSTOPMODE,BCOUT,PCOUT,M,P,CARRYOUT,CARRYOUTF);
parameter A0REG = 0; // If equal (0) --> No register, else --> Registered 
parameter A1REG = 1; // If equal (0) --> No register, else --> Registered 
parameter B0REG = 0; // If equal (0) --> No register, else --> Registered
parameter B1REG = 1; // If equal (0) --> No register, else --> Registered
parameter CREG =1;   // If equal (0) --> No register, else --> Registered
parameter DREG =1;   // If equal (0) --> No register, else --> Registered
parameter MREG =1;   // If equal (0) --> No register, else --> Registered
parameter PREG =1;   // If equal (0) --> No register, else --> Registered
parameter CARRYINREG =1; // If equal (0) --> No register, else --> Registered
parameter CARRYOUTREG =1; // If equal (0) --> No register, else --> Registered 
parameter OPMODEREG =1;   // If equal (0) --> No register, else --> Registered
parameter CARRYINSEL = "OPMODE5";  // Selects between CARRYIN and opcode[5]
parameter BINPUT = "DIRECT";      // Selects between direct (B) input and cascaded input (BCIN)
parameter RSTTYPE = "SYNC";      // Selects whether all registers have a synchronous or asynchronous reset 

input [17:0] A,B,D,BCIN;   
input [47:0] C,PCIN;
input [7:0] OPMODE;
input CLK,CARRYIN,CEA,CEB,CEC,CED,CEM,CEP,CEOPMODE,CECARRYIN,RSTA,RSTB,RSTC,RSTD,RSTP,RSTM,RSTCARRYIN,RSTOPMODE;

output  CARRYOUT,CARRYOUTF;
output  [47:0] P,PCOUT;
output  [17:0] BCOUT;
output  [35:0] M;

wire [17 : 0] D_OUT, B_OUT, A_OUT;
wire [47 : 0] C_OUT;
wire [7 : 0] OPMODE_OUT;
wire [17 : 0] b_out, PRE_ADD_SUB_OUT, SEL1, b1_reg_out, a1_reg_out;
wire [35 : 0] MUL_OUT, M_OUT;
wire CARRYCASCADE, CIN_OUT, CARRYOUT_IN;
wire [47 : 0] POST_ADD_SUB_OUT;
reg [47 : 0] X_OUT, Z_OUT;

assign b_out = (BINPUT == "DIRECT") ? B : ((BINPUT == "CASCADE") ? BCIN : 18'b0);

MUX #(.sel(DREG), .size(18), .rsttype(RSTTYPE)) d (.X(D), .rst(RSTD), .cen(CED), .clk(CLK), .out(D_OUT)); // D instantiation
MUX #(.sel(B0REG), .size(18), .rsttype(RSTTYPE)) b (.X(b_out), .rst(RSTB), .cen(CEB), .clk(CLK), .out(B_OUT)); // B0 instantiation
MUX #(.sel(A0REG), .size(18), .rsttype(RSTTYPE)) a (.X(A), .rst(RSTA), .cen(CEA), .clk(CLK), .out(A_OUT)); // A0 instantiation
MUX #(.sel(CREG), .size(48), .rsttype(RSTTYPE)) c (.X(C), .rst(RSTC), .cen(CEC), .clk(CLK), .out(C_OUT)); // C instantiation
MUX #(.sel(OPMODEREG), .size(8), .rsttype(RSTTYPE)) opmode (.X(OPMODE), .rst(RSTOPMODE), .cen(CEOPMODE), .clk(CLK), .out(OPMODE_OUT)); // OPMODE instantiation

assign PRE_ADD_SUB_OUT = (OPMODE_OUT[6] == 1'b0) ? (D_OUT + B_OUT) : (D_OUT - B_OUT);
assign SEL1 = (OPMODE_OUT[4] == 1'b0) ? (B_OUT) : (PRE_ADD_SUB_OUT);

MUX #(.sel(B1REG), .size(18), .rsttype(RSTTYPE)) b1reg (.X(SEL1), .rst(RSTB), .cen(CEB), .clk(CLK), .out(b1_reg_out)); // B1 instantiation
MUX #(.sel(A1REG), .size(18), .rsttype(RSTTYPE)) a1reg (.X(A_OUT), .rst(RSTA), .cen(CEA), .clk(CLK), .out(a1_reg_out)); // A1 instantiation

assign MUL_OUT = a1_reg_out * b1_reg_out;
assign BCOUT = b1_reg_out;

MUX #(.sel(MREG), .size(36), .rsttype(RSTTYPE)) m (.X(MUL_OUT), .rst(RSTM), .cen(CEM), .clk(CLK), .out(M_OUT)); // M instantiation
assign CARRYCASCADE = (CARRYINSEL == "OPMODE5") ? (OPMODE_OUT[5]) : ((CARRYINSEL == "CARRYIN") ? (CARRYIN) : (1'b0));
MUX #(.sel(CARRYINREG), .size(1), .rsttype(RSTTYPE)) carryin (.X(CARRYCASCADE), .rst(RSTCARRYIN), .cen(CECARRYIN), .clk(CLK), .out(CIN_OUT)); // CYI instantiation
assign M = M_OUT;

always @ (*)
  begin
    case (OPMODE_OUT[1 : 0])
      2'b00 : X_OUT = 48'b0;
      2'b01 : X_OUT = M_OUT;
      2'b10 : X_OUT = P;
      2'b11 : X_OUT = {D_OUT[11 : 0], a1_reg_out, b1_reg_out};
      default : X_OUT = 48'b0;
    endcase
  end

always @ (*)
  begin
    case (OPMODE_OUT[3 : 2])
      2'b00 : Z_OUT = 48'b0;
      2'b01 : Z_OUT = PCIN;
      2'b10 : Z_OUT = P;
      2'b11 : Z_OUT = C_OUT;
      default : Z_OUT = 48'b0;
    endcase
  end
assign {CARRYOUT_IN ,POST_ADD_SUB_OUT} = (OPMODE_OUT[7] == 1'b0) ? (Z_OUT + X_OUT + CIN_OUT) : (Z_OUT - (X_OUT + CIN_OUT));
MUX #(.sel(CARRYOUTREG), .size(1), .rsttype(RSTTYPE)) carryout (.X(CARRYOUT_IN), .rst(RSTCARRYIN), .cen(CECARRYIN), .clk(CLK), .out(CARRYOUT)); // CYO instantiation
assign CARRYOUTF = CARRYOUT;

MUX #(.sel(PREG), .size(48), .rsttype(RSTTYPE)) p (.X(POST_ADD_SUB_OUT), .rst(RSTP), .cen(CEP), .clk(CLK), .out(P)); // P instantiation
assign PCOUT = P;

endmodule