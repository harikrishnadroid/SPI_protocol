//i have implemented this whole design in EDA playground so i had used inlcude "keyword"
`include "spi_master.sv"
`include "spi_slave.sv"

module top(input pclk,
           input rst,
           input en,
           input cpha,
           input cpol,
           input [7:0] div,
           input   [7:0] master_tx_data);
  
  wire miso;
  wire mosi;
  wire sclk;
  wire [7:0] master_data;
  
  master master(.pclk(pclk),
                    .rst(rst),
                    .en(en),
                    .cpha(cpha),
                    .cpol(cpol),
                    .div(div),
                .master_tx_data(master_tx_data),
                    .sclk(sclk),
                    .ss(ss),
                    .miso(miso),
                    .mosi(mosi));
  
  slave slave(.sclk(sclk),
              .rst(rst),
                  .ss(ss),
                  .miso(miso),
                  .mosi(mosi));
endmodule
                   
                   
                   
                   
  
  
  
  
  
  
  
