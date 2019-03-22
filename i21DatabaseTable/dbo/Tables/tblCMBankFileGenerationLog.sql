CREATE TABLE [dbo].[tblCMBankFileGenerationLog] (
    [intBankFileGenerationLogId] INT            IDENTITY (1, 1) NOT NULL,
    [intBankAccountId]           INT            NOT NULL,
    [intTransactionId]           INT            NOT NULL,
    [strTransactionId]           NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strProcessType]             NVARCHAR (20)  COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankFileFormatId]        INT            NOT NULL,
    [dtmGenerated]               DATETIME       NOT NULL,
    [intBatchId]                 INT            NOT NULL,
    [strFileName]                NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [ysnSent]                    BIT            CONSTRAINT [DF_tblCMBankFileGenerationLog_ysnSent] DEFAULT ((0)) NOT NULL,
    [dtmSent]                    DATETIME       NULL,
    [intEntityId]                INT            NOT NULL,
    [intConcurrencyId]           INT            CONSTRAINT [DF_tblCMBankFileGenerationLog_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblCMBankFileGenerationLog] PRIMARY KEY CLUSTERED ([intBankFileGenerationLogId] ASC)
);

