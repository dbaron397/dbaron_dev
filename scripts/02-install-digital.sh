#!/usr/bin/env bash
# Fluxo digital:
#   - Yosys (compilado)
#   - Icarus Verilog, Verilator, GTKWave (já via apt, em 00-install-deps.sh)
#   - Nix + OpenLane2 (RTL -> GDS)
#
# OpenLane2 roda em ambiente Nix isolado; não conflita com Yosys/KLayout
# instalados em /usr/local.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

banner "02 — Ferramentas digitais"

require_sudo

: "${YOSYS_REF:=main}"

# ------------------------------------------------------------------
# Yosys
# ------------------------------------------------------------------
install_yosys() {
    local dir="$IC_SRC/yosys"
    git_sync https://github.com/YosysHQ/yosys.git "$dir" "$YOSYS_REF"
    log "Atualizando submódulos do Yosys..."
    ( cd "$dir" && git submodule update --init --recursive )
    log "Compilando Yosys (-j$MAKE_JOBS)... pode levar alguns minutos."
    run_logged yosys-build -- make -C "$dir" -j"$MAKE_JOBS" PREFIX="$INSTALL_PREFIX"
    log "Instalando Yosys..."
    run_logged yosys-install -- sudo make -C "$dir" install PREFIX="$INSTALL_PREFIX"
    ok "Yosys instalado: $(yosys -V 2>&1 | head -1 || true)"
}

# ------------------------------------------------------------------
# Nix (instalação via Determinate Systems installer - multi-user e limpo)
# ------------------------------------------------------------------
install_nix() {
    if has_cmd nix; then
        log "Nix já instalado ($(nix --version)). Pulando."
        return
    fi
    log "Instalando Nix via Determinate Systems installer..."
    curl --proto '=https' --tlsv1.2 -sSf -L \
        https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
    log "Nix instalado. Pode ser necessário abrir um novo shell para ativar."
    ok "Nix pronto."
}

# ------------------------------------------------------------------
# OpenLane2 (via Nix flake - método oficial recomendado)
# ------------------------------------------------------------------
install_openlane2() {
    local dir="$IC_SRC/openlane2"
    git_sync https://github.com/efabless/openlane2.git "$dir"
    log "Pre-buildando ambiente Nix do OpenLane2 (pode levar 15-30 min na 1a vez)..."
    # Ativa Nix no shell atual
    if ! has_cmd nix; then
        # Tenta carregar Nix do perfil padrão
        . /etc/profile.d/nix.sh 2>/dev/null || \
        . "$HOME/.nix-profile/etc/profile.d/nix.sh" 2>/dev/null || \
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null || true
    fi
    if ! has_cmd nix; then
        warn "Nix não disponível na sessão atual. Abra um novo terminal e rode:"
        warn "  cd $dir && nix develop"
        return
    fi
    # Pre-cria o shell ambiente para popular caches (opcional mas recomendado)
    ( cd "$dir" && nix-shell -p nix-info --run "nix develop --accept-flake-config --command echo OpenLane2 ok" ) || \
        warn "Pre-build falhou; você pode rodar 'nix develop' manualmente mais tarde."
    ok "OpenLane2 clonado em $dir. Para usar: cd $dir && nix develop"
}

# ------------------------------------------------------------------
# Orquestra
# ------------------------------------------------------------------
install_yosys
install_nix
install_openlane2

banner "Digital: concluído"
log "Testes rápidos:"
log "  yosys -V"
log "  iverilog -V | head -1"
log "  verilator --version"
log "  gtkwave --version"
log ""
log "Para rodar OpenLane2 em um projeto:"
log "  cd ~/ic/tools/src/openlane2 && nix develop"
log "  openlane --help"
