﻿PRINT 'Begin SM Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicatonDropPublication'))
       DROP PROCEDURE uspSMReplicatonDropPublication;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMCreateAuditLogMigrationPlan'))
       DROP PROCEDURE uspSMCreateAuditLogMigrationPlan;
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

PRINT 'End SM Clean up Objects - Drop obsolete objects'
GO
