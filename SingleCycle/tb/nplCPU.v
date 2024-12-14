`timescale 1ns/1ps
`include "Top.v"
`include "Instruction_Memory.v"
`include "Data_Memory.v"
`include "tsmc18.v"
module CPU_Testbench;

    reg clk;
    reg rst;
    wire [31:0] rd_data;
    wire [31:0] pc;
    wire [31:0] instruction;
    wire [31:0] Mem_out;
    wire MemRead;
    wire [1:0] MemWrite;
    wire [31:0] Read_data_2;


    // Instantiate the DUT (Top Module)
    Top dut (
        .clk(clk),
        .rst(rst),
        .data(Mem_out),
        .rd_data(rd_data),
        .instruction(instruction), 
        .MemREAD(MemRead),
        .MemWrite(MemWrite),
        .Read_data_2(Read_data_2),
        .pc(pc)

    );

    Data_Memory data_memory(
        .clk(clk), 
        .address(rd_data), 
        .write_data(Read_data_2), 
        .read_data(Mem_out),
        .MemREAD(MemRead), 
        .MemWrite(MemWrite)
    );

    Instruction_Memory instruction_memory(
        .clk(clk), 
        .pc(pc), 
        .instruction(instruction)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end

    // Initialize memory and simulation
    initial begin
        rst = 1;
        #20 rst = 0;


        // Load instructions into instruction memory
        $readmemh("rv32i_test.hex", instruction_memory.sram.mem);

        // Load data into data memory
        $readmemh("rv32i_test.hex", data_memory.sram.mem);

        // Run for sufficient time
        repeat (10000) @(posedge clk);

        // Verify the results
        check_registers();
        check_memory();
        check_hand_calculated();
        $finish;
    end

    // Function to check final register values
    task check_registers;
        begin
            $display("Checking Register File...");
            check_value("x1", dut.regfile.Registers[1], 32'h0000000A);
            check_value("x2", dut.regfile.Registers[2], 32'h00000014);
            check_value("x3", dut.regfile.Registers[3], 32'h0000001E);
            check_value("x4", dut.regfile.Registers[4], 32'h0000000A);
            check_value("x5", dut.regfile.Registers[5], 32'h12345000);
            check_value("x6", dut.regfile.Registers[6], 32'h00000000);
            check_value("x7", dut.regfile.Registers[7], 32'h0000001E);
            check_value("x8", dut.regfile.Registers[8], 32'h0000001E);
            check_value("x9", dut.regfile.Registers[9], 32'h0000000A);
            check_value("x10", dut.regfile.Registers[10], 32'h0000000F);
            check_value("x11", dut.regfile.Registers[11], 32'h00000005);
            check_value("x12", dut.regfile.Registers[12], 32'h00000028);
            check_value("x13", dut.regfile.Registers[13], 32'h00000005);
            check_value("x14", dut.regfile.Registers[14], 32'h00000005);
            check_value("x15", dut.regfile.Registers[15], 32'h00000001);
            check_value("x16", dut.regfile.Registers[16], 32'h00000000);
            check_value("x17", dut.regfile.Registers[17], 32'h00000001);
            check_value("x18", dut.regfile.Registers[18], 32'h00000000);
            check_value("x19", dut.regfile.Registers[19], 32'h00000001);
            check_value("x20", dut.regfile.Registers[20], 32'h00001000);
            check_value("x21", dut.regfile.Registers[21], 32'h0000000A);
            check_value("x22", dut.regfile.Registers[22], 32'h00000014);
            check_value("x23", dut.regfile.Registers[23], 32'h00001004);
            check_value("x31", dut.regfile.Registers[31], 32'h00000000);
        end
    endtask


    // Function to compare memory with hand-calculated expected values
    task check_hand_calculated;
        begin
            $display("Checking Hand Calculated Results...");
            check_value("add", data_memory.sram.mem[0], 15);
            check_value("sub", data_memory.sram.mem[1], 5);
            check_value("and", data_memory.sram.mem[2], 0);
            check_value("or", data_memory.sram.mem[3], 15);
            check_value("xor", data_memory.sram.mem[4], 15);
            check_value("sll", data_memory.sram.mem[5], 320);
            check_value("srl", data_memory.sram.mem[6], 0);
            check_value("sra", data_memory.sram.mem[7], 0);
            check_value("slt", data_memory.sram.mem[8], 0);
            check_value("sltu", data_memory.sram.mem[9], 0);
            check_value("beq", data_memory.sram.mem[10], 1);
            check_value("bne", data_memory.sram.mem[11], 1);
            check_value("blt", data_memory.sram.mem[12], 1);
            check_value("bge", data_memory.sram.mem[13], 1);
            check_value("bltu", data_memory.sram.mem[14], 1);
            check_value("bgeu", data_memory.sram.mem[15], 1);
            check_value("jal", data_memory.sram.mem[16], 42);
            check_value("jalr", data_memory.sram.mem[17], 0);
            check_value("lw", data_memory.sram.mem[18], 10);
        end
    endtask

    // Function to compare values and display results
    task check_value(input [31:0] name, input [31:0] value, input [31:0] expected);
        if (value !== expected) begin
            $display("ERROR: %s = 0x%h, expected 0x%h", name, value, expected);
        end else begin
            $display("PASS: %s = 0x%h", name, value);
        end
    endtask
    
endmodule
