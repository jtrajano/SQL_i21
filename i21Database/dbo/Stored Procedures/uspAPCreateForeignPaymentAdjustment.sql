CREATE PROCEDURE [dbo].[uspAPCreateForeignPaymentAdjustment]
	@GLEntries AS RecapTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

-- BEGIN TRY

DECLARE @functionalCurrency INT;
-- DECLARE @SavePoint NVARCHAR(32) = 'uspAPCreateForeignPaymentAdjustment';
-- DECLARE @transCount INT = @@TRANCOUNT;

SELECT TOP 1 
	@functionalCurrency = intDefaultCurrencyId 
FROM tblSMCompanyPreference

-- IF @transCount = 0 BEGIN TRANSACTION
-- ELSE SAVE TRAN @SavePoint

SELECT 
	A.[dtmDate],
	A.[strBatchId],
	A.[intAccountId],
	(currentGLPay.dblTotal + prevGLPay.dblTotal) - pay.dblPayment,
	A.[dblCredit],
	A.[dblDebitUnit],
	A.[dblCreditUnit],
	A.[strDescription],
	A.[strCode],    
	'Decimal loss due to rounding.',
	A.[intCurrencyId],
	A.[intCurrencyExchangeRateTypeId],
	A.[dblExchangeRate],
	A.[dtmDateEntered] ,
	A.[dtmTransactionDate],
	A.[strJournalLineDescription],
	A.[intJournalLineNo],
	A.[ysnIsUnposted],    
	A.[intUserId],
	A.[intEntityId],
	A.[strTransactionId],
	A.[intTransactionId],
	A.[strTransactionType],
	A.[strTransactionForm],
	A.[strModuleName],
	A.[intConcurrencyId],
	A.[dblDebitForeign],
	A.[dblDebitReport],
	A.[dblCreditForeign],
	A.[dblCreditReport],
	A.[dblReportingRate],
	A.[dblForeignRate],
	A.[strRateType]
FROM (
	SELECT TOP 1 * FROM @GLEntries
	WHERE intCurrencyId <> @functionalCurrency
) A
CROSS APPLY (
	SELECT strJournalLineDescription, SUM(dblTotal) AS dblTotal
	FROM (
		SELECT 
			A2.strJournalLineDescription,
			SUM(dblDebit - dblCredit) AS dblTotal
		FROM @GLEntries A2
		WHERE A2.strJournalLineDescription = A.strJournalLineDescription
		GROUP BY A2.strJournalLineDescription
		-- UNION ALL --DISCOUNT
		-- SELECT
		-- 	SUM(dblDebit - dblDebit) AS dblTotal
		-- FROM @GLEntries A3
		-- INNER JOIN tblAPPaymentDetail A4 ON A3.intJournalLineNo = A4.intPaymentDetailId
		-- INNER JOIN tblAPBill A5 ON A4.intBillId = A5.intBillId
		-- WHERE 
		-- 	A3.strJournalLineDescription = 'Discount'
		-- AND A5.strBillId = A.strJournalLineDescription
		UNION ALL --INTEREST
		SELECT
			A3.strJournalLineDescription,
			SUM(dblCredit - dblDebit) AS dblTotal
		FROM @GLEntries A3
		INNER JOIN tblAPPaymentDetail A4 ON A3.intJournalLineNo = A4.intPaymentDetailId
		INNER JOIN tblAPBill A5 ON A4.intBillId = A5.intBillId
		WHERE 
			A3.strJournalLineDescription = 'Interest'
		AND A5.strBillId = A.strJournalLineDescription
		GROUP BY A3.strJournalLineDescription
	) tmp
	GROUP BY strJournalLineDescription
) currentGLPay
CROSS APPLY (
	SELECT 
		C.strJournalLineDescription,
		SUM(dblDebit - dblCredit) AS dblTotal
	FROM tblGLDetail C
	WHERE C.strJournalLineDescription = currentGLPay.strJournalLineDescription
	AND C.ysnIsUnposted = 0
	GROUP BY C.strJournalLineDescription
	-- UNION ALL --DISCOUNT
	-- SELECT
	-- 	SUM(dblDebit - dblDebit) AS dblTotal
	-- FROM @GLEntries A3
	-- INNER JOIN tblAPPaymentDetail A4 ON A3.intJournalLineNo = A4.intPaymentDetailId
	-- INNER JOIN tblAPBill A5 ON A4.intBillId = A5.intBillId
	-- WHERE 
	-- 	A3.strJournalLineDescription = 'Discount'
	-- AND A5.strBillId = A.strJournalLineDescription
	UNION ALL --INTEREST
	SELECT
		C4.strBillId AS strJournalLineDescription,
		SUM(dblCredit - dblDebit) AS dblTotal
	FROM tblGLDetail C2
	INNER JOIN tblAPPaymentDetail C3 ON C2.intJournalLineNo = C3.intPaymentDetailId
	INNER JOIN tblAPBill C4 ON C4.intBillId = C3.intBillId
	WHERE 
		C2.strJournalLineDescription = 'Interest'
	AND C4.strBillId = currentGLPay.strJournalLineDescription
	AND C2.ysnIsUnposted = 0
	GROUP BY C4.strBillId
) prevGLPay
CROSS APPLY (
	SELECT SUM(E.dblPayment) dblPayment
	FROM tblAPPayment D
	INNER JOIN tblAPPaymentDetail E ON D.intPaymentId = E.intPaymentId
	INNER JOIN tblAPBill F ON E.intBillId = E.intBillId
	WHERE F.strBillId = currentGLPay.strJournalLineDescription
	AND D.ysnPosted = 1
) pay
WHERE
	(currentGLPay.dblTotal + prevGLPay.dblTotal) <> pay.dblPayment

-- IF @transCount = 0
-- 	BEGIN
-- 		IF (XACT_STATE()) = -1
-- 		BEGIN
-- 			ROLLBACK TRANSACTION
-- 		END
-- 		ELSE IF (XACT_STATE()) = 1
-- 		BEGIN
-- 			COMMIT TRANSACTION
-- 		END
-- 	END		
-- ELSE
-- 	BEGIN
-- 		IF (XACT_STATE()) = -1
-- 		BEGIN
-- 			ROLLBACK TRANSACTION  @SavePoint
-- 		END
-- 	END	
-- END TRY
-- BEGIN CATCH
-- 	DECLARE @ErrorSeverity INT,
-- 			@ErrorNumber   INT,
-- 			@ErrorMessage nvarchar(4000),
-- 			@ErrorState INT,
-- 			@ErrorLine  INT,
-- 			@ErrorProc nvarchar(200);
-- 	-- Grab error information from SQL functions
-- 	SET @ErrorSeverity = ERROR_SEVERITY()
-- 	SET @ErrorNumber   = ERROR_NUMBER()
-- 	SET @ErrorMessage  = ERROR_MESSAGE()
-- 	SET @ErrorState    = ERROR_STATE()
-- 	SET @ErrorLine     = ERROR_LINE()

-- 	IF @transCount = 0
-- 		BEGIN
-- 			IF (XACT_STATE()) = -1
-- 			BEGIN
-- 				ROLLBACK TRANSACTION
-- 			END
-- 			ELSE IF (XACT_STATE()) = 1
-- 			BEGIN
-- 				COMMIT TRANSACTION
-- 			END
-- 		END	

-- 	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
-- END CATCH
