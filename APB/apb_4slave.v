//Master
module apb_master #(parameter n=16)(input pclk,prstn,transfer,write,input [n-1:0]prdata,input pready,input [n-1:0]addr,input [n-1:0]wdata, output reg psel,penable,pwrite,output reg [n-1:0]paddr,output reg [n-1:0]pwdata,output reg [n-1:0] data_out);
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
  always @(posedge pclk) begin
    if(!prstn)
      data_out<=0;
    else if (psel && penable && !pwrite && pready)
      data_out<= prdata;
      
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
      if(psel && penable && pwrite) 
        mem[paddr[2:0]]<=pwdata;
      else 
        prdata<=mem[paddr[2:0]];
      end
    end
endmodule
      
//Top module

module apb_top #(parameter n=16)(input transfer,pclk,prstn,write,input [n-1:0]wdata,input [n-1:0]addr);
  
  wire master_psel;
  wire [3:0]psel;
  wire penable;
  wire pwrite;
  wire pready;
  wire [n-1:0]pwdata;
  wire [n-1:0]paddr;
  wire [n-1:0]prdata;
  wire [n-1:0]data_out;
  wire [n-1:0] prdata0,prdata1,prdata2,prdata3;
  wire pready0,pready1,pready2,pready3;
  
  apb_master m1(.pclk(pclk),.prstn(prstn),.transfer(transfer),.write(write),.addr(addr),.wdata(wdata),.pready(pready),.prdata(prdata),.psel(master_psel),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),.data_out(data_out));
  
  assign psel[0]= master_psel & (paddr[3:2] == 2'b00);
  assign psel[1]= master_psel & (paddr[3:2] == 2'b01);
  assign psel[2]= master_psel & (paddr[3:2] == 2'b10);
  assign psel[3]= master_psel & (paddr[3:2] == 2'b11);
  
  assign prdata = (psel[0]) ? prdata0 :(psel[1]) ? prdata1 :(psel[2]) ? prdata2 :(psel[3])?prdata3:0;
  
  assign pready = (psel[0]) ? pready0 :(psel[1]) ? pready1 :(psel[2]) ? pready2 :(psel[3])?pready3:0;

  apb_slave s1(.pclk(pclk),.prstn(prstn),.psel(psel[0]),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),.prdata(prdata0),.pready(pready0));
  
  apb_slave s2(.pclk(pclk),.prstn(prstn),.psel(psel[1]),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),.prdata(prdata1),.pready(pready1));
  
  apb_slave s3(.pclk(pclk),.prstn(prstn),.psel(psel[2]),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),.prdata(prdata2),.pready(pready2));
  
  apb_slave s4(.pclk(pclk),.prstn(prstn),.psel(psel[3]),.penable(penable),.pwrite(pwrite),.paddr(paddr),.pwdata(pwdata),.prdata(prdata3),.pready(pready3));
  
    
endmodule

  
