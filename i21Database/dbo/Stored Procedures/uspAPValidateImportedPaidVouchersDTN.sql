﻿CREATE PROCEDURE [dbo].[uspAPValidateImportedPaidVouchersDTN]
	
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
SET 
	I.intEntityVendorId = ISNULL(MD.intEntityVendorId, -1), I.strNotes = CASE WHEN MD.intEntityVendorId IS NULL THEN 'Vendor Mapping not found.' ELSE NULL END
	,I.dblDiscount = ABS(I.dblDiscount)
FROM tblAPImportPaidVouchersForPayment I
LEFT JOIN tblGLVendorMapping VM ON VM.intVendorMappingId = I.intEntityVendorId
LEFT JOIN tblGLVendorMappingDetail MD ON MD.intVendorMappingId = VM.intVendorMappingId AND MD.strMapVendorName = I.strEntityVendorName

DECLARE @cteTbl AS TABLE(
	intRow INT,
	intId INT
)

INSERT INTO @cteTbl
	SELECT ROW_NUMBER() OVER(PARTITION BY A.strVendorOrderNumber ORDER BY A.intId) intRow,
	A.intId
	FROM tblAPImportPaidVouchersForPayment A

-- ;WITH cte AS (
-- 	SELECT ROW_NUMBER() OVER(PARTITION BY A.strVendorOrderNumber ORDER BY A.intId) intRow,
-- 	A.intId
-- 	FROM tblAPImportPaidVouchersForPayment A
-- )

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
						A.dblPayment > B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Overpayment'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment'
					WHEN
						A.dblPayment < B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Underpayment'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment'
					WHEN
						ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) > ABS((B.dblTotal - B.dblPaymentTemp))
					THEN 'Already included in payment' + P.strPaymentRecordNum
					ELSE NULL
					END,
		A.strBillId = B.strBillId,
		A.strVendorOrderNumber = A.strVendorOrderNumber
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN @cteTbl cte ON cte.intId = A.intId
OUTER APPLY	(
	SELECT *
	FROM (
		SELECT *, ROW_NUMBER() OVER (ORDER BY intBillId ASC) intRow
		FROM vyuAPBillForImport forImport
		WHERE forImport.intEntityVendorId = A.intEntityVendorId
			AND LTRIM(RTRIM(ISNULL(forImport.strPaymentScheduleNumber, forImport.strVendorOrderNumber))) = A.strVendorOrderNumber
			AND ISNULL(forImport.dblTotal, dblAmountDue) = ((A.dblPayment + A.dblDiscount) - A.dblInterest)
			AND ISNULL(forImport.dblTempDiscount, 0) = ISNULL(A.dblDiscount, 0)
	) voucher
	WHERE voucher.intRow = cte.intRow
) B
OUTER APPLY (
	SELECT STUFF(
		(
			SELECT ', ' + P.strPaymentRecordNum 
			FROM tblAPPaymentDetail PD 
			INNER JOIN tblAPPayment P ON P.intPaymentId = PD.intPaymentId 
			WHERE PD.intBillId = B.intBillId AND ISNULL(PD.intPayScheduleId, 0) = ISNULL(B.intPayScheduleId, 0) AND PD.dblPayment <> 0
			ORDER BY P.intPaymentId FOR XML PATH('')
		), 1, 1, ''
	) AS strPaymentRecordNum
) P
WHERE A.strNotes IS NULL
AND A.dblPayment > 0

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
						A.dblPayment > B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Overpayment'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment'
					WHEN
						A.dblPayment < B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Underpayment'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment'
					WHEN
						ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) > ABS((B.dblTotal - B.dblPaymentTemp))
					THEN 'Already included in payment' + P.strPaymentRecordNum
					ELSE NULL
					END,
		A.strBillId = B.strBillId,
		A.strVendorOrderNumber = A.strVendorOrderNumber
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN @cteTbl cte ON cte.intId = A.intId
OUTER APPLY	(
	SELECT *
	FROM (
		SELECT *, ROW_NUMBER() OVER (ORDER BY intBillId ASC) intRow
		FROM vyuAPBillForImport forImport
		WHERE forImport.intEntityVendorId = A.intEntityVendorId
			AND ISNULL(forImport.dblTotal, dblAmountDue) = ((A.dblPayment + A.dblDiscount) - A.dblInterest)
			AND forImport.intTransactionType = 3
	) voucher
	WHERE voucher.intRow = cte.intRow
) B
OUTER APPLY (
	SELECT STUFF(
		(
			SELECT ', ' + P.strPaymentRecordNum 
			FROM tblAPPaymentDetail PD 
			INNER JOIN tblAPPayment P ON P.intPaymentId = PD.intPaymentId 
			WHERE PD.intBillId = B.intBillId AND ISNULL(PD.intPayScheduleId, 0) = ISNULL(B.intPayScheduleId, 0) AND PD.dblPayment <> 0
			ORDER BY P.intPaymentId FOR XML PATH('')
		), 1, 1, ''
	) AS strPaymentRecordNum
) P
WHERE A.strNotes IS NULL
AND A.dblPayment < 0
	
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