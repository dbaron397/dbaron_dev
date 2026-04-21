#!/usr/bin/env bash
# Instala PDKs SkyWater (sky130A, sky130B) e GlobalFoundries (gf180mcuD)
# via Volare (https://github.com/efabless/volare).
#
# Volare baixa builds pré-compiladas e versionadas — muito mais rápido que
# rodar open_pdks do zero.
#
# Destino: $PDK_ROOT  (padrão ~/ic/pdks)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

banner "03 — PDKs SkyWater + GF180MCU (via Volare)"

# ------------------------------------------------------------------
# Instala o Volare em um venv Python isolado.
# ------------------------------------------------------------------
VOLARE_VENV="$IC_ROOT/tools/volare-venv"
if [[ ! -d "$VOLARE_VENV" ]]; then
    log "Criando venv Python para Volare em $VOLARE_VENV"
    python3 -m venv "$VOLARE_VENV"
fi
# shellcheck disable=SC1091
source "$VOLARE_VENV/bin/activate"
pip install --upgrade pip wheel >/dev/null
log "Instalando/atualizando volare..."
pip install --upgrade volare

mkdir -p "$PDK_ROOT"
export PDK_ROOT

# ------------------------------------------------------------------
# SkyWater (sky130A + sky130B saem do mesmo build/commit)
# ------------------------------------------------------------------
log "Ativando SKY130 (última build estável do Volare)..."
# 'volare enable' sem argumento extra usa o commit default recomendado.
volare enable --pdk sky130

# ------------------------------------------------------------------
# GF180MCU  (variante D é a "default" recomendada hoje)
# ------------------------------------------------------------------
log "Ativando GF180MCU..."
volare enable --pdk gf180mcu

deactivate || true

ok "Volare terminou."
log "PDKs em \$PDK_ROOT:"
ls -1 "$PDK_ROOT"

banner "PDKs SkyWater / GF180 instalados"

log "Próximo: bash scripts/04-install-ihp-pdk.sh (para IHP SG13G2)"
