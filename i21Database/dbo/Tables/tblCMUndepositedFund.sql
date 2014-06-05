CREATE TABLE [dbo].[tblCMUndepositedFund] (
    [intUndepositedFundId]		INT IDENTITY (1, 1) NOT NULL,
    [strSourceTransactionId]	NVARCHAR (40) COLLATE Latin1_General_CI_AS NOT NULL,	    
    [intSourceTransactionId]	INT NULL,
	[dblDeposit]				DECIMAL (18, 6) DEFAULT 0 NOT NULL,
	[strSourceSystem]			NVARCHAR(20) NULL,
	[intBankDepositId]			INT NULL,
	[intBankDepositDetailId]	INT NULL,
	[intAptrxmstId]				INT NULL,
	[intApchkmstId]				INT NULL,
	[intApeglmstId]				INT NULL,
    [intCreatedUserId]			INT NULL,
    [dtmCreated]				DATETIME NULL,
    [intLastModifiedUserId]		INT NULL,
    [dtmLastModified]			DATETIME NULL,
    [intConcurrencyId]			INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMUndepositedFund] PRIMARY KEY CLUSTERED ([intUndepositedFundId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intSourceTransactionId]
    ON [dbo].[tblCMUndepositedFund]([intSourceTransactionId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_strSourceTransactionId]
    ON [dbo].[tblCMUndepositedFund]([strSourceTransactionId] ASC);	
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intBankDepositLinkId]
    ON [dbo].[tblCMUndepositedFund]([intBankDepositDetailId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intAptrxmstArchiveId]
    ON [dbo].[tblCMUndepositedFund]([intAptrxmstId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intApchkmstArchiveId]
    ON [dbo].[tblCMUndepositedFund]([intApchkmstId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intApeglmstArchiveId]
    ON [dbo].[tblCMUndepositedFund]([intApeglmstId] ASC);

