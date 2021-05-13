PRINT 'Begin SM Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicatonDropPublication'))
       DROP PROCEDURE uspSMReplicatonDropPublication;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMCreateAuditLogMigrationPlan'))
       DROP PROCEDURE uspSMCreateAuditLogMigrationPlan;
GO




PRINT 'End SM Clean up Objects - Drop obsolete objects'
GO
