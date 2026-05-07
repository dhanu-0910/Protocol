
//RECEIVER

module receiver #(parameter n=8)(input r_clk, input r_rstn, input rx_en, input rx, output reg [n-1:0]dataout, output reg frame_error, output reg parity_error, output reg ready);
  
  reg[$clog2(n-1):0]count=0;
  localparam [2:0] idle=0,start=1,data=3,parity=4,stop=5;
  reg [2:0]state,next_state;
  reg parity_bit;
  reg [3:0]sample;
  
  always @(posedge r_clk or negedge r_rstn) begin
    if(!r_rstn)
      state<=idle;
    else
      state<=next_state;
  end
  
  always @(posedge r_clk or negedge r_rstn) begin
    if(!r_rstn)
      count<=0;
    else if(state==data && rx_en==1 && sample==15)
      count<=count+1;
    else if(state!=data)
      count<=0;
  end
  always @(posedge r_clk or negedge r_rstn) begin
    if(!r_rstn)
      sample <= 0;
    else if(rx_en) begin
      if(state == idle)
        sample <= 0;
      else if(sample == 15)
        sample <= 0; 
      else
        sample <= sample + 1;
      end
  end
  
  always @(*) begin
    next_state=state;
    case(state)
      idle: begin
        if(rx==0)
          next_state=start;
        else
          next_state=idle;
      end
      start: begin
        if(rx==1 && sample==8)
          next_state=idle;
        else if(rx_en && sample==15)
          next_state=data;
        else
          next_state=start;
      end
      data: begin
        if(rx_en && count==n-1 && sample==15)
          next_state=parity;
        else
          next_state=data;
      end
      parity: begin
        if(rx_en && sample==15) 
          next_state=stop;
        else
          next_state=parity;
      end
      stop: begin
        if(rx_en && sample==15)
          next_state=idle;
        else
          next_state=stop;
      end
      default: next_state=idle;
    endcase
  end
  
  
  always @(posedge r_clk or negedge r_rstn) begin
    if(!r_rstn) begin
      ready<=0;
      dataout<=0;
      frame_error<=0;
      parity_error<=0;
    end
    else begin
      case(state)
        idle: begin
          if(rx_en && !rx) 
            ready<=0;
          else
            ready<=1;
        end

        start: begin
   		  ready <= 0;
          if(sample == 0) begin
            dataout <= 0;
            parity_error <= 0;
            frame_error <= 0;
          end
        end
        data: begin
          ready<=0;
          if(rx_en && sample==8)
            dataout[count] <= rx;
        end
        parity: begin
          ready<=0;
          if(rx_en && sample==8)
            parity_error<=(^dataout!=rx);
        end
        stop: begin
          ready<=0;
          if(rx_en && sample==8)
            frame_error<=~rx;
        end
        default: begin
          ready<=0;
          frame_error<=0;
          parity_error<=0;
          dataout<=0;
        end
      endcase
    end
  end
endmodule
