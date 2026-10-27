# Enable systemd services

mapfile -t units < <(collect services)
for u in "${units[@]}"; do
    if (( DRY_RUN )) || systemctl cat "$u" >/dev/null 2>&1; then
        run sudo systemctl enable "$u" || warn "Couldn't enable $u"
    else
        warn "Unit $u doesn't exist"
    fi
done

(( ${#units[@]} + ${#units[@]} )) || log "No services for this profile"