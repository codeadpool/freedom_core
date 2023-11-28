`timescale 1ns / 1ps
module registerFile (

    input clk,
    input reset, 
    input write_enable,

    input [4:0] read_reg1,
    input [4:0] read_reg2,

    input [4:0] write_reg,
    input [31:0] write_data,

    output  [31:0] read_data1,
    output  [31:0] read_data2
);

integer i;
reg [31:0] cpu_registers [31:0];

// for easing simulation, declaring reg0 to 0
initial begin
    cpu_registers[0] = 32'b0;
end

// hardwried reg0 to 0
assign read_data1 = (read_reg1 != 0) ? cpu_registers[read_reg1] : 32'b0;
assign read_data2 = (read_reg2 != 0) ? cpu_registers[read_reg2] : 32'b0;

always @(posedge clk) begin
    if (reset) begin   
        for (i = 1; i < 32; i = i + 1) begin
            cpu_registers[i] <= 32'b0;
        end
    end else if (write_enable && write_reg != 5'b0) begin
        cpu_registers[write_reg] <= write_data;
    end
end

endmodule
