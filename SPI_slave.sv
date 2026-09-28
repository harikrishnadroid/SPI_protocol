//SPI slave verilog code
//This slave can be communicate with any mode.
//But in real-time any slave can only be communiacte with any one specific mode which will be decided by the Architect.  


module slave #(parameter cpol=0,parameter cpha=0)
  
             (input sclk,
              input rst,
             input mosi,
             input ss,
             output  miso);
  
  reg [7:0] slave_tx1_shift_reg=8'b00001111;
  reg [7:0] slave_tx2_shift_reg=8'b11110000;
  reg [7:0] slave_rx1_shift_reg;
  reg [7:0] slave_rx2_shift_reg;
  reg [2:0] count1;
  reg [2:0] count2; 
  reg miso1;
  reg miso2;
  
  
  assign miso=(cpol==cpha)?miso2:miso1;
  
  always @(posedge sclk or posedge rst)begin
    if(rst)begin
      count1<=0;
      slave_rx1_shift_reg<=0;
      miso1=0;
    end
    else if(!ss)begin
      if(cpha==cpol)begin 
        slave_rx1_shift_reg<={slave_rx1_shift_reg[6:0],mosi};
      end
      else begin
        if(cpol!=cpha)begin
          miso1<=slave_tx_shift_reg[0];
          slave_tx1_shift_reg<={1'b0,slave_tx1_shift_reg[7:1]}; 
          count1<=count1+1;
        end
     end
    end
  end

  
  always @(negedge sclk or posedge rst)begin
    if(rst)begin
      count2<=0;
      slave_rx2_shift_reg<=0;
      miso2=0;
    end 
    else if(!ss)begin
      if(cpol==cpha)begin
        miso2<=slave_tx2_shift_reg[0];
        slave_tx2_shift_reg<={1'b0,slave_tx2_shift_reg[7:1]}; 
        count2<=count2+1;
      end
      else begin
        if(cpol!=cpha)begin
          slave_rx2_shift_reg<={slave_rx2_shift_reg[6:0],mosi};
        end
      end
    end
  end
endmodule
