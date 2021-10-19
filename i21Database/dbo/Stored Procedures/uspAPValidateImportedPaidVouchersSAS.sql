CREATE PROCEDURE [dbo].[uspAPValidateImportedPaidVouchersSAS]
	
AS

BEGIN  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRY  
  
DECLARE @transCount INT = @@TRANCOUNT;  
IF @transCount = 0 BEGIN TRANSACTION; 

;WITH cte AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY A.strStore, A.strVendorOrderNumber ORDER BY A.intId) intRow,
	A.intId
	FROM tblAPImportPaidVouchersForPayment A
)

UPDATE A
	SET A.strNotes = CASE
					-- WHEN 
					-- 	A.intCurrencyId = B.intCurrencyId
					-- AND B.ysnPaid = 0
					-- AND B.ysnPosted = 1
					-- AND B.intBillId > 0
					-- AND ABS(A.dblPayment) = B.dblAmountDue --MAKE THE CSV DATA AMOUNT POSITIVE TO CORRECTLY VALIDATE WITH tblAPBill.dblAmountDue
					-- -- THEN 
					-- -- 	(
					-- -- 		CASE 
					-- -- 		WHEN ABS(A.dblPayment) < 0 AND B.intTransactionType = 1
					-- -- 		THEN 'Invalid amount.'
					-- -- 		ELSE NULL END
					-- -- 	)
					-- THEN NULL
					WHEN 
						A.intCurrencyId != B.intCurrencyId
					THEN 'Currency is different on current selected currency.'
					WHEN 
						B.ysnPaid = 1
					THEN 'Voucher already paid.'
					WHEN 
						B.ysnPosted = 0
					THEN 'Voucher is not yet posted'
					WHEN 
						B.intBillId IS NULL
					THEN 'Voucher not found.'
					WHEN 
						A.dblPayment > (B.dblAmountDue * -1) AND B.intTransactionType = 3
					THEN 'Overpayment'
					WHEN 
						A.dblPayment > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment'
						WHEN 
						A.dblPayment < (B.dblAmountDue * -1) AND B.intTransactionType = 3
					THEN 'Underpayment'
					WHEN 
						A.dblPayment < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment'
					WHEN 
						A.dblPayment < 0 AND B.intTransactionType != 3
					THEN 'Amount is negative. Debit Memo type is expected.'
					WHEN
						ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) > (B.dblTotal - B.dblPaymentTemp)
					THEN 'Already included in payment' + P.strPaymentRecordNum
					ELSE NULL
					END,
		A.strBillId = B.strBillId,
		A.strVendorOrderNumber = A.strStore + '-' + A.strVendorOrderNumber
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN cte cte ON cte.intId = A.intId
OUTER APPLY	(
	SELECT *
	FROM (
		SELECT *, ROW_NUMBER() OVER (ORDER BY intBillId ASC) intRow
		FROM tblAPBill 
		WHERE strVendorOrderNumber = A.strStore + '-' + A.strVendorOrderNumber AND intEntityVendorId = A.intEntityVendorId
	) voucher
	WHERE voucher.intRow = cte.intRow
) B
OUTER APPLY (
	SELECT STUFF(
		(
			SELECT ', ' + P.strPaymentRecordNum 
			FROM tblAPPaymentDetail PD 
			INNER JOIN tblAPPayment P ON P.intPaymentId = PD.intPaymentId 
			WHERE PD.intBillId = B.intBillId 
			ORDER BY P.intPaymentId FOR XML PATH('')
		), 1, 1, ''
	) AS strPaymentRecordNum
) P
	
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

	IF (XACT_STATE()) = -1  
	BEGIN  
		ROLLBACK TRANSACTION  
	END  
	ELSE IF (XACT_STATE()) = 1 AND @transCount = 0  
	BEGIN  
		ROLLBACK TRANSACTION  
	END  

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)  
END CATCH  
  
RETURN 0  
END  