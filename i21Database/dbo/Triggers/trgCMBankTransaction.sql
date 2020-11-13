ALTER TRIGGER trgCMBankTransaction
ON dbo.tblCMBankTransaction
AFTER INSERT, UPDATE, DELETE
AS
IF EXISTS(
	SELECT TOP 1 1  FROM inserted i JOIN tblGLDetail G on G.strTransactionId = i.strTransactionId WHERE G.ysnIsUnposted = 0
	UNION
	SELECT TOP 1 1  FROM deleted i JOIN tblGLDetail G on G.strTransactionId = i.strTransactionId WHERE G.ysnIsUnposted = 0
	)
BEGIN

	IF (EXISTS( SELECT TOP 1 1 FROM deleted) AND NOT EXISTS(SELECT TOP 1 1 FROM deleted )) -- DELETE OPERATION
	OR
	(EXISTS( SELECT TOP 1 1 FROM deleted) AND EXISTS(SELECT TOP 1 1 FROM deleted ))
		AND (
			UPDATE (dblAmount)
			OR UPDATE (dtmDate)
			OR UPDATE (intCurrencyId)
			OR UPDATE (strTransactionId)
		)
	BEGIN
		RAISERROR ('Transaction has already been posted and further changes are not possible without unposting.',16, 1)
		ROLLBACK TRANSACTION
	END
END
