#!/usr/local/bin/zsh
remote_log_dir='/var/mobile/Containers/Data/Application/D4B762CC-0C3A-4073-B25A-E97A5A32E012/Documents/InspectiveC/Chrome'
local_log_dir='./logs'
scp -r -P "${THEOS_DEVICE_PORT}" "root@${THEOS_DEVICE_IP}:${remote_log_dir}/*.log" "${local_log_dir}/."
echo "Logs collected"
