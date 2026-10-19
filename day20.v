`timescale 1ns/1ps

//======================================================================
// DAY 20 - SYNCHRONOUS FIFO
//
// FIFO DEPTH : 8
// DATA WIDTH : 8
//
// ARCHITECTURE
//----------------------------------------------------------------------
// Basic Gates
//      ↓
// Half Adder
//      ↓
// Full Adder
//      ↓
// 4-bit Incrementer
//      ↓
// Write/Read Pointer
//      ↓
// 8 x 8 Memory
//      ↓
// Occupancy Counter
//      ↓
// Full / Empty Logic
//      ↓
// Structural FIFO
//      ↓
// RTL FIFO
//      ↓
// Top Module
//======================================================================


//======================================================================
// LEVEL 1 : BASIC GATES
//======================================================================

module not_gate(
    input A,
    output Y
);

    assign Y = ~A;

endmodule


module and_gate(
    input A,
    input B,
    output Y
);

    assign Y = A & B;

endmodule


module or_gate(
    input A,
    input B,
    output Y
);

    assign Y = A | B;

endmodule


module xor_gate(
    input A,
    input B,
    output Y
);

    assign Y = A ^ B;

endmodule


module nand_gate(
    input A,
    input B,
    output Y
);

    assign Y = ~(A & B);

endmodule


module nor_gate(
    input A,
    input B,
    output Y
);

    assign Y = ~(A | B);

endmodule


//======================================================================
// LEVEL 2 : HALF ADDER
//======================================================================

module half_adder(
    input A,
    input B,
    output Sum,
    output Carry
);

    xor_gate XOR1(
        .A(A),
        .B(B),
        .Y(Sum)
    );

    and_gate AND1(
        .A(A),
        .B(B),
        .Y(Carry)
    );

endmodule


//======================================================================
// LEVEL 3 : FULL ADDER
//======================================================================

module full_adder(
    input A,
    input B,
    input Cin,
    output Sum,
    output Cout
);

    wire S1;
    wire C1;
    wire C2;

    half_adder HA1(
        .A(A),
        .B(B),
        .Sum(S1),
        .Carry(C1)
    );

    half_adder HA2(
        .A(S1),
        .B(Cin),
        .Sum(Sum),
        .Carry(C2)
    );

    or_gate OR1(
        .A(C1),
        .B(C2),
        .Y(Cout)
    );

endmodule


//======================================================================
// LEVEL 4 : 4-BIT INCREMENTER
//
// Y = A + 1
//
// Example:
// A = 4'b1001
// Y = 4'b1010
//
// A = 4'b1111
// Y = 4'b0000
//======================================================================

module incrementer_4bit(
    input  [3:0] A,
    output [3:0] Y
);

    wire C1;
    wire C2;
    wire C3;
    wire C4;

    full_adder FA0(
        .A(A[0]),
        .B(1'b0),
        .Cin(1'b1),
        .Sum(Y[0]),
        .Cout(C1)
    );

    full_adder FA1(
        .A(A[1]),
        .B(1'b0),
        .Cin(C1),
        .Sum(Y[1]),
        .Cout(C2)
    );

    full_adder FA2(
        .A(A[2]),
        .B(1'b0),
        .Cin(C2),
        .Sum(Y[2]),
        .Cout(C3)
    );

    full_adder FA3(
        .A(A[3]),
        .B(1'b0),
        .Cin(C3),
        .Sum(Y[3]),
        .Cout(C4)
    );

endmodule


//======================================================================
// LEVEL 5 : 3-BIT POINTER REGISTER
//
// FIFO depth = 8
//
// 3 bits are sufficient:
// 000 -> 0
// 001 -> 1
// ...
// 111 -> 7
//
// After 111, the 3-bit pointer wraps to 000.
//======================================================================

module pointer_3bit(
    input clk,
    input reset,
    input enable,
    output reg [2:0] pointer
);

    wire [3:0] incremented_pointer;

    // 4-bit incrementer is used here.
    incrementer_4bit POINTER_INCREMENTER(
        .A({1'b0, pointer}),
        .Y(incremented_pointer)
    );

    always @(posedge clk) begin

        if(reset)
            pointer <= 3'b000;

        else if(enable)
            pointer <= incremented_pointer[2:0];

    end

endmodule


//======================================================================
// LEVEL 6 : 8 x 8 FIFO MEMORY
//
// 8 locations
// Each location = 8 bits
//
// Single synchronous read port.
//======================================================================

module fifo_memory_8x8(

    input clk,
    input reset,

    input        wr_en,
    input  [2:0] wr_addr,
    input  [7:0] wr_data,

    input        rd_en,
    input  [2:0] rd_addr,
    output reg [7:0] rd_data

);

    reg [7:0] memory [0:7];

    integer i;

    always @(posedge clk) begin

        if(reset) begin

            rd_data <= 8'h00;

            for(i = 0; i < 8; i = i + 1)
                memory[i] <= 8'h00;

        end

        else begin

            // ----------------------------------------------------------
            // WRITE
            // ----------------------------------------------------------

            if(wr_en)
                memory[wr_addr] <= wr_data;


            // ----------------------------------------------------------
            // SYNCHRONOUS READ
            // ----------------------------------------------------------

            if(rd_en)
                rd_data <= memory[rd_addr];

        end

    end

endmodule


//======================================================================
// LEVEL 7 : OCCUPANCY COUNTER
//
// count = number of valid data items in FIFO
//
// 0 -> EMPTY
// 8 -> FULL
//======================================================================

module fifo_count_control(

    input clk,
    input reset,

    input write_do,
    input read_do,

    output reg [3:0] count

);

    always @(posedge clk) begin

        if(reset) begin

            count <= 4'd0;

        end

        else begin

            case({write_do, read_do})

                // WRITE ONLY
                2'b10:
                    count <= count + 4'd1;

                // READ ONLY
                2'b01:
                    count <= count - 4'd1;

                // SIMULTANEOUS WRITE + READ
                // Number of stored items does not change.
                2'b11:
                    count <= count;

                // NO OPERATION
                2'b00:
                    count <= count;

                default:
                    count <= count;

            endcase

        end

    end

endmodule


//======================================================================
// LEVEL 8 : FULL / EMPTY LOGIC
//======================================================================

module fifo_status_logic(

    input [3:0] count,

    output empty,
    output full

);

    assign empty = (count == 4'd0);

    assign full  = (count == 4'd8);

endmodule


//======================================================================
// LEVEL 9 : STRUCTURAL SYNCHRONOUS FIFO
//======================================================================

module synchronous_fifo_structural(

    input clk,
    input reset,

    input        wr_en,
    input        rd_en,
    input  [7:0] wr_data,

    output [7:0] rd_data,

    output full,
    output empty,

    output [2:0] wr_ptr,
    output [2:0] rd_ptr,

    output [3:0] count,

    output write_do,
    output read_do

);

    // ---------------------------------------------------------------
    // VALID OPERATIONS
    // ---------------------------------------------------------------

    assign write_do = wr_en && !full;

    assign read_do  = rd_en && !empty;


    // ---------------------------------------------------------------
    // WRITE POINTER
    // ---------------------------------------------------------------

    pointer_3bit WRITE_POINTER(

        .clk(clk),
        .reset(reset),
        .enable(write_do),
        .pointer(wr_ptr)

    );


    // ---------------------------------------------------------------
    // READ POINTER
    // ---------------------------------------------------------------

    pointer_3bit READ_POINTER(

        .clk(clk),
        .reset(reset),
        .enable(read_do),
        .pointer(rd_ptr)

    );


    // ---------------------------------------------------------------
    // MEMORY
    // ---------------------------------------------------------------

    fifo_memory_8x8 MEMORY(

        .clk(clk),
        .reset(reset),

        .wr_en(write_do),
        .wr_addr(wr_ptr),
        .wr_data(wr_data),

        .rd_en(read_do),
        .rd_addr(rd_ptr),
        .rd_data(rd_data)

    );


    // ---------------------------------------------------------------
    // OCCUPANCY COUNT
    // ---------------------------------------------------------------

    fifo_count_control COUNT_CONTROL(

        .clk(clk),
        .reset(reset),

        .write_do(write_do),
        .read_do(read_do),

        .count(count)

    );


    // ---------------------------------------------------------------
    // FULL / EMPTY STATUS
    // ---------------------------------------------------------------

    fifo_status_logic STATUS(

        .count(count),

        .empty(empty),
        .full(full)

    );

endmodule


//======================================================================
// LEVEL 10 : RTL SYNCHRONOUS FIFO
//======================================================================

module synchronous_fifo_rtl(

    input clk,
    input reset,

    input        wr_en,
    input        rd_en,
    input  [7:0] wr_data,

    output reg [7:0] rd_data,

    output full,
    output empty

);

    reg [7:0] memory [0:7];

    reg [2:0] wr_ptr;
    reg [2:0] rd_ptr;

    reg [3:0] count;

    wire write_do;
    wire read_do;

    integer i;


    // ---------------------------------------------------------------
    // STATUS
    // ---------------------------------------------------------------

    assign full  = (count == 4'd8);

    assign empty = (count == 4'd0);


    // ---------------------------------------------------------------
    // VALID OPERATIONS
    // ---------------------------------------------------------------

    assign write_do = wr_en && !full;

    assign read_do  = rd_en && !empty;


    // ---------------------------------------------------------------
    // SEQUENTIAL FIFO
    // ---------------------------------------------------------------

    always @(posedge clk) begin

        if(reset) begin

            wr_ptr  <= 3'b000;
            rd_ptr  <= 3'b000;

            count   <= 4'd0;

            rd_data <= 8'h00;

            for(i = 0; i < 8; i = i + 1)
                memory[i] <= 8'h00;

        end

        else begin

            // -------------------------------------------------------
            // WRITE
            // -------------------------------------------------------

            if(write_do) begin

                memory[wr_ptr] <= wr_data;

                wr_ptr <= wr_ptr + 3'd1;

            end


            // -------------------------------------------------------
            // READ
            // -------------------------------------------------------

            if(read_do) begin

                rd_data <= memory[rd_ptr];

                rd_ptr <= rd_ptr + 3'd1;

            end


            // -------------------------------------------------------
            // OCCUPANCY COUNT
            // -------------------------------------------------------

            case({write_do, read_do})

                2'b10:
                    count <= count + 4'd1;

                2'b01:
                    count <= count - 4'd1;

                2'b11:
                    count <= count;

                2'b00:
                    count <= count;

                default:
                    count <= count;

            endcase

        end

    end

endmodule


//======================================================================
// LEVEL 11 : TOP MODULE
//======================================================================

module synchronous_fifo_top(

    input clk,
    input reset,

    input        wr_en,
    input        rd_en,
    input  [7:0] wr_data,

    output [7:0] rd_data,

    output full,
    output empty

);

    synchronous_fifo_structural FIFO(

        .clk(clk),
        .reset(reset),

        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),

        .rd_data(rd_data),

        .full(full),
        .empty(empty),

        .wr_ptr(),
        .rd_ptr(),
        .count(),
        .write_do(),
        .read_do()

    );

endmodule