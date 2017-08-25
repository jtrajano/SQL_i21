PRINT N'***** BEGIN INSERT OFFLINE GUID (SCALE) *****'
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM sys.indexes WHERE name = 'UK_tblSCTicket_intTicketPoolId_strTicketNumber_strOfflineGuid')
	BEGIN
	PRINT 'Update Offline Guid'
	UPDATE tblSCTicket SET [strOfflineGuid] = NEWID() WHERE strOfflineGuid = ''
	--PRINT 'NULL strOffline Constraint'
	--EXEC('ALTER TABLE tblSCTicket ADD [strOfflineGuid] NVARCHAR(100) COLLATE Latin1_General_CI_AS')
	--EXEC('CREATE UNIQUE NONCLUSTERED INDEX UK_tblSCTicket_strOfflineGuid ON tblSCTicket(strOfflineGuid) WHERE strOfflineGuid IS NOT NULL') 
	END
GO
PRINT N'***** END INSERT OFFLINE GUID (SCALE)*****'