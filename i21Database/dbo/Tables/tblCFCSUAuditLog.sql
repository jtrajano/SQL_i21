CREATE TABLE [dbo].[tblCFCSUAuditLog] (
    [intId]            INT             IDENTITY (1, 1) NOT NULL,
    [strSessionId]     NVARCHAR (1000) NULL,
    [intPK]            INT             NULL,
    [strType]          NVARCHAR (100)  NULL,
    [strTableName]     NVARCHAR (200)  NULL,
    [strFieldName]     NVARCHAR (200)  NULL,
    [strOldValue]      NVARCHAR (MAX)  NULL,
    [strNewValue]      NVARCHAR (MAX)  NULL,
    [dtmUpdateDate]    DATETIME        NULL,
    [strUserName]      NVARCHAR (100)  NULL,
    [strRecord]        NVARCHAR (MAX)  NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF_tblCFCSUAuditLog_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCSUAuditLog] PRIMARY KEY CLUSTERED ([intId] ASC)
);



