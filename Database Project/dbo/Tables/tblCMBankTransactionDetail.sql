CREATE TABLE [dbo].[tblCMBankTransactionDetail] (
    [intBankTransactionDetailID] INT             IDENTITY (1, 1) NOT NULL,
    [strTransactionID]           NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dtmDate]                    DATETIME        NULL,
    [intGLAccountID]             INT             NOT NULL,
    [strDescription]             NVARCHAR (250)  COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDebit]                   DECIMAL (18, 6) NOT NULL,
    [dblCredit]                  DECIMAL (18, 6) NOT NULL,
    [intUndepositedFundID]       INT             NULL,
    [intEntityID]                INT             NULL,
    [intCreatedUserID]           INT             NULL,
    [dtmCreated]                 DATETIME        NULL,
    [intLastModifiedUserID]      INT             NULL,
    [dtmLastModified]            DATETIME        NULL,
    [intConcurrencyID]           INT             NOT NULL,
    CONSTRAINT [PK_tblCMBankTransactionDetail] PRIMARY KEY CLUSTERED ([intBankTransactionDetailID] ASC),
    CONSTRAINT [FK_tblCMBankTransactiontblCMBankTransactionDetail] FOREIGN KEY ([strTransactionID]) REFERENCES [dbo].[tblCMBankTransaction] ([strTransactionID]) ON DELETE CASCADE
);


GO
CREATE NONCLUSTERED INDEX [IX_FK_tblCMBankTransactiontblCMBankTransactionDetail]
    ON [dbo].[tblCMBankTransactionDetail]([strTransactionID] ASC);

