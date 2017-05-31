CREATE PROCEDURE [dbo].[uspAPCreateBillReversal]
	@billId INT,
	@userId INT,
	@createdReversal INT OUTPUT
AS

DECLARE @postSuccess BIT = 0;
DECLARE @postParam NVARCHAR(50);
DECLARE @batchId NVARCHAR(50);
DECLARE @error NVARCHAR(200);
DECLARE @debitMemoRecordNum NVARCHAR(50);

EXEC uspAPDuplicateBill @billId, @userId, @createdReversal OUT
EXEC uspSMGetStartingNumber 18, @debitMemoRecordNum OUTPUT

UPDATE A
	SET A.ysnPosted = 0
	,A.ysnPaid = 0
	,A.intTransactionType = 3
	,A.dtmDate = GETDATE()
	,A.dtmBillDate = (SELECT dtmBillDate FROM tblAPBill WHERE intBillId = @billId) --restore bill date
	,A.dblAmountDue = A.dblTotal
	,A.dblPayment = 0
	,A.strBillId = @debitMemoRecordNum
	,A.strReference = null
FROM tblAPBill A
WHERE A.intBillId = @createdReversal

SET @postParam = CAST(@createdReversal AS NVARCHAR(50));
EXEC uspAPPostBill @post=1,@recap=0,@isBatch=0,@param=@postParam,@exclude=DEFAULT,@transactionType=DEFAULT,@userId=@userId,@batchId=DEFAULT, @batchIdUsed=@batchId output, @success=@postSuccess output

IF @@ERROR != 0 OR @postSuccess = 0
BEGIN
	DELETE FROM tblAPBill
	WHERE intBillId = @createdReversal

	IF(@postSuccess = 0)
	BEGIN
		SET @error = (SELECT TOP 1 strMessage FROM tblAPPostResult WHERE intTransactionId = @createdReversal AND strBatchNumber = @batchId)
		RAISERROR(@error, 16, 1);
	END
	ELSE
	BEGIN
		RAISERROR('Unable to create reversal.', 16, 1);
	END
	DELETE FROM tblAPPostResult WHERE intTransactionId = @createdReversal AND strBatchNumber = @batchId
END
ELSE
BEGIN
	UPDATE A
		SET A.intTransactionReversed = @createdReversal
	FROM tblAPBill A
	WHERE A.intBillId = @billId
END