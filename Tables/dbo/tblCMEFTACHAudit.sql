CREATE TABLE [dbo].[tblCMEFTACHAudit] (
    [intEFTACHNo]      INT            NOT NULL,
    [intBankAccountId] INT            NOT NULL,
    [intEFTACHStatus]  INT            NOT NULL,
    [strRemarks]       NVARCHAR (200) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMEFTACHAudit] PRIMARY KEY CLUSTERED ([intEFTACHNo] ASC, [intBankAccountId] ASC),
    CONSTRAINT [FK_tblCMBankAccounttblCMEFTACHAudit] FOREIGN KEY ([intBankAccountId]) REFERENCES [dbo].[tblCMBankAccount] ([intBankAccountId])
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankAccounttblCMEFTACHAudit]
    ON [dbo].[tblCMEFTACHAudit]([intBankAccountId] ASC);

