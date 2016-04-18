Use DiaWebDSL 
Go

select b.name, a.last_execution_time 
from sys.dm_exec_procedure_stats a 
inner join sys.objects b 
	on a.object_id = b.object_id 
where DB_NAME(a.database_ID) = 'DiaWebDSL'

SELECT object_name(object_id), last_execution_time, last_elapsed_time, execution_count
FROM   sys.dm_exec_procedure_stats ps 
where lower(object_name(object_id)) like 'sp_del%'
order by 1

SELECT  a.execution_count ,
    OBJECT_NAME(objectid) Name,
    query_text = SUBSTRING( 
    b.text, 
    a.statement_start_offset/2, 
    (    CASE WHEN a.statement_end_offset = -1 
        THEN len(convert(nvarchar(max), b.text)) * 2 
        ELSE a.statement_end_offset 
        END - a.statement_start_offset)/2
    ) ,
    b.dbid ,
    dbname = db_name(b.dbid) ,
    b.objectid ,
    a.creation_time,
    a.last_execution_time,
    a.*
FROM sys.dm_exec_query_stats a 
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) as b 
WHERE OBJECT_NAME(objectid) = 'sp_DeletePatient'
ORDER BY a.last_execution_time DESC