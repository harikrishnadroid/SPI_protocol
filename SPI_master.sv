//SPI master verilog code


module master(input pclk,
                    input rst,
                    input en,
                    output reg ss,
                    input [7:0] master_tx_data,
                    input cpha,
                    input cpol,
                    input miso,
                    input [7:0] div,
                    output reg mosi,
                    output  reg sclk);
  
  parameter idle=2'b00;
  parameter load=2'b01;
  parameter transfer=2'b10;
  parameter done=2'b11;
  
  reg [1:0] present_state,next_state;
  reg [7:0] master_tx_shift_reg;
  reg [7:0] master_rx_shift_reg;
  reg [3:0] count;
  reg [2:0] clk_count;
  reg sclk_d;
  
  wire posedge_sclk;
  wire negedge_sclk;
  wire sample_en;
  wire shift_en;
  
  always @(posedge pclk or posedge rst)begin
    if(rst) begin
      present_state<=idle;
    end
    else
      present_state<=next_state;
  end
  
  always @(*)begin
    ss=1;
    case(present_state)
      idle:begin
          next_state=load;
      end
      load:begin
        ss=0;
        if(en)
          next_state=transfer; 
        else
          next_state=load;
      end
      
      transfer:begin
        ss=0;
        if(count==4'b1000)
          next_state=done;
        else
          next_state=transfer;
      end
      
      done:begin
          next_state=idle;
      end
      
      default:next_state=idle;
    endcase
  end
  
  always @(posedge pclk)begin
    if(present_state==transfer)begin
      if(clk_count==div-1)begin
        clk_count<=3'b0;
        sclk<=~sclk;
      end
      else begin
        clk_count<=clk_count+1;
      end
    end
    else begin
      clk_count<=3'b0;
      sclk<=cpol;
    end
  end
           
  
  assign posedge_sclk =sclk &~sclk_d;
  assign negedge_sclk =~sclk & sclk_d;
  assign sample_en=((posedge_sclk) && (cpol==cpha)) || ((cpol!=cpha) && (negedge_sclk));
  assign shift_en=((posedge_sclk) && (cpha!=cpol)) || ((negedge_sclk) && (cpol==cpha));
  
  always @(posedge pclk or posedge rst)begin
    if(rst)begin
      sclk_d=0;
    end
    else begin
        sclk_d<=sclk;
    end
  end
        
  always @(posedge pclk or posedge rst)begin
    if(rst)begin
      master_rx_shift_reg<=0;
      count<=0;
    end
    else begin 
     case(present_state)
       load:begin
         master_tx_shift_reg<=master_tx_data;
         mosi<=master_tx_shift_reg[7];
       end
       transfer:begin
         if(sample_en)
           master_rx_shift_reg<={miso,master_rx_shift_reg[7:1]};
         else begin
           if(shift_en)begin
             mosi<=master_tx_shift_reg[6];
             master_tx_shift_reg<={master_tx_shift_reg[6:0],1'b0};
             count<=count+1;
            end
          end
        end
     endcase
    end
  end
endmodule
          
      
        
