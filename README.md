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
### 🧠 Conjunto de Instruções (ISA) e Decodificação

A palavra de controle `cmd_in[6:0]` possui o seguinte formato de campos:

| Bits | Campo | Descrição |
| :---: | :---: | :--- |
| `6:5` | `muxA` | Seleção do Multiplexador A da ALU (`in_select_a`) |
| `4:3` | `muxB` | Seleção do Multiplexador B da ALU (`in_select_b`) |
| `2:0` | `opcode` | Operação a ser executada pela ALU |

O barramento de `opcode` deve ser decodificado pela Unidade de Controle de acordo com a tabela abaixo:

| opcode[2] | opcode[1] | opcode[0] | Operação / Instrução |
| :---: | :---: | :---: | :--- |
| 0 | 0 | 0 | **Add** (Soma) |
| 0 | 0 | 1 | **Sub** (Subtração) |
| 0 | 1 | 0 | **Mul** (Multiplicação) |
| 0 | 1 | 1 | **Div** (Divisão) |
| 1 | 0 | 0 | **NOP** (Nenhuma Operação) |
| 1 | 0 | 1 | **Load** (Carregar da Memória) |
| 1 | 1 | 0 | **Store** (Salvar na Memória) |
| 1 | 1 | 1 | **NOP** (Nenhuma Operação) |

---

## 🧮 Arquitetura do Datapath (Caminho de Dados)

O comportamento do hardware integrado segue estritamente as seguintes conexões estruturais:

- **Multiplexação de Entrada (Mux A e B):** Dois multiplexadores de 4 para 1 selecionam as entradas da ALU com base em `in_select_a` e `in_select_b`. Eles são alimentados por `din_1`, `din_2`, `din_3` e pelo laço de retroalimentação (*feedback loop*) vindo do registrador de saída da CPU.
- **Registradores de Estágio (Habilitados por Clock):**
  - O registrador de entrada captura `cmd_in` e os dados externos quando `datain_reg_en` está ativo.
  - Os registradores pré-ALU isolam as entradas da ALU quando `aluin_reg_en` está ativo.
  - O registrador pós-ALU captura o resultado quando `aluout_reg_en` está ativo.
- **Unidade de Memória:** Bloco de memória RAM controlado pelos sinais síncronos `memoryWrite` e `memoryRead` gerados pela controladora.
- **Lógica de Erro e Validação:**
  - A unidade de controle monitora condições de erro através do pino `p_error`.
  - O sinal `nvalid_data` deve ser ativado (*asserted*) se houver uma tentativa de alimentar a ALU com dados vindos do laço de retroalimentação se o resultado anterior do registrador de saída não tiver sido válido (**Condição de Erro / Error Condition**).

---

## 🌲 Árvore de Diretórios

```text
meu-projeto-cpu/
│
├── .gitignore                   # Ignora arquivos temporários de simulação (.vcd, .fsdb, csrc, etc.)
├── README.md                    # Especificação geral, ISA e status do projeto
│
├── rtl_top/                     # Módulo principal (Top-Level RTL)
│   └── cpu_top.sv               # Conecta todos os submódulos abaixo
│
├── control/                     # 1. Unidade de Controle (FSM)
│   ├── rtl/
│   │   └── control.sv
│   └── tb/
│       ├── filelist.f           # Localizado aqui: Mantém a sujeira de simulação nesta pasta
│       ├── Verification_Plan.md
│       └── tb_control.sv
│
├── alu/                         # 2. Unidade Lógica e Aritmética (ALU)
│   ├── rtl/
│   │   └── alu.sv
│   └── tb/
│       ├── filelist.f           # Localizado aqui
│       └── tb_alu.sv
│
├── memory/                      # 3. Bloco de Memória RAM
│   ├── rtl/
│   │   └── memory.sv
│   └── tb/
│       ├── filelist.f           # Localizado aqui
│       └── tb_memory.sv
│
├── mux/                         # 4. Multiplexadores de Entrada (Mux A e Mux B)
│   ├── rtl/
│   │   └── mux_4to1.sv          # Mux 4:1 para seleção de operandos e feedback
│   └── tb/
│       ├── filelist.f           # Localizado aqui
│       └── tb_mux_4to1.sv
│
├── common/                      # 5. Componentes Genéricos Reutilizáveis
│   └── rtl/
│       └── register_en.sv       # Registrador parametrizável com sinal de 'Enable'
│
└── dv/                          # 6. Ambiente de Verificação Integrada (Top-Level DV)
    ├── filelist.f               # Arquivo mestre que aponta para os filelists das subpastas tb/
    ├── env/
    │   ├── cpu_env.sv           # Container que conecta Driver, Monitor e Scoreboard
    │   └── cpu_scoreboard.sv    # Auto-checking: Compara saída real com o modelo esperado
    ├── tests/
    │   ├── cpu_base_test.sv     # Teste base com as configurações de simulação
    │   └── cpu_random_test.sv   # Testes com estímulos aleatórios restritos
    └── tb_top.sv                # Testbench Top (Gera clock/reset e instancia a cpu_top)

```
---

## 🎯 Objetivos de Verificação (Verification Plan)

Como parte do aprendizado direcionado à certificação Synopsys, a estratégia de teste deste projeto está dividida em:

1. **Testes Unitários (Block-Level Verification):**
   - Validar isoladamente os blocos combinacionais (`mux`, `alu`).
   - Validar a Máquina de Estados Finitos (FSM) do bloco `control`, garantindo o tempo exato de 3 estágios.
2. **Cobertura Funcional (Functional Coverage):**
   - Criação de `covergroups` para garantir que 100% dos opcodes, seleções de MUX e transições de erro foram exercitados.
   - Aplicação de cobertura cruzada (*cross coverage*) entre instruções e estados de erro.
3. **Testes do Sistema (Top-Level Verification):**
   - Simulação da CPU completa interconectada (`cpu_top.sv`).
   - Aplicação de estímulos aleatórios restritos (*Constrained Random Verification*) para simular uma sequência real de programas (instruções consecutivas), avaliando o comportamento do laço de feedback e acessos à memória.

---

## 🚀 Fluxo de Compilação e Simulação (VCS + Verdi)

O ambiente de verificação utiliza as ferramentas da Synopsys para compilação (VCS) e depuração visual de ondas (Verdi). Para manter o repositório organizado, **toda simulação deve ser executada de dentro da pasta `tb/` de cada bloco (ou na pasta raiz `dv/` para o topo)**.

### 🏁 Passo a Passo no Terminal

Navegue até a pasta de testes do módulo desejado (exemplo com o multiplexador):

`cd mux/tb/`

#### 1. Compilação com o VCS
O comando abaixo compila o hardware e o testbench listados no arquivo `filelist.f`:

`vcs -full64 -f filelist.f -debug_access+all -kdb -l comp.log`

- **-full64**: Garante a execução do simulador em arquitetura de 64 bits.
- **-f filelist.f**: Passa o arquivo de manifesto contendo os caminhos dos códigos `.sv` a serem compilados.
- **-debug_access+all**: Habilita a visibilidade total dos sinais internos do circuito (essencial para o *dump* de ondas).
- **-kdb**: Gera a base de dados de conhecimento de hardware (*Knowledge Database*) para integração nativa com o Verdi.
- **-l comp.log**: Salva todas as mensagens, avisos e erros de compilação no arquivo `comp.log`.

#### 2. Execução da Simulação
Após a compilação com sucesso, o VCS gera um binário executável chamado `simv`. Para rodar os testes e aplicar os estímulos do testbench, execute:

`./simv`

> 📝 *Nota:* A execução deste binário vai gerar o arquivo de ondas em formato nativo da Synopsys (`test.fsdb`) configurado dentro do código do testbench.

#### 3. Depuração Visual com o Verdi
Para abrir a interface gráfica do Verdi e analisar os diagramas de tempo (formas de onda) dos sinais, use:

`verdi -dbdir simv.daidir -ssf test.fsdb &`

- **-dbdir simv.daidir**: Carrega a estrutura lógica do hardware que foi compilada previamente pelo VCS.
- **-ssf test.fsdb**: Abre automaticamente o arquivo de ondas (*Signal Scan File*) gerado durante a execução do `./simv`.
- **&**: Comando do Linux para rodar o Verdi em segundo plano, deixando o seu terminal livre para novos comandos.