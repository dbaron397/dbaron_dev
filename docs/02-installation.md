# 2. Instalação das ferramentas e PDKs

Pré-requisito: WSL2 + Ubuntu 24.04 pronto (ver [01-wsl-setup.md](01-wsl-setup.md)).

Tudo aqui roda **dentro do Ubuntu** (WSL).

## 2.1 Clonar este repositório no lugar certo

```bash
mkdir -p ~/ic
cd ~/ic
git clone <URL-do-seu-repositorio> setup
cd ~/ic/setup
```

> O caminho `~/ic/setup` é assumido pelos scripts. Se quiser usar outro, edite
> `env/ic-bashrc.sh` e ajuste `IC_HOME`.

## 2.2 Rodar os scripts em ordem

Cada script pode ser rodado de forma independente e é idempotente (re-rodar é
seguro). Os logs ficam em `~/ic/tools/logs/`.

### 2.2.1 Dependências do sistema

```bash
bash scripts/00-install-deps.sh
```

Instala via `apt`: toolchain C/C++, Tcl/Tk, bibliotecas X11/Cairo, Python 3,
flex/bison e tudo que as ferramentas precisam para compilar.

### 2.2.2 Ferramentas analógicas

```bash
bash scripts/01-install-analog.sh
```

Compila e instala em `/usr/local`:

- **Xschem** — captura de esquemático + netlist (versão `master` do Stefan Schippers)
- **ngspice** — simulador (última release estável, via SourceForge tarball)
- **Magic** — layout + DRC (`RTimothyEdwards/magic`, branch `master`)
- **Netgen** — LVS (`RTimothyEdwards/netgen`)
- **KLayout** — visualização/edição de GDS (.deb oficial da klayout.de)
- **gaw3** — waveform viewer (opcional, do autor do Xschem)

Vai levar 20-40 min dependendo da máquina.

### 2.2.3 Ferramentas digitais

```bash
bash scripts/02-install-digital.sh
```

Instala:

- **Yosys** — síntese Verilog → gates (compilado, última release)
- **Icarus Verilog** — simulação Verilog comportamental (apt)
- **Verilator** — simulação Verilog de alto desempenho (apt)
- **GTKWave** — visualização de waveforms digitais (apt)
- **Nix package manager** — necessário para OpenLane2 (fluxo RTL→GDS completo)
- **OpenLane2** — orquestra Yosys + OpenROAD + KLayout etc. (via Nix)

> OpenLane2 roda em um ambiente Nix isolado — isso mantém OpenROAD, OpenSTA,
> magic etc. do fluxo digital totalmente separados do que você compilou em
> `/usr/local`, sem conflitos de versão.

### 2.2.4 PDKs SkyWater e GlobalFoundries (via Volare)

```bash
bash scripts/03-install-pdks.sh
```

Instala:

- `sky130A` e `sky130B` (SkyWater 130 nm)
- `gf180mcuD` (GlobalFoundries 180 nm MCU)

Via `volare`, que baixa builds pré-compilados e versionados. Fica em
`$PDK_ROOT = ~/ic/pdks`.

### 2.2.5 PDK IHP SG13G2

```bash
bash scripts/04-install-ihp-pdk.sh
```

Clona `IHP-GmbH/IHP-Open-PDK` para `~/ic/pdks/ihp-sg13g2`. Esse PDK já vem com
configurações nativas para Xschem, Magic e ngspice.

## 2.3 Ativar o ambiente no shell

Adicione no final de `~/.bashrc`:

```bash
source ~/ic/setup/env/ic-bashrc.sh
```

Recarregue:

```bash
source ~/.bashrc
```

Isso define:
- `IC_HOME`, `PDK_ROOT`
- PATH para `~/ic/setup/bin` (helpers como `use-pdk`)
- Aliases úteis

Confirme:

```bash
use-pdk                 # deve listar: sky130A, sky130B, gf180mcuD, ihp-sg13g2
xschem --version
ngspice --version
magic -v
klayout -v
yosys -V
```

## 2.4 Ordem se você tem pouco tempo

Mínimo viável para começar analógico com SKY130:

```bash
bash scripts/00-install-deps.sh
bash scripts/01-install-analog.sh
bash scripts/03-install-pdks.sh
```

~1 hora de build no total. Digital e IHP podem vir depois.

---

Próximo passo: **[docs/03-pdk-management.md](03-pdk-management.md)** para
entender como os PDKs ficam organizados e como trocar entre eles.
