module tb_uart;
  parameter n = 8;
  reg r_clk;
  reg t_clk;
  reg w_en;
  reg t_rstn;
  reg r_rstn;
  reg [n-1:0] datain;
  wire [n-1:0] dataout;
  wire ready;
  wire busy;
  wire frame_error;
  wire parity_error;
  
  top_module #(n) dut(
    .r_clk(r_clk),
    .t_clk(t_clk),
    .w_en(w_en),
    .t_rstn(t_rstn),
    .r_rstn(r_rstn),
    .datain(datain),

    .dataout(dataout),
    .ready(ready),
    .busy(busy),
    .frame_error(frame_error),
    .parity_error(parity_error));
  // TX clock = 50 MHz
  initial begin
    t_clk = 0;
    forever #10 t_clk = ~t_clk;
  end
  // RX clock = 100 MHz
  initial begin
    r_clk = 0;
    forever #5 r_clk = ~r_clk;
  end
  initial begin
    w_en = 0;
    datain = 0;
    t_rstn = 0;
    r_rstn = 0;
    // reset
    #100;
    t_rstn = 1;
    r_rstn = 1;
    // wait
    #100;
    @(posedge t_clk);
    datain = 8'b10101011;
    w_en = 1;
    @(posedge t_clk);
    w_en = 0;
    // wait until transmitter starts
    wait(busy==1);
    // wait until transmission completes
    wait(busy==0);
    // wait until receiver ready
    wait(ready==1);
    #1000;
    @(posedge t_clk);
    datain = 8'b11001101;
    w_en = 1;
    @(posedge t_clk);
    w_en = 0;
    wait(busy==1);
    wait(busy==0);
    wait(ready==1);
    #1000;
    $finish;
  end
  initial begin

    $monitor(
    "TIME=%0t | DATA_IN=%b | DATA_OUT=%b | BUSY=%b | READY=%b | PARITY_ERR=%b | FRAME_ERR=%b",$time,datain,dataout,busy,ready,parity_error,frame_error);
  end
endmodule
