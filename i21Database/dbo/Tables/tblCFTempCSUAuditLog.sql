CREATE TABLE [dbo].[tblCFTempCSUAuditLog] (
    [strType]       NVARCHAR (100) NULL,
    [strTableName]  NVARCHAR (200) NULL,
    [intPK]         INT            NULL,
    [strFieldName]  NVARCHAR (200) NULL,
    [strOldValue]   NVARCHAR (MAX) NULL,
    [strNewValue]   NVARCHAR (MAX) NULL,
    [dtmUpdateDate] DATETIME       NULL,
    [strUserName]   NVARCHAR (100) NULL
);

