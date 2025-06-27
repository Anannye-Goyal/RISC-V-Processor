`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: RISC V Processor
// Module Name: processor
// Project Name: Designing a RISC V Processor
//////////////////////////////////////////////////////////////////////////////////

module processor(input clk1, input clk2);                  // Taking 2 clocks to avoid racing condition

    reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
    reg [31:0] ID_EXE_IR, ID_EXE_NPC, ID_EXE_A, ID_EXE_B, ID_EXE_IMMD;
    reg [31:0] EXE_MEM_IR, EXE_MEM_ALUOUT, EXE_MEM_B;
    reg [31:0] MEM_WB_IR, MEM_WB_ALUOUT, MEM_WB_LOAD;
    
    reg [2:0] ID_EXE_TYPE, EXE_MEM_TYPE, MEM_WB_TYPE;      // Type of instruction received
    reg EXE_MEM_cond;                                      // Condition for BRANCH instruction
    reg HALT_RECEIVED;                                     // Flag for halt instruction
    reg BRANCH_RECEIVED;                                   // Flag for branch instruction
    
    reg [31:0] Reg_Bank [0:31];                            // 32 register bank of 32 bits each
    reg [31:0] Mem [0:1023];                               // 1024 memory blocks of 32 bits each   
    
    // ALU Operations
    parameter ADD = 6'b000000,       // Add 
              SUB = 6'b000001,       // Subtract
              AND = 6'b000010,       // Bitwise AND
              OR =  6'b000011,       // Bitwise OR
              MUL = 6'b000100,       // Multiply
              SLT = 6'b000101,       // Set Less Than
              
              ADDI = 6'b000110,      // Add Immediate
              SUBI = 6'b000111,      // Subtract Immediate
              SLTI = 6'b001000,      // Set Less Than Immediate
              MULI = 6'b001001,      // Multiply Immediate
              
              LD = 6'b001010,        // Load
              ST = 6'b001011,        // Store
              
              BEQZ =  6'b001100,     // Branch if EQual to Zero
              BNEQZ = 6'b001101,     // Branch if Not EQualt to Zero
              
              HLT = 6'b001110;       // Halt
              
    // Type of Instruction          
    parameter RR_ALU = 3'b000,       // Register-to-register ALU operation
              RM_ALU = 3'b001,       // Register-to-Memory ALU operation
              LOAD = 3'b010,         // Load instruction
              STORE = 3'b011,        // Store instruction
              BRANCH = 3'b100,       // Branch instruction
              HALT = 3'b101,         // Halt instruction   
              FLUSHED = 3'b110;      // Flushed instruction  
              
    // Instruction Fetch Stage
    always @(posedge clk1)
        if(HALT_RECEIVED == 0) begin
            if(((EXE_MEM_IR[31:26] == BEQZ) && (EXE_MEM_cond == 1)) || ((EXE_MEM_IR[31:26] == BNEQZ) && (EXE_MEM_cond == 0)))
                begin
                    IF_ID_IR <= Mem[EXE_MEM_ALUOUT];                 // Take Branch Instruction
                    IF_ID_NPC <= EXE_MEM_ALUOUT + 1;                 // Update New Program Counter  
                    PC <= EXE_MEM_ALUOUT + 1;                        // Update Program Counter
                end
            else
                begin
                    IF_ID_IR <= Mem[PC];                             // Take normal instruction
                    IF_ID_NPC <= PC + 1;
                    PC <= PC + 1;
                end
        end                    
    
    // Instruction Decode Stage
    always @(posedge clk2)
        if(HALT_RECEIVED == 0) begin
            if(BRANCH_RECEIVED == 1'b1) begin
                ID_EXE_IR <= 32'h00000000;                               // Flush the instruction
                ID_EXE_TYPE <= FLUSHED;
                ID_EXE_A    <= 0;
                ID_EXE_B    <= 0;
                ID_EXE_NPC  <= 0;
                ID_EXE_IMMD <= 0;
            end    
            else begin
                if(IF_ID_IR[25:21] == 5'd0) ID_EXE_A <= 0;               // Consider R0 as constant 0
                else ID_EXE_A <= Reg_Bank[IF_ID_IR[25:21]];              // Source Register 1 
            
                if(IF_ID_IR[20:16] == 5'd0) ID_EXE_B <= 0;               // Consider R0 as constant 0
                else ID_EXE_B <= Reg_Bank[IF_ID_IR[20:16]];              // Source Register 2
            
                ID_EXE_IR <= IF_ID_IR;
                ID_EXE_NPC <= IF_ID_NPC;   
                ID_EXE_IMMD <= {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};   // Sign Extend the Immediate Data
                
            
                case(IF_ID_IR[31:26])                                    // Set the type of instruction 
                    ADD, SUB, AND, OR, MUL, SLT: ID_EXE_TYPE <= RR_ALU;
                    ADDI, SUBI, SLTI, MULI:      ID_EXE_TYPE <= RM_ALU;
                    LD:                          ID_EXE_TYPE <= LOAD;                 
                    ST:                          ID_EXE_TYPE <= STORE;  
                    BEQZ, BNEQZ:                 ID_EXE_TYPE <= BRANCH;
                    HLT:                         ID_EXE_TYPE <= HALT;
                    default:                     ID_EXE_TYPE <= HALT;
                endcase
            end    
        end
        
       // Execution Stage
       always @(posedge clk1)
       if(HALT_RECEIVED == 0) begin
           
           case(ID_EXE_TYPE)                                                 // Calculate ALUOUT
               RR_ALU: begin
                   case(ID_EXE_IR[31:26])                                    // Opcode
                       ADD:        EXE_MEM_ALUOUT <= ID_EXE_A + ID_EXE_B;
                       SUB:        EXE_MEM_ALUOUT <= ID_EXE_A - ID_EXE_B; 
                       AND:        EXE_MEM_ALUOUT <= ID_EXE_A & ID_EXE_B;
                       OR:         EXE_MEM_ALUOUT <= ID_EXE_A | ID_EXE_B;
                       MUL:        EXE_MEM_ALUOUT <= ID_EXE_A * ID_EXE_B;
                       SLT:        EXE_MEM_ALUOUT <= ID_EXE_A < ID_EXE_B;
                       default:    EXE_MEM_ALUOUT <= 32'hxxxxxxxx;
                   endcase
                   BRANCH_RECEIVED <= 1'b0;
               end  
               
               RM_ALU: begin
                   case(ID_EXE_IR[31:26])  
                       ADDI:      EXE_MEM_ALUOUT <= ID_EXE_A + ID_EXE_IMMD;
                       SUBI:      EXE_MEM_ALUOUT <= ID_EXE_A - ID_EXE_IMMD;
                       SLTI:      EXE_MEM_ALUOUT <= ID_EXE_A < ID_EXE_IMMD;
                       MULI:      EXE_MEM_ALUOUT <= ID_EXE_A * ID_EXE_IMMD;
                       default:   EXE_MEM_ALUOUT <= 32'hxxxxxxxx;
                   endcase
                   BRANCH_RECEIVED <= 1'b0;
               end  
               
               LOAD, STORE: begin
                   EXE_MEM_ALUOUT <= ID_EXE_A + ID_EXE_IMMD;
                   EXE_MEM_B <= ID_EXE_B;
                   BRANCH_RECEIVED <= 1'b0;
               end
               
               BRANCH: begin
                   EXE_MEM_ALUOUT <= ID_EXE_NPC + ID_EXE_IMMD;
                   EXE_MEM_cond <= (ID_EXE_A == 0);
                   if(((ID_EXE_IR[31:26] == BEQZ) && (ID_EXE_A == 0)) || ((ID_EXE_IR[31:26] == BNEQZ) && (ID_EXE_A != 0)))
                       BRANCH_RECEIVED <= 1'b1;
               end
               
               HALT: BRANCH_RECEIVED <= 1'b0;
               
               FLUSHED: BRANCH_RECEIVED <= 1'b0;
           endcase 
           
           EXE_MEM_IR <= ID_EXE_IR;
           EXE_MEM_TYPE <= ID_EXE_TYPE;                                                                               
       end     
       
       // Memory Stage
       always @(posedge clk2)
       if(HALT_RECEIVED == 0) begin
           
           case(EXE_MEM_TYPE)
               RR_ALU, RM_ALU: MEM_WB_ALUOUT <= EXE_MEM_ALUOUT;
               LOAD:           MEM_WB_LOAD <= Mem[EXE_MEM_ALUOUT];
               STORE:          Mem[EXE_MEM_ALUOUT] <= EXE_MEM_B; 
               FLUSHED:        begin end                     
                                  
           endcase
           
           MEM_WB_TYPE <= EXE_MEM_TYPE;
           MEM_WB_IR <= EXE_MEM_IR;
       end       
       
       // Write Back Stage
       always @(posedge clk1)
           begin
              case(MEM_WB_TYPE)
                   RR_ALU:   Reg_Bank[MEM_WB_IR[15:11]] <= MEM_WB_ALUOUT;
                   RM_ALU:   Reg_Bank[MEM_WB_IR[20:16]] <= MEM_WB_ALUOUT;
                   LOAD:     Reg_Bank[MEM_WB_IR[20:16]] <= MEM_WB_LOAD;
                   FLUSHED:  begin end
                   HALT:     HALT_RECEIVED <= 1'b1;                           // HALT here so that all the previous instructions are unaffected
               endcase
           end                                                                     
              
endmodule