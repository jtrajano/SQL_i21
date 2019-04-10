CREATE PROCEDURE [dbo].[uspAPCreateBillReversal]
	@billId INT,
	@userId INT,
	@createdReversal INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @postSuccess BIT = 0;
DECLARE @postParam NVARCHAR(50);
DECLARE @batchId NVARCHAR(50);
DECLARE @error NVARCHAR(200);
DECLARE @debitMemoRecordNum NVARCHAR(50);
DECLARE @SavePoint NVARCHAR(32) = 'uspAPCreateBillReversal';

BEGIN TRY

--MAKE SURE BILL TYPE ONLY
IF (SELECT intTransactionType FROM tblAPBill WHERE intBillId = @billId) <> 1
BEGIN
	RAISERROR('Invalid transaction type for bill reversal.', 16, 1);
	RETURN;
END

IF @transCount = 0 BEGIN TRANSACTION
ELSE SAVE TRAN @SavePoint

EXEC uspAPDuplicateBill @billId = @billId, @userId = @userId, @type = 3, @billCreatedId = @createdReversal OUT
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
	,A.dblDiscount = CASE WHEN A.intTransactionType > 1 THEN 0 ELSE A.dblDiscount END
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

IF @transCount = 0
BEGIN
	IF (XACT_STATE()) = -1
	BEGIN
		ROLLBACK TRANSACTION
	END
	ELSE IF (XACT_STATE()) = 1
	BEGIN
		COMMIT TRANSACTION
	END
END	

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF @transCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
			BEGIN
				ROLLBACK TRANSACTION
			END
			ELSE IF (XACT_STATE()) = 1
			BEGIN
				COMMIT TRANSACTION
			END
		END		
	-- ELSE
	-- 	BEGIN
	-- 		IF (XACT_STATE()) = -1
	-- 		BEGIN
	-- 			ROLLBACK TRANSACTION  @SavePoint
	-- 		END
	-- 	END	

	SET @error = @ErrorMessage;
	
	IF @throwError = 1
	BEGIN
		RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
	END
END CATCH