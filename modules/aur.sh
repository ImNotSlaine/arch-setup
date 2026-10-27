# AUR repository packages

mapfile -t pkgs < <(collect aur)
if (( ${#pkgs[@]} )); then
    run paru -S --needed --noconfirm "${pkgs[@]}"
else
    log "No AUR packages for this profile"
fi