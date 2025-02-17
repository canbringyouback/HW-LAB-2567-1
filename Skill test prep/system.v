`timescale 1ns / 1ps

module system (
    input wire Clk,
    input wire Reset,
    input wire [3:0] Trigger,

    // Outputs for BCD Digits
    output reg [3:0] BCD0, // Least significant digit
    output reg [3:0] BCD1,
    output reg [3:0] BCD2,
    output reg [3:0] BCD3 // Most significant digit

    // Debugging Outputs
          // Indicates if trigger action happens
);
reg [13:0] bcd_value;       // Binary counter value
reg [16:0] debounce_counter;  // Debounce counter
    // **Synchronous Reset and Debounce Logic**
always @(posedge Clk) begin
    if (Reset) begin
        // Reset all registers
        BCD0 <= 4'b0001;
        BCD1 <= 4'b0000;
        BCD2 <= 4'b0000;
        BCD3 <= 4'b0000;
        bcd_value <= 14'd1;
        debounce_counter <= 10'd0;
       

    end else begin
        // If Trigger is asserted (Trigger != 4'b0000)
        if (Trigger != 4'b0000) begin
            if (debounce_counter == 0) begin
               if (bcd_value <= 9999) begin
            case (Trigger)
                4'b0001: bcd_value <= bcd_value + 1; // Increment by 1
                4'b0010: bcd_value <= bcd_value + 2; // Increment by 2
                4'b0100: bcd_value <= bcd_value * 2; // Multiply by 2
                4'b1000: bcd_value <= bcd_value * 3; // Multiply by 3
                default: bcd_value <= bcd_value;
            endcase
            end
                debounce_counter <= 10'd1;  // Start debounce counting
            end else begin
                // Continue counting during debounce period (until 1024 cycles)
                debounce_counter <= debounce_counter + 1;
             
            end 
        end else begin
            // If Trigger is deasserted (Trigger == 4'b0000)
            if ( debounce_counter>0&&  debounce_counter< 1024) begin
               
                  debounce_counter <= debounce_counter + 1;
            end
            else begin debounce_counter <= 10'd0;

            end
        end
        
        // If Trigger is deasserted after debounce completes, reset everything if trigger reasserts

    end
end



 
    // **Overflow Handling & BCD Conversion**
    always @(posedge Clk) begin
        if (bcd_value > 9999) begin
            BCD0 <= 4'b1111;
            BCD1 <= 4'b1111;
            BCD2 <= 4'b1111;
            BCD3 <= 4'b1111;
        end else begin
            // Convert binary to BCD using mod 10 method
            BCD0 <= bcd_value % 10;
            BCD1 <= (bcd_value / 10) % 10;
            BCD2 <= (bcd_value / 100) % 10;
            BCD3 <= (bcd_value / 1000) % 10;
        end
    end

endmodule
