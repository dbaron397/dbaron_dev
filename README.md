# Ambiente de Design de CI Open-Source (Analógico + Digital)

Guia em português para montar, do zero, um fluxo completo de projeto de circuitos
integrados usando ferramentas open-source no **Windows 11 + WSL2 (Ubuntu 24.04)**.

Foco principal no fluxo **analógico** (Xschem / ngspice / Magic / Netgen /
KLayout), mas com toda a stack **digital** também instalada (Yosys / OpenROAD
via OpenLane2 / Icarus Verilog / Verilator / GTKWave).

Suporte nativo para trocar entre os PDKs abertos:

| PDK                | Processo                      | Uso principal              |
|--------------------|-------------------------------|----------------------------|
| `sky130A`          | SkyWater 130 nm (variante A)  | Analógico + Digital geral  |
| `sky130B`          | SkyWater 130 nm (variante B)  | Analógico com RRAM         |
| `gf180mcuD`        | GlobalFoundries 180 nm MCU    | Analógico / alta tensão    |
| `ihp-sg13g2`       | IHP SG13G2 130 nm BiCMOS      | Analógico / RF / BiCMOS    |

---

## Estrutura de diretórios no disco

Depois de rodar os scripts, você vai ter:

```
$HOME/ic/
├── setup/                   # este repositório
│   ├── scripts/             # instaladores
│   ├── env/                 # arquivos de ambiente por PDK
│   ├── bin/                 # helpers (use-pdk)
│   ├── docs/                # documentação
│   └── examples/            # projetos mínimos de validação
├── tools/
│   └── src/                 # códigos-fonte das ferramentas (git clones)
├── pdks/                    # PDK_ROOT -- um diretório por PDK, isolados
│   ├── sky130A/
│   ├── sky130B/
│   ├── gf180mcuD/
│   └── ihp-sg13g2/
└── projects/                # seus projetos ficam aqui
```

As ferramentas são instaladas com `prefix=/usr/local` (padrão), então os
binários ficam em `/usr/local/bin` e podem ser chamados de qualquer lugar.

---

## Ordem de instalação

Leia os documentos em `docs/` na ordem indicada:

1. **[docs/01-wsl-setup.md](docs/01-wsl-setup.md)** — instalar WSL2 + Ubuntu 24.04 no Windows 11
2. **[docs/02-installation.md](docs/02-installation.md)** — rodar os scripts de instalação
3. **[docs/03-pdk-management.md](docs/03-pdk-management.md)** — como trocar entre PDKs
4. **[docs/04-first-project.md](docs/04-first-project.md)** — criar e simular o primeiro circuito

### Resumo ultra-curto (depois do WSL pronto)

```bash
# Clone este repo no lugar certo
mkdir -p ~/ic && cd ~/ic
git clone <URL-do-seu-fork> setup
cd setup

# Instala TUDO (leva ~1-2h no total)
bash scripts/00-install-deps.sh
bash scripts/01-install-analog.sh
bash scripts/02-install-digital.sh
bash scripts/03-install-pdks.sh
bash scripts/04-install-ihp-pdk.sh

# Carrega o ambiente
echo 'source ~/ic/setup/env/ic-bashrc.sh' >> ~/.bashrc
source ~/.bashrc

# Escolhe um PDK e começa
use-pdk sky130A
```

---

## Trocar de PDK

```bash
use-pdk                 # lista PDKs disponíveis
use-pdk sky130A         # ativa SkyWater 130A
use-pdk gf180mcuD       # troca para GF 180 MCU
use-pdk ihp-sg13g2      # troca para IHP SG13G2
```

O comando ajusta as variáveis de ambiente (`PDK`, `PDK_ROOT`, caminhos do
Xschem, Magic, ngspice e Netgen) e imprime qual PDK ficou ativo. Nenhum
arquivo é compartilhado entre PDKs — é seguro trocar no meio de uma sessão.

Dentro de um projeto, os arquivos `.xschemrc`, `.magicrc` e `.spiceinit` usam
apenas `$PDK_ROOT` e `$PDK`, então o mesmo projeto roda em qualquer PDK
compatível sem editar arquivos.

---

## Licenças das ferramentas

Todas as ferramentas e PDKs desta stack são open-source (ISC, Apache-2.0,
GPL-2/3). Os PDKs Sky130 e GF180MCU são Apache-2.0; o IHP SG13G2 é Apache-2.0
com uma licença de foundry adicional aceita automaticamente ao clonar.
