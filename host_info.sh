# !bin/bash

host_name=$(hostname)
timestamp=$(date "+%Y-%m-%d %H:%M:%S")
host_data=$(lscpu)
mem_info=$(free -m)
db_host=$1
sql_port=$2
db_name=$3
psql_user=$4
psql_password=$5
#check the number of command line arguments
if [[ "$#" -ne 5 ]] 
then
	echo "All the required arguments are not provided"
	echo "usage: ./host_usage.sh psql_host psql_port db_name psql_user psql_password"
	exit 1
fi
export PGPASSWORD="$psql_password"
Architecture=$(echo "$host_data" | grep -i "architecture:" | awk '{print $2}')
L2_cache=$(echo "$host_data" | grep -i "l2 cache:" | awk  '{print $3//[^0-9]/'})
cpu_model=$(echo "$host_data" | sed -nr '/Model name/ s/.*: \s*(.*)@.*/\1/p')
cpu_mhz=$(echo "$host_data" | grep -i "cpu mhz:" | awk '{print $3}')
cpu_number=$(echo "$host_data" | grep -i "^cpu(s):" | awk '{print $2}')
total_mem=$(echo "$mem_info" | grep -i mem  | awk '{print $2}')
echo "$host_name $timestamp  $Architecture $L2_cache $cpu_model $cpu_mhz $cpu_number $total_mem"
echo $host_name
insert_hostdata="INSERT INTO 
		host_info 
		(hostname,cpu_number,cpu_architecture,cpu_model,cpu_mhz,L2_cache,Total_memory,curr_timestamp) 
		values ('$host_name', $cpu_number,'$Architecture','$cpu_model',$cpu_mhz,$L2_cache,$total_mem,'$timestamp');"


psql -h $db_host -p $sql_port -d $db_name -U $psql_user -c "$insert_hostdata"
