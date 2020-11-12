CREATE TRIGGER trgCMBankTransactionDetail
ON dbo.tblCMBankTransactionDetail
FOR INSERT, UPDATE, DELETE
AS
IF EXISTS( 
    SELECT TOP 1 1  FROM inserted i JOIN tblCMBankTransaction t on i.intTransactionId = t.intTransactionId 
    JOIN tblGLDetail G on G.strTransactionId = t.strTransactionId
    WHERE G.ysnIsUnposted = 0
	UNION
	SELECT TOP 1 1  FROM deleted i JOIN tblCMBankTransaction t on i.intTransactionId = t.intTransactionId 
    JOIN tblGLDetail G on G.strTransactionId = t.strTransactionId
    WHERE G.ysnIsUnposted = 0
	)
BEGIN
    RAISERROR (70031,16, 1)
    ROLLBACK TRANSACTION
END