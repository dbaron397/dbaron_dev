# shellcheck shell=bash
# Limpa variáveis ligadas a PDK anterior antes de ativar um novo.
# Chamado automaticamente por `use-pdk` antes do pdk-<nome>.sh.

unset PDK PDKPATH
unset XSCHEM_LIBRARY_PATH XSCHEM_USER_LIBRARY_PATH XSCHEMRC
unset MAGIC_RC MAGIC_EXT MAGICRC
unset NGSPICE_MODEL_PATH SPICE_LIB_DIR
unset STD_CELL_LIBRARY IO_CELL_LIBRARY
unset KLAYOUT_HOME KLAYOUT_PATH

# PDK_ROOT é persistente (não muda entre PDKs)
export PDK_ROOT="${PDK_ROOT:-$HOME/ic/pdks}"
