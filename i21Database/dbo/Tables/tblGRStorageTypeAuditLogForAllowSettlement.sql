CREATE TABLE [dbo].[tblGRStorageTypeAuditLogForAllowSettlement]
(
    intStorageTypeAuditLogId INT IDENTITY(1,1) PRIMARY KEY
    ,intStorageTypeId INT
    ,strOldValue NVARCHAR(100)
    ,strNewValue NVARCHAR(100)
    ,dtmClientDateUpdated DATETIME
    ,dtmDateUpdated DATETIME DEFAULT(GETDATE())    
)
