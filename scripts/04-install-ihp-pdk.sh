#!/usr/bin/env bash
# Instala o PDK IHP SG13G2 (130 nm BiCMOS) clonando o repositório oficial.
# O repo já traz setup para Xschem, Magic e ngspice.
#
# Origem: https://github.com/IHP-GmbH/IHP-Open-PDK
# Destino: $PDK_ROOT/ihp-sg13g2

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

banner "04 — PDK IHP SG13G2"

: "${IHP_REF:=main}"

IHP_DIR="$PDK_ROOT/ihp-sg13g2"

mkdir -p "$PDK_ROOT"

if [[ -d "$IHP_DIR/.git" ]]; then
    log "IHP-Open-PDK já presente; atualizando..."
    git -C "$IHP_DIR" fetch --all --prune
    git -C "$IHP_DIR" pull --ff-only
else
    log "Clonando IHP-Open-PDK em $IHP_DIR ..."
    # --depth 1 deixa o clone bem menor; remova se quiser histórico completo.
    git clone --depth 1 --branch "$IHP_REF" \
        https://github.com/IHP-GmbH/IHP-Open-PDK.git "$IHP_DIR"
fi

# O PDK IHP é distribuído com submódulos (models, examples) — garante atualização:
git -C "$IHP_DIR" submodule update --init --recursive || true

log "Estrutura do PDK IHP:"
ls -1 "$IHP_DIR" | head -20

ok "IHP SG13G2 instalado em $IHP_DIR"
log "Uso: use-pdk ihp-sg13g2"
