CREATE TABLE [dbo].[tblCMCreditCardBatchEntry] (
    [intCreditCardBatchEntryId] INT             IDENTITY (1, 1) NOT NULL,
    [strCreditCardBatchEntryId] NVARCHAR (20)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankAccountId]          INT             NOT NULL,
    [dblTotal]                  DECIMAL (18, 6) DEFAULT 0 NOT NULL,
    [intCreatedUserId]          INT             NULL,
    [dtmCreated]                DATETIME        NULL,
    [intLastModifiedUserId]     INT             NULL,
    [dtmLastModified]           DATETIME        NULL,
    [intConcurrencyId]          INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMCreditCardBatchEntry] PRIMARY KEY CLUSTERED ([intCreditCardBatchEntryId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMCreditCardBatchEntry] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId]),
    UNIQUE NONCLUSTERED ([strCreditCardBatchEntryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [tblCMCreditCardBatchEntry_intBankAccountId]
    ON [dbo].[tblCMCreditCardBatchEntry]([intBankAccountId] ASC);


GO
CREATE NONCLUSTERED INDEX [tblCMCreditCardBatchEntry_strCreditCardBatchEntryId]
    ON [dbo].[tblCMCreditCardBatchEntry]([strCreditCardBatchEntryId] ASC);

