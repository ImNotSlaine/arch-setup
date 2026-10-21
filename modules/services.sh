# Enable systemd services

mapfile -t units < <(collect_units system)
for u in "${units[@]}"; do
    if (( DRY_RUN )) || systemctl cat "$u" >/dev/null 2>&1; then
        run sudo systemctl enable "$u" || warn "Couldn't enable $u"
    else
        warn "Unit $u doesn't exist"
    fi
done

mapfile -t uunits < <(collect_units user)
for u in "${uunits[@]}"; do
    run systemctl --user enable "$u" || warn "Couldn't enable $u. No user active"
done

(( ${#units[@]} + ${#units[@]} )) || log "No services for this profile"