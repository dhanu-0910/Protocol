module apb_tb;

parameter n = 16;

reg pclk;
reg prstn;
reg transfer;
reg write;
reg [n-1:0] addr;
reg [n-1:0] wdata;

apb_top #(n) dut (
.pclk(pclk),
.prstn(prstn),
.transfer(transfer),
.write(write),
.addr(addr),
.wdata(wdata)
);

always #5 pclk = ~pclk;

initial begin

$dumpfile("apb.vcd");
$dumpvars(0, apb_tb);
  $monitor("time=%0t pclk=%b prstn=%b transfer=%b write=%b addr=%d wdata=%h | psel=%b penable=%b pwrite=%b paddr=%d pwdata=%h pready=%b prdata=%h", $time,pclk,prstn, transfer, write, addr, wdata, dut.psel, dut.penable, dut.pwrite, dut.paddr, dut.pwdata, dut.pready, dut.prdata );

pclk = 1;
prstn = 0;
transfer = 0;
write = 0;
addr = 0;
wdata = 0;

#10 prstn = 1;

#10
transfer = 1;
write = 1;
addr = 3;
wdata = 16'h00AA;

#10 transfer = 1;

#30
transfer = 1;
write = 0;
addr = 3;

#10 transfer = 1;

#50 $finish;

end

endmodule

