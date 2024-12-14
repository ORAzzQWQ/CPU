module CLINT (
    input wire clk,
    input wire rst,
    
    // Interrupt inputs
    input wire [7:0] interrupt_flag,
    
    // Instruction inputs
    input wire [31:0] inst,
    input wire [31:0] inst_addr_if,
    
    // Jump control
    input wire jump_flag,
    input wire [31:0] jump_addr,
    
    // CSR register inputs
    input wire [31:0] csr_mtvec,
    input wire [31:0] csr_mepc,
    input wire [31:0] csr_mstatus,
    input wire interrupt_enable,
    
    // Control outputs
    output reg ctrl_stall_flag,
    
    // CSR control outputs
    output reg csr_reg_we,
    output reg [11:0] csr_reg_wa,
    output reg [31:0] csr_reg_wd,
    
    // Interrupt control outputs
    output reg [31:0] id_interrupt_handler_addr,
    output reg id_interrupt_assert
);
    
    // Interrupt State
    localparam STATE_IDLE = 2'b00;
    localparam STATE_SYNC_ASSERT = 2'b01;
    localparam STATE_ASYNC_ASSERT = 2'b10;
    localparam STATE_MRET = 2'b11;
    
    // CSR State
    localparam CSR_IDLE = 3'b000;
    localparam CSR_MSTATUS = 3'b001;
    localparam CSR_MEPC = 3'b010;
    localparam CSR_MRET = 3'b011;
    localparam CSR_MCAUSE = 3'b100;

    // Internal registers
    reg [1:0] interrupt_state;
    reg [2:0] csr_state;
    reg [31:0] inst_addr;
    reg [31:0] cause;
    
    // Interrupt state machine
    always @(*) begin
        if(inst == `ECALL || inst == `EBREAK)
            interrupt_state = STATE_SYNC_ASSERT;
        else if (interrupt_flag != 0 && interrupt_enable)
            interrupt_state = STATE_ASYNC_ASSERT;
        else if(inst == `MRET)
            interrupt_state = STATE_MRET;
        else
            interrupt_state = STATE_IDLE
    end

    // CSR state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            csr_state <= CSR_IDLE;
            inst_addr <= 32'b0;
            cause <= 32'b0;
        end
        else begin
            case (csr_state)
                CSR_IDLE: begin
                    case (interrupt_state)
                        STATE_SYNC_ASSERT: begin
                            csr_state <= CSR_MEPC;
                            inst_addr <= jump_flag ? (jump_addr - 32'h4) : inst_addr_if;
                            case (inst)
                                `ECALL: cause <= 32'd11;
                                `EBREAK: cause <= 32'd3;
                                default: cause <= 32'd10;
                            endcase
                        end
                        STATE_ASYNC_ASSERT: begin
                            csr_state <= CSR_MEPC;
                            instruction_address <= jump_flag ? jump_address : instruction_address_if;
                            cause <= interrupt_flag[0] ? 32'h80000007 : 32'h8000000B;
                        end
                        STATE_MRET: begin
                            csr_state <= CSR_MRET;
                        end
                        default: csr_state <= CSR_IDLE;
                    endcase
                end
                CSR_MEPC: csr_state <= CSR_MSTATUS;
                CSR_MSTATUS: csr_state <= CSR_MCAUSE;
                CSR_MCAUSE: csr_state <= CSR_IDLE;
                CSR_MRET: csr_state <= CSR_IDLE;
                default: csr_state <= CSR_IDLE;
            endcase
        end
    end

    // Control signals
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ctrl_stall_flag <= 1'b0;
            csr_reg_we <= 1'b0;
            csr_reg_wa <= 12'b0;
            csr_reg_wd <= 32'b0;
            id_interrupt_assert <= 1'b0;
            id_interrupt_handler_addr <= 32'b0;
        end
        else begin
            ctrl_stall_flag <= (interrupt_state != STATE_IDLE) || (csr_state != CSR_IDLE);
            csr_reg_we <= (csr_state != CSR_IDLE);
            
            // CSR write address
            case (csr_state)
                CSR_MEPC: csr_reg_wa <= `MEPC;
                CSR_MCAUSE: csr_reg_wa <= `MCAUSE;
                CSR_MSTATUS, CSR_MRET: csr_reg_wa <= `MSTATUS;
                default: csr_reg_wa <= 12'b0;
            endcase
            
            // CSR write data
            case (csr_state)
                CSR_MEPC: csr_reg_wd <= inst_addr;
                CSR_MCAUSE: csr_reg_wd <= cause;
                CSR_MSTATUS: csr_reg_wd <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                CSR_MRET: csr_reg_wd <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                default: csr_reg_wd <= 32'b0;
            endcase
            
            // Interrupt assert and handler address
            id_interrupt_assert <= (csr_state == CSR_MCAUSE) || (csr_state == CSR_MRET);
            id_interrupt_handler_addr <= (csr_state == CSR_MCAUSE) ? csr_mtvec :
                                         (csr_state == CSR_MRET) ? csr_mepc : 32'b0;
        end
    end

endmodule