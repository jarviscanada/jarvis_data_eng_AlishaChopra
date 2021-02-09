

CREATE TABLE IF NOT EXISTS PUBLIC.host_info 
(
	id SERIAL PRIMARY KEY,
	hostname varchar(300) NOT NULL,
	cpu_number INT NOT NULL,
	cpu_architecture varchar(100) NOT NULL,
	cpu_model varchar(350) NOT NULL,
	cpu_mhz numeric(10,3) NOT NULL,
	L2_cache INT NOT NULL,
	Total_memory bigint NOT NULL,
	curr_timestamp timestamp NOT NULL
);

CREATE TABLE IF NOT EXISTS PUBLIC.resource_usage
(
	usage_timestamp timestamp NOT NULL,
	host_id int NOT NULL,
	memory_free bigint NOT NULL,
	cpu_idle numeric(10,2)  NOT NULL,
	cpu_kernel numeric(10,2)  NOT NULL,
	disk_io int NOT NULL,
	disk_available bigint NOT NULL,
	FOREIGN KEY(host_id) REFERENCES host_info(id)
);

