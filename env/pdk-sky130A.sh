# shellcheck shell=bash
# SkyWater Sky130A -- variante padrão para analógico e digital.

export PDK="sky130A"
export PDKPATH="$PDK_ROOT/$PDK"

if [[ ! -d "$PDKPATH" ]]; then
    echo "ERRO: $PDKPATH não existe. Rode scripts/03-install-pdks.sh." >&2
    return 1
fi

# Xschem
export XSCHEM_LIBRARY_PATH="$PDKPATH/libs.tech/xschem"
# Adiciona caminho user (se houver) sem quebrar se não existir
if [[ -d "$HOME/ic/projects/xschem-user" ]]; then
    export XSCHEM_USER_LIBRARY_PATH="$HOME/ic/projects/xschem-user"
fi

# Magic
export MAGIC_RC="$PDKPATH/libs.tech/magic/${PDK}.magicrc"

# ngspice
export NGSPICE_MODEL_PATH="$PDKPATH/libs.tech/ngspice"
export SPICE_LIB_DIR="$NGSPICE_MODEL_PATH"

# Digital defaults
export STD_CELL_LIBRARY="sky130_fd_sc_hd"
export IO_CELL_LIBRARY="sky130_fd_io"

# KLayout
export KLAYOUT_HOME="$PDKPATH/libs.tech/klayout"
