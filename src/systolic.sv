module systolic #
(
    parameter D_W = 8,
    parameter N = 2
)
(
    input   wire             clk,                   // Clock Input
    input   wire             rst,                   // Reset cores & Regs
    input   reg              init,                  // Init process
    input   wire [D_W-1:0]   x       [N-1:0],       // Row input
    input   wire [D_W-1:0]   y       [N-1:0],       // Column input
    output  reg  [2*D_W-1:0] z       [N-1:0][N-1:0] // MAC unit indv outputs
);
//
// Initlize wires
//
wire [D_W-1:0]   in_x     [N-1:0][N-1:0];
wire [D_W-1:0]   in_y     [N-1:0][N-1:0];
wire [D_W-1:0]   out_x    [N-1:0][N-1:0];
wire [D_W-1:0]   out_y    [N-1:0][N-1:0];
wire [2*D_W-1:0] out_z    [N-1:0][N-1:0];
wire             init_in  [N-1:0][N-1:0];
wire             init_out [N-1:0][N-1:0];
// wire assign to output
assign z = out_z;
//
//initalize counter
//
// Initalize MAC module COL >> ROW
assign init_in[0][0] = init;
//
// Loop Generate MAC matrix
genvar i,j,k;
generate 
    //
    for(i=0; i<N; i=i+1) begin
        //
        // Assign initialization wire to first row
        if(i==0) begin
            for(k=0; k<N-1;k++) begin
                assign init_in[0][k+1] = init_out[0][k];
            end 
        end
        //
        for(j=0; j<N; j = j + 1) begin
            //
            // Assign wires to mac modules
            for(k=0;k<N-1;k=k+1) begin
                assign in_x[i][k+1] = out_x[i][k];
                assign in_y[k+1][j] = out_y[k][j];
            end
            //
            // Asssign initalization signal to columns
            if(i==0) begin
                for (k=0;k<N-1;k++) begin
                    assign init_in[k+1][j]=init_out[k][j];
                end
            end
            //
            // Input Columns & Row Assignment
            if(j==0) assign in_x[i][0] = x[i];
            if(i==0) assign in_y[0][j] = y[j];
            //
            mac #(.D_W(D_W)) mac_inst 
                (
                    .clk      (clk),
                    .rst      (rst),
                    .init     (init_in[i][j]),
                    .out_init (init_out[i][j]),
                    .in_x     (in_x[i][j]),
                    .in_y     (in_y[i][j]),
                    .out_x    (out_x[i][j]),
                    .out_y    (out_y[i][j]),
                    .out_z    (out_z[i][j])
                );
            //
        end
    end
    //
endgenerate
//
endmodule