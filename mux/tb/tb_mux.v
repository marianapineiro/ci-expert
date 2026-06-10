// test bench to parameterized 4 in mux

module tb_mux;

    // 1. DeclaraÃ§Ã£o de parÃ¢metros e sinais
    parameter W = 8;
    reg [W-1:0] d1, d2, d3, d4;
    reg [1:0] sel;
    wire [W-1:0] out;

    // 2. InstanciaÃ§Ã£o do MÃ³dulo (UUT - Unit Under Test)
    mux4 #(W) uut (
        .din1(d1),
        .din2(d2),
        .din3(d3),
        .din4(d4),
        .select(sel),
        .dout(out)
    );

    // 3. Bloco de estÃ­mulos
    initial begin
		$fsdbDumpfile("test.fsdb");
        $fsdbDumpvars(0, tb_mux);

        // Configura valores iniciais para as entradas
        d1 = 8'hAA; d2 = 8'hBB; d3 = 8'hCC; d4 = 8'hDD;
        sel = 2'b00;

        // Monitora as mudanÃ§as no terminal
        $monitor("Tempo=%0t | Sel=%b | Saida=%h", $time, sel, out);

        // Testando cada canal
        #10 sel = 2'b00; // Deve sair AA
        #10 sel = 2'b01; // Deve sair BB
        #10 sel = 2'b11; // Deve sair DD
        #10 sel = 2'b10; // Deve sair CC
        #10 sel = 2'b00; // Deve sair AA
	#10 sel = 2'b00; // Deve sair AA
        #10 sel = 2'b11; // Deve sair DD
        #10 sel = 2'b01; // Deve sair BB
        
        #10 $finish;     // Finaliza a simulaÃ§Ã£o
    end

    // 4. vcd
    initial begin
        $dumpfile("mux4_waves.vcd");
        $dumpvars(0, tb_mux);
    end

endmodule