module system(
    output [6:0] seg,
    output dp,
    output [3:0] an,
    input [7:0] sw,
    output wire RsTx, //uart
    input wire RsRx, //uart // [7:4] for Higher num hex, [3:0] for Lower num
    input clk
    
    );

    wire [3:0] num3, num2, num1, num0; // left to right
    wire an0, an1, an2, an3;
    assign an = {an3, an2, an1, an0};
    
    ////////////////////////////////////////
    // Clock
    wire targetClk;
    wire [18:0] tclk;
     wire  [7:0]O;

    assign tclk[0] = clk;
    genvar c;
    generate for(c = 0; c < 18; c = c + 1) begin
        clockDiv fDiv(tclk[c+1], tclk[c]);
    end endgenerate
    
    clockDiv fdivTarget(targetClk, tclk[18]);
    
    ////////////////////////////////////////
    // Display
    
    ////////////////////////////////////////
    // Single Pulser
    
    ////////////////////////////////////////
    // RAM
    uart uart_instance(clk, RsRx, RsTx,O); // Instance of uart
    // Remove assignment to data1
    // reg [7:0] data1; 
    // assign data1 = RsTx; // Remove this line
    quadSevenSeg q7seg(seg, dp, an0, an1, an2, an3,O, O,O, O, targetClk);
    
endmodule
