CREATE PROCEDURE [dbo].[uspAPFixVoucher]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
IF @transCount = 0 BEGIN TRANSACTION;

DECLARE @billsToFixPayment TABLE(intBillId INT)
DECLARE @billsFixed TABLE(intBillId INT)

INSERT INTO @billsToFixPayment
SELECT intBillId FROM vyuAPBillStatus WHERE strStatus != 'OK'

--FIX PAYMENT STATUS
UPDATE A
	SET A.dblPayment = B.dblPayment
	,A.dblAmountDue = A.dblTotal - (B.dblPayment + B.dblDiscount) + B.dblInterest
	,A.ysnPaid = CASE WHEN (A.dblTotal - (B.dblPayment + B.dblDiscount) + B.dblInterest) = 0 THEN 1 ELSE 0 END
	,A.dtmDatePaid = B.dtmDatePaid
OUTPUT inserted.intBillId INTO @billsFixed
FROM tblAPBill A
INNER JOIN vyuAPBillPaymentActual B
	ON A.intBillId = B.intBillId
WHERE A.intBillId IN (
	SELECT intBillId FROM vyuAPBillStatus B WHERE B.strStatus != 'OK'
)
AND A.ysnPosted = 1

--CHECK IF ALL AFFECTED VOUCHERS HAS AN ISSUE
IF(EXISTS(SELECT 1 FROM @billsFixed WHERE intBillId NOT IN (SELECT intBillId FROM @billsToFixPayment)))
BEGIN
	RAISERROR('Unexpected bill(s) affected.', 16, 1);
END

IF @transCount = 0 COMMIT TRANSACTION;

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
    SET @ErrorProc     = ERROR_PROCEDURE()
    -- Not all errors generate an error state, to set to 1 if it's zero
    IF @ErrorState  = 0 SET @ErrorState = 1
    -- If the error renders the transaction as uncommittable or we have open transactions, we may want to rollback
    IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
    RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH