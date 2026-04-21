# shellcheck shell=bash
# GlobalFoundries 180 nm MCU -- variante D (3.3V + 5V + 6V devices).

export PDK="gf180mcuD"
export PDKPATH="$PDK_ROOT/$PDK"

if [[ ! -d "$PDKPATH" ]]; then
    echo "ERRO: $PDKPATH não existe. Rode scripts/03-install-pdks.sh." >&2
    return 1
fi

export XSCHEM_LIBRARY_PATH="$PDKPATH/libs.tech/xschem"
export MAGIC_RC="$PDKPATH/libs.tech/magic/${PDK}.magicrc"
export NGSPICE_MODEL_PATH="$PDKPATH/libs.tech/ngspice"
export SPICE_LIB_DIR="$NGSPICE_MODEL_PATH"

# GF180 tem várias std cell libs; 7T "high density" é o default comum
export STD_CELL_LIBRARY="gf180mcu_fd_sc_mcu7t5v0"
export IO_CELL_LIBRARY="gf180mcu_fd_io"

export KLAYOUT_HOME="$PDKPATH/libs.tech/klayout"
