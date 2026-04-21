# shellcheck shell=bash
# Funções comuns usadas por todos os scripts de instalação.
# Deve ser *sourced*, não executado.

set -euo pipefail

# --- Paths padrão ---------------------------------------------------------
: "${IC_HOME:=$HOME/ic/setup}"
: "${IC_ROOT:=$HOME/ic}"
: "${IC_SRC:=$IC_ROOT/tools/src}"
: "${IC_LOGS:=$IC_ROOT/tools/logs}"
: "${PDK_ROOT:=$IC_ROOT/pdks}"
: "${INSTALL_PREFIX:=/usr/local}"
: "${MAKE_JOBS:=$(nproc)}"

mkdir -p "$IC_SRC" "$IC_LOGS" "$PDK_ROOT"

# --- Logging --------------------------------------------------------------
_ts() { date '+%H:%M:%S'; }
log()   { printf '\033[1;34m[%s] %s\033[0m\n' "$(_ts)" "$*"; }
ok()    { printf '\033[1;32m[%s] OK: %s\033[0m\n' "$(_ts)" "$*"; }
warn()  { printf '\033[1;33m[%s] WARN: %s\033[0m\n' "$(_ts)" "$*" >&2; }
die()   { printf '\033[1;31m[%s] ERRO: %s\033[0m\n' "$(_ts)" "$*" >&2; exit 1; }

# --- Helpers --------------------------------------------------------------

# Clona ou atualiza um repositório git para um diretório destino específico.
# Uso: git_sync <url> <dir> [ref]
git_sync() {
    local url="$1" dest="$2" ref="${3:-}"
    if [[ -d "$dest/.git" ]]; then
        log "git fetch em $dest"
        git -C "$dest" fetch --all --tags --prune
    else
        log "git clone $url -> $dest"
        git clone "$url" "$dest"
    fi
    if [[ -n "$ref" ]]; then
        log "checkout $ref em $dest"
        git -C "$dest" checkout "$ref"
    fi
}

# Executa um comando, direcionando stdout/stderr para log nomeado.
# Uso: run_logged <nome> -- <cmd...>
run_logged() {
    local name="$1"; shift
    [[ "$1" == "--" ]] && shift
    local logfile="$IC_LOGS/${name}.log"
    log "Executando [$name] -> log: $logfile"
    if ! ( "$@" ) >"$logfile" 2>&1; then
        tail -n 40 "$logfile" >&2 || true
        die "[$name] falhou. Log completo em $logfile"
    fi
}

# Retorna 0 se o binário já existe no PATH.
has_cmd() { command -v "$1" >/dev/null 2>&1; }

# Requer que o script rode com privilégios sudo disponíveis (pede senha 1x).
require_sudo() {
    if ! sudo -v; then
        die "sudo é necessário. Abortando."
    fi
    # Mantém sudo vivo em background enquanto o script roda.
    ( while true; do sudo -n true; sleep 60; done ) 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null || true' EXIT
}

banner() {
    printf '\n\033[1;36m%s\033[0m\n' "================================================================"
    printf '\033[1;36m  %s\033[0m\n' "$*"
    printf '\033[1;36m%s\033[0m\n\n' "================================================================"
}
