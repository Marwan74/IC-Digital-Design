module MUX (X, rst, cen, clk, out);
parameter sel = 0;
parameter size = 18;
parameter rsttype = "SYNC";
input [size - 1 : 0] X;
input rst, clk, cen;
output reg [size - 1 : 0] out;

reg [size - 1 : 0 ] X_reg;

generate
  if (rsttype == "SYNC")
    begin
      always @ (posedge clk)
        begin
          if (rst)
            X_reg <= 0;
          else if (cen)
            X_reg <= X;
        end
    end
  else
    begin
      always @ (posedge clk, posedge rst)
        begin
          if (rst)
            X_reg <= 0;
          else if (cen)
            X_reg <= X;
        end
    end
endgenerate 

always @ (*)
  begin
    if (sel)
      out = X_reg;
    else
      out = X;
  end
endmodule