
PRINT 'BEGIN DELETE REPLICATION TABLES'

DELETE FROM tblSMReplicationConfigurationTable
DELETE FROM tblSMReplicationConfiguration
DELETE FROM tblSMReplicationTable

DECLARE @sql nvarchar(max) = N'';

SET @sql = N'DBCC CHECKIDENT(''tblSMReplicationConfiguration'',RESEED, 0); ' +
			'DBCC CHECKIDENT(''tblSMReplicationTable'',RESEED, 0); ' + 
			'DBCC CHECKIDENT(''tblSMReplicationConfigurationTable'',RESEED, 0); ' ; 

EXECUTE sp_executesql @sql;


PRINT 'END DELETE REPLICATION TABLES'