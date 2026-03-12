
module apb_tb;

parameter n = 16;

reg transfer;
reg pclk;
reg prstn;
reg write;
reg [n-1:0] wdata;
reg [n-1:0] addr;

apb_top #(n) dut(
.transfer(transfer),
.pclk(pclk),
.prstn(prstn),
.write(write),
.wdata(wdata),
.addr(addr)
);


// Clock generation
always #5 pclk = ~pclk;


// Monitor signals
initial begin
  $dumpfile("out_apb.vcd");
  $dumpvars(0,apb_tb);
  $monitor("time=%0t clk=%b rst=%b transfer=%b write=%b addr=%d wdata=%d | psel=%b penable=%b pwrite=%b paddr=%d pwdata=%d prdata=%d data_out=%d pready=%b",$time,pclk,prstn,transfer,write,addr,wdata,dut.master_psel,dut.penable,dut.pwrite,dut.paddr,dut.pwdata,dut.prdata,dut.data_out,dut.pready);
end


// Stimulus
initial begin

pclk = 0;
prstn = 0;
transfer = 0;
write = 0;
addr = 0;
wdata = 0;

#10 prstn = 1;


// Write to slave0
#10 transfer = 1;
write = 1;
addr = 2;
wdata = 10;

#20 transfer = 0;


// Write to slave1
#10 transfer = 1;
write = 1;
addr = 5;
wdata = 20;

#20 transfer = 0;


// Write to slave2
#10 transfer = 1;
write = 1;
addr = 8;
wdata = 30;

#20 transfer = 0;


// Write to slave3
#10 transfer = 1;
write = 1;
addr = 12;
wdata = 40;

#20 transfer = 0;


// Read from slave0
#10 transfer = 1;
write = 0;
addr = 12;

#20 transfer = 0;


// Read from slave2
#10 transfer = 1;
write = 0;
addr = 8;

#20 transfer = 0;

#50 $finish;

end

endmodule
