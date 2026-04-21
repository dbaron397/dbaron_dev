# shellcheck shell=bash
# Bloco para incluir no ~/.bashrc:
#   source ~/ic/setup/env/ic-bashrc.sh
#
# Define variáveis base e registra a função shell `use-pdk` para troca rápida
# de PDK na sessão corrente.

# --- Caminhos base --------------------------------------------------------
export IC_HOME="${IC_HOME:-$HOME/ic/setup}"
export IC_ROOT="${IC_ROOT:-$HOME/ic}"
export PDK_ROOT="${PDK_ROOT:-$IC_ROOT/pdks}"

# Adiciona bin/ do setup ao PATH
case ":$PATH:" in
    *":$IC_HOME/bin:"*) ;;
    *) export PATH="$IC_HOME/bin:$PATH" ;;
esac

# Venv do Volare — ativa apenas quando necessário (evita poluir o shell).
ic-volare() {
    # shellcheck disable=SC1091
    source "$IC_ROOT/tools/volare-venv/bin/activate"
}

# --- Função use-pdk -------------------------------------------------------
# Precisa ser função (não script) porque exporta vars no shell atual.
use-pdk() {
    local env_dir="$IC_HOME/env"
    local pdk="${1:-}"

    if [[ -z "$pdk" ]]; then
        echo "PDKs disponíveis:"
        ( cd "$env_dir" && ls pdk-*.sh 2>/dev/null \
            | sed -E 's|^pdk-||; s|\.sh$||' \
            | sed 's/^/  - /' )
        if [[ -n "${PDK:-}" ]]; then
            echo
            echo "PDK ativo no momento: $PDK"
        fi
        return 0
    fi

    local file="$env_dir/pdk-${pdk}.sh"
    if [[ ! -f "$file" ]]; then
        echo "ERRO: PDK '$pdk' não encontrado em $env_dir." >&2
        echo "Rode 'use-pdk' sem argumento para listar os disponíveis." >&2
        return 1
    fi

    # shellcheck disable=SC1090
    source "$env_dir/pdk-common.sh"
    # shellcheck disable=SC1090
    source "$file"

    printf '\033[1;32m==> PDK ativo: %s\033[0m\n' "$PDK"
    printf '    PDK_ROOT            = %s\n' "$PDK_ROOT"
    printf '    PDKPATH             = %s\n' "$PDKPATH"
    printf '    XSCHEM_LIBRARY_PATH = %s\n' "$XSCHEM_LIBRARY_PATH"
    printf '    MAGIC_RC            = %s\n' "$MAGIC_RC"
}

# --- Aliases práticos -----------------------------------------------------
alias ic-cd-projects='cd $IC_ROOT/projects'
alias ic-cd-setup='cd $IC_HOME'

# Autocompletion simples para use-pdk
_use_pdk_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local choices
    choices=$(cd "$IC_HOME/env" 2>/dev/null && ls pdk-*.sh 2>/dev/null \
              | sed -E 's|^pdk-||; s|\.sh$||')
    # shellcheck disable=SC2207
    COMPREPLY=( $(compgen -W "$choices" -- "$cur") )
}
complete -F _use_pdk_complete use-pdk 2>/dev/null || true
