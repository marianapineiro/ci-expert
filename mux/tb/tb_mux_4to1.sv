`timescale 1ns/1ps

module tb_mux_4to1;

    // Declaração de Parâmetros
    parameter int WIDTH = 8;
    
    // Declaração dos Sinais Locais (Agrupados por tamanho usando vírgulas)
    logic [1:0]       tb_in_select;
    logic [WIDTH-1:0] tb_din_1, tb_din_2, tb_din_3, tb_din_4, tb_dout;

    // Conexão do Hardware (DUT)
    mux_4to1 #(
        .WIDTH(WIDTH)
    ) dut (
        .in_select (tb_in_select),
        .din_1     (tb_din_1),
        .din_2     (tb_din_2),
        .din_3     (tb_din_3),
        .feedback  (tb_din_4), // A porta interna 'feedback' se conecta ao seu 'tb_din_4'
        .dout      (tb_dout)
    );

    // Configuração do dump de ondas para o Verdi
    initial begin
        $fsdbDumpfile("test.fsdb");
        $fsdbDumpvars(0, tb_mux_4to1);
    end

    // Geração de Estímulos Direcionados
    initial begin
        // Inicializa todas as entradas
        tb_in_select = 2'b00;
        tb_din_1     = 8'hAA; // Dado padrão 1 (10101010)
        tb_din_2     = 8'hBB; // Dado padrão 2 (10111011)
        tb_din_3     = 8'hCC; // Dado padrão 3 (11001100)
        tb_din_4     = 8'hDD; // Dado padrão 4 (11011101)
        
        #10; // Espera 10ns
        
        // Teste 1: Seleciona Entrada 1
        tb_in_select = 2'b00;
        #10;
        
        // Teste 2: Seleciona Entrada 2
        tb_in_select = 2'b01;
        #10;
        
        // Teste 3: Seleciona Entrada 3
        tb_in_select = 2'b10;
        #10;
        
        // Teste 4: Seleciona Entrada 4 (Antigo feedback)
        tb_in_select = 2'b11;
        #10;

        // Fim dos testes
        $display("[TB_INFO] Simulacao finalizada com sucesso!");
        $finish;
    end

endmodule