CREATE TABLE [dbo].[tblGRStorageTypeAuditLogForAllowSettlement]
(
    intStorageTypeAuditLogId INT IDENTITY(1,1) PRIMARY KEY
    ,intStorageTypeId INT
    ,ysnOldValue BIT
    ,ysnNewValue BIT
    ,dtmDateUpdated DATETIME DEFAULT(GETDATE())
    ,intUserId INT
)
