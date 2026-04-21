#!/usr/bin/env bash
# Compila e instala as ferramentas do fluxo analógico:
#   Xschem, ngspice, Magic, Netgen, KLayout, gaw3
#
# Prefix padrão: /usr/local  (exigir sudo)
# Fontes ficam em ~/ic/tools/src/<tool>.
# Logs em ~/ic/tools/logs/<tool>.log.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

banner "01 — Ferramentas analógicas"

require_sudo

# ------------------------------------------------------------------
# Versões / refs
# ------------------------------------------------------------------
# Refs podem ser alteradas via env var, ex.: NGSPICE_VERSION=44 bash 01-install-analog.sh
: "${XSCHEM_REF:=master}"            # Xschem: usa master (muito ativo, estável)
: "${MAGIC_REF:=master}"             # magic
: "${NETGEN_REF:=master}"            # netgen
: "${KLAYOUT_VERSION:=0.29.11}"      # klayout (se .deb, senão build from source)

# ------------------------------------------------------------------
# Xschem
# ------------------------------------------------------------------
install_xschem() {
    local dir="$IC_SRC/xschem"
    git_sync https://github.com/StefanSchippers/xschem.git "$dir" "$XSCHEM_REF"
    log "Configurando Xschem..."
    ( cd "$dir" && ./configure --prefix="$INSTALL_PREFIX" )
    log "Compilando Xschem (-j$MAKE_JOBS)..."
    run_logged xschem-build -- make -C "$dir" -j"$MAKE_JOBS"
    log "Instalando Xschem..."
    run_logged xschem-install -- sudo make -C "$dir" install
    ok "Xschem instalado: $(xschem --version 2>&1 | head -1 || true)"
}

# ------------------------------------------------------------------
# ngspice
# ------------------------------------------------------------------
install_ngspice() {
    local dir="$IC_SRC/ngspice"

    # Clona direto do git oficial (SourceForge) -- evita problema de versão/tarball.
    # Repo canônico; sem dependência de número de release.
    git_sync https://git.code.sf.net/p/ngspice/ngspice "$dir"

    log "Configurando ngspice (autogen + configure)..."
    ( cd "$dir" && ./autogen.sh )
    ( cd "$dir" && ./configure \
        --prefix="$INSTALL_PREFIX" \
        --disable-debug \
        --with-x \
        --with-readline=yes \
        --enable-xspice \
        --enable-cider \
        --enable-openmp )
    log "Compilando ngspice (-j$MAKE_JOBS)..."
    run_logged ngspice-build -- make -C "$dir" -j"$MAKE_JOBS"
    log "Instalando ngspice..."
    run_logged ngspice-install -- sudo make -C "$dir" install
    ok "ngspice instalado: $(ngspice -v 2>&1 | head -1 || true)"
}

# ------------------------------------------------------------------
# Magic
# ------------------------------------------------------------------
install_magic() {
    local dir="$IC_SRC/magic"
    git_sync https://github.com/RTimothyEdwards/magic.git "$dir" "$MAGIC_REF"
    log "Configurando Magic..."
    ( cd "$dir" && ./configure --prefix="$INSTALL_PREFIX" )
    log "Compilando Magic..."
    run_logged magic-build -- make -C "$dir" -j"$MAKE_JOBS"
    log "Instalando Magic..."
    run_logged magic-install -- sudo make -C "$dir" install
    ok "Magic instalado: $(magic -v 2>&1 | head -1 || true)"
}

# ------------------------------------------------------------------
# Netgen
# ------------------------------------------------------------------
install_netgen() {
    local dir="$IC_SRC/netgen"
    git_sync https://github.com/RTimothyEdwards/netgen.git "$dir" "$NETGEN_REF"
    log "Configurando Netgen..."
    ( cd "$dir" && ./configure --prefix="$INSTALL_PREFIX" )
    log "Compilando Netgen..."
    run_logged netgen-build -- make -C "$dir" -j"$MAKE_JOBS"
    log "Instalando Netgen..."
    run_logged netgen-install -- sudo make -C "$dir" install
    ok "Netgen instalado."
}

# ------------------------------------------------------------------
# KLayout (via .deb oficial — muito mais rápido que compilar)
# ------------------------------------------------------------------
install_klayout() {
    if has_cmd klayout; then
        log "KLayout já presente ($(klayout -v 2>&1 | head -1)). Pulando."
        return
    fi
    local ver="$KLAYOUT_VERSION"
    local deb="klayout_${ver}-1_amd64.deb"
    local url="https://www.klayout.org/downloads/Ubuntu-24/${deb}"
    local tmp="$IC_SRC/$deb"
    log "Baixando KLayout ${ver}..."
    wget -O "$tmp" "$url"
    log "Instalando KLayout..."
    sudo apt install -y "$tmp"
    rm -f "$tmp"
    ok "KLayout instalado: $(klayout -v 2>&1 | head -1 || true)"
}

# ------------------------------------------------------------------
# gaw3 (waveform viewer, opcional mas útil com Xschem)
# ------------------------------------------------------------------
install_gaw() {
    local dir="$IC_SRC/xschem-gaw"
    git_sync https://github.com/StefanSchippers/xschem-gaw.git "$dir"
    log "Configurando gaw3..."
    ( cd "$dir" && aclocal && automake --add-missing 2>/dev/null || true )
    ( cd "$dir" && ./configure --prefix="$INSTALL_PREFIX" )
    log "Compilando gaw3..."
    run_logged gaw-build -- make -C "$dir" -j"$MAKE_JOBS"
    log "Instalando gaw3..."
    run_logged gaw-install -- sudo make -C "$dir" install
    ok "gaw3 instalado."
}

# ------------------------------------------------------------------
# Orquestra — comente a linha da ferramenta que você não quer (re)instalar
# ------------------------------------------------------------------
install_xschem
install_ngspice
install_magic
install_netgen
install_klayout
install_gaw || warn "gaw3 falhou (opcional); siga em frente."

banner "Analog: concluído"
log "Teste rápido:"
log "  xschem --version"
log "  ngspice -v | head -1"
log "  magic -v"
log "  netgen -batch lvs -h  (deve imprimir help)"
log "  klayout -v"
