`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISC V Processor
// Module Name: processor
// Project Name: Designing a RISC V Processor
//////////////////////////////////////////////////////////////////////////////////

module tb3_processor_factorial;

    reg clk1 = 1'b0;
    reg clk2 = 1'b0;
    integer k;
    processor risc5(clk1, clk2);
      
    initial begin
        repeat(200)                              // Generating clocks
            begin
                #5 clk1 = 1'b1; 
                #5 clk1 = 1'b0;
                #5 clk2 = 1'b1;
                #5 clk2 = 1'b0;
            end
        end        
        
    initial begin
        for(k = 0; k < 32; k = k + 1)           // Random initialization of registers
            risc5.Reg_Bank[k] = k; 
        
        risc5.Mem[0] = 32'h180A00C8;            // ADDI   R10, R0, 200 
        risc5.Mem[1] = 32'h18020001;            // ADDI   R2, R0, 1
        risc5.Mem[2] = 32'h29430000;            // LD     R3, R10, 0
        
        risc5.Mem[3] = 32'h0CE73800;            // OR     R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[4] = 32'h10431000;            // MUL    R2, R2, R3     (Loop start)
        risc5.Mem[5] = 32'h1C630001;            // SUBI   R3, R3, 1    
        
        risc5.Mem[6] = 32'h0CE73800;            // OR     R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[7] = 32'h3460FFFC;            // BNEQZ  R3, Loop       (Shift back -4)
        risc5.Mem[8] = 32'h2D42FFFE;            // ST     R2, R10, -2    (Mem[R10 - 2] <= R2)
        risc5.Mem[9] = 32'h38000000;            // HLT  
        
        risc5.Mem[200] = 7;   
        
        risc5.HALT_RECEIVED = 1'b0;
        risc5.PC = 1'b0;
        risc5.BRANCH_RECEIVED = 1'b0;
        
        #1500;
        $display("Mem[200]: %4d, Mem[198]: %6d", risc5.Mem[200], risc5.Mem[198]); 
            
        #2000 $finish;   
    end
    
    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, tb3_processor_factorial);
        $monitor("R2: %4d", risc5.Reg_Bank[2]);
    end    
          
endmodule
