# Shared functions.

: "${DRY_RUN:=0}"

log()   { printf '\e[32m==>\e[0m %s\n' "$*"; }
warn()  { printf '\e[33m[!]\e[0m %s\n' "$*" >&2; }
die()   { printf '\e[31m[x]\e[0m %s\n' "$*" >&2; exit 1; }

run() {
    if (( DRY_RUN )); then
        printf '\e[33m[dry-run]\e[0m %s\n '; printf '%q ' "$@"; echo
    else
        "$@"
    fi
}

read_list() {
    sed 's/[[:space:]]*#.*//' "$1" | grep -v '^[[:space:]]*$' || true
}

# Collect all packages of active groups 
collect_pkgs() {
    local kind=$1 g f
    for g in "${PKG_GROUPS[@]}"; do
        f="$ROOT/packages/$kind/$g.txt"
        if [[ -f $f ]]; then read_list "$f"; fi
    done | sort -u
}

# Collect all flatpaks of active groups
collect_flatpaks() {
    local g f
    for g in "${PKG_GROUPS[@]}"; do
        f="$ROOT/packages/flatpak/$g.txt"
        if [[ -f $f ]]; then read_list "$f"; fi
    done | sort -u
}

# Collect systemd units of active groups
collect_units() {
    local kind=$1 g f
    for g in "${PKG_GROUPS[@]}"; do
        f="$ROOT/services/$kind/$g.txt"
        if [[ -f $f ]]; then read_list "$f"; fi
    done | sort -u
}