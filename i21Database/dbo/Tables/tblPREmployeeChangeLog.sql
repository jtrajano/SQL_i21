CREATE TABLE [dbo].[tblPREmployeeChangeLog]
(
	[intEmployeeChangeLogId] INT NOT NULL PRIMARY KEY IDENTITY, 
	[intAuditLogId] INT NULL, 
    [intEntityEmployeeId] INT NULL, 
    [strEntityNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intEntityChangedId] INT NULL, 
    [strChangedBy] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [dtmChangedOn] DATETIME NULL, 
    [strTableName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strFieldName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strKeyValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strFrom] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strTo] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((1))
)
