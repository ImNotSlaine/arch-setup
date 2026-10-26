# Configure Flathub

SCOPE=--system
FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

log "Adding remote Flathub"
run sudo flatpak remote-add --if-not-exists "$SCOPE" flathub "$FLATHUB_URL"

if (( EDIT )); then
    tmp="$(mktemp -d)"
    log "Installing ArtCraft launcher app"
    run wget "$tmp" "https://github.com/storytold/craft-launcher/releases/download/v0.5.1/artcraft-launcher-0.5.1-linux-x86_64.flatpak"
    run flatpak install --user "$tmp/artcraft-launcher-0.5.1-linux-x86_64.flatpak" \
        || warn "Couldn't install Artcraft launcher app"
fi

mapfile -t apps < <(collect_flatpaks)
if (( ${#apps[@]} == 0 )); then
    log "No flatpaks in profile"
else
    for app in "${apps[@]}"; do
        if (( ! DRY_RUN )) && flatpak info "$app" > /dev/null 2>&1; then
            log "$app already installed"
            continue
        fi
        run sudo flatpak install "$SCOPE" -y --noninteractive flathub "$app" \
            || warn "Couldn't install $app"
    done
fi