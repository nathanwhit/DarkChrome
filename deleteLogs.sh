#!/usr/local/bin/zsh
remote_log_dir='/var/mobile/Containers/Data/Application/CD8307A6-38FC-459E-9269-D13966195167/Documents/InspectiveC/Chrome'
local_log_dir='./logs'
ssh '-T' '-p' "${THEOS_DEVICE_PORT}" "root@${THEOS_DEVICE_IP}" << EOF
    find "${remote_log_dir}" -name '*.log' -delete
    exit
EOF

rm -f "${local_log_dir}/*.log"
echo "All logs deleted"
