CREATE TABLE [dbo].[tblCMCreditCardBatchEntry] (
    [cntID]                 INT             IDENTITY (1, 1) NOT NULL,
    [strBatchID]            NVARCHAR (20)   COLLATE Latin1_General_CI_AS NOT NULL,
    [intBankAccountID]      INT             NOT NULL,
    [dblTotal]              DECIMAL (18, 6) NOT NULL,
    [intCreatedUserID]      INT             NULL,
    [dtmCreated]            DATETIME        NULL,
    [intLastModifiedUserID] INT             NULL,
    [dtmLastModified]       DATETIME        NULL,
    [intConcurrencyID]      INT             NOT NULL,
    CONSTRAINT [PK_tblCMCreditCardBatchEntry] PRIMARY KEY CLUSTERED ([strBatchID] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMCreditCardBatchEntry] FOREIGN KEY ([intBankAccountID]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMCreditCardBatchEntry]
    ON [dbo].[tblCMCreditCardBatchEntry]([intBankAccountID] ASC);

