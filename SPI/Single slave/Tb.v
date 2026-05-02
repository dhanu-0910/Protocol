module spi_tb;
  reg clk;
  reg resetn;
  reg [7:0]datain;
  reg cpol;
  reg cpha;
  reg start;
  wire [7:0]dataout;
  wire done;
  wire busy;
  
  spi_top_module dut(.*);
  always #5 clk=~clk;
  initial begin
    $dumpfile("spi_out.vcd");
    $dumpvars(0,spi_tb);
    $monitor("time=%0t clk=%0b resetn=%0b datain=%0b start=%0d cpol=%0b cpha=%0b dataout=%0b busy=%0d done=%0b",$time,clk,resetn,datain,start,cpol,cpha,dataout,busy,done);
  end
  initial begin
    clk=0;
    resetn=0;#10;
    resetn=1;#10;
    datain=8'b11011011;cpol=0;cpha=1;#10;
    start=1;#100;
    start=0;#200;
    $finish;
  end
endmodule
    
    

