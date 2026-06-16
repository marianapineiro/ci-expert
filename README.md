# 💻 Multicycle CPU Design & Verification

Este projeto faz parte dos meus estudos práticos para a trilha de **Verification (Synopsys Purple Certification)**. O objetivo é projetar, integrar e verificar uma CPU multiciclo de 3 estágios (sem pipeline) utilizando **SystemVerilog**.

---

## 🛠️ Especificações Gerais do Sistema

- **Arquitetura:** Processador multiciclo de 3 estágios, sem pipeline (*no pipelining*).
- **Sinais Globais:** Os sinais de clock (`clk`) e reset (`rst`) devem ser conectados a todos os módulos do sistema.
- **Operandos de Entrada:** O sistema possui 3 variáveis externas com barramentos de entrada dedicados (`din_1`, `din_2`, `din_3`) para uso como operandos.
- **Saídas Globais:** - `{dout_high, dout_low}`: Barramento de saída de dados combinado (com o dobro da largura padrão `WIDTH`).
  - `cpu_rdy`: Sinal que indica o término da execução de uma instrução.
  - `zero` / `error`: Sinais de status que indicam resultado nulo ou condições de erro no processamento.

---

## 📐 Arquitetura da Unidade de Controle (Control Block)

A unidade de controle é responsável por decodificar a palavra de instrução de 7 bits (`cmd_in`) e gerar todos os sinais de habilitação de registradores, seleção de multiplexadores e temporização dos 3 estágios do processador.

### 🔌 Interface do Módulo (Portas)

```systemverilog
module control (
    input logic        clk,
    input logic        rst,
    input logic [6:0]  cmd_in,
    input logic        p_error,
    
    output logic       aluin_reg_en,
    output logic       datain_reg_en,
    output logic       memoryWrite,
    output logic       memoryRead,
    output logic       selmux2,
    output logic       cpu_rdy,
    output logic       aluout_reg_en,
    output logic       nvalid_data,
    output logic [1:0] in_select_a,
    output logic [1:0] in_select_b,
    output logic [2:0] opcode
);
endmodule
``` 
---

## Árvore de diretórios 

```text
meu-projeto-cpu/
│
├── .gitignore                   # Ignora arquivos temporários de simulação (.vcd, .log, etc.)
├── README.md                    # Especificação geral e status do projeto
│
├── rtl_top/                     # Módulo principal (Top-Level RTL)
│   └── cpu_top.sv               # Conecta todos os submódulos abaixo
│
├── control/                     # 1. Unidade de Controle (FSM)
│   ├── rtl/
│   │   └── control.sv
│   └── tb/
│       ├── Verification_Plan.md
│       └── tb_control.sv
│
├── alu/                         # 2. Unidade Lógica e Aritmética (ALU)
│   ├── rtl/
│   │   └── alu.sv
│   └── tb/
│       └── tb_alu.sv
│
├── memory/                      # 3. Bloco de Memória RAM
│   ├── rtl/
│   │   └── memory.sv
│   └── tb/
│       └── tb_memory.sv
│
├── mux/                         # 4. Multiplexadores de Entrada (Mux A e Mux B)
│   ├── rtl/
│   │   └── mux_4to1.sv          # Mux 4:1 para seleção de operandos e feedback
│   └── tb/
│       └── tb_mux_4to1.sv
│
├── common/                      # 5. Componentes Genéricos Reutilizáveis
│   └── rtl/
│       └── register_en.sv       # Registrador parametrizável com sinal de 'Enable'
│
└── dv/                          # 6. Ambiente de Verificação Integrada (Top-Level DV)
    ├── env/
    │   ├── cpu_env.sv           # Container que conecta Driver, Monitor e Scoreboard
    │   └── cpu_scoreboard.sv    # Auto-checking: Compara saída real com o modelo esperado
    ├── tests/
    │   ├── cpu_base_test.sv     # Teste base com as configurações de simulação
    │   └── cpu_random_test.sv   # Testes com estímulos aleatórios restritos
    └── tb_top.sv                # Testbench Top (Gera clock/reset e instancia a cpu_top)
```
