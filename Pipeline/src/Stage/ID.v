`include "ID/Branch_Comparator.v"
`include "ID/Controller.v"
`include "ID/Decoder.v"
`include "ID/RegFile.v"
`include "ID/CSR_RegFile.v"

module ID (
    input         clk,
    input         rst,
    input         RegWrite_in,
    input   [4:0]  rd_in,
    input   [31:0] instruction,
    input   [31:0] pc,
    input   [31:0] Write_data,

    output [6:0]  opcode,
    output [4:0]  rs1,
    output [4:0]  rs2,
    output [4:0]  rd_out,
    output [2:0]  funct3,
    output [6:0]  funct7,
    output [31:0] Read_data_1,
    output [31:0] Read_data_2,

    output      branch_taken,
////Controller
    output          Branch,
    output          MemREAD,
    output          MemtoReg,
    output [1:0]  MemWrite,
    output           ALUSrc,
    output           RegWrite,
    output [4:0]  ALUOp
);

    //csr wire
    wire [31:0] csr_wd, mepc, mstatus, mtvec, interrupt_handler_address ;
    wire interrupt_enable, csr_we, interrupt_assert;
    wire [11:0] csr_wa;

    Branch_Comparator branch_comparator(
        .funct3(funct3), 
        .opcode(opcode), 
        .Read_data_1(Read_data_1), 
        .Read_data_2(Read_data_2), 
        .branch_taken(branch_taken)
    );

    Controller controller(
        .opcode(opcode), 
        .funct3(funct3), 
        .funct7(funct7), 
        .Branch(Branch), 
        .MemREAD(MemRead), 
        .MemtoReg(MemtoReg), 
        .MemWrite(MemWrite), 
        .ALUSrc(ALUSrc), 
        .RegWrite(RegWrite)
    );

    wire [11:0] csr_addr;
    Decoder decoder(
        .instruction(instruction), 
        .opcode(opcode), 
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd_out), 
        .funct3(funct3), 
        .funct7(funct7),

        .interrupt_assert(interrupt_assert),
        .interrupt_handler_address(interrupt_handler_address),
        .csr_we_id2ex(), //to id_ex
        .csr_addr(csr_addr)
    );

    RegFile regfile(
        .clk(clk),
        .Read_register_1(rs1), 
        .Read_register_2(rs2), 
        .Write_register(rd_in), 
        .Write_data(Write_data), 
        .RegWrite(RegWrite_in), 
        .Read_data_1(Read_data_1), 
        .Read_data_2(Read_data_2)
    );



    CSR_RegFile csr(
        .clk(clk),
        .rst(rst),
        .csr_ra_id(csr_addr),
        
        //id_ex input
        .csr_we_ex(),
        .csr_wa_ex(),
        .csr_wd_ex(),

        .we_clint(csr_we),
        .wa_clint(csr_wa),
        .wd_clint(csr_wd),
        .csr_rd(), //to id_ex

        .clint_csr_mstatus(mstatus),
        .clint_csr_mepc(mepc),
        .clint_csr_mtvec(mtvec),
        .interrupt_enable(interrupt_enable)
    );

    CLINT Clint(
        .clk(clk),
        .rst(rst),
        .interrupt_flag(),
        .inst(instruction),
        .inst_addr_if(pc),

        .jump_flag(),
        .jump_addr(),

        .csr_mtvec(mtvec),
        .csr_mepc(mepc),
        .csr_mstatus(mstatus),
        .interrupt_enable(interrupt_enable),
        
        .ctrl_stall_flag(),

        .csr_reg_we(csr_we),
        .csr_reg_wa(csr_wa),
        .csr_reg_wd(csr_wd),

        .id_interrupt_handler_addr(interrupt_handler_address),
        .id_interrupt_assert(interrupt_assert)
    );



endmodule