﻿CREATE PROCEDURE [dbo].[uspAPUpdatePrepayStatus]
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
	A.intBillId
FROM tblAPPaymentDetail A
INNER JOIN @paymentIds B ON A.intPaymentId = B.intId
INNER JOIN tblAPBill C ON A.intBillId = C.intBillId
WHERE C.intTransactionType IN (2,13)

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION

--Check if there are still payment(PAY) for prepaid transaction
--If none, set ysnPrepayHasPayment to false
UPDATE A
	SET A.ysnPrepayHasPayment = CASE WHEN prepayment.intPaymentId IS NOT NULL THEN 1 ELSE 0 END
FROM tblAPBill A
INNER JOIN @billIds B ON A.intBillId = B.intId
OUTER APPLY
(
	SELECT TOP 1 
		pay.intPaymentId
	FROM tblAPPaymentDetail payDetail
	INNER JOIN tblAPPayment pay
		ON pay.intPaymentId = payDetail.intPaymentId
	LEFT JOIN tblCMBankTransaction E ON pay.strPaymentRecordNum = E.strTransactionId AND E.ysnCheckVoid = 0
	WHERE 
		B.intId = payDetail.intBillId
	AND payDetail.dblPayment != 0
	--AND pay.ysnPrepay = 1
	AND A.intTransactionType IN (2,13)
	AND pay.ysnPosted = 1
	--IF CHECK OR ACH PAYMENT METHOD, IT SHOULD BE PRINTED
	AND 1 = (CASE WHEN pay.intPaymentMethodId IN (2,7) AND E.dtmCheckPrinted IS NULL THEN 0 ELSE 1 END)
) prepayment


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
