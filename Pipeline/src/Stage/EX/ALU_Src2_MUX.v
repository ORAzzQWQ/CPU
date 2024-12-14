module ALU_Sr2c_MUX (
    input             ALU_Src,
    input       [1:0] FowardB,
    input      [31:0] imm,
    input      [31:0] Read_data_2,
    input      [31:0] rd_data,
    input      [31:0] Write_data,
    output reg [31:0] ALU_in2
);
    always@*begin
        case(ForwardB)
            2'b00: ALU_in2 = (ALU_Src) ? imm : Read_data_2;
            2'b01: ALU_in2 = Write_data;
            2'b10: ALU_in2 = rd_data;
        endcase
    end
endmodule
