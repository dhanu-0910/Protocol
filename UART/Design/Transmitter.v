
//TRANSMITTER

module transmitter #(parameter n=8)(input t_clk, input t_rstn, input w_en, input tx_en, input [n-1:0]datain, output reg tx, output reg busy);
  
  reg[$clog2(n)-1:0]count=0;
  localparam [2:0] idle=0,start=1,data=2,parity=3,stop=4;
  reg [2:0]state,next_state;
  reg [n-1:0]q;
  
  always @(posedge t_clk or negedge t_rstn) begin
    if(!t_rstn) 
      state<=idle;
    else
      state<=next_state;
  end
  
  always @(posedge t_clk or negedge t_rstn) begin
    if(!t_rstn) 
      count<=0;
    else if(state==data && tx_en==1)
      count<=count+1;
    else if(state!=data)
      count<=0;      
  end
  
  always @(*) begin
    next_state=state;
    case(state)
      idle: begin
        if(w_en)
          next_state=start;
        else
          next_state=idle;
      end
      start: begin
        if(tx_en)
          next_state=data;
        else
          next_state=start;
      end
      data: begin
        if(tx_en && count==n-1)
          next_state=parity;
        else
          next_state=data;
      end
      parity: begin
        if(tx_en)
          next_state=stop;
        else
          next_state=parity;
      end
      stop: begin
        if(tx_en)
          next_state=idle;
        else
          next_state=stop;
      end
      default: next_state=idle;
    endcase
  end
  
  always @(posedge t_clk or negedge t_rstn) begin
    if(!t_rstn) begin
      tx<=0;
      busy<=0;
      q<=0;
    end
    else begin
      case(state)
        idle: begin
          tx<=1;
          busy<=0;        
        end
        start: begin
          busy<=1;
          if(tx_en) begin
            tx<=0;
            q<=datain;
          end
        end
        data: begin
          busy<=1;
          if(tx_en) begin
            tx<=q[0];
            q<={1'b0,q[n-1:1]};
          end
        end
        parity: begin
          busy<=1;
          if(tx_en)
            tx<=^datain;
        end
        stop: begin
          if(tx_en) begin
            tx<=1;
            busy<=0;
          end
        end
      endcase
    end
  end
endmodule
