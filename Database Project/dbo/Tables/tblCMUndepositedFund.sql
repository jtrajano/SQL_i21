CREATE TABLE [dbo].[tblCMUndepositedFund] (
    [intUndepositedFundId]  INT             IDENTITY (1, 1) NOT NULL,
    [strTransactionId]      NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDebit]              DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[intBankTransactionId]  INT             NULL,
    [strBankTransactionId]  NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserID]      INT             NULL,
    [dtmCreated]            DATETIME        NULL,
    [intLastModifiedUserID] INT             NULL,
    [dtmLastModified]       DATETIME        NULL,
    [intConcurrencyId]      INT             NOT NULL DEFAULT 1,
    CONSTRAINT [PK_tblCMUndepositedFund] PRIMARY KEY CLUSTERED ([intUndepositedFundId] ASC)
);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_strTransactionId]
    ON [dbo].[tblCMUndepositedFund]([strTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intBankTransactionId]
    ON [dbo].[tblCMUndepositedFund]([intBankTransactionId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_strBankTransactionId]
    ON [dbo].[tblCMUndepositedFund]([strBankTransactionId] ASC);
