#!/usr/bin/env bash
# Install needed packages
# Dotfiles are managed with the chezmoi package, installed if needed.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT/lib/common.sh"

MODULES=(bootstrap gpu packages aur flatpak services)
PROFILE="", GAMING=0; DEV=0; EDIT=0; DRY_RUN=0; ONLY=()

usage() {
    cat <<USAGE
Use: $0 --profile laptop|desktop [options]
    --profile P laptop|desktop (asks if ommited)
    --dev       Add devs module
    --gaming    Add gaming module (actives multilib repository)
    --edit      Add editing module
    --only M    Execute only specific module (repeatable)
    --dry-run   Shows result without executing
    -h, --help  Shows this help

Optional variable: GPU_OVERRIDE=nvidia,intel (forces detected GPU)
USAGE
    exit "${1:-0}"
}

while (( $# )); do
    case "$1" in
        --profile)  PROFILE="${2:-}"; shift 2 ;;
        --dev)      DEV=1; shift ;;
        --gaming)   GAMING=1; shift ;;
        --edit)     EDIT=1; shift ;;
        --only)     ONLY+=("${2:-}"); shift 2 ;;
        --dry-run)  DRY_RUN=1; shift ;;
        -h|--help)  usage 0 ;;
        *) warn "Unknown option: $1"; usage 1 ;;
    esac
done

if [[ -z $PROFILE ]]; then
    [[ -t 0 ]] || die "Missing --profile (no terminal for asking)"
    select PROFILE in laptop desktop; do [[ -n $PROFILE ]] && break; done
fi
[[ $PROFILE == laptop || $PROFILE == desktop ]] || die "Invalid profile: $PROFILE"

(( EUID != 0 )) || die "Please don't run this script as root"
command -v pacman >/dev/null || die "This script only works on Arch or Arch based distributions"

PKG_GROUPS=(base "$PROFILE")
(( DEV ))       && PKG_GROUPS+=(dev)
(( GAMING ))    && PKG_GROUPS+=(gaming)
(( EDIT ))      && PKG_GROUPS+=(edit)
export ROOT DRY_RUN GAMING DEV EDIT PROFILE

log "Profile: $PROFILE | Groups: ${PKG_GROUPS[*]} | dry-run: $DRY_RUN"

for m in "${MODULES[@]}"; do
    if (( ${#ONLY[@]} )) && [[ ! " ${ONLY[*]} " == *" $m "* ]]; then continue; fi
    log "Module: $m"
    source "$ROOT/modules/$m.sh"
done

log "Ready. Run chezmoi init --apply <user> and reboot"