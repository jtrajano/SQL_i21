CREATE TABLE [dbo].[tblCFCSUAuditLog] (
    [intId]            INT             IDENTITY (1, 1) NOT NULL,
    [strSessionId]     NVARCHAR (1000) COLLATE Latin1_General_CI_AS NULL,
    [intPK]            INT             NULL,
	[intNetworkId]	   INT			   NULL,
	[strNetwork]	   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strType]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strTableName]     NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [strFieldName]     NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
    [strOldValue]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strNewValue]      NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [dtmUpdateDate]    DATETIME        NULL,
    [strUserName]      NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [strRecord]        NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
    [strAccountNumber] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[strRawOldValue]   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
	[strRawNewValue]   NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT             CONSTRAINT [DF_tblCFCSUAuditLog_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCSUAuditLog] PRIMARY KEY CLUSTERED ([intId] ASC) WITH (FILLFACTOR = 70)
);
GO

