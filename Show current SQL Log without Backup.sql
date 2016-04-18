Declare @ErrorLog Table (LogID int identity(1, 1) not null primary key,
LogDate datetime null, 
ProcessInfo nvarchar(100) null,
LogText nvarchar(4000) null) 

Insert Into @ErrorLog (LogDate, ProcessInfo, LogText)
Exec master..xp_readerrorlog 

Select *
From @ErrorLog
Where ProcessInfo <> 'Backup' and ProcessInfo <> 'Logon' --filter stuff out
Order By LogID Desc 

--Recovery completed for database CTS_HMSA (database ID 25) in 2 second(s) (analysis 0 ms, redo 0 ms, undo 1565 ms.)
-- This is an informational message only. No user action is required.

--Login failed for user 'DiawebTHRApp'. Reason: An error occurred while evaluating the password. [CLIENT: 10.1.8.184]
--Login failed for user 'DiawebTHRApp'. Reason: An error occurred while evaluating the password. [CLIENT: 10.1.8.184]

--SQL Server has encountered 6578 occurrence(s) of I/O requests taking longer than 15 seconds to complete on 
--file [C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\tempdb.mdf] in database [tempdb] (2).
--  The OS file handle is 0x0000000000000A64.  The offset of the latest long I/O is: 0x000000159e0000