#!/usr/local/bin/zsh
remote_log_dir='/var/mobile/Containers/Data/Application/D4B762CC-0C3A-4073-B25A-E97A5A32E012/Documents/InspectiveC/Chrome'
local_log_dir='./logs'
ssh '-T' '-p' "${THEOS_DEVICE_PORT}" "root@${THEOS_DEVICE_IP}" << EOF
    find "${remote_log_dir}" -name '*.log' -delete
    exit
EOF

echo "All remote logs deleted"
