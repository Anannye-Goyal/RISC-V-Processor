`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISC V Processor
// Module Name: processor
// Project Name: Designing a RISC V Processor
//////////////////////////////////////////////////////////////////////////////////

module tb1_processor_add;

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
            
        risc5.Mem[0] = 32'h1801000C;            // ADDI R1, R0, 12
        risc5.Mem[1] = 32'h18020014;            // ADDI R2, R0, 20
        risc5.Mem[2] = 32'h18030017;            // ADDI R3, R0, 23
        risc5.Mem[3] = 32'h00222000;            // ADD  R4, R1, R2
        
        risc5.Mem[4] = 32'h0CE73800;            // OR   R7, R7, R7     (Dummy instruction)
        
        risc5.Mem[5] = 32'h00832800;            // ADD  R5, R4, R3
        risc5.Mem[6] = 32'h38000000;            // HLT     
        
        risc5.HALT_RECEIVED = 1'b0;
        risc5.PC = 1'b0;
        risc5.BRANCH_RECEIVED = 1'b0;
        
        #300;
        for(k = 0; k < 6; k = k + 1)
            $display("R%1d = %2d", k, risc5.Reg_Bank[k]); 
            
        #320 $finish;   
    end
    
    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, tb1_processor_add);
    end    
          
endmodule
