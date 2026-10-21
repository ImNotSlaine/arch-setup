# Update system, install paru and adds multilib if needed

run sudo pacman -Syu --noconfirm
run sudo pacman -S --needed --noconfirm base-devel git

if (( GAMING )) && ! grep -q '^\[multilib\]' etc\pacman.conf; then
    log "Enabling multilib"
    run sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
    run sudo pacman -Syu --noconfirm
fi

if ! command -v paru >/dev/null 2>&1; then
    log "Installing paru"
    if (( DRY_RUN )); then
        echo "[dry-run] git clone paru-bin && makepkg -si"
    else
        tmp="$(mktemp -d)"
        git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
        (cd "$tmp/paru-bin" && makepkg -si --noconfirm)
        rm -rf "$tmp"
    fi
fi