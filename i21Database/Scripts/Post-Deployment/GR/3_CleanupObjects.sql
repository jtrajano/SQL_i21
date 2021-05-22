PRINT 'Begin Ticket Management Clean up Objects - Drop obsolete objects'
GO


IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspDMMergeTables'))
       DROP PROCEDURE uspDMMergeTables;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMSyncTables'))
       DROP PROCEDURE uspSMSyncTables;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationRemoteConfiguration'))
       DROP PROCEDURE uspSMReplicationRemoteConfiguration;
GO




PRINT 'End Ticket Management Clean up Objects - Drop obsolete objects'
GO
