CREATE PROCEDURE [dbo].[uspAPValidateImportedPaidVouchersIndiana]
AS

BEGIN  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRY  
  
DECLARE @locRef NVARCHAR(50);
DECLARE @transCount INT = @@TRANCOUNT;  
IF @transCount = 0 BEGIN TRANSACTION; 

UPDATE A
	SET A.strVendorOrderNumber = D.strLocationNumber + SUBSTRING(A.strVendorOrderNumber, CHARINDEX('-', A.strVendorOrderNumber), LEN(A.strVendorOrderNumber))
						+ CASE WHEN A.dblPayment < 0 THEN 'R' ELSE '' END
		,A.dblPayment = CASE WHEN B.dblInvoiceAdjPercentage > 0 
							THEN A.dblPayment - ((B.dblInvoiceAdjPercentage / 100) * A.dblPayment)
						ELSE A.dblPayment
						END
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN tblAPVendor B
	ON A.intEntityVendorId = B.intEntityId
LEFT JOIN tblAPVendorImportInfo C
	ON B.intEntityId = C.intEntityVendorId
LEFT JOIN tblSMCompanyLocation D
	ON D.intCompanyLocationId = C.intCompanyLocationId
WHERE C.strLocationXRef = SUBSTRING(A.strVendorOrderNumber, 1, CHARINDEX('-', A.strVendorOrderNumber) - 1)

UPDATE A
	SET A.strNotes = CASE
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
						A.dblPayment > 0 AND B.intTransactionType != 1
					THEN 'Amount is positive. Voucher type is expected.'
					WHEN 
						A.dblPayment < 0 AND B.intTransactionType != 3
					THEN 'Amount is negative. Debit Memo type is expected.'
					WHEN 
						A.dblPayment > (B.dblAmountDue * -1) AND B.intTransactionType = 3
					THEN 'Overpayment'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment'
						WHEN 
						A.dblPayment < (B.dblAmountDue * -1) AND B.intTransactionType = 3
					THEN 'Underpayment'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment'
					WHEN
						ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) > (B.dblTotal - B.dblPaymentTemp)
					THEN 'Already included in payment' + P.strPaymentRecordNum
					ELSE NULL
					END,
		A.strBillId = B.strBillId
FROM tblAPImportPaidVouchersForPayment A
LEFT JOIN tblAPBill B
ON 
	B.strVendorOrderNumber = A.strVendorOrderNumber
AND B.intEntityVendorId = A.intEntityVendorId
OUTER APPLY (
	SELECT STUFF(
		(
			SELECT ', ' + P.strPaymentRecordNum 
			FROM tblAPPaymentDetail PD 
			INNER JOIN tblAPPayment P ON P.intPaymentId = PD.intPaymentId 
			WHERE PD.intBillId = B.intBillId AND PD.dblPayment <> 0
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