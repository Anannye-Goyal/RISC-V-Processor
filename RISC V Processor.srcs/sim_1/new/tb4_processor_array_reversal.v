`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISC V Processor
// Module Name: processor
// Project Name: Designing a RISC V Processor
//////////////////////////////////////////////////////////////////////////////////

module tb4_processor_array_reversal;

    reg clk1 = 1'b0;
    reg clk2 = 1'b0;
    integer k;
    processor risc5(clk1, clk2);
      
    initial begin
        repeat(400)                              // Generating clocks
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
        
        risc5.Mem[0] = 32'h18140001;            // ADDI   R20, R0, 1     (Always true condition)    
        risc5.Mem[1] = 32'h180A00C8;            // ADDI   R10, R0, 200   (Array size address)
        
        risc5.Mem[2] = 32'h0CE73800;            // OR     R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[3] = 32'h294B0000;            // LD     R11, R10, 0    (Array size)
        risc5.Mem[4] = 32'h194C0001;            // ADDI   R12, R10, 1    (Array start address)
        risc5.Mem[5] = 32'h180D0000;            // ADDI   R13, R0, 0     (low)
        risc5.Mem[6] = 32'h1D6E0001;            // SUBI   R14, R11, 1    (high)
        
        risc5.Mem[7] = 32'h0CE73800;            // OR     R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[8] = 32'h15AE7800;            // SLT    R15, R13, R14  (check low <= high)
        
        risc5.Mem[9] = 32'h0CE73800;            // OR     R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[10] = 32'h31E0000B;           // BEQZ   R15, Halt      (Task completed, PC = PC + 11)
        risc5.Mem[11] = 32'h018D8000;           // ADD    R16, R12, R13  (Address of left element)
        
        risc5.Mem[12] = 32'h0CE73800;           // OR     R7, R7, R7     (Dummy instruction) 
        
        risc5.Mem[13] = 32'h2A110000;           // LD     R17, R16, 0    (Left element)
        risc5.Mem[14] = 32'h018E9000;           // ADD    R18, R12, R14  (Address of right element) 
        
        risc5.Mem[15] = 32'h0CE73800;           // OR     R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[16] = 32'h2A530000;           // LD     R19, R18, 0    (Right element)
        risc5.Mem[17] = 32'h2E510000;           // ST     R17, R18, 0    (Mem[R18] <-- R17)
        risc5.Mem[18] = 32'h2E130000;           // ST     R19, R16, 0    (Mem[R16] <-- R19)
        risc5.Mem[19] = 32'h19AD0001;           // ADDI   R13, R13, 1    (Low++)
        risc5.Mem[20] = 32'h1DCE0001;           // SUBI   R14, R14, 1    (High--)     
        risc5.Mem[21] = 32'h3680FFF2;           // BNEQZ  R20, Loop      (Shift back -14)****
        risc5.Mem[22] = 32'h38000000;           // HLT  
        
        risc5.Mem[200] = 7; 
        risc5.Mem[201] = 3;
        risc5.Mem[202] = 2;
        risc5.Mem[203] = 6;
        risc5.Mem[204] = 9;
        risc5.Mem[205] = 0;
        risc5.Mem[206] = 1;
        risc5.Mem[207] = 6;
        $display("Mem[200]: %2d, Mem[201]: %2d, Mem[202]: %2d, Mem[203]: %2d, Mem[204]: %2d, Mem[205]: %2d, Mem[206]: %2d, Mem[207]: %2d", 
                  risc5.Mem[200], risc5.Mem[201], risc5.Mem[202], risc5.Mem[203], risc5.Mem[204], risc5.Mem[205], risc5.Mem[206], risc5.Mem[207]); 
          
        
        risc5.HALT_RECEIVED = 1'b0;
        risc5.PC = 1'b0;
        risc5.BRANCH_RECEIVED = 1'b0;
        
        #4000;
        $display("Mem[200]: %2d, Mem[201]: %2d, Mem[202]: %2d, Mem[203]: %2d, Mem[204]: %2d, Mem[205]: %2d, Mem[206]: %2d, Mem[207]: %2d", 
                  risc5.Mem[200], risc5.Mem[201], risc5.Mem[202], risc5.Mem[203], risc5.Mem[204], risc5.Mem[205], risc5.Mem[206], risc5.Mem[207]); 
            
        #4500 $finish;   
    end
    
    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, tb4_processor_array_reversal);
    end    
          
endmodule
