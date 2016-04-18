-- good articles from Paul Randall on transaction logs
-- http://www.sqlskills.com/blogs/paul/are-io-latencies-killing-your-performance/
-- http://sqlperformance.com/2012/12/io-subsystem/trimming-t-log-fat

DECLARE @Reset bit = 0;
        
IF NOT EXISTS (SELECT NULL FROM tempdb.sys.objects 
WHERE name LIKE '%#fileStats%')  
        SET @Reset = 1;  -- force a reset

IF @Reset = 1 BEGIN 
        IF EXISTS (SELECT NULL FROM tempdb.sys.objects 
        WHERE name LIKE '%#fileStats%')  
                DROP TABLE #fileStats;

        SELECT 
                database_id, 
                file_id, 
                num_of_reads, 
                num_of_bytes_read, 
                io_stall_read_ms, 
                num_of_writes, 
                num_of_bytes_written, 
                io_stall_write_ms, io_stall
        INTO #fileStats 
        FROM sys.dm_io_virtual_file_stats(null, null);
END

SELECT  
        DB_NAME(vfs.database_id) AS database_name, 
        --vfs.database_id , 
        vfs.FILE_ID , 
        (vfs.io_stall_read_ms - history.io_stall_read_ms)
         / NULLIF((vfs.num_of_reads - history.num_of_reads), 0) avg_read_latency,
        (vfs.io_stall_write_ms - history.io_stall_write_ms)
         / NULLIF((vfs.num_of_writes - history.num_of_writes), 0) AS avg_write_latency ,
        mf.physical_name 
FROM    sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs 
                JOIN sys.master_files AS mf 
                        ON vfs.database_id = mf.database_id AND vfs.FILE_ID = mf.FILE_ID 
                RIGHT OUTER JOIN #fileStats history 
                        ON history.database_id = vfs.database_id AND history.file_id = vfs.file_id
ORDER BY avg_write_latency DESC;