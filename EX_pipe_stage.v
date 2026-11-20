`timescale 1ns / 1ps

module EX_pipe_stage (
    input [31:0] id_ex_instr,
    input [31:0] reg1,
    reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A,
    Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
);

  // Write your code here
  wire zero;
  wire [3:0] alu_control;
  wire [31:0] alu_mux_output, Forward_A_mux_output, Forward_B_mux_output;

  assign alu_in2_out = Forward_B_mux_output;

  ALUControl EX_alu_ctrl (
      .ALUOp(id_ex_alu_op),
      .Function(id_ex_instr[5:0]),
      .ALU_Control(alu_control)
  );

  ALU EX_alu (
      .a(Forward_A_mux_output),
      .b(alu_mux_output),
      .alu_control(alu_control),
      .zero(zero),
      .alu_result(alu_result)
  );

  mux4 #(
      .mux_width(32)
  ) Forward_A_mux (
      .a  (reg1),
      .b  (mem_wb_write_back_result),
      .c  (ex_mem_alu_result),
      .d  (32'd0),
      .sel(Forward_A),
      .y  (Forward_A_mux_output)
  );

  mux4 #(
      .mux_width(32)
  ) Forward_B_mux (
      .a  (reg2),
      .b  (mem_wb_write_back_result),
      .c  (ex_mem_alu_result),
      .d  (32'd0),
      .sel(Forward_B),
      .y  (Forward_B_mux_output)
  );

  mux2 #(
      .mux_width(32)
  ) EX_alu_mux (
      .a  (Forward_B_mux_output),
      .b  (id_ex_imm_value),
      .sel(id_ex_alu_src),
      .y  (alu_mux_output)
  );

endmodule
