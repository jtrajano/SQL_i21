--PRINT N'***** BEGIN INSERT OFFLINE GUID (SCALE) *****'
--GO
--IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSCTicket')
--BEGIN
--IF NOT EXISTS (SELECT TOP 1 1
--FROM sys.indexes
--WHERE name = 'UK_tblSCTicket_strOfflineGuid')
--BEGIN
--PRINT 'NULL strOffline Constraint'
--EXEC('ALTER TABLE tblSCTicket ADD [strOfflineGuid] NVARCHAR(100) COLLATE Latin1_General_CI_AS')
--EXEC('UPDATE tblSCTicket SET [strOfflineGuid] = NEWID()')
----EXEC('ALTER TABLE tblSCTicket ALTER COLUMN strOfflineGuid nvarchar(100)')
--EXEC('CREATE UNIQUE NONCLUSTERED INDEX UK_tblSCTicket_strOfflineGuid ON tblSCTicket(strOfflineGuid) WHERE strOfflineGuid IS NOT NULL') 
--END

--END
--GO
--PRINT N'***** END INSERT OFFLINE GUID (SCALE)*****'

--PRINT N'***** BEGIN INSERT OFFLINE GUID (SCALE) *****'
--GO
--IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSCTicket')
--BEGIN
--IF OBJECT_ID('dbo.[UK_tblSCTicket_strOfflineGuid]') IS NULL
--BEGIN
--EXEC('ALTER TABLE tblSCTicket  ADD [strOfflineGuid] NVARCHAR(100) COLLATE Latin1_General_CI_AS')
--EXEC('UPDATE tblSCTicket SET [strOfflineGuid] = NEWID()')
--EXEC('ALTER TABLE tblSCTicket ALTER COLUMN strOfflineGuid nvarchar(100)')
--EXEC('CREATE UNIQUE NONCLUSTERED INDEX UK_tblSCTicket_strOfflineGuid ON tblSCTicket(strOfflineGuid) WHERE strOfflineGuid IS NOT NULL') 
--END

----EXEC('ALTER TABLE tblSCTicket ADD CONSTRAINT UK_tblSCTicket_strOfflineGuid UNIQUE (strOfflineGuid)')

----EXEC(
----'ALTER TABLE tblSCTicket ADD [strOfflineGuid] NVARCHAR(100) COLLATE Latin1_General_CI_AS
----UPDATE [dbo].[tblSCTicket] SET strOfflineGuid = NEWID()
----ALTER TABLE tblSCTicket ALTER COLUMN strOfflineGuid nvarchar(100) NOT NULL 
----ALTER TABLE tblSCTicket ADD CONSTRAINT UK_tblSCTicket_strOfflineGuid UNIQUE')

--END


--GO
--PRINT N'***** END INSERT OFFLINE GUID (SCALE)*****'