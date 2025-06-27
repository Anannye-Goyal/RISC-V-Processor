`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISC V Processor
// Module Name: processor
// Project Name: Designing a RISC V Processor
//////////////////////////////////////////////////////////////////////////////////

module tb2_processor_load_store;

    reg clk1 = 1'b0;
    reg clk2 = 1'b0;
    integer k;
    processor risc5(clk1, clk2);
      
    initial begin
        repeat(20)                              // Generating clocks
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
        
        risc5.Mem[0] = 32'h18010064;            // ADDI R1, R0, 100 
        
        risc5.Mem[1] = 32'h0CE73800;            // OR   R7, R7, R7     (Dummy instruction) 
            
        risc5.Mem[2] = 32'h28220000;            // LD   R2, R1, 0
        
        risc5.Mem[3] = 32'h0CE73800;            // OR   R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[4] = 32'h18420032;            // ADDI R2, R2, 50
        
        risc5.Mem[5] = 32'h0CE73800;            // OR   R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[6] = 32'h2C220001;            // ST   R2, R1, 1      (Mem[R1 + 1] <= R2)
        risc5.Mem[7] = 32'h38000000;            // HLT  
        
        risc5.Mem[100] = 90;   
        
        risc5.HALT_RECEIVED = 1'b0;
        risc5.PC = 1'b0;
        risc5.BRANCH_RECEIVED = 1'b0;
        
        #500;
        $display("Mem[100]: %4d, Mem[101]: %4d", risc5.Mem[100], risc5.Mem[101]); 
            
        #600 $finish;   
    end
    
    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, tb2_processor_load_store);
    end    
          
endmodule
