//Baud Generator For RECEIVER

module baud_gen_rx #(parameter frequency=100000000, baud_rate=9600)(input r_clk,input r_rstn,output reg rx_en);
  
  localparam integer clk_cycle=frequency/(baud_rate*16);
  reg[$clog2(clk_cycle)-1:0]rx_counter=0;
  
  always @(posedge r_clk or negedge r_rstn) begin
    if(!r_rstn) begin
      rx_counter<=0;    
      rx_en<=0;
    end
    else begin
      if(rx_counter==clk_cycle-1) begin
        rx_counter<=0;
        rx_en<=1;
      end
      else begin
        rx_counter<=rx_counter+1;
        rx_en<=0;
      end
    end
  end 
endmodule
