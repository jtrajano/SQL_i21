CREATE PROCEDURE [dbo].[uspAPValidateImportedPaidVouchers]
	
AS

BEGIN  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  
  
BEGIN TRY  
  
DECLARE @transCount INT = @@TRANCOUNT;  
IF @transCount = 0 BEGIN TRANSACTION; 

UPDATE I
SET I.intEntityVendorId = ISNULL(MD.intEntityVendorId, -1), I.strNotes = CASE WHEN MD.intEntityVendorId IS NULL THEN 'Vendor Mapping not found.' ELSE NULL END
FROM tblAPImportPaidVouchersForPayment I
LEFT JOIN tblGLVendorMapping VM ON VM.intVendorMappingId = I.intEntityVendorId
LEFT JOIN tblGLVendorMappingDetail MD ON MD.intVendorMappingId = VM.intVendorMappingId AND MD.strMapVendorName = I.strEntityVendorName

;WITH cte AS (
	SELECT ROW_NUMBER() OVER(PARTITION BY A.strVendorOrderNumber ORDER BY A.intId) intRow,
	A.intId
	FROM tblAPImportPaidVouchersForPayment A
)

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
						B.intTransactionType = 3 AND ((A.dblPayment + A.dblDiscount) - A.dblInterest) > 0
					THEN 'Debit Memo type amount should be negative.'
					WHEN 
						ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue
					THEN (CASE WHEN B.intTransactionType = 3 THEN 'Underpayment' ELSE 'Overpayment' END)
					WHEN 
						ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue
					THEN (CASE WHEN B.intTransactionType = 3 THEN 'Overpayment' ELSE 'Underpayment' END)
					ELSE NULL
					END,
		A.strBillId = B.strBillId
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN cte cte ON cte.intId = A.intId
OUTER APPLY	(
	SELECT *
	FROM (
		SELECT *, ROW_NUMBER() OVER (ORDER BY intBillId ASC) intRow
		FROM tblAPBill 
		WHERE strVendorOrderNumber = A.strVendorOrderNumber AND intEntityVendorId = A.intEntityVendorId AND CONVERT(NVARCHAR(10), dtmBillDate, 101) = CONVERT(NVARCHAR(10), A.dtmBillDate, 101)
	) voucher
	WHERE voucher.intRow = cte.intRow
) B
WHERE A.strNotes IS NULL
	
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