`include "Stage/IF.v"
`include "Stage/IF_ID.v"
`include "Stage/ID.v"
`include "Stage/ID_EX.v"
`include "Stage/EX.v"
`include "Stage/EX_MEM.v"
`include "Stage/MEM.v"
`include "Stage/MEM_WB.v"
`include "Stage/WB.v"

module Top(
    input clk,
    input rst,
    input [31:0] data,
    input [31:0] instruction,
    output [31:0] pc,
    output [31:0] rd_data,
    output [31:0] Read_data_2,
    output MemREAD,
    output [1:0]MemWrite
);

    IF if_stage(
        .clk(clk),
        .rst(rst),
        .branch(Branch),
        .branch_taken(),
        .instruction_in(instruction),
        .instruction_out(instruction_out_IF),
        .pc(pc),
        .next_pc(next_pc),
        .imm(imm)
    );

    IF_ID if_id(
        .clk(clk),
        .pc_in(pc),
        .imm_in(imm),
        .instruction_in(instruction_out_IF),
        .pc_out(pc_out),
        .imm_out(imm_out),
        .instruction_out(instruction_out)
    );

    ID id(
        .clk(clk),
        .rst(rst),
        .RegWrite_in(RegWrite),
        .rd_in(rd_in),
        .instruction(instruction_out),
        .pc(pc_out),
        .Write_data(Write_data),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd_out(rd_out),
        .funct3(funct3),
        .funct7(funct7),
        .Read_data_1(Read_data_1),
        .Read_data_2(Read_data_2),
        .branch_taken(branch_taken),
        .Branch(Branch),
        .MemREAD(MemREAD),
        .MemtoReg(MemtoReg),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .ALUOp(ALUOp)
    );
endmodule