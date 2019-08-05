﻿CREATE PROCEDURE [dbo].[uspAPValidateImportedPaidVouchersOhio]
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
							A.intCurrencyId = B.intCurrencyId
						AND B.ysnPaid = 0
						AND B.ysnPosted = 1
						AND B.intBillId > 0
						AND A.dblPayment <= B.dblAmountDue
						THEN NULL
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
						A.dblPayment > B.dblAmountDue
					THEN 'Overpayment'
					ELSE NULL
					END,
		A.strBillId = B.strBillId
FROM tblAPImportPaidVouchersForPayment A
LEFT JOIN tblAPBill B
ON 
	B.strVendorOrderNumber = A.strVendorOrderNumber
AND B.intEntityVendorId = A.intEntityVendorId
	
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