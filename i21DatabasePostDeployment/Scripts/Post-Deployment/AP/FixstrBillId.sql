--Generate strBill if it is empty or null,
PRINT 'BEGIN Fixing strBillId'
IF EXISTS(SELECT 1 FROM tblAPBill WHERE ISNULL(strBillId,'') = '')
BEGIN
			
	DECLARE @BillId NVARCHAR(50)
	DECLARE @intBillId INT
	DECLARE @type INT
	DECLARE @posted BIT

	EXEC uspAPFixStartingNumbers

	SELECT * INTO #tmpWrongBillId FROM tblAPBill 
	WHERE ISNULL(strBillId,'') = ''

	WHILE((SELECT TOP 1 1 FROM #tmpWrongBillId) IS NOT NULL)
	BEGIN

		SELECT TOP 1 @intBillId = intBillId, @type = intTransactionType, @posted = ysnPosted FROM #tmpWrongBillId

		IF @type = 1
			EXEC uspSMGetStartingNumber 9, @BillId OUT
		ELSE IF @type = 3
			EXEC uspSMGetStartingNumber 17, @BillId OUT
		ELSE IF @type = 2
			EXEC uspSMGetStartingNumber 20, @BillId OUT

		--Updating tblAPBill
		UPDATE tblAPBill
		SET strBillId = @BillId
		WHERE intBillId = @intBillId

		IF(@posted = 1) AND EXISTS(SELECT * FROM sys.columns WHERE [name] = N'intTransactionId' AND [object_id] = OBJECT_ID(N'tblGLDetail'))
		BEGIN
			EXEC sp_executesql N'
				UPDATE A
				SET strTransactionId = @billId,
				intTransactionId = @intbillId 
				FROM tblGLDetail A
				WHERE strTransactionForm = CAST(@intbillId AS NVARCHAR(50)) AND strCode = ''AP''		
			', N'@billId NVARCHAR(50), @intbillId INT', @billId = @BillId, @intbillId = @intBillId
		END

		DELETE FROM #tmpWrongBillId
		WHERE intBillId = @intBillId

	END

	ALTER TABLE dbo.tblAPBill
		ADD CONSTRAINT[UK_dbo.tblAPBill_strBillId] UNIQUE(strBillId);

END

--Updating GL Detail Bill Id
IF EXISTS(SELECT 1 FROM tblGLDetail A
			INNER JOIN tblAPBill B ON A.intTransactionId = B.intBillId
				WHERE ISNULL(A.strTransactionId,'') = '')
BEGIN

	UPDATE A
		SET A.strTransactionId = B.strBillId
	FROM tblGLDetail A
	INNER JOIN tblAPBill B ON A.intTransactionId = B.intBillId
				WHERE ISNULL(A.strTransactionId,'') = ''

END

PRINT 'END Fixing strBillId'