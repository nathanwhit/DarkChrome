#!/usr/local/bin/zsh
remote_log_dir='/var/mobile/Containers/Data/Application/DF1F3F16-A5E5-48DA-BB49-1696B37AAB0A/Documents/InspectiveC/Chrome'
local_log_dir='./logs'
scp -r -P "${THEOS_DEVICE_PORT}" "root@${THEOS_DEVICE_IP}:${remote_log_dir}/*.log" "${local_log_dir}/."
echo "Logs collected"
