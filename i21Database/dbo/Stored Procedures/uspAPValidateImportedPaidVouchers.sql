CREATE PROCEDURE [dbo].[uspAPValidateImportedPaidVouchers]
	@ignoreInvoiceMatch BIT
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
	I.intEntityVendorId = ISNULL(MD.intEntityVendorId, I.intEntityVendorId), I.strNotes = CASE WHEN MD.intEntityVendorId IS NULL THEN 'Vendor Mapping not found.' ELSE NULL END,
	I.dblDiscount = ABS(I.dblDiscount)
FROM tblAPImportPaidVouchersForPayment I
LEFT JOIN tblGLVendorMapping VM ON VM.intVendorMappingId = I.intEntityVendorId
LEFT JOIN tblGLVendorMappingDetail MD ON MD.intVendorMappingId = VM.intVendorMappingId AND MD.strMapVendorName = I.strEntityVendorName

DECLARE @cteTbl AS TABLE(
	intRow INT,
	intId INT
)

INSERT INTO @cteTbl
SELECT ROW_NUMBER() OVER(PARTITION BY A.strVendorOrderNumber, A.dblPayment ORDER BY A.intId) intRow,
	A.intId
	FROM tblAPImportPaidVouchersForPayment A

-- ;WITH cte AS (
-- 	SELECT ROW_NUMBER() OVER(PARTITION BY A.strVendorOrderNumber, A.dblPayment ORDER BY A.intId) intRow,
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
					THEN 'Voucher is not yet posted.'
					WHEN 
						A.dblPayment > 0 AND B.intTransactionType != 1
					THEN 'Amount is positive. Voucher type is expected.'
					WHEN 
						A.dblPayment < 0 AND B.intTransactionType != 3
					THEN 'Amount is negative. Debit Memo type is expected.'
					WHEN 
						A.dblPayment > B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Overpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment.'
					WHEN 
						A.dblPayment < B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Underpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment.'
					WHEN 
						B.intPayScheduleId IS NOT NULL AND P.strPaymentRecordNum IS NOT NULL
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN
						B.intPayScheduleId IS NULL AND ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) >= ABS((B.dblTotal - B.dblPaymentTemp))
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN 
						cte.intRow	> 1 AND B.intBillId IS NULL
					THEN 'Duplicate row entry.'
					WHEN 
						B.intBillId IS NULL
					THEN CASE
						 WHEN @ignoreInvoiceMatch = 1
						 THEN 'Will create empty payment.'
						 ELSE 'Voucher not found.'
						 END
					ELSE NULL
					END,
		A.strBillId = B.strBillId
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
			--forImport.ysnInPaymentSched > THIS IS EXPECTING THAT THE DISCOUNT WHAS PART OF PAYMENT SCHEDULE tblAPVoucherPaymentSchedule.dblDiscount
			--HOWEVER, DISCOUNT MAY STILL EXISTS ON IMPORT BUT NOT ON tblAPVoucherPaymentSchedule.dblDiscount
			--IT IS BETTER TO NO CHECK FOR DISCOUNT, JUST COMPARE THE PAYMENT
			--ISNULL(forImport.dblTempDiscount, 0) = (CASE WHEN forImport.ysnInPaymentSched = 1 THEN A.dblDiscount ELSE 0 END)
			--PAYMENT FIELD SHOULD BE THE GROSS PAYMENT ON CSV
			--AND ISNULL(forImport.dblTempDiscount, 0) = ISNULL(A.dblDiscount, 0)
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
WHERE
	A.strNotes IS NULL
AND A.dblPayment > 0

--CHILD VENDOR MATCHING
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
					THEN 'Voucher is not yet posted.'
					WHEN 
						A.dblPayment > 0 AND B.intTransactionType != 1
					THEN 'Amount is positive. Voucher type is expected.'
					WHEN 
						A.dblPayment < 0 AND B.intTransactionType != 3
					THEN 'Amount is negative. Debit Memo type is expected.'
					WHEN 
						A.dblPayment > B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Overpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment.'
					WHEN 
						A.dblPayment < B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Underpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment.'
					WHEN 
						B.intPayScheduleId IS NOT NULL AND P.strPaymentRecordNum IS NOT NULL
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN
						B.intPayScheduleId IS NULL AND ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) >= ABS((B.dblTotal - B.dblPaymentTemp))
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN 
						cte.intRow	> 1 AND B.intBillId IS NULL
					THEN 'Duplicate row entry.'
					WHEN 
						B.intBillId IS NULL
					THEN CASE
						 WHEN @ignoreInvoiceMatch = 1
						 THEN 'Will create empty payment.'
						 ELSE 'Voucher not found.'
						 END
					ELSE NULL
					END,
		A.strBillId = B.strBillId,
		A.intEntityVendorId = B.intEntityVendorId
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN @cteTbl cte ON cte.intId = A.intId
OUTER APPLY	(
	SELECT *
	FROM (
		SELECT forImport.*, ROW_NUMBER() OVER (ORDER BY intBillId ASC) intRow
		FROM vyuAPBillForImport forImport
		INNER JOIN tblAPVendor childVend ON forImport.intEntityVendorId = childVend.intEntityId
		INNER JOIN tblAPVendor parentVendor ON childVend.strVendorPayToId = parentVendor.strVendorId
		WHERE parentVendor.intEntityId = A.intEntityVendorId 
			AND LTRIM(RTRIM(ISNULL(forImport.strPaymentScheduleNumber, forImport.strVendorOrderNumber))) = A.strVendorOrderNumber
			AND ISNULL(forImport.dblTotal, dblAmountDue) = ((A.dblPayment + A.dblDiscount) - A.dblInterest)
			--IF PAYMENT SCHEDULE COMPARE DISCOUNT ON PAYMENT TEMP
			--ELSE DISCOUNT WILL BE 0, DISCOUNT HAS BEEN HANDLED ABOVE (A.dblPayment + A.dblDiscount)
			--forImport.ysnInPaymentSched > THIS IS EXPECTING THAT THE DISCOUNT WHAS PART OF PAYMENT SCHEDULE tblAPVoucherPaymentSchedule.dblDiscount
			--HOWEVER, DISCOUNT MAY STILL EXISTS ON IMPORT BUT NOT ON tblAPVoucherPaymentSchedule.dblDiscount
			--IT IS BETTER TO NO CHECK FOR DISCOUNT, JUST COMPARE THE PAYMENT
			--ISNULL(forImport.dblTempDiscount, 0) = (CASE WHEN forImport.ysnInPaymentSched = 1 THEN A.dblDiscount ELSE 0 END)
			--PAYMENT FIELD SHOULD BE THE GROSS PAYMENT ON CSV
			--AND ISNULL(forImport.dblTempDiscount, 0) = (CASE WHEN forImport.ysnInPaymentSched = 1 THEN A.dblDiscount ELSE 0 END)
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
WHERE
	A.strNotes = 'Voucher not found.'
AND A.dblPayment > 0
AND A.strBillId IS NULL
AND B.intBillId IS NOT NULL

--DEBIT MEMO MATCHING
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
					THEN 'Voucher is not yet posted.'
					WHEN 
						A.dblPayment > 0 AND B.intTransactionType != 1
					THEN 'Amount is positive. Voucher type is expected.'
					WHEN 
						A.dblPayment < 0 AND B.intTransactionType != 3
					THEN 'Amount is negative. Debit Memo type is expected.'
					WHEN 
						A.dblPayment > B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Overpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment.'
					WHEN 
						A.dblPayment < B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Underpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment.'
					WHEN 
						B.intPayScheduleId IS NOT NULL AND P.strPaymentRecordNum IS NOT NULL
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN
						B.intPayScheduleId IS NULL AND ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) >= ABS((B.dblTotal - B.dblPaymentTemp))
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN 
						cte.intRow	> 1 AND B.intBillId IS NULL
					THEN 'Duplicate row entry.'
					WHEN 
						B.intBillId IS NULL
					THEN CASE
						 WHEN @ignoreInvoiceMatch = 1
						 THEN 'Will create empty payment.'
						 ELSE 'Voucher not found.'
						 END
					ELSE NULL
					END,
		A.strBillId = B.strBillId
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
WHERE 
	A.strNotes IS NULL
AND A.dblPayment < 0

--CHILD VENDOR MATCHING DEBIT MEMO
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
					THEN 'Voucher is not yet posted.'
					WHEN 
						A.dblPayment > 0 AND B.intTransactionType != 1
					THEN 'Amount is positive. Voucher type is expected.'
					WHEN 
						A.dblPayment < 0 AND B.intTransactionType != 3
					THEN 'Amount is negative. Debit Memo type is expected.'
					WHEN 
						A.dblPayment > B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Overpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) > B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Overpayment.'
					WHEN 
						A.dblPayment < B.dblAmountDue AND B.intTransactionType = 3
					THEN 'Underpayment.'
					WHEN 
						((A.dblPayment + A.dblDiscount) - A.dblInterest) < B.dblAmountDue  AND B.intTransactionType = 1
					THEN 'Underpayment.'
					WHEN 
						B.intPayScheduleId IS NOT NULL AND P.strPaymentRecordNum IS NOT NULL
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN
						B.intPayScheduleId IS NULL AND ABS((A.dblPayment + A.dblDiscount) - A.dblInterest) >= ABS((B.dblTotal - B.dblPaymentTemp))
					THEN 'Already included in payment' + P.strPaymentRecordNum + '.'
					WHEN 
						cte.intRow	> 1 AND B.intBillId IS NULL
					THEN 'Duplicate row entry.'
					WHEN 
						B.intBillId IS NULL
					THEN CASE
						 WHEN @ignoreInvoiceMatch = 1
						 THEN 'Will create empty payment.'
						 ELSE 'Voucher not found.'
						 END
					ELSE NULL
					END,
		A.strBillId = B.strBillId,
		A.intEntityVendorId = B.intEntityVendorId
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN @cteTbl cte ON cte.intId = A.intId
OUTER APPLY	(
	SELECT *
	FROM (
		SELECT forImport.*, ROW_NUMBER() OVER (ORDER BY intBillId ASC) intRow
		FROM vyuAPBillForImport forImport
		INNER JOIN tblAPVendor childVend ON forImport.intEntityVendorId = childVend.intEntityId
		INNER JOIN tblAPVendor parentVendor ON childVend.strVendorPayToId = parentVendor.strVendorId
		WHERE parentVendor.intEntityId = A.intEntityVendorId 
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
WHERE
	A.strNotes = 'Voucher not found.'
AND A.dblPayment < 0
AND A.strBillId IS NULL
AND B.intBillId IS NOT NULL

;WITH cte AS (
	SELECT DENSE_RANK() OVER(ORDER BY A.dtmDatePaid, A.intEntityVendorId, A.strCheckNumber, A.intCustomPartition) intRow,
	A.intId
	FROM tblAPImportPaidVouchersForPayment A
	WHERE A.strNotes = 'Will create empty payment.'
)

UPDATE A
SET A.strNotes = 'Will create empty payment (' + CAST(cte.intRow AS NVARCHAR(10)) + ').',
    A.intCustomPartition = cte.intRow
FROM tblAPImportPaidVouchersForPayment A
INNER JOIN cte cte ON cte.intId = A.intId
WHERE A.strNotes = 'Will create empty payment.'
	
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