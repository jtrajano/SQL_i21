CREATE TABLE [dbo].[tblCMEFTACHAudit] (
    [intEFTACHNo]      INT            NOT NULL,
    [intBankAccountID] INT            NOT NULL,
    [intEFTACHStatus]  INT            NOT NULL,
    [strRemarks]       NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyID] INT            NULL,
    CONSTRAINT [PK_tblCMEFTACHAudit] PRIMARY KEY CLUSTERED ([intEFTACHNo] ASC, [intBankAccountID] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMEFTACHAudit] FOREIGN KEY ([intBankAccountID]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountID])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMEFTACHAudit]
    ON [dbo].[tblCMEFTACHAudit]([intBankAccountID] ASC);

