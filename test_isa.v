/**
 * Step 4: Creating a RISC-V processor
 *         The instruction decoder
 * central LED blinks, other LEDs show instr type.
 * DONE*
 */

`default_nettype none
// `include "clockworks.v"

module SOC (
    input  CLK,        // system clock 
    input  SW1,      // reset button
    output LED1,
    output LED2,
    output LED3,
    output LED4,
    output S2_A,
    output S2_B,
    output S2_C,
    output S2_D,
    output S2_E,
    output S2_F,
    output S2_G
);

    wire clk;    // internal clock
    wire resetn; // internal reset signal, goes low on reset

    reg [31:0] MEM [0:255]; 
    reg [31:0] PC;       // program counter
    reg [31:0] instr;    // current instruction

`include "riscv_assembly.v"

    initial begin
        PC = 0;
        ADD(x0,x0,x0);
        ADD(x1,x0,x0);
        ADDI(x1,x1,1);
        ADDI(x1,x1,1);
        ADDI(x1,x1,1);
        ADDI(x1,x1,1);
        ADD(x2,x1,x0);
        ADD(x3,x1,x2);
        SRLI(x3,x3,3);
        SLLI(x3,x3,31);
        SRAI(x3,x3,5);
        SRLI(x1,x3,26);
        EBREAK();
    end

    // See the table P. 105 in RISC-V manual

    // The 10 RISC-V instructions
    wire isALUreg  =  (instr[6:0] == 7'b0110011); // rd <- rs1 OP rs2   
    wire isALUimm  =  (instr[6:0] == 7'b0010011); // rd <- rs1 OP Iimm
    wire isBranch  =  (instr[6:0] == 7'b1100011); // if(rs1 OP rs2) PC<-PC+Bimm
    wire isJALR    =  (instr[6:0] == 7'b1100111); // rd <- PC+4; PC<-rs1+Iimm
    wire isJAL     =  (instr[6:0] == 7'b1101111); // rd <- PC+4; PC<-PC+Jimm
    wire isAUIPC   =  (instr[6:0] == 7'b0010111); // rd <- PC + Uimm
    wire isLUI     =  (instr[6:0] == 7'b0110111); // rd <- Uimm   
    wire isLoad    =  (instr[6:0] == 7'b0000011); // rd <- mem[rs1+Iimm]
    wire isStore   =  (instr[6:0] == 7'b0100011); // mem[rs1+Simm] <- rs2
    wire isSYSTEM  =  (instr[6:0] == 7'b1110011); // special

    // The 5 immediate formats
    wire [31:0] Uimm={    instr[31],   instr[30:12], {12{1'b0}}};
    wire [31:0] Iimm={{21{instr[31]}}, instr[30:20]};
    wire [31:0] Simm={{21{instr[31]}}, instr[30:25],instr[11:7]};
    wire [31:0] Bimm={{20{instr[31]}}, instr[7],instr[30:25],instr[11:8],1'b0};
    wire [31:0] Jimm={{12{instr[31]}}, instr[19:12],instr[20],instr[30:21],1'b0};

    // Source and destination registers
    wire [4:0] rs1Id = instr[19:15];
    wire [4:0] rs2Id = instr[24:20];
    wire [4:0] rdId  = instr[11:7];

    // Function codes
    wire [2:0] funct3 = instr[14:12];
    wire [6:0] funct7 = instr[31:25];

    // The registers bank
    reg [31:0] RegisterBank [0:31];
    reg [31:0] rs1;
    reg [31:0] rs2;
    wire [31:0] writeBackData;
    wire        writeBackEn;
   assign writeBackData = aluOut; 
   assign writeBackEn = (state == EXECUTE && (isALUreg || isALUimm));   

    //The ALU
    wire [31:0] aluIn1 = rs1;
    wire [31:0] aluIn2 = isALUreg ? rs2 : Iimm;
    reg [31:0] aluOut;
    wire [4:0] shamt = isALUreg ? rs2[4:0] : instr[24:20]; // shift amount

    //Check page 130 of RISC-V reference manual
    always @(*) begin
        case(funct3)
    3'b000: aluOut = (funct7[5] & instr[5]) ? (aluIn1-aluIn2) : (aluIn1+aluIn2);
    3'b001: aluOut = aluIn1 << shamt;
    3'b010: aluOut = ($signed(aluIn1) < $signed(aluIn2));
    3'b011: aluOut = (aluIn1 < aluIn2);
    3'b100: aluOut = (aluIn1 ^ aluIn2);
    3'b101: aluOut = funct7[5]? ($signed(aluIn1) >>> shamt) : (aluIn1 >> shamt); 
    3'b110: aluOut = (aluIn1 | aluIn2);
    3'b111: aluOut = (aluIn1 & aluIn2);	
        endcase
    end

    //Use a FSM to switch between fetch instruction, register and execute
    localparam FETCH_INSTR = 0;
    localparam FETCH_REGS  = 1;
    localparam EXECUTE     = 2;
    reg [1:0] state = FETCH_INSTR;

    always @(posedge clk) begin
    if(SW1) begin
        PC    <= 0;
        state <= FETCH_INSTR;
        instr <= 32'b0000000_00000_00000_000_00000_0110011; // NOP
    end else begin
        //Continuously write back to registers
        if(writeBackEn && rdId != 0) begin
        RegisterBank[rdId] <= writeBackData;
        LED1 <= writeBackData[0];
        LED2 <= writeBackData[1];
        LED3 <= writeBackData[2];
        LED4 <= writeBackData[3];
    end
    
    case(state)
    FETCH_INSTR: begin
        instr <= MEM[PC];
        state <= FETCH_REGS;
    end
    FETCH_REGS: begin
        rs1 <= RegisterBank[rs1Id];
        rs2 <= RegisterBank[rs2Id];
        state <= EXECUTE;
    end
    EXECUTE: begin
        if(!isSYSTEM) begin
        PC <= PC + 1;
        end
        state <= FETCH_INSTR;	          
    end
    endcase
    end 
    end 
    
    hexConverter hex_value_data(
        .bitin(PC),
        .a_output(S2_A),
        .b_output(S2_B),
        .c_output(S2_C),
        .d_output(S2_D),
        .e_output(S2_E),
        .f_output(S2_F),
        .g_output(S2_G)
    );

    // Gearbox and reset circuitry.
    Clockworks #(
        .SLOW(21) // Divide clock frequency by 2^21
    )CW(
        .CLK(CLK),
        .RESET(SW1),
        .clk(clk),
        .resetn(resetn)
    );
   
endmodule