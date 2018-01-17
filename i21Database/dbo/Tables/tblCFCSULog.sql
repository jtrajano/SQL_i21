CREATE TABLE [dbo].[tblCFCSULog] (
    [intCSULogId]      INT            IDENTITY (1, 1) NOT NULL,
    [strMessage]       NVARCHAR (MAX) NULL,
    [strRecordId]      NVARCHAR (MAX) NULL,
    [strAccountNumber] NVARCHAR (MAX) NULL,
    [strUpdateDate]    DATETIME       NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFCSULog_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCSULog] PRIMARY KEY CLUSTERED ([intCSULogId] ASC)
);

