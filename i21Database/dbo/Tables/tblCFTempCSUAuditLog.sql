CREATE TABLE [dbo].[tblCFTempCSUAuditLog] (
    [strType]       NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strTableName]  NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [intPK]         INT            NULL,
    [strFieldName]  NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [strOldValue]   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strNewValue]   NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [dtmUpdateDate] DATETIME       NULL,
    [strUserName]   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL
);

