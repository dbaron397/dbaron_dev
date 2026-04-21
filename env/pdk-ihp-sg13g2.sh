# shellcheck shell=bash
# IHP SG13G2 -- 130 nm BiCMOS open-source PDK da IHP.
# Estrutura de diretórios é diferente dos PDKs Volare: o repo IHP-Open-PDK
# contém a tecnologia em subdiretórios tipo ihp-sg13g2/libs.tech/... .

export PDK="ihp-sg13g2"
# O clone vai para $PDK_ROOT/ihp-sg13g2, e internamente tem ihp-sg13g2/libs.tech/...
export PDKPATH="$PDK_ROOT/ihp-sg13g2/ihp-sg13g2"

if [[ ! -d "$PDKPATH" ]]; then
    # Fallback: algumas versões do repo expõem a pasta direto
    if [[ -d "$PDK_ROOT/ihp-sg13g2/libs.tech" ]]; then
        PDKPATH="$PDK_ROOT/ihp-sg13g2"
    else
        echo "ERRO: $PDKPATH não existe. Rode scripts/04-install-ihp-pdk.sh." >&2
        return 1
    fi
fi

# Xschem
export XSCHEM_LIBRARY_PATH="$PDKPATH/libs.tech/xschem"

# Magic
if [[ -f "$PDKPATH/libs.tech/magic/sg13g2.magicrc" ]]; then
    export MAGIC_RC="$PDKPATH/libs.tech/magic/sg13g2.magicrc"
elif [[ -f "$PDKPATH/libs.tech/magic/ihp-sg13g2.magicrc" ]]; then
    export MAGIC_RC="$PDKPATH/libs.tech/magic/ihp-sg13g2.magicrc"
fi

# ngspice
export NGSPICE_MODEL_PATH="$PDKPATH/libs.tech/ngspice"
export SPICE_LIB_DIR="$NGSPICE_MODEL_PATH"

# Digital
export STD_CELL_LIBRARY="sg13g2_stdcell"
export IO_CELL_LIBRARY="sg13g2_io"

# KLayout
export KLAYOUT_HOME="$PDKPATH/libs.tech/klayout"
