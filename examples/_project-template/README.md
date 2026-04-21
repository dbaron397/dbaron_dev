# Template de projeto

Copie este diretório inteiro para `~/ic/projects/<nome-do-projeto>/` e já
começa com um projeto PDK-agnóstico pronto.

```bash
cp -r ~/ic/setup/examples/_project-template ~/ic/projects/meu_projeto
cd ~/ic/projects/meu_projeto
use-pdk sky130A
xschem
```

## Estrutura

```
meu_projeto/
├── .xschemrc        # config do Xschem (usa $PDK_ROOT / $PDK)
├── .spiceinit       # opções do ngspice
├── .magicrc         # carrega tech do PDK ativo
├── simulation/      # netlists e testbenches SPICE  (gerado pelo Xschem)
├── layout/          # arquivos .mag e .gds
│   └── gds/         # GDS exportados/importados
└── docs/            # notas do projeto
```

## Trocando de PDK no mesmo projeto

```bash
use-pdk gf180mcuD    # todos os arquivos de config passam a apontar para GF180
xschem               # reabre já no novo PDK
```

Lembre: o **circuito** (devices instanciados) é específico do PDK. A *infra*
do projeto (config files) é que é PDK-agnóstica.
