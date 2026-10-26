# Official Arch repository packages

# mapfile -t pkgs < <(collect_pkgs pacman)
# if (( ${#pkgs[@]} )); then
#     run sudo pacman -S --needed --noconfirm "${pkgs[@]}"
# else
#     log "No pacman packages for this profile"
# fi

mapfile -t pkgs < <(collect_list pacman)
if (( ${#pkgs[@]} )); then
    run sudo pacman -S --needed --noconfirm "${pkgs[@]}"
else
    log "No pacman packages for this profile"
fi