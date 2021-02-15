SELECT 
cpu_number,
id as host_id,
total_memory, 
rank() over(Partition by cpu_number order by Total_memory desc) 
FROM host_info;

create function calculate_used_memory_percentage(totalMemory numeric,freeMemory numeric, OUT percentage numeric) As $$
BEGIN

	percentage := ((totalMemory - freeMemory)/totalMemory)*100; 
END;
$$ LANGUAGE plpgsql;
 	
SELECT 
info.id, 
hostname, 
to_timestamp((extract('epoch' from usage.usage_timestamp)::int/300)*300) as "timestamp", 
Round(AVG(calculate_used_memory_percentage(cast(total_memory as numeric),cast(memory_free as numeric)))::numeric,2) as "avg_used_mem_percentage" 
FROM 
host_info info INNER JOIN resource_usage usage 
ON info.id=usage.host_id 
GROUP BY 
info.id,
to_timestamp((extract('epoch' from usage.usage_timestamp)::int/300)*300),
hostname 
ORDER BY timestamp;

SELECT host_id, "ts", count(host_id) as "num_data_points"
FROM 
(SELECT host_id,hostname, 
to_timestamp((extract('epoch' from usage.usage_timestamp)::int/300)*300) as "ts"
FROM
resource_usage usage INNER JOIN host_info info
ON usage.host_id=info.id) as t 
GROUP BY 
host_id,
"ts",
hostname
having count(host_id)<3
order by "ts";

