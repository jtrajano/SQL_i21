CREATE TRIGGER [dbo].[trgCFTransactionRecordNumber]
ON [dbo].[tblCFTransaction]
AFTER INSERT
AS
	DECLARE @CFID NVARCHAR(50)

	-- IF STARTING NUMBER IS EDITABLE --
		 -- FIX STARTING NUMBER --

	EXEC uspSMGetStartingNumber 52, @CFID OUT
	
	IF(@CFID IS NOT NULL)
	BEGIN
		UPDATE tblCFTransaction
			SET tblCFTransaction.strTransactionId = @CFID,
				tblCFTransaction.intForDeleteTransId = CAST(REPLACE(@CFID,'CFDT-','') AS int)
		FROM tblCFTransaction A
			INNER JOIN INSERTED B ON A.intTransactionId = B.intTransactionId
	END
GO