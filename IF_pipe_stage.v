`timescale 1ns / 1ps

module IF_pipe_stage (
    input clk,
    reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
);

  // write your code here
  reg  [ 9:0] pc;
  wire [ 9:0] pc_next;
  wire [ 9:0] pc_branch;
  wire [31:0] q;

  always @(posedge clk or posedge reset) begin
    if (reset) pc <= 10'd0;
    else if (en) pc <= pc_next;
  end

  assign pc_plus4 = pc + 4;

  // branch mux
  mux2 #(
      .mux_width(10)
  ) branch_mux (
      .a  (pc_plus4),
      .b  (branch_address),
      .sel(branch_taken),
      .y  (pc_branch)
  );

  // jump mux
  mux2 #(
      .mux_width(10)
  ) jump_mux (
      .a  (pc_branch),
      .b  (jump_address),
      .sel(jump),
      .y  (pc_next));

  // getting instruction from instruction memory
  instruction_mem instr_mem (
      .read_addr(pc),
      .data(instr)
  );


endmodule
