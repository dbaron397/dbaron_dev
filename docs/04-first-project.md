# 4. Primeiro projeto — inversor CMOS no SKY130

Objetivo: validar que Xschem, ngspice, Magic, Netgen e o PDK SKY130 estão
funcionando. Vamos capturar um inversor CMOS, simular, desenhar o layout,
rodar DRC e LVS.

## 4.1 Criar o projeto

```bash
use-pdk sky130A

mkdir -p ~/ic/projects/inv_sky130
cd ~/ic/projects/inv_sky130

# Copia o template do repositório
cp -r ~/ic/setup/examples/_project-template/. .
```

O template traz:
- `.xschemrc` — carrega bibliotecas do PDK ativo
- `.spiceinit` — opções default do ngspice
- `.magicrc` — carrega tech e setup do PDK ativo
- `sim/` — diretório para netlists e resultados
- `layout/` — diretório para GDS/MAG

## 4.2 Esquemático no Xschem

```bash
xschem
```

Dentro do Xschem:

1. `File → New schematic` → salve como `inverter.sch`.
2. Tecla `Insert` (ou menu `Objects → Insert symbol`).
3. Navegue para `sky130_fd_pr` e adicione:
   - `nfet_01v8` → clique para colocar
   - `pfet_01v8` → clique para colocar
4. Edite propriedades (tecla `q` sobre o símbolo):
   - NMOS: `W=1u L=0.15u nf=1 m=1`
   - PMOS: `W=2u L=0.15u nf=1 m=1`
5. Conecte gates, drains. Adicione ports (`Insert → ipin/opin`):
   - `IN` (entrada), `OUT` (saída), `VDD`, `VSS`
6. `Netlist → Netlist type → SPICE`, depois `Netlist → Create netlist` (ou `N`).

O netlist sai em `simulation/inverter.spice`.

## 4.3 Testbench e simulação

Crie `sim/tb_inverter.spice`:

```spice
* Testbench: DC sweep e transiente do inversor
.include ~/ic/projects/inv_sky130/simulation/inverter.spice
.lib $PDK_ROOT/sky130A/libs.tech/ngspice/sky130.lib.spice tt

Vdd vdd 0 1.8
Vin in  0 PULSE(0 1.8 1n 100p 100p 2n 4n)

Xinv in out vdd 0 inverter

.tran 10p 10n
.control
run
plot v(in) v(out)
.endc
.end
```

Rode:

```bash
ngspice sim/tb_inverter.spice
```

Uma janela de plot deve abrir mostrando o chaveamento.

## 4.4 Layout no Magic

```bash
cd layout
magic -T sky130A
```

No Magic:
- `File → Read → inverter` para criar novo
- Use `sky130A.tech` paleta lateral
- Desenhe difusões, polys, contatos, metal1
- `DRC check → DRC count total` para rodar DRC

Salve (`:save inverter`) e exporte GDS:
```
gds write inverter
```

## 4.5 Extração e LVS

Extrair netlist do layout no Magic:

```
extract all
ext2spice lvs
ext2spice
```

Gera `inverter.spice` a partir do layout. LVS com Netgen:

```bash
cd ~/ic/projects/inv_sky130
netgen -batch lvs \
  "layout/inverter.spice inverter" \
  "simulation/inverter.spice inverter" \
  $PDK_ROOT/sky130A/libs.tech/netgen/sky130A_setup.tcl \
  lvs.report
```

Abrir `lvs.report` — deve terminar com `Circuits match uniquely.`

## 4.6 Checklist final

- [ ] `use-pdk sky130A` define o ambiente sem erros
- [ ] Xschem abre e enxerga `sky130_fd_pr`
- [ ] ngspice simula e plota a forma de onda
- [ ] Magic abre com a tech sky130A
- [ ] DRC passa limpo
- [ ] Netgen retorna "Circuits match uniquely"

Com isso, o setup analógico está confirmado. Repita com `use-pdk gf180mcuD` e
`use-pdk ihp-sg13g2` trocando os nomes de device (`nfet_03v3`, `sg13_lv_nmos`
etc.) para validar os outros PDKs.

## 4.7 Próximos passos sugeridos

- Analog: amp-diff, bandgap, OTA — há exemplos no
  [github.com/iic-jku/](https://github.com/iic-jku) (Harald Pretl, JKU).
- Digital: teste OpenLane2 com um contador de 4 bits
  (`openlane --init-design-config ./contador`).
- Mixed-signal: Xschem permite embutir blocos digitais como caixa-preta e
  simular com ngspice + ícones Verilog (`.lib digital`).
