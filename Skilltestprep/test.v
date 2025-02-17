`timescale 1ps / 1ps

module system_tb;

    // Testbench Signals
    reg Clk;
    reg Reset;
    reg [3:0] Trigger;
    wire [3:0] BCD0, BCD1, BCD2, BCD3;

    // Instantiate DUT (Device Under Test)
    system uut (
        .Clk(Clk),
        .Reset(Reset),
        .Trigger(Trigger),
        .BCD0(BCD0),
        .BCD1(BCD1),
        .BCD2(BCD2),
        .BCD3(BCD3)
    );

    // Clock Generation (50MHz)
    always #10 Clk = ~Clk;

    // Task to Simulate Debounced Trigger Press with Intermittent Noise and Custom Deassert/Reassert Sequence
    task trigger_press(input [3:0] trig);
        begin
            // Apply the trigger signal
            Trigger = trig;

            // Noise during debounce period 0 to 1024
            repeat (1023) begin
                @(posedge Clk);
                // Apply random noise (deassert and reassert the trigger signal during debounce)
                if ($random % 2) begin
                    Trigger = 4'b0000;  // Deassert
                end else begin
                    Trigger = trig;     // Reassert
                end
            end

            // Now, introduce the deassertion and reassertion at 1025:
            repeat (1023) begin
            @(posedge Clk); 
            Trigger = trig;   // Deassert on the falling edge of cycle 1025
            end
              // Reassert trigger on the falling edge of cycle 1025
        
             @(negedge Clk);
            Trigger = 4'b0000; 
              @(posedge Clk); 
            Trigger = trig; 
            // Proper deassertion on 1027 rising edge
            @(posedge Clk); 
            Trigger = 4'b0000;   // Deassert the trigger on 1027 rising edge

            // After debounce period, ensure trigger is fully deasserted
            repeat (50) @(posedge Clk); // Allow some delay before next trigger
        end
    endtask

    // Test Sequence
    initial begin
        // Initialize Signals
        Clk = 0;
        Reset = 1;
        Trigger = 4'b0000;

        // Apply Reset
        #50;
        Reset = 0;

        // Apply Trigger[0] (Increment by 1) with noise
        trigger_press(4'b0001);
        #50;

        // Apply Trigger[1] (Increment by 2) with noise
        trigger_press(4'b0010);
        #50;

        // Apply Trigger[2] (Multiply by 2) with noise
        trigger_press(4'b0100);
        #50;

        // Apply Trigger[3] (Multiply by 3) with noise
        trigger_press(4'b1000);
        #50;

        // Overflow Condition (Force > 9999)
        repeat (15) trigger_press(4'b1000);
        #50;

        // Reset After Overflow
        Reset = 1;
        #50;
        Reset = 0;

        // End Test
        $display("All tests completed.");
        $stop;
    end

endmodule
