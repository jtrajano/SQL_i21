CREATE PROCEDURE [dbo].[uspAPCreatePaymentFromVoucherBatch]
	@userId INT,
	@voucherBatchId INT,
	@batchPaymentId INT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @bankId INT
DECLARE @user INT = @userId
DECLARE @batchBillsForPayment CURSOR
DECLARE @billIds NVARCHAR(MAX)
DECLARE @createdPayment INT
DECLARE @paymentBatchId INT
DECLARE @transCount INT = @@TRANCOUNT
IF @transCount = 0 BEGIN TRANSACTION;

SELECT @paymentBatchId = ISNULL(MAX(A.intBatchId),0) + 1 FROM tblAPPayment A

SET @batchBillsForPayment = CURSOR FORWARD_ONLY FOR

WITH batchBills 
(
	intEntityVendorId
	,intBillId
	,ysnOneBillPerPayment
	,intBankId
)
AS
(
	SELECT
		B.intEntityVendorId
		,B.intBillId
		,C.ysnOneBillPerPayment
		,E.intBankAccountId
	FROM tblAPBillBatch A
	INNER JOIN tblAPBill B ON A.intBillBatchId = B.intBillBatchId
	INNER JOIN tblAPVendor C ON B.intEntityVendorId = C.[intEntityId]
	INNER JOIN tblSMCompanyLocation D ON B.intShipToId = D.intCompanyLocationId
	LEFT JOIN tblCMBankAccount E ON D.intCashAccount = E.intGLAccountId
	WHERE A.intBillBatchId = @voucherBatchId
	AND B.dblAmountDue > 0 AND B.ysnPosted = 1
)

SELECT
	DISTINCT
	strBillIds = (CASE WHEN A.ysnOneBillPerPayment = 0
						THEN SUBSTRING(
							(SELECT ',' + CAST(B.intBillId AS NVARCHAR(100))
							FROM batchBills B
							WHERE B.intEntityVendorId = A.intEntityVendorId
							ORDER BY B.intBillId
							FOR XML PATH('')),2,200000)
						ELSE CAST(A.intBillId AS NVARCHAR(100)) END)
	,intBankId
FROM batchBills A
GROUP BY A.intEntityVendorId, A.intBillId, A.ysnOneBillPerPayment, A.intBankId;

OPEN @batchBillsForPayment;
FETCH NEXT FROM @batchBillsForPayment INTO @billIds, @bankId
WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC uspAPCreatePayment @userId = @user, @bankAccount = @bankId, @billId = @billIds, @createdPaymentId = @createdPayment OUTPUT
	UPDATE A
		SET A.intBatchId = @paymentBatchId
	FROM tblAPPayment A
	WHERE A.intPaymentId = @createdPayment
	FETCH NEXT FROM @batchBillsForPayment INTO @billIds, @bankId
END
CLOSE @batchBillsForPayment;
DEALLOCATE @batchBillsForPayment;

SET @batchPaymentId = @paymentBatchId;

IF @transCount = 0 COMMIT TRANSACTION

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
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH