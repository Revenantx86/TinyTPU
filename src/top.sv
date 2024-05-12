module top #
(
    parameter D_W = 8,
    parameter N = 2,
    parameter WORD = 8
)
(
    input  wire clk,
    input  wire rst,
    input  wire data_in_x,
    input  wire data_in_y,
    input  wire load_en,
    input  wire init,
    output reg data_out_z,
    output reg tx_ready
);
//
// REG & WIRES
wire  [D_W-1:0]   data_core_x  [N-1:0];
wire  [D_W-1:0]   data_core_y  [N-1:0];
wire  [2*D_W-1:0] data_core_z   [N-1:0][N-1:0];
//
/*
    Input Control Module
*/
control #(.D_W(D_W), .N(N), .WORD(WORD)) 
        control_inst (
                        .clk(clk),
                        .rst(rst),
                        .data_in_x(data_in_x),
                        .data_in_y(data_in_y),
                        .load_en(load_en),
                        .init(init),
                        .out_x(data_core_x),
                        .out_y(data_core_y)
                     );

output_control #(.D_W(D_W), .N(N))
        output_control_inst (
                                .clk(clk),
                                .rst(rst),
                                .core_out_z(data_core_z),
                                .init(init),
                                .data_out_z(data_out_z),
                                .tx_ready(tx_ready)
                            );
/*
    Systolic Core
*/
systolic #(.D_W(D_W), .N(N)) 
        systolic_inst (
                        .clk(clk),
                        .rst(rst),
                        .init(init),
                        .x(data_core_x),
                        .y(data_core_y),
                        .z(data_core_z)
                      );
//
//
//
endmodule