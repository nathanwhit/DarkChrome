#!/usr/local/bin/zsh
remote_log_dir='/var/mobile/Containers/Data/Application/EC02EA17-AA03-4B46-833E-09426639F946/Documents/InspectiveC/Chrome'
local_log_dir='./logs'
scp -r -P "${THEOS_DEVICE_PORT}" "root@${THEOS_DEVICE_IP}:${remote_log_dir}/*.log" "${local_log_dir}/."
echo "Logs collected"
