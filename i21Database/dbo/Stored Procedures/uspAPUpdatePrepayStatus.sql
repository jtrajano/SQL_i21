CREATE PROCEDURE [dbo].[uspAPUpdatePrepayStatus]
	@paymentIds Id READONLY
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @billIds Id
INSERT INTO @billIds
SELECT
	intBillId
FROM tblAPPaymentDetail A
INNER JOIN @paymentIds B ON A.intPaymentId = B.intId

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

UPDATE A
	SET A.ysnPrepayHasPayment = ISNULL(payments.ysnHasPayment,0)
FROM tblAPBill A
INNER JOIN @billIds B ON A.intBillId = B.intId
OUTER APPLY (
	SELECT
		CASE WHEN E.strTransactionId IS NOT NULL THEN 1 ELSE 0 END AS ysnHasPayment
	FROM tblAPPayment B
	INNER JOIN @paymentIds C ON B.intPaymentId = C.intId
	INNER JOIN tblAPPaymentDetail D ON B.intPaymentId = D.intPaymentId
	LEFT JOIN tblCMBankTransaction E ON B.strPaymentRecordNum = E.strTransactionId
	WHERE D.intBillId = A.intBillId AND E.ysnCheckVoid = 0 AND D.dblPayment != 0
) payments

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

END
