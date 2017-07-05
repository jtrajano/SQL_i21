CREATE TABLE [dbo].[tblCMUndepositedFund] (    
	[intUndepositedFundId]		INT IDENTITY (1, 1) NOT NULL,
	[intBankAccountId]			INT NOT NULL,
    [strSourceTransactionId]	NVARCHAR (40) COLLATE Latin1_General_CI_AS NOT NULL,	    
    [intSourceTransactionId]	INT NULL,
	[intLocationId]				INT NULL,	
	[dtmDate]					DATETIME NULL,
	[strName]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblAmount]					DECIMAL (18, 6) DEFAULT 0 NOT NULL,
	[strSourceSystem]			NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[strPaymentMethod]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intBankDepositId]			INT NULL,
    [intCreatedUserId]			INT NULL,
    [dtmCreated]				DATETIME NULL,
	[ysnToProcess]				BIT NOT NULL DEFAULT ((0)),
	[ysnGenerated]				BIT NULL,
	[ysnNotified]				BIT NULL,
	[strNotificationStatus]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ysnCommitted]				BIT NULL,
	[intBankFileAuditId]		INT NULL,
	[ysnHold]					BIT NOT NULL DEFAULT ((0)),
	[strHoldReason]				NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
    [intLastModifiedUserId]		INT NULL,
    [dtmLastModified]			DATETIME NULL,
    [intConcurrencyId]			INT DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMUndepositedFund] PRIMARY KEY CLUSTERED ([intUndepositedFundId] ASC)
);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intBankAccountId]
    ON [dbo].[tblCMUndepositedFund]([intBankAccountId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intSourceTransactionId]
    ON [dbo].[tblCMUndepositedFund]([intSourceTransactionId] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_strSourceTransactionId]
    ON [dbo].[tblCMUndepositedFund]([strSourceTransactionId] ASC);	
GO
CREATE NONCLUSTERED INDEX [IX_tblCMUndepositedFund_intBankDepositId]
    ON [dbo].[tblCMUndepositedFund]([intBankDepositId] ASC);
GO

CREATE TRIGGER trg_delete_tblCMUndepositedFund
ON [dbo].tblCMUndepositedFund
INSTEAD OF DELETE
AS
BEGIN 

	SET NOCOUNT ON

	------------------------------------------------------------------------------------------
	-- Validate the undeposited fund first before deleting the record. Prevent delete if: 
	------------------------------------------------------------------------------------------
	-- 1. ...if undeposited fund is already deposited
	IF EXISTS (
		SELECT	TOP 1 1 
		FROM	deleted d INNER JOIN dbo.tblCMUndepositedFund undep 
					ON d.intUndepositedFundId = undep.intUndepositedFundId
		WHERE	d.intBankDepositId IS NOT NULL
	)
	BEGIN
		RAISERROR('Unable to delete undeposited fund because it is used in Bank Deposit transaction.', 11, 1)
		GOTO EXIT_TRIGGER
	END
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

	-- Delete records
	DELETE	dbo.tblCMUndepositedFund
	FROM	dbo.tblCMUndepositedFund 
	WHERE	intUndepositedFundId IN (SELECT d.intUndepositedFundId FROM deleted d)
	IF @@ERROR <> 0 GOTO EXIT_TRIGGER

EXIT_TRIGGER:

END
GO