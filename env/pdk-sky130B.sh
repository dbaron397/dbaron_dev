# shellcheck shell=bash
# SkyWater Sky130B -- variante com devices RRAM (ReRAM) adicionais.
# Estrutura idêntica ao 130A.

export PDK="sky130B"
export PDKPATH="$PDK_ROOT/$PDK"

if [[ ! -d "$PDKPATH" ]]; then
    echo "ERRO: $PDKPATH não existe. Rode scripts/03-install-pdks.sh." >&2
    return 1
fi

export XSCHEM_LIBRARY_PATH="$PDKPATH/libs.tech/xschem"
export MAGIC_RC="$PDKPATH/libs.tech/magic/${PDK}.magicrc"
export NGSPICE_MODEL_PATH="$PDKPATH/libs.tech/ngspice"
export SPICE_LIB_DIR="$NGSPICE_MODEL_PATH"

export STD_CELL_LIBRARY="sky130_fd_sc_hd"
export IO_CELL_LIBRARY="sky130_fd_io"

export KLAYOUT_HOME="$PDKPATH/libs.tech/klayout"
