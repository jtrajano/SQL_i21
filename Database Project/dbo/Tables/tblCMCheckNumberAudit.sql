CREATE TABLE [dbo].[tblCMCheckNumberAudit] (
    [intCheckNo]           INT            NOT NULL,
    [intBankAccountID]     INT            NOT NULL,
    [intCheckNumberStatus] INT            NOT NULL,
    [strRemarks]           NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID]     INT            NOT NULL,
    CONSTRAINT [PK_tblCMCheckNumberAudit] PRIMARY KEY CLUSTERED ([intCheckNo] ASC, [intBankAccountID] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMCheckNumberAudit] FOREIGN KEY ([intBankAccountID]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMCheckNumberAudit]
    ON [dbo].[tblCMCheckNumberAudit]([intBankAccountID] ASC);

