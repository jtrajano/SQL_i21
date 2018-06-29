CREATE TRIGGER trgCMDeleteUndepositedFunds
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