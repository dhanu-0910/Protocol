
//Baud Gererator For TRANSMITTER

module baud_gen_tx #(parameter frequency=50000000, baud_rate=9600)(input t_clk, input t_rstn, output reg tx_en);
  
  localparam integer clk_cycle= frequency/(baud_rate);
  reg[$clog2(clk_cycle)-1:0]tx_counter=0;
  
  always @(posedge t_clk or negedge t_rstn) begin
    if(!t_rstn) begin
      tx_en<=0;
      tx_counter<=0;
    end
    else begin
      if(tx_counter==clk_cycle-1) begin
        tx_counter<=0;
        tx_en<=1;
      end
      else begin
        tx_en<=0;
        tx_counter<=tx_counter+1;
      end
    end
  end
endmodule
