//Master
module apb_master #(parameter n=16)(input pclk,prstn,transfer,write,input [n-1:0]prdata,input pready,input [n-1:0]addr,input [n-1:0]wdata, output reg psel,penable,pwrite,output reg [n-1:0]paddr,output reg [n-1:0]pwdata);
  parameter idle=2'b00, setup=2'b01,access=2'b10;
  reg [1:0]state;
  always @(posedge pclk or negedge prstn) begin
    if(!prstn)
      state<=idle;
    else begin
      case(state)
        idle:begin
          if(transfer)
            state<=setup;
          else
            state<=idle;
        end
        setup:
            state<=access;
        access:
          if(pready) begin
            if(transfer)
              state<=setup;
            else
              state<=idle;
          end
          else
            state<=access;
        default:state<=idle;
      endcase
    end
  end
  always @(posedge pclk or negedge prstn) begin
    if(!prstn) begin
      psel<=0;
      penable<=0;
      pwrite<=0;
      paddr<=0;
      pwdata<=0;
    end
    else begin
      case(state)
        idle:begin
          psel<=0;
          penable<=0;
        end
        setup:begin
          psel<=1;
          penable<=0;
          pwrite<=write;
          paddr<=addr;
          pwdata<=wdata;
        end
        access: begin
          psel<=1;
          penable<=1;
        end
      endcase
    end 
  end
endmodule

//Slave    
            
      
module apb_slave #(parameter n=16)(input pclk,prstn,psel,penable,pwrite,input [n-1:0]paddr,input [n-1:0]pwdata,output reg[n-1:0]prdata,output reg pready);
  reg [n-1:0]mem[7:0];
  integer i;
  always @(posedge pclk or negedge prstn) begin
    
    if(!prstn) begin
      pready<=0;
      prdata<=0;
    end
    else begin
      pready<=1;
      if(psel && penable) begin
      if(pwrite)
        mem[paddr]<=pwdata;
      else
        prdata<=mem[paddr];
    end
    end
    
  end
endmodule
      
//Top module

module apb_top #(parameter n=16)(input transfer,pclk,prstn,write,input [n-1:0]wdata,input [n-1:0]addr);
  wire psel;
  wire penable;
  wire pwrite;
  wire pready;
  wire [n-1:0]pwdata;
  wire [n-1:0]paddr;
  wire [n-1:0]prdata;
  apb_master m1(.pclk(pclk),.prstn(prstn),.transfer(transfer),.write(write),.addr(addr),.wdata(wdata),.pready(pready),.prdata(prdata),.psel(psel),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata));


apb_slave s1(.pclk(pclk),.prstn(prstn),.psel(psel),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),.prdata(prdata),.pready(pready));
endmodule

  
