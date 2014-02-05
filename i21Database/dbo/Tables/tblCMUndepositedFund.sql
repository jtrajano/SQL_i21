CREATE TABLE [dbo].[tblCMUndepositedFund] (
    [intUndepositedFundId]  INT             IDENTITY (1, 1) NOT NULL,
    [strTransactionId]      NVARCHAR (40)   COLLATE Latin1_General_CI_AS NOT NULL,
    [dblDebit]              DECIMAL (18, 6) DEFAULT 0 NOT NULL,
    [intBankTransactionId]  INT             NULL,
    [strBankTransactionId]  NVARCHAR (40)   COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserID]      INT             NULL,
    [dtmCreated]            DATETIME        NULL,
    [intLastModifiedUserID] INT             NULL,
    [dtmLastModified]       DATETIME        NULL,
    [intConcurrencyId]      INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMUndepositedFund] PRIMARY KEY CLUSTERED ([intUndepositedFundId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intBankTransactionId]
    ON [dbo].[tblCMUndepositedFund]([intBankTransactionId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_strBankTransactionId]
    ON [dbo].[tblCMUndepositedFund]([strBankTransactionId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_strTransactionId]
    ON [dbo].[tblCMUndepositedFund]([strTransactionId] ASC);

