PRINT 'Begin SM Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicatonDropPublication'))
       DROP PROCEDURE uspSMReplicatonDropPublication;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationDropPublication'))
       DROP PROCEDURE uspSMReplicationDropPublication;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspIUAuditLogs'))
       DROP PROCEDURE uspIUAuditLogs;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMCreateReIndexMaintenancePlan'))
       DROP PROCEDURE uspSMCreateReIndexMaintenancePlan;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMValidateRemoteDBServer'))
       DROP PROCEDURE uspSMValidateRemoteDBServer;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMErrorMessages'))
       DROP PROCEDURE uspSMErrorMessages;
GO


IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicatonDropPublication'))
       DROP PROCEDURE uspSMReplicatonDropPublication;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMValidateRemoteDBServer'))
       DROP PROCEDURE uspSMValidateRemoteDBServer;
GO



PRINT 'End SM Clean up Objects - Drop obsolete objects'
GO
