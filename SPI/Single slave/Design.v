//MASTER

module master(input clk, input resetn, input start, input cpol, input cpha, input [7:0]datain, input miso, output reg mosi, output reg sclk, output reg cs, output reg [7:0]dataout, output reg done, output reg busy);
  
  parameter idle=0,load=1,transfer=2,stop=3;
  reg [1:0]state,next_state;
  reg [3:0]count;
  reg [7:0]shift_data;
  reg pre_sclk;
  wire falling_edge;
  wire rising_edge;
  assign falling_edge=(pre_sclk==1 && sclk==0);
  assign rising_edge=(pre_sclk==0 && sclk==1);
  
//State Register
  
  always @(posedge clk or negedge resetn) begin
    if(!resetn)
      state<=idle;
    else
      state<=next_state;
  end

//State Transition
  
  always @(*) begin
    case(state)
      idle: begin
        next_state= (start)?load:idle;
      end
      load: begin
        next_state= (!cs)?transfer:load;
      end
      transfer: begin
        next_state= (count==7)?stop:transfer;
      end
      stop: begin
        next_state= idle;
      end
      default: next_state= idle;
    endcase
  end
  
//SCLK Generation
  
  always @(posedge clk or negedge resetn) begin
    if(!resetn)
      sclk<=0;
    else begin
      if(state==idle || state==load || state==stop)
        sclk<=cpol;
      if(state==transfer)
        sclk<=~sclk;
    end
  end
  
//Pre_SCLK (Edge Detection)
  
  always @(posedge clk or negedge resetn) begin
    if(!resetn)
      pre_sclk<=cpol;
    else
      pre_sclk<=sclk;
  end
  
//Master FSM Operation
  
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      sclk<=0;
      cs<=1;
      done<=0;
      busy<=0;
      dataout<=0;
      mosi<=0;
      count<=0;
      shift_data<=0;
    end
    else begin
      case(state)
        idle: begin
          cs<=1;
          done<=0;
          busy<=0;
        end
        load: begin
          cs<=0;
          done<=0;
          busy<=1;
          shift_data<=datain;
          count<=0;
          if(cpha==0)
            mosi<=datain[7];
        end
        transfer: begin
          busy<=1;
          done<=0;
          case({cpol,cpha})
            2'b00: begin
              if(falling_edge)
                mosi<=shift_data[7];
              if(rising_edge) begin
                shift_data<={shift_data[6:0],miso};
                count<=count+1;
              end
            end
            2'b01: begin
              if(rising_edge)
               mosi<=shift_data[7];
              if(falling_edge) begin
               shift_data<={shift_data[6:0],miso};
               count<=count+1;
             end
           end
            2'b10: begin
              if(rising_edge)
               mosi<=shift_data[7];
              if(falling_edge) begin
               shift_data<={shift_data[6:0],miso};
               count<=count+1;
             end
           end
            2'b11: begin
              if(falling_edge)
               mosi<=shift_data[7];
              if(rising_edge) begin
               shift_data<={shift_data[6:0],miso};
               count<=count+1;
             end
            end
          endcase
        end
        stop: begin
          dataout<=shift_data;
          cs<=1;
          busy<=0;
          done<=1;
        end
      endcase
    end
  end
endmodule
          
//SLAVE

module slave(input clk, input resetn, input [7:0]datain, input cpol, input cpha, input sclk, input mosi, input cs, output reg done, output reg busy, output reg [7:0]dataout, output reg miso);
  
  reg [3:0]count;
  reg [7:0]shift_data;
  reg pre_sclk;
  wire falling_edge;
  wire rising_edge;
  assign falling_edge=(pre_sclk==1 && sclk==0);
  assign rising_edge=(pre_sclk==0 && sclk==1);
  
//Pre_SCLK(Edge detection)
  always @(posedge clk or negedge resetn) begin
    if(!resetn)
      pre_sclk<=cpol;
    else
      pre_sclk<=sclk;
  end
  
//Slave FSM Operation
  
  always @(posedge clk or negedge resetn) begin
    if(!resetn) begin
      done<=0;
      busy<=0;
      dataout<=0;
      miso<=0;
      count<=0;
      //shift_data<=0;
    end
    else begin
      busy<=0;
      done<=0;
      if(!cs) begin
        if(count==0) begin
          shift_data<=datain;
        end
        busy<=1;
        done<=0;
        case({cpol,cpha}) 
          2'b00: begin
            if(falling_edge)
              miso<=shift_data[7];
            if(rising_edge) begin
              shift_data<={shift_data[6:0],mosi};
              if(count==7) begin
                dataout<={shift_data[6:0],mosi};
                done<=1;
                busy<=0;
                count<=0;
              end
              else 
                count<=count+1;
            end
          end
          2'b01: begin
            if(rising_edge)
              miso<=shift_data[7];
            if(falling_edge) begin
              shift_data<={shift_data[6:0],mosi};
              if(count==7) begin
                dataout<={shift_data[6:0],mosi};
                done<=1;
                busy<=0;
                count<=0;
              end
              else 
                count<=count+1;
            end
          end
          2'b10: begin
            if(rising_edge)
              miso<=shift_data[7];
            if(falling_edge) begin
              shift_data<={shift_data[6:0],mosi};
              if(count==7) begin
                dataout<={shift_data[6:0],mosi};
                done<=1;
                busy<=0;
                count<=0;
              end
              else 
                count<=count+1;
            end
          end
          2'b11: begin
            if(falling_edge)
              miso<=shift_data[7];
            if(rising_edge) begin
              shift_data<={shift_data[6:0],mosi};
              if(count==7) begin
                dataout<={shift_data[6:0],mosi};
                done<=1;
                busy<=0;
                count<=0;
              end
              else 
                count<=count+1;
            end
          end
          default: begin
            miso<=0;
            busy<=0;
            done<=0;
          end
        endcase
      end
      else begin
        count<=0;
        miso<=0;
        busy<=0;
        done<=0;  
      end
    end
  end
endmodule

//TOP MODULE

module spi_top_module(input clk, input resetn, input [7:0]datain, input cpol, input cpha, input start, output [7:0]dataout, output done, output busy);
  wire sclk;
  wire miso;
  wire mosi;
  wire cs;
  wire [7:0]master_out;
  
  master m1(.clk(clk),.resetn(resetn),.datain(datain),.cpol(cpol),.cpha(cpha),.start(start),.miso(miso),.mosi(mosi),.cs(cs),.sclk(sclk),.done(done),.busy(busy),.dataout(master_out));
  
  slave s1(.clk(clk),.resetn(resetn),.datain(datain),.cpol(cpol),.cpha(cpha),.miso(miso),.mosi(mosi),.cs(cs),.sclk(sclk),.done(done),.busy(busy),.dataout(dataout));
endmodule
