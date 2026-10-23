# Detect GPU(s) and install needed drivers
# For manual override: GPU_OVERRIDE=nvidia, intel ./install.sh ...

INTEL_PKGS=(mesa vulkan-intel intel-media-driver)
AMD_PKGS=(mesa vulkan-radeon libva-mesa-driver)
NVIDIA_PKGS=(nvidia-open nvidia-utils nvidia-settings)
HYBRID_PKGS=(nvidia-prime)
INTEL_LIB32=(lib32-mesa lib32-vulkan-intel)
AMD_LIB32=(lib32-mesa lib32-vulkan-radeon)
NVIDIA_LIB32=(lib32-nvidia-utils)

intel=0; amd=0; nvidia=0

if [[ -n "${GPU_OVERRIDE:-}" ]]; then
    [[ $GPU_OVERRIDE == *intel* ]] && intel=1
    [[ $GPU_OVERRIDE == *amd* ]] && amd=1
    [[ $GPU_OVERRIDE == *nvidia* ]] && nvidia=1
else
    for f in /sys/class/drm/card[0-9]*/device/vendor; do
        [[ -r $f ]] || continue
        case "$(<"$f")" in
            0x8086) intel=1 ;;
            0x1002) amd=1 ;;
            0x10de) nvidia=1 ;;
        esac
    done
fi

pkgs=()
if (( intel )); then
    log "Intel GPU detected"; pkgs+=("${INTEL_PKGS[@]}")
    (( GAMING )) && pkgs+=("${INTEL_LIB32[@]}")
fi
if (( amd )); then
    log "AMD GPU detected"; pkgs+=("${AMD_PKGS[@]}")
    (( GAMING )) && pkgs+=("${AMD_LIB32[@]}")
fi
if (( nvidia)); then
    log "Nvidia GPU detected"; pkgs+=("${NVIDIA_PKGS[@]}")
    (( GAMING )) && pkgs+=("${NVIDIA_LIB32[@]}")
    warn "nvidia-open only works for Turing (GTX 16xx/RTX 20xx) or newer"
    warn "Use nvidia-open-dkms + headers if not using kernel 'linux'"
fi
if (( nvidia && (intel || amd ) )); then
    log "Hybrid system: adding nvidia-prime"; pkgs+=("${HYBRID_PKGS[@]}")
fi
if (( ${#pkgs[@]} == 0 )); then
    log "Unknown GPU or VM: adding mesa"; pkgs=(mesa)
fi

mapfile -t pkgs < <(printf '%s\n' "${pkgs[@]}" | sort -u)
run sudo pacman -S --needed --noconfirm "${pkgs[@]}"