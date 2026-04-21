# 3. Organização e troca de PDKs

## 3.1 Layout em disco

Todos os PDKs vivem em `$PDK_ROOT` (por padrão `~/ic/pdks`), cada um em seu
próprio diretório:

```
~/ic/pdks/
├── sky130A/
│   ├── libs.ref/          # models, LEF, GDS, SPICE das standard cells
│   ├── libs.tech/
│   │   ├── xschem/        # símbolos e netlists xschem
│   │   ├── magic/         # regras magic + .magicrc
│   │   ├── ngspice/       # include models + corners
│   │   ├── netgen/        # setup LVS
│   │   └── klayout/       # DRC/LVS scripts klayout
│   └── ...
├── sky130B/               # mesma estrutura (variante com RRAM)
├── gf180mcuD/             # mesma estrutura, GF 180nm
└── ihp-sg13g2/            # IHP 130nm BiCMOS
    └── ihp-sg13g2/
        └── libs.tech/xschem/, magic/, ngspice/, ...
```

Zero compartilhamento entre PDKs — cada um é auto-contido.

## 3.2 Variáveis de ambiente que cada PDK define

Quando você faz `use-pdk <nome>`, as seguintes variáveis são exportadas:

| Variável                | Para quê                                             |
|-------------------------|------------------------------------------------------|
| `PDK`                   | Nome do PDK ativo (ex: `sky130A`)                    |
| `PDK_ROOT`              | `~/ic/pdks` (onde TODOS os PDKs vivem)               |
| `PDKPATH`               | `$PDK_ROOT/$PDK` (PDK ativo atual)                   |
| `XSCHEM_LIBRARY_PATH`   | Caminho das bibliotecas do xschem do PDK             |
| `XSCHEM_USER_LIBRARY_PATH` | Bibliotecas do usuário (projetos)                 |
| `STD_CELL_LIBRARY`      | Lib digital default (ex: `sky130_fd_sc_hd`)          |
| `MAGIC_RC`              | Caminho do `.magicrc` do PDK                         |
| `NGSPICE_MODEL_PATH`    | Diretório de models ngspice                          |

## 3.3 Comando `use-pdk`

`use-pdk` é um shell function (precisa ser **sourced**, não executado). O
`ic-bashrc.sh` já faz o source da função, então basta chamar:

```bash
use-pdk                 # sem argumento: lista PDKs instalados
use-pdk sky130A         # ativa
use-pdk gf180mcuD       # troca
echo $PDK               # sky130A / gf180mcuD / ...
```

Saída típica:

```
$ use-pdk sky130A
==> PDK ativo: sky130A
    PDK_ROOT = /home/user/ic/pdks
    PDKPATH  = /home/user/ic/pdks/sky130A
    XSCHEM_LIBRARY_PATH inclui $PDKPATH/libs.tech/xschem
```

## 3.4 Como um projeto fica "PDK-agnóstico"

Em cada projeto, use os arquivos-template de `examples/_project-template/`:

**`.xschemrc`** (fica na raiz do projeto):
```tcl
# Usa o PDK ativo via variáveis de ambiente
set PDK_ROOT $env(PDK_ROOT)
set PDK $env(PDK)
append XSCHEM_LIBRARY_PATH :$env(XSCHEM_LIBRARY_PATH)
# customizações do projeto
```

**`.spiceinit`**:
```
set ngbehavior=hsa
set ng_nomodcheck
```

**`.magicrc`**: apenas `source $::env(MAGIC_RC)` e pronto.

Com isso, trocar de PDK é apenas `use-pdk outro-pdk` e abrir o mesmo projeto
de novo — não edita nada.

> **Atenção:** obviamente um esquemático que instancia `sky130_fd_pr__nfet_01v8`
> não vai rodar em GF180 ou IHP. "PDK-agnóstico" aqui se refere à
> *infraestrutura* do projeto; o conteúdo do circuito depende do PDK alvo.
> Uma prática comum é ter um `device_wrappers.sch` por PDK e o circuito usar
> wrappers.

## 3.5 Atualizar PDKs

**SkyWater / GF180 (via Volare):**
```bash
# Lista versões disponíveis
volare ls-remote --pdk sky130
# Ativa uma versão específica
volare enable --pdk sky130 <commit-sha>
```

**IHP SG13G2:**
```bash
cd ~/ic/pdks/ihp-sg13g2 && git pull
```

## 3.6 Espaço em disco (referência)

| PDK           | Tamanho aproximado |
|---------------|--------------------|
| `sky130A`     | ~2 GB              |
| `sky130B`     | ~2 GB              |
| `gf180mcuD`   | ~3 GB              |
| `ihp-sg13g2`  | ~5 GB              |
| **Total**     | **~12 GB**         |

Mais as ferramentas compiladas (~3 GB) e o ambiente Nix do OpenLane2 (~5 GB).
Reserve ~25 GB livres.

---

Próximo passo: **[docs/04-first-project.md](04-first-project.md)** para criar
seu primeiro circuito analógico e confirmar que o setup funciona.
