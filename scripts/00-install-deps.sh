#!/usr/bin/env bash
# Instala todas as dependências de sistema (via apt) para o restante dos
# scripts compilarem as ferramentas de IC.
# Testado em Ubuntu 24.04 LTS (WSL2).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"

banner "00 — Dependências de sistema (apt)"

require_sudo

sudo apt update

log "Instalando pacotes base..."
sudo apt install -y \
    build-essential autoconf automake libtool pkg-config \
    git curl wget ca-certificates gnupg \
    python3 python3-pip python3-venv python3-dev \
    flex bison \
    tcl-dev tk-dev itcl3-dev itk3-dev \
    libreadline-dev \
    libffi-dev \
    libx11-dev libxrender-dev libxt-dev libxext-dev libxpm-dev \
    libxaw7-dev libxcb1-dev \
    libcairo2-dev \
    libfftw3-dev \
    mesa-common-dev libglu1-mesa-dev \
    libgsl-dev \
    m4 tcsh csh \
    graphviz xdot \
    gawk \
    libboost-system-dev libboost-filesystem-dev libboost-python-dev \
    libboost-regex-dev libboost-thread-dev libboost-program-options-dev \
    zlib1g-dev \
    libeigen3-dev \
    libssl-dev \
    xz-utils unzip \
    clang llvm \
    xorg-dev \
    xdot

log "Instalando ferramentas auxiliares digitais e waveform viewers..."
sudo apt install -y \
    iverilog \
    verilator \
    gtkwave \
    magic-vlsi || warn "magic-vlsi do apt não disponível (ok, compilamos manualmente)."

log "Habilitando python3 como 'python' (via update-alternatives)..."
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 10 || true

ok "Dependências de sistema instaladas."
log "Próximo: bash scripts/01-install-analog.sh"
