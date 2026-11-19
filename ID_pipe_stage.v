`timescale 1ns / 1ps


module ID_pipe_stage (
    input clk,
    reset,
    input [9:0] pc_plus4,
    input [31:0] instr,
    input mem_wb_reg_write,
    input [4:0] mem_wb_write_reg_addr,
    input [31:0] mem_wb_write_back_data,
    input Data_Hazard,
    input Control_Hazard,
    output [31:0] reg1,
    reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg,
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
);

  // write your code here
  // Remember that we test if the branch is taken or not in the decode stage.

  wire hazard_flush_signal, equality_test;
  wire reg_dst, ctrl_mtr, ctrl_mr, ctrl_mw, ctrl_alu_src, ctrl_rw, branch;
  wire [1:0] ctrl_alu_op;
  wire [5:0] opcode;
  wire [6:0] control_signals, control_outputs;

  sign_extend sign_extend_value (
      .sign_ex_in (instr[15:0]),
      .sign_ex_out(imm_value)
  );

  assign jump_address = {instr[7:0], 2'b00};
  assign branch_address = pc_plus4 + (imm_value << 2);

  assign opcode = instr[31:26];
  control control_module (
      .reset(reset),
      .opcode(opcode),
      .reg_dst(reg_dst),
      .mem_to_reg(ctrl_mtr),
      .alu_op(ctrl_alu_op),
      .mem_read(ctrl_mr),
      .mem_write(ctrl_mw),
      .alu_src(ctrl_alu_src),
      .reg_write(ctrl_rw),
      .branch(branch),
      .jump(jump)
  );

  assign hazard_flush_signal = (~Data_Hazard | Control_Hazard);
  assign control_signals = {ctrl_mtr, ctrl_alu_op, ctrl_mr, ctrl_mw, ctrl_alu_src, ctrl_rw};
  assign {mem_to_reg, alu_op, mem_read, mem_write, alu_src, reg_write} = control_outputs;
  mux2 #(
      .mux_width(7)
  ) control_signals_mux (
      .a  (control_signals),
      .b  (7'd0),
      .sel(hazard_flush_signal),
      .y  (control_outputs)
  );

  // register dest mux
  mux2 #(
      .mux_width(5)
  ) register_dest_mux (
      .a  (instr[20:16]),
      .b  (instr[15:11]),
      .sel(reg_dst),
      .y  (destination_reg)
  );

  register_file reg_file (
      .clk(clk),
      .reset(reset),
      .reg_write_en(mem_wb_reg_write),
      .reg_write_dest(mem_wb_write_reg_addr),
      .reg_write_data(mem_wb_write_back_data),
      .reg_read_addr_1(instr[25:21]),
      .reg_read_addr_2(instr[20:16]),
      .reg_read_data_1(reg1),
      .reg_read_data_2(reg2)
  );

  assign equality_test = ((reg1 ^ reg2) == 32'd0) ? 1 : 0;
  assign branch_taken  = (equality_test & branch);

endmodule
