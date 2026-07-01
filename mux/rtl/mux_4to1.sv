module mux_4to1 #(
    parameter int WIDTH = 8 // Largura padrão dos barramentos de dados
)(
    // Declaração das portas do módulo
    input  logic [1:0]          in_select, // Sinal de controle de 2 bits
    input  logic [WIDTH-1:0]    din_1, din_2, din_3, din_4,      // Entrada de dados (4 entradas de largura 'WIDTH')
    output logic [WIDTH-1:0]    dout        // Saída multiplexada
);

    // Lógica interna combinacional
    // O bloco 'always_comb' garante que a saída atualiza INSTANTANEAMENTE
    // sempre que qualquer uma das entradas mudar.
    always_comb begin
        unique case (in_select)
            2'b00:   dout = din_1;  // 2: Indica o tamanho do dado (ele tem exatamente 2 bits de largura).
                                    // 'b: Indica a base numérica (neste caso, binária). 
                                    // Se fosse hexadecimal seria 'h, e se fosse decimal seria 'd.
                                    // 00: É o valor em si. Ou seja, os dois bits estão em nível lógico baixo (zero).
            2'b01:   dout = din_2;
            2'b10:   dout = din_3;
            2'b11:   dout = din_4;
            default: dout = '0; // literal de vetor zerado ('0).
        endcase
    end

endmodule 