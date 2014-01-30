CREATE TABLE [dbo].[tblCMCreditCardBatchEntry] (
    [intCreditCardBatchEntryId]			INT             IDENTITY (1, 1) NOT NULL,
    [strCreditCardBatchEntryId]			NVARCHAR (20)   COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    [intBankAccountId]					INT             NOT NULL,
    [dblTotal]							DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intCreatedUserId]					INT             NULL,
    [dtmCreated]						DATETIME        NULL,
    [intLastModifiedUserId]				INT             NULL,
    [dtmLastModified]					DATETIME        NULL,
    [intConcurrencyId]					INT             NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMCreditCardBatchEntry] PRIMARY KEY CLUSTERED ([intCreditCardBatchEntryId]),
    CONSTRAINT [FK_tblCMBankAccounttblCMCreditCardBatchEntry] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
);

GO
CREATE NONCLUSTERED INDEX [tblCMCreditCardBatchEntry_strCreditCardBatchEntryId]
    ON [dbo].[tblCMCreditCardBatchEntry]([strCreditCardBatchEntryId] ASC);

GO

CREATE NONCLUSTERED INDEX [tblCMCreditCardBatchEntry_intBankAccountId]
    ON [dbo].[tblCMCreditCardBatchEntry]([intBankAccountId] ASC);

GO