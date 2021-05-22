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

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationPullSubscription'))
       DROP PROCEDURE uspSMReplicationPullSubscription;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationMainConfiguration'))
       DROP PROCEDURE uspSMReplicationMainConfiguration;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationDropPullSubscription'))
       DROP PROCEDURE uspSMReplicationDropPullSubscription;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationDropPublication'))
       DROP PROCEDURE uspSMReplicationDropPublication;
GO




PRINT 'End Ticket Management Clean up Objects - Drop obsolete objects'
GO
