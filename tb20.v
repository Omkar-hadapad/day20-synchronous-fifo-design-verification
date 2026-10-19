`timescale 1ns/1ps

//======================================================================
// DAY 20 TESTBENCH
// SYNCHRONOUS FIFO
//
// SELF-CHECKING VERIFICATION
//
// Verification:
// 1. Basic gates
// 2. Half adder
// 3. Full adder
// 4. 4-bit incrementer
// 5. Pointer
// 6. Memory
// 7. Count control
// 8. Full/empty logic
// 9. Structural FIFO
// 10. RTL FIFO
// 11. FIFO ordering
// 12. Overflow
// 13. Underflow
// 14. Simultaneous read/write
// 15. Structural vs RTL
//======================================================================

module day20_tb;

    reg clk;
    reg reset;

    integer pass_count;
    integer fail_count;

    integer i;

    //==================================================================
    // CLOCK
    //==================================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    //==================================================================
    // BASIC GATES
    //==================================================================

    reg A;
    reg B;

    wire not_y;
    wire and_y;
    wire or_y;
    wire xor_y;
    wire nand_y;
    wire nor_y;

    not_gate NOT1(
        .A(A),
        .Y(not_y)
    );

    and_gate AND1(
        .A(A),
        .B(B),
        .Y(and_y)
    );

    or_gate OR1(
        .A(A),
        .B(B),
        .Y(or_y)
    );

    xor_gate XOR1(
        .A(A),
        .B(B),
        .Y(xor_y)
    );

    nand_gate NAND1(
        .A(A),
        .B(B),
        .Y(nand_y)
    );

    nor_gate NOR1(
        .A(A),
        .B(B),
        .Y(nor_y)
    );


    //==================================================================
    // HALF ADDER
    //==================================================================

    wire ha_sum;
    wire ha_carry;

    half_adder HA(
        .A(A),
        .B(B),
        .Sum(ha_sum),
        .Carry(ha_carry)
    );


    //==================================================================
    // FULL ADDER
    //==================================================================

    reg Cin;

    wire fa_sum;
    wire fa_carry;

    full_adder FA(
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(fa_sum),
        .Cout(fa_carry)
    );


    //==================================================================
    // 4-BIT INCREMENTER
    //==================================================================

    reg [3:0] inc_A;
    wire [3:0] inc_Y;

    incrementer_4bit INC(
        .A(inc_A),
        .Y(inc_Y)
    );


    //==================================================================
    // POINTER
    //==================================================================

    reg pointer_enable;
    wire [2:0] pointer;

    pointer_3bit PTR(
        .clk(clk),
        .reset(reset),
        .enable(pointer_enable),
        .pointer(pointer)
    );


    //==================================================================
    // MEMORY
    //==================================================================

    reg mem_wr_en;
    reg mem_rd_en;

    reg [2:0] mem_wr_addr;
    reg [2:0] mem_rd_addr;

    reg [7:0] mem_wr_data;

    wire [7:0] mem_rd_data;

    fifo_memory_8x8 MEM(
        .clk(clk),
        .reset(reset),

        .wr_en(mem_wr_en),
        .wr_addr(mem_wr_addr),
        .wr_data(mem_wr_data),

        .rd_en(mem_rd_en),
        .rd_addr(mem_rd_addr),
        .rd_data(mem_rd_data)
    );


    //==================================================================
    // COUNT CONTROL
    //==================================================================

    reg write_do;
    reg read_do;

    wire [3:0] count;

    fifo_count_control COUNT(
        .clk(clk),
        .reset(reset),
        .write_do(write_do),
        .read_do(read_do),
        .count(count)
    );


    //==================================================================
    // STATUS
    //==================================================================

    wire status_empty;
    wire status_full;

    fifo_status_logic STATUS(
        .count(count),
        .empty(status_empty),
        .full(status_full)
    );


    //==================================================================
    // STRUCTURAL FIFO
    //==================================================================

    reg fifo_wr_en;
    reg fifo_rd_en;

    reg [7:0] fifo_wr_data;

    wire [7:0] s_rd_data;

    wire s_full;
    wire s_empty;

    wire [2:0] s_wr_ptr;
    wire [2:0] s_rd_ptr;

    wire [3:0] s_count;

    wire s_write_do;
    wire s_read_do;

    synchronous_fifo_structural STRUCT_FIFO(

        .clk(clk),
        .reset(reset),

        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .wr_data(fifo_wr_data),

        .rd_data(s_rd_data),

        .full(s_full),
        .empty(s_empty),

        .wr_ptr(s_wr_ptr),
        .rd_ptr(s_rd_ptr),

        .count(s_count),

        .write_do(s_write_do),
        .read_do(s_read_do)
    );


    //==================================================================
    // RTL FIFO
    //==================================================================

    wire [7:0] r_rd_data;

    wire r_full;
    wire r_empty;

    synchronous_fifo_rtl RTL_FIFO(

        .clk(clk),
        .reset(reset),

        .wr_en(fifo_wr_en),
        .rd_en(fifo_rd_en),
        .wr_data(fifo_wr_data),

        .rd_data(r_rd_data),

        .full(r_full),
        .empty(r_empty)
    );


    //==================================================================
    // SELF-CHECKING TASK - 1 BIT
    //==================================================================

    task check_1bit;

        input [127:0] name;
        input expected;
        input actual;

        begin

            if(expected === actual) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %-30s | Expected=%b Actual=%b",
                    name,
                    expected,
                    actual
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %-30s | Expected=%b Actual=%b",
                    name,
                    expected,
                    actual
                );

            end

        end

    endtask


    //==================================================================
    // SELF-CHECKING TASK - 8 BIT
    //==================================================================

    task check_8bit;

        input [127:0] name;
        input [7:0] expected;
        input [7:0] actual;

        begin

            if(expected === actual) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %-30s | Expected=%h Actual=%h",
                    name,
                    expected,
                    actual
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %-30s | Expected=%h Actual=%h",
                    name,
                    expected,
                    actual
                );

            end

        end

    endtask


    //==================================================================
    // MAIN TEST
    //==================================================================

    initial begin

        pass_count = 0;
        fail_count = 0;

        A = 0;
        B = 0;
        Cin = 0;

        inc_A = 0;

        reset = 1;
        pointer_enable = 0;

        mem_wr_en = 0;
        mem_rd_en = 0;
        mem_wr_addr = 0;
        mem_rd_addr = 0;
        mem_wr_data = 0;

        write_do = 0;
        read_do = 0;

        fifo_wr_en = 0;
        fifo_rd_en = 0;
        fifo_wr_data = 0;

        $dumpfile("day20.vcd");
        $dumpvars(0, day20_tb);


        //==============================================================
        // TEST 1 : BASIC GATES
        //==============================================================

        $display("\n==============================================");
        $display("TEST 1 : BASIC GATES");
        $display("==============================================");

        for(i = 0; i < 4; i = i + 1) begin

            A = i[1];
            B = i[0];

            #1;

            check_1bit("NOT",  ~(A),      not_y);
            check_1bit("AND",  (A & B),   and_y);
            check_1bit("OR",   (A | B),   or_y);
            check_1bit("XOR",  (A ^ B),   xor_y);
            check_1bit("NAND", ~(A & B),  nand_y);
            check_1bit("NOR",  ~(A | B),  nor_y);

        end


        //==============================================================
        // TEST 2 : HALF ADDER
        //==============================================================

        $display("\n==============================================");
        $display("TEST 2 : HALF ADDER");
        $display("==============================================");

        for(i = 0; i < 4; i = i + 1) begin

            A = i[1];
            B = i[0];

            #1;

            check_1bit("HA SUM",   A ^ B, ha_sum);
            check_1bit("HA CARRY", A & B, ha_carry);

        end


        //==============================================================
        // TEST 3 : FULL ADDER
        //==============================================================

        $display("\n==============================================");
        $display("TEST 3 : FULL ADDER");
        $display("==============================================");

        for(i = 0; i < 8; i = i + 1) begin

            A   = i[2];
            B   = i[1];
            Cin = i[0];

            #1;

            check_1bit(
                "FA SUM",
                A ^ B ^ Cin,
                fa_sum
            );

            check_1bit(
                "FA CARRY",
                (A&B) | (A&Cin) | (B&Cin),
                fa_carry
            );

        end


        //==============================================================
        // TEST 4 : 4-BIT INCREMENTER
        //==============================================================

        $display("\n==============================================");
        $display("TEST 4 : 4-BIT INCREMENTER");
        $display("==============================================");

        for(i = 0; i < 16; i = i + 1) begin

            inc_A = i[3:0];

            #1;

            // IMPORTANT:
            // 4-bit incrementer:
            // 0 -> 1
            // ...
            // 14 -> 15
            // 15 -> 0
            //
            // Carry is discarded because Y is only 4 bits.

            check_8bit(
                "INCREMENTER",
                (i + 1) & 8'h0F,
                {4'b0000, inc_Y}
            );

        end


        //==============================================================
        // TEST 5 : POINTER
        //==============================================================

        $display("\n==============================================");
        $display("TEST 5 : POINTER");
        $display("==============================================");

        reset = 1;

        @(posedge clk);
        #1;

        check_8bit(
            "POINTER RESET",
            8'h00,
            {5'b00000, pointer}
        );

        reset = 0;
        pointer_enable = 1;

        for(i = 1; i <= 8; i = i + 1) begin

            @(posedge clk);
            #1;

            check_8bit(
                "POINTER COUNT",
                i % 8,
                {5'b00000, pointer}
            );

        end

        pointer_enable = 0;


        //==============================================================
        // TEST 6 : MEMORY WRITE/READ
        //==============================================================

        $display("\n==============================================");
        $display("TEST 6 : 8x8 MEMORY");
        $display("==============================================");

        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;

        // WRITE
        for(i = 0; i < 8; i = i + 1) begin

            mem_wr_addr = i[2:0];
            mem_wr_data = i * 8'h11;
            mem_wr_en   = 1;

            @(posedge clk);

        end

        mem_wr_en = 0;

        // READ
        for(i = 0; i < 8; i = i + 1) begin

            mem_rd_addr = i[2:0];
            mem_rd_en   = 1;

            @(posedge clk);
            #1;

            check_8bit(
                "MEMORY READ",
                i * 8'h11,
                mem_rd_data
            );

        end

        mem_rd_en = 0;


        //==============================================================
        // TEST 7 : COUNT CONTROL
        //==============================================================

        $display("\n==============================================");
        $display("TEST 7 : OCCUPANCY COUNTER");
        $display("==============================================");

        reset = 1;

        @(posedge clk);
        #1;

        check_8bit(
            "COUNT RESET",
            8'h00,
            count
        );

        reset = 0;

        write_do = 1;

        for(i = 1; i <= 8; i = i + 1) begin

            @(posedge clk);
            #1;

            check_8bit(
                "COUNT UP",
                i,
                count
            );

        end

        write_do = 0;

        #1;

        check_1bit(
            "FULL",
            1'b1,
            status_full
        );

        check_1bit(
            "EMPTY",
            1'b0,
            status_empty
        );

        read_do = 1;

        for(i = 7; i >= 0; i = i - 1) begin

            @(posedge clk);
            #1;

            check_8bit(
                "COUNT DOWN",
                i,
                count
            );

        end

        read_do = 0;

        check_1bit(
            "EMPTY",
            1'b1,
            status_empty
        );


        //==============================================================
        // TEST 8 : FIFO RESET
        //==============================================================

        $display("\n==============================================");
        $display("TEST 8 : FIFO RESET");
        $display("==============================================");

        reset = 1;

        @(posedge clk);
        #1;

        check_1bit(
            "FIFO EMPTY AFTER RESET",
            1'b1,
            s_empty
        );

        check_1bit(
            "FIFO FULL AFTER RESET",
            1'b0,
            s_full
        );

        check_8bit(
            "FIFO READ DATA RESET",
            8'h00,
            s_rd_data
        );

        reset = 0;


        //==============================================================
        // TEST 9 : FILL FIFO
        //==============================================================

        $display("\n==============================================");
        $display("TEST 9 : FILL FIFO");
        $display("==============================================");

        for(i = 0; i < 8; i = i + 1) begin

            fifo_wr_en   = 1;
            fifo_wr_data = 8'h10 + i;

            @(posedge clk);
            #1;

        end

        fifo_wr_en = 0;

        check_1bit(
            "FIFO FULL",
            1'b1,
            s_full
        );

        check_1bit(
            "FIFO NOT EMPTY",
            1'b0,
            s_empty
        );


        //==============================================================
        // TEST 10 : OVERFLOW PROTECTION
        //==============================================================

        $display("\n==============================================");
        $display("TEST 10 : OVERFLOW PROTECTION");
        $display("==============================================");

        fifo_wr_en   = 1;
        fifo_wr_data = 8'hFF;

        @(posedge clk);
        #1;

        check_1bit(
            "FULL REMAINS HIGH",
            1'b1,
            s_full
        );

        // Structural and RTL outputs should remain identical
        check_8bit(
            "RTL/STRUCTURAL DATA",
            r_rd_data,
            s_rd_data
        );

        fifo_wr_en = 0;


        //==============================================================
        // TEST 11 : FIFO ORDER
        //==============================================================

        $display("\n==============================================");
        $display("TEST 11 : FIFO ORDER");
        $display("==============================================");

        for(i = 0; i < 8; i = i + 1) begin

            fifo_rd_en = 1;

            @(posedge clk);
            #1;

            check_8bit(
                "FIFO ORDER",
                8'h10 + i,
                s_rd_data
            );

            check_8bit(
                "STRUCTURAL VS RTL",
                s_rd_data,
                r_rd_data
            );

        end

        fifo_rd_en = 0;

        check_1bit(
            "FIFO EMPTY",
            1'b1,
            s_empty
        );


        //==============================================================
        // TEST 12 : UNDERFLOW PROTECTION
        //==============================================================

        $display("\n==============================================");
        $display("TEST 12 : UNDERFLOW PROTECTION");
        $display("==============================================");

        fifo_rd_en = 1;

        @(posedge clk);
        #1;

        check_1bit(
            "EMPTY REMAINS HIGH",
            1'b1,
            s_empty
        );

        fifo_rd_en = 0;


        //==============================================================
        // TEST 13 : SIMULTANEOUS READ/WRITE
        //==============================================================

        $display("\n==============================================");
        $display("TEST 13 : SIMULTANEOUS READ/WRITE");
        $display("==============================================");

        // Write AA
        fifo_wr_en   = 1;
        fifo_wr_data = 8'hAA;

        @(posedge clk);
        #1;

        // Write BB
        fifo_wr_data = 8'hBB;

        @(posedge clk);
        #1;

        fifo_wr_en = 0;

        // Simultaneous READ AA + WRITE CC
        fifo_wr_en   = 1;
        fifo_rd_en   = 1;
        fifo_wr_data = 8'hCC;

        @(posedge clk);
        #1;

        check_8bit(
            "SIMULTANEOUS READ",
            8'hAA,
            s_rd_data
        );

        check_8bit(
            "STRUCTURAL VS RTL",
            s_rd_data,
            r_rd_data
        );

        fifo_wr_en = 0;
        fifo_rd_en = 0;


        //==============================================================
        // TEST 14 : STRUCTURAL VS RTL
        //==============================================================

        $display("\n==============================================");
        $display("TEST 14 : STRUCTURAL VS RTL");
        $display("==============================================");

        reset = 1;

        @(posedge clk);
        #1;

        reset = 0;

        // WRITE FOUR VALUES
        for(i = 0; i < 4; i = i + 1) begin

            fifo_wr_en   = 1;
            fifo_wr_data = 8'h40 + i;

            @(posedge clk);
            #1;

            check_1bit(
                "FULL MATCH",
                s_full,
                r_full
            );

            check_1bit(
                "EMPTY MATCH",
                s_empty,
                r_empty
            );

        end

        fifo_wr_en = 0;

        // READ FOUR VALUES
        for(i = 0; i < 4; i = i + 1) begin

            fifo_rd_en = 1;

            @(posedge clk);
            #1;

            check_8bit(
                "STRUCTURAL VS RTL DATA",
                s_rd_data,
                r_rd_data
            );

            check_1bit(
                "FULL MATCH",
                s_full,
                r_full
            );

            check_1bit(
                "EMPTY MATCH",
                s_empty,
                r_empty
            );

        end

        fifo_rd_en = 0;


        //==============================================================
        // FINAL RESULT
        //==============================================================

        $display("\n==============================================");
        $display("DAY 20 VERIFICATION COMPLETE");
        $display("==============================================");

        $display("PASS COUNT = %0d", pass_count);
        $display("FAIL COUNT = %0d", fail_count);

        if(fail_count == 0) begin

            $display("----------------------------------------------");
            $display("RESULT : ALL TESTS PASSED");
            $display("----------------------------------------------");

        end
        else begin

            $display("----------------------------------------------");
            $display("RESULT : FAILURES DETECTED");
            $display("----------------------------------------------");

        end

        #20;

        $finish;

    end


    //==================================================================
    // CONTINUOUS MONITOR
    //==================================================================

    initial begin

        $monitor(
            "TIME=%0t | CLK=%b | RESET=%b | WR=%b | RD=%b | DATA_IN=%h | DATA_OUT=%h | WR_PTR=%d | RD_PTR=%d | COUNT=%d | FULL=%b | EMPTY=%b",

            $time,
            clk,
            reset,
            fifo_wr_en,
            fifo_rd_en,
            fifo_wr_data,
            s_rd_data,
            s_wr_ptr,
            s_rd_ptr,
            s_count,
            s_full,
            s_empty
        );

    end

endmodule