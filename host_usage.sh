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

if [[ "$#" -ne 5 ]]
then
        echo "All the required arguments are not provided"
        echo "usage: ./host_usage.sh psql_host psql_port db_name psql_user psql_password"
        exit 1
fi
export PGPASSWORD="$psql_password"

host_id=$(psql -h localhost -p 5432 -U postgres -d host_agent -c "SELECT id FROM host_info WHERE hostname='$hostname';" | sed -n '3p' | xargs)
cpu_kernel=$(echo "$system_io" | tail -1 | awk '{print $3}'| xargs )
cpu_idle=$(echo "$system_io" | tail -1 | awk '{print $6}'| xargs )
free_memory=$(echo "$memory" | grep Mem | awk '{print $4}'| xargs)
disk_available=$(echo "$disk_root" | tail -1 | awk '{print $4}' | xargs)
disk_io=$(vmstat -D 1 1 | grep -i "disks" | awk '{print $1}')
insert_host_usage_data="INSERT INTO resource_usage
			(usage_timestamp,host_id,memory_free,cpu_idle,cpu_kernel,disk_io,disk_available) values ('$timestamp',$host_id,$free_memory,$cpu_idle,$cpu_kernel,$disk_io,$disk_available);"
echo "$host_id $free_memory $disk_available"
#insert values in host_usage through PSQL
psql -h $db_host -p $sql_port -U $psql_user -d $db_name -c "$insert_host_usage_data"


