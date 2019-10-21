CREATE TABLE [dbo].[tblCFCSULog] (
    [intCSULogId]      INT            IDENTITY (1, 1) NOT NULL,
    [strMessage]       NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strRecordId]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strAccountNumber] NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [dtmUpdateDate]    DATETIME       NULL,
    [strCardNumber]	   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            CONSTRAINT [DF_tblCFCSULog_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFCSULog] PRIMARY KEY CLUSTERED ([intCSULogId] ASC)
);

