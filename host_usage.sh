#! /bin/bash
hostname=$(hostname)
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
system_io=$(iostat -c)
cpu_utilization=$(top -b -n 1 -d1 | grep "Cpu(s)" | awk '{print $2}' | awk -F. '{print $1}')
memory=$(free)
disk_details=$(df -h)
disk_root=$(df /root)
db_host=$1
sql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

export PGPASSWORD="$psql_password"
host_id=$(psql -h localhost -p 5432 -U postgres  -d host_agent -c "SELECT id FROM host_info WHERE hostname='$hostname';" | xargs)
cpu_kernel=$(echo "$system_io" | tail -1 | awk '{print $3}'| xargs )
cpu_idle=$(echo "$system_io" | tail -1 | awk '{print $6}'| xargs )
free_memory=$(echo "$memory" | grep Mem | awk '{print $4}'| xargs)
disk_available=$(echo "$disk_root" | tail -1 | awk '{print $4}' | xargs)
disk_io=$(vmstat -D 1 1 | grep -i "disks" | awk '{print $1}')

echo "$host_id $disk_io"


