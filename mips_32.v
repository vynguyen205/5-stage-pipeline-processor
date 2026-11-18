`timescale 1ns / 1ps

module mips_32 (
    input clk,
    reset,
    output [31:0] result
);

  // define all the wires here. You need to define more wires than the ones you did in Lab2

  wire en, flush, branch_taken, jump;
  wire mem_wb_reg_write;
  wire mem_to_reg, mem_read, mem_write, alu_src, reg_write;
  wire Data_Hazard, Control_Hazard;
  wire id_ex_mem_to_reg, id_ex_mem_read, id_ex_mem_write;
  wire id_ex_alu_src, id_ex_reg_write;
  wire ex_mem_mem_to_reg, ex_mem_mem_read, ex_mem_mem_write, ex_mem_reg_write;

  wire [1:0] alu_op, id_ex_alu_op;
  wire [1:0] Forward_A, Foward_B;
  wire [9:0] branch_address, jump_address;
  wire [9:0] pc, pc_plus4, if_id_pc_plus4;
  wire [31:0] write_back_data, mem_wb_write_back_data;
  wire [31:0] instr, if_id_instr, id_ex_instr, ex_mem_instr;
  wire [31:0] imm_value, id_ex_imm_value;
  wire [31:0] reg1, reg2, id_ex_reg1, id_ex_reg2;
  wire [31:0] alu_result, alu_in2_out, ex_mem_alu_result, ex_mem_alu_in2_out;
  wire [4:0] destination_reg, id_ex_destination_reg, ex_mem_destination_reg;
  wire [4:0] mem_wb_write_reg_addr, mem_wb_destination_reg;
  wire [6:0] ID_EX_control_signals, ID_EX_control_outputs;
  wire [3:0] EX_MEM_control_signals, EX_MEM_control_outputs;

  // Build the pipeline as indicated in the lab manual

  ///////////////////////////// Instruction Fetch
  // Complete your code here
  IF_pipe_stage IF_stage (
      .clk(clk),
      .reset(reset),
      .en(en),
      .branch_address(branch_address),
      .jump_address(jump_address),
      .branch_taken(branch_taken),
      .jump(jump),
      .pc_plus4(pc_plus4),
      .instr(instr)
  );

  ///////////////////////////// IF/ID registers
  // Complete your code here
  // store pc+4 into piepline IF/ID register for later use
  pipe_reg_en #(
      .WIDTH(32)
  ) instr_pipe (
      .clk(clk),
      .reset(reset),
      .flush(flush),
      .en(en),
      .d(instr),
      .q(if_id_instr)
  );

  // store instr into piepline IF/ID register for later use
  pipe_reg_en #(
      .WIDTH(10)
  ) pc_plus4_pipe (
      .clk(clk),
      .reset(reset),
      .flush(flush),
      .en(en),
      .d(pc_plus4),
      .q(if_id_pc_plus4)
  );

  ///////////////////////////// Instruction Decode
  // Complete your code here
  ID_pipe_stage ID_stage (
      .clk(clk),
      .reset(reset),
      .pc_plus4(if_id_pc_plus4),
      .instr(if_id_instr),
      .mem_wb_reg_write(mem_wb_reg_write),
      .mem_wb_write_reg_addr(mem_wb_destination_reg),
      .mem_wb_write_back_data(write_back_data),
      .Data_Hazard(Data_Hazard),
      .Control_Hazard(Control_Hazard),
      .reg1(reg1),
      .reg2(reg2),
      .imm_value(imm_value),
      .branch_address(branch_address),
      .jump_address(jump_address),
      .branch_taken(branch_taken),
      .destination_reg(destination_reg),
      .mem_to_reg(mem_to_reg),
      .alu_op(alu_op),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .alu_src(alu_src),
      .reg_write(reg_write),
      .jump(jump)
  );


  ///////////////////////////// ID/EX registers
  // Complete your code here
  pipe_reg #(
      .WIDTH(32)
  ) ID_EX_reg1 (
      .clk(clk),
      .reset(reset),
      .d(reg1),
      .q(id_ex_reg1)
  );

  pipe_reg #(
      .WIDTH(32)
  ) ID_EX_reg2 (
      .clk(clk),
      .reset(reset),
      .d(reg2),
      .q(id_ex_reg2)
  );

  pipe_reg #(
      .WIDTH(32)
  ) ID_EX_instr (
      .clk(clk),
      .reset(reset),
      .d(if_id_instr),
      .q(id_ex_instr)
  );

  pipe_reg #(
      .WIDTH(32)
  ) ID_EX_imm_val (
      .clk(clk),
      .reset(reset),
      .d(imm_value),
      .q(id_ex_imm_value)
  );

  pipe_reg #(
      .WIDTH(5)
  ) ID_EX_dest_reg (
      .clk(clk),
      .reset(reset),
      .d(destination_reg),
      .q(id_ex_destination_reg)
  );



  assign ID_EX_control_signals = {mem_to_reg, alu_op, mem_read, mem_write, alu_src, reg_write};
  assign {
    id_ex_mem_to_reg,
    id_ex_alu_op,
    id_ex_mem_read,
    id_ex_mem_write,
    id_ex_alu_src,
    id_ex_reg_write } = ID_EX_control_outputs;

  pipe_reg #(
      .WIDTH(7)
  ) ID_EX_signals (
      .clk(clk),
      .reset(reset),
      .d(ID_EX_control_signals),
      .q(ID_EX_control_outputs)
  );


  ///////////////////////////// Hazard_detection unit
  // Complete your code here    


  ///////////////////////////// Execution    
  // Complete your code here

  EX_pipe_stage EX_stage (
      .id_ex_instr(id_ex_instr),
      .reg1(id_ex_reg1),
      .reg2(id_ex_reg2),
      .id_ex_imm_value(id_ex_imm_value),
      .ex_mem_alu_result(ex_mem_alu_result),
      .mem_wb_write_back_result(write_back_data),
      .id_ex_alu_src(id_ex_alu_src),
      .id_ex_alu_op(id_ex_alu_op),
      .Foward_A(Foward_A),
      .Foward_B(Foward_B),
      .alu_in2_out(alu_in2_out),
      .alu_result(alu_result)
  );

  ///////////////////////////// Forwarding unit
  // Complete your code here 


  ///////////////////////////// EX/MEM registers
  // Complete your code here 

  pipe_reg #(
      .WIDTH(32)
  ) EX_MEM_instr (
      .clk(clk),
      .reset(reset),
      .d(id_ex_instr),
      .q(ex_mem_instr)
  );

  pipe_reg #(
      .WIDTH(5)
  ) EX_MEM_dest_reg (
      .clk(clk),
      .reset(reset),
      .d(id_ex_destination_reg),
      .q(ex_mem_destination_reg)
  );

  pipe_reg #(
      .WIDTH(32)
  ) EX_MEM_alu_result (
      .clk(clk),
      .reset(reset),
      .d(alu_result),
      .q(ex_mem_alu_result)
  );

  pipe_reg #(
      .WIDTH(32)
  ) EX_MEM_alu_in2_out (
      .clk(clk),
      .reset(reset),
      .d(alu_in2_out),
      .q(ex_mem_alu_in2_out)
  );

  assign EX_MEM_control_signals = {
    id_ex_mem_to_reg, id_ex_mem_read, id_ex_mem_write, id_ex_reg_write
  };
  assign {
    ex_mem_mem_to_reg,
    ex_mem_mem_read,
    ex_mem_mem_write,
    ex_mem_reg_write } = EX_MEM_control_outputs;

  pipe_reg #(
      .WIDTH(4)
  ) EX_MEM_signals (
      .clk(clk),
      .reset(reset),
      .d(EX_MEM_control_signals),
      .q(EX_MEM_control_outputs)
  );


  ///////////////////////////// memory    
  // Complete your code here


  ///////////////////////////// MEM/WB registers  
  // Complete your code here


  ///////////////////////////// writeback    
  // Complete your code here



endmodule
