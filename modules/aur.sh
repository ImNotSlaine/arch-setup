# AUR repository packages

mapfile -t pkgs < <(collect_pkgs aur)
if (( ${#pkgs[@]} )); then
    run paru -S --needed --noconfirm "${pkgs[@]}"
else
    log "No AUR packages for this profile"
fi