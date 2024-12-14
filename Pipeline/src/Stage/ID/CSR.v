module CSR_RegFile (
    input clk,
    input rst,
    
    input csr_we_ex,
    input [11:0] csr_ra_id,
    input [11:0] csr_wa_ex,
    input [31:0] csr_wd_ex,
    
    input we_clint,
    //input [11:0] ra_clint,
    input [11:0] wa_clint,
    input [31:0] wd_clint,

    //to id_ex
    output [31:0] csr_rd,

    // to clint
    output reg [31:0] clint_csr_mstatus,
    output reg [31:0] clint_csr_mepc,
    output reg [31:0] clint_csr_mtvec,
    output reg interrupt_enable
);

    // CSR Registers
    reg [63:0] cycles;
    reg [31:0] mtvec;
    reg [31:0] mcause;
    reg [31:0] mepc;
    reg [31:0] mie;
    reg [31:0] mstatus;
    reg [31:0] mscratch;

    wire [11:0] wa, ra;
    wire [31:0] wd, rd;

    // Cycle counter
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cycles <= 64'b0;
        end else begin
            cycles <= cycles + 1'b1;
        end
    end

    // CSR write control
    always @(*) begin
        if (csr_we_ex) begin
            wa = csr_wa_ex;
            wd = csr_wd_ex;
        end
        else if (we_clint) begin
            wa = wa_clint;
            wd  = wd_clint;
        end
        else begin
            wa = 12'b0;
            wd = 32'b0;
        end
    end


    // Write logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mstatus  <= 32'b0;
            mie      <= 32'b0;
            mtvec    <= 32'b0;
            mscratch <= 32'b0;
            mepc     <= 32'b0;
            mcause   <= 32'b0;
        end else begin
            case (wa)
                `MTVEC:    mtvec <= wd;
                `MCAUSE:   mcause <= wd;
                `MEPC:     mepc <= wd;
                `MIE:      mie <= wd;
                `MSTATUS:  mstatus <= wd;
                `MSCRATCH: mscratch <= wd;
            endcase
        end
    end

        // CSR read operation for ID stage
    always @(*) begin
        case (csr_ra_id)
            // `CYCLEL:   csr_rd = cycles[31:0];
            // `CYCLEH:   csr_rd = cycles[63:32];
            `MTVEC:    csr_rd = mtvec;
            `MCAUSE:   csr_rd = mcause;
            `MEPC:     csr_rd = mepc;
            `MIE:      csr_rd = mie;
            `MSTATUS:  csr_rd = mstatus;
            `MSCRATCH: csr_rd = mscratch;
            default:      csr_rd = 32'b0;
        endcase
    end

    assign interrupt_enable = (mstatus[3] == 1'b1);
    assign clint_csr_mtvec = mtvec;
    assign clint_csr_mepc = mepc;
    assign clint_csr_mstatus = mstatus;

    // // CSR read operation for CLINT
    // always @(*) begin
    //     case (ra_clint)
    //         `CYCLEL:   clint_reg_data = cycles[31:0];
    //         `CYCLEH:   clint_reg_data = cycles[63:32];
    //         `MTVEC:    clint_reg_data = mtvec;
    //         `MCAUSE:   clint_reg_data = mcause;
    //         `MEPC:     clint_reg_data = mepc;
    //         `MIE:      clint_reg_data = mie;
    //         `MSTATUS:  clint_reg_data = mstatus;
    //         `MSCRATCH: clint_reg_data = mscratch;
    //         default:      clint_reg_data = 32'b0;
    //     endcase
    // end

    // Output assignments


endmodule

