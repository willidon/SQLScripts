-- query to get data on tempdb files

SELECT files.physical_name, files.name, 
  stats.num_of_writes, (1.0 * stats.io_stall_write_ms / stats.num_of_writes) AS avg_write_stall_ms,
  stats.num_of_reads, (1.0 * stats.io_stall_read_ms / stats.num_of_reads) AS avg_read_stall_ms
FROM sys.dm_io_virtual_file_stats(2, NULL) as stats
INNER JOIN master.sys.master_files AS files 
  ON stats.database_id = files.database_id
  AND stats.file_id = files.file_id
WHERE files.type_desc = 'ROWS'

-- query to find page contention problems in tempdb
Select session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_description,
      ResourceType = Case
When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 1 % 8088 = 0 Then 'Is PFS Page'
            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 2 % 511232 = 0 Then 'Is GAM Page'
            When Cast(Right(resource_description, Len(resource_description) - Charindex(':', resource_description, 3)) As Int) - 3 % 511232 = 0 Then 'Is SGAM Page'
            Else 'Is Not PFS, GAM, or SGAM page'
            End
From sys.dm_os_waiting_tasks
Where wait_type Like 'PAGE%LATCH_%'
And resource_description Like '2:%'

-- modified query above
Select session_id,
wait_type,
wait_duration_ms,
blocking_session_id,
resource_Description,
Descr.*
From sys.dm_os_waiting_tasks as waits inner join sys.dm_os_buffer_Descriptors as Descr
on LEFT(waits.resource_description, Charindex(':', waits.resource_description,0)-1) = Descr.database_id
and SUBSTRING(waits.resource_description, Charindex(':', waits.resource_description)+1,Charindex(':', waits.resource_description,Charindex(':', resource_description)+1)- (Charindex(':', resource_description)+1)) = Descr.[file_id]
and Right(waits.resource_description, Len(waits.resource_description) - Charindex(':', waits.resource_description, 3)) = Descr.[page_id]
Where wait_type Like 'PAGE%LATCH_%'