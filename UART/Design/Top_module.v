`include "baud_gen_tx.v"
`include "baud_gen_rx.v"
`include "transmitter.v"
`include "receiver.v"
//TOP MODULE

module top_module #(parameter n=8)(input r_clk,t_clk,w_en, input t_rstn,r_rstn, input [n-1:0]datain, output [n-1:0]dataout,output ready,busy,frame_error,parity_error);
  
  wire tx;
  wire tx_en,rx_en;
  
  baud_gen_tx t0(.t_clk(t_clk),.t_rstn(t_rstn),.tx_en(tx_en));
  baud_gen_rx r0(.r_clk(r_clk),.r_rstn(r_rstn),.rx_en(rx_en));
  transmitter #(.n(n)) t1(.t_clk(t_clk),.t_rstn(t_rstn),.datain(datain),.tx_en(tx_en),.w_en(w_en),.tx(tx),.busy(busy));
  receiver #(.n(n)) r1(.r_clk(r_clk),.r_rstn(r_rstn),.rx(tx),.rx_en(rx_en),.dataout(dataout),.ready(ready),.frame_error(frame_error),.parity_error(parity_error));
  
endmodule
