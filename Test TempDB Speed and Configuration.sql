SELECT name, log_reuse_wait_desc FROM sys.databases;

select files.physical_name, files.name,
	stats.num_of_writes, (1.0 * stats.io_stall_write_ms / stats.num_of_writes) AS avg_write_stall_ms,
	stats.num_of_reads, (1.0 * stats.io_stall_read_ms / stats.num_of_reads) AS avg_read_stall_ms
from sys.dm_io_virtual_file_stats(2,NULL) as stats
inner join master.sys.master_files as files
	on stats.database_id = files.database_id
	and stats.file_id = files.file_id
where files.type_desc = 'ROWS'

exec sp_whoisactive