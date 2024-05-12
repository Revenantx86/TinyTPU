module control # 
(
    parameter D_W = 8,
    parameter N = 2,
    parameter WORD = 8
)
(
    input wire clk,
    input wire rst,
    input wire data_in_x,
    input wire data_in_y,
    input wire load_en,
    input wire init,
    output reg [D_W-1:0] out_x [N-1:0],
    output reg [D_W-1:0] out_y [N-1:0]
);
//
/*
    State Machine
*/
enum {IDLE,LOAD,TRANSFER} STATE;
//
/*
    Generate Memory Block
*/
reg  [$clog2(WORD)-1:0] addr_x_ram     [N-1:0];
reg                     rd_en_x_ram    [N-1:0];
reg                     wr_en_x_ram    [N-1:0];
reg  [D_W-1:0]          data_in_x_reg;
//
reg  [$clog2(WORD)-1:0] addr_y_ram     [N-1:0];
reg                     rd_en_y_ram    [N-1:0];
reg                     wr_en_y_ram    [N-1:0];
reg  [D_W-1:0]          data_in_y_reg;
//
genvar n;
generate 
    for(n=0;n<N;n++) begin
        //Initalize memory X & Y
        dff_mem #( .D_W(D_W), .WORD(WORD)) 
                mem_x (
                        .clk(clk),
                        .rst(rst),
                        .addr(addr_x_ram[n]),
                        .rd_en(rd_en_x_ram[n]),
                        .wr_en(wr_en_x_ram[n]),
                        .data_in(data_in_x_reg),
                        .data_out(out_x[n])
                    );
        dff_mem #( .D_W(D_W), .WORD(WORD)) 
                mem_y (
                        .clk(clk),
                        .rst(rst),
                        .addr(addr_y_ram[n]),
                        .rd_en(rd_en_y_ram[n]),
                        .wr_en(wr_en_y_ram[n]),
                        .data_in(data_in_y_reg),
                        .data_out(out_y[n])
                    );
    end
endgenerate

always @(posedge clk) begin
    if(rst) begin
        STATE <= IDLE;
    end
    else begin
        case(STATE) 
        IDLE: begin
            if(load_en) 
                STATE <= LOAD;
            else if(init)
                STATE <= TRANSFER;
        end
        LOAD: begin
            if(!load_en)
                STATE <= IDLE;
        end
        TRANSFER: begin
            if(rd_en_x_ram[N-1]) 
                STATE <= IDLE;
        end
        endcase
    end
end


reg [$clog2(D_W)-1:0]       bit_counter;
reg [$clog2(N)-1:0]         addr_counter;
reg [$clog2(N)-1:0]         ram_counter;

integer i;
always @(posedge clk) begin
    if(rst) begin
        //
        bit_counter   <= 0;
        addr_counter  <= 0;
        ram_counter   <= 0;
        data_in_x_reg <= 0;
        data_in_y_reg <= 0;
        //
        for(i=0;i<N;i++) begin
            // Reset X
            addr_x_ram[i]  <= 0;
            wr_en_x_ram[i] <= 0;
            rd_en_x_ram[i] <= 0;
            // Reset Y
            addr_y_ram[i]  <= 0;
            wr_en_y_ram[i] <= 0;
            rd_en_y_ram[i] <= 0;            
        end
        //
    end
    else begin
        case(STATE)
            IDLE : begin
                addr_counter <= 0;
                // X Row
                wr_en_x_ram[N-1] <= 0;
                rd_en_x_ram[N-1] <= 0;
                // Y Column
                wr_en_y_ram[N-1] <= 0;
                rd_en_y_ram[N-1] <= 0;
            end
            LOAD: begin
                //
                bit_counter <= bit_counter + 1;
                // Load data for X row
                wr_en_x_ram[ram_counter] <= 0;
                data_in_x_reg <= {data_in_x,data_in_x_reg[D_W-1:1]};
                //
                // Load data for Y Column
                wr_en_y_ram[ram_counter] <= 0;
                data_in_y_reg <= {data_in_y,data_in_y_reg[D_W-1:1]};
                //
                if(bit_counter == D_W-1) begin
                    // X Row
                    wr_en_x_ram[ram_counter] <= 1;
                    // Y Column
                    wr_en_y_ram[ram_counter] <= 1;
                end
                //
                if(wr_en_x_ram[ram_counter]== 1) begin
                    // X Row
                    addr_x_ram[ram_counter]  <= addr_x_ram[ram_counter] + 1;
                    // X Row
                    addr_y_ram[ram_counter]  <= addr_y_ram[ram_counter] + 1;
                end
                if(addr_x_ram[ram_counter] == N-1 && wr_en_x_ram[ram_counter]) begin
                    // X Row & Y Row common ram word block counter
                    ram_counter <= ram_counter + 1;
                end
            end
            TRANSFER : begin
                // X & Y Common 
                wr_en_x_ram[ram_counter] <= 0;
                //
                if(rd_en_x_ram[N-1]) begin
                    rd_en_x_ram[0] <= 0;
                    rd_en_y_ram[0] <= 0;
                end
                else begin // Initalize transfer
                    rd_en_x_ram[0] <= 1;
                    rd_en_y_ram[0] <= 1;
                end
                addr_counter <= addr_counter + 1;
                // Assign updated addres X & Y
                addr_x_ram[0] <= addr_counter;
                addr_y_ram[0] <= addr_counter;
            end
        endcase
    end
end

// Assign reading
genvar x;
for (x=1;x<N;x=x+1)
begin
    always@(posedge clk)
    begin
        if(STATE == TRANSFER) begin
            // Assign for X row
            addr_x_ram[x] <= addr_x_ram[x-1]; 
            rd_en_x_ram[x]   <= rd_en_x_ram[x-1];
            // ASsign for Y column 
            addr_y_ram[x] <= addr_y_ram[x-1];
            rd_en_y_ram[x] <= rd_en_y_ram[x-1];
        end
    end
end

endmodule