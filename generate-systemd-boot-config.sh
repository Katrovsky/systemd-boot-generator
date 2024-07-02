#!/bin/bash

set -euo pipefail

CONFIG_DIR="/boot/loader/entries"
KERNEL_DIR="/boot"

generate_options() {
    local root_partition=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
    local partuuid=$(lsblk -npo PARTUUID "$root_partition")
    local rootfstype=$(findmnt -n -o FSTYPE /)
    local options="root=PARTUUID=$partuuid zswap.enabled=0"

    [[ $rootfstype == "btrfs" ]] && {
        local root_subvol=$(findmnt -n -o OPTIONS / | grep -oP 'subvol=\K[^,]+')
        options+=" rootflags=subvol=$root_subvol"
    }

    echo "$options rw rootfstype=$rootfstype"
}

generate_config() {
    local kernel_name="$1" kernel_version="$2" initrd_type="$3"
    local config_file="$CONFIG_DIR/${kernel_name}${initrd_type:+-$initrd_type}.conf"
    local options=$(generate_options)
    
    [[ -f "$config_file" ]] && grep -q "^options $options$" "$config_file" && {
        echo "Configuration file $config_file is up to date."
        return
    }

    cat << EOF > "$config_file"
# Created by: generate-systemd-boot-config.sh
# Created on: $(date +"%Y-%m-%d_%H-%M-%S")
title   Arch Linux ($kernel_version)${initrd_type:+ ($initrd_type)}
linux   /vmlinuz-$kernel_version
initrd  /initramfs-$kernel_version${initrd_type:+-$initrd_type}.img
options $options
EOF

    echo "Generated systemd-boot configuration file: $config_file"
}

main() {
    mkdir -p "$CONFIG_DIR"

    # Remove old configs
    comm -23 <(find "$CONFIG_DIR" -name "linux*.conf" | sort) \
              <(find "$KERNEL_DIR" -name 'vmlinuz-*' | sed 's/.*vmlinuz-/linux/' | sort) |
    xargs -r rm -v

    # Generate new configs
    find "$KERNEL_DIR" -name 'vmlinuz-*' | sort -V |
    while read -r kernel_path; do
        kernel_version=${kernel_path##*/vmlinuz-}
        kernel_name=${kernel_version%%-*}
        
        generate_config "$kernel_name" "$kernel_version" ""
        [[ -f "$KERNEL_DIR/initramfs-$kernel_version-fallback.img" ]] &&
            generate_config "$kernel_name" "$kernel_version" "fallback"
    done
}

main "$@"