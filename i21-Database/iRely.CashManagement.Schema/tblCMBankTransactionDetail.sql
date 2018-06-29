CREATE TABLE [dbo].[tblCMBankTransactionDetail] (
    [intTransactionDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intTransactionId]       INT             NOT NULL,
    [dtmDate]                DATETIME        NULL,
    [intGLAccountId]         INT             NOT NULL,
    [strDescription]         NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
    [dblDebit]               DECIMAL (18, 6) DEFAULT 0 NOT NULL,
    [dblCredit]              DECIMAL (18, 6) DEFAULT 0 NOT NULL,
    [intUndepositedFundId]   INT             NULL,
    [intEntityId]            INT             NULL,
    [intCreatedUserId]       INT             NULL,
    [dtmCreated]             DATETIME        NULL,
    [intLastModifiedUserId]  INT             NULL,
    [dtmLastModified]        DATETIME        NULL,
    [intConcurrencyId]       INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMBankTransactionDetail] PRIMARY KEY CLUSTERED ([intTransactionDetailId] ASC),
    CONSTRAINT [FK_tblCMBankTransactiontblCMBankTransactionDetail] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblCMBankTransaction] ([intTransactionId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGLAccounttblCMBankTransactionDetail] FOREIGN KEY ([intGLAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransactionDetail_intEntityId]
    ON [dbo].[tblCMBankTransactionDetail]([intEntityId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransactionDetail_intGLAccountId]
    ON [dbo].[tblCMBankTransactionDetail]([intGLAccountId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransactionDetail_intTransactionId]
    ON [dbo].[tblCMBankTransactionDetail]([intTransactionId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMBankTransactionDetail_intUndepositedFundId]
    ON [dbo].[tblCMBankTransactionDetail]([intUndepositedFundId] ASC);

