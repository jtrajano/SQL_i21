CREATE PROCEDURE [dbo].[uspAPImportandCreatePayment]
	@templateId INT,
	@locationId INT,
	@bankAccountId INT,
	@userId INT,
	@createdPaymentIds NVARCHAR(1000) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	DECLARE @datePaid DATETIME;
	DECLARE @vendorId INT;
	DECLARE @checkNumber NVARCHAR(55);
	DECLARE @intIds NVARCHAR(MAX);
	DECLARE @billIds NVARCHAR(MAX);
	DECLARE @createdPaymentId INT;
	DECLARE @createdPayments NVARCHAR(MAX) = '';

	--VENDOR DEFAULTS
	DECLARE @currencyId INT = NULL;
	DECLARE @paymentMethodId INT = NULL;
	DECLARE @payToAddress INT = NULL;

	--EFT Import Config
	DECLARE @archiveServer NVARCHAR(MAX) = NULL
	DECLARE @importServer NVARCHAR(MAX) = NULL
	
	SELECT TOP 1 
		@archiveServer = strArchiveServer
		,@importServer = strFromServer
	FROM tblAPCompanyPreference

	IF ISNULL(dbo.fnTrim(@archiveServer), '') = ''
		AND ISNULL(dbo.fnTrim(@importServer), '') != ''
	BEGIN
		RAISERROR('Archived Failed. Directory not exists or permission denied.', 16, 1);
	END

	DELETE FROM tblAPImportPaidVouchersForPayment WHERE strNotes IS NOT NULL AND strNotes NOT LIKE '%Will create empty payment%'

	IF OBJECT_ID('tempdb..#tmpMultiVouchersImport') IS NOT NULL DROP TABLE #tmpMultiVouchersImport
	SELECT dtmDatePaid,
		--    intEntityVendorId,
			md.intEntityVendorId, -- use the vendor set on CSV
		   strCheckNumber,
		--    intIds = STUFF((SELECT ',' + CONVERT(VARCHAR(12), I2.intId) FROM tblAPImportPaidVouchersForPayment I2 WHERE I2.dtmDatePaid = I.dtmDatePaid AND I2.intEntityVendorId = I.intEntityVendorId AND (I2.strCheckNumber = I.strCheckNumber OR (I2.strCheckNumber IS NULL AND I.strCheckNumber IS NULL)) AND I2.intCustomPartition = I.intCustomPartition FOR XML PATH('')), 1, 1, '')
		intIds = STUFF((SELECT ',' + CONVERT(VARCHAR(12), I2.intId) FROM tblAPImportPaidVouchersForPayment I2 WHERE I2.dtmDatePaid = I.dtmDatePaid 
						AND md.strMapVendorName = I2.strEntityVendorName AND (I2.strCheckNumber = I.strCheckNumber OR (I2.strCheckNumber 
IS NULL AND I.strCheckNumber IS NULL)) AND I2.intCustomPartition = I.intCustomPartition FOR XML PATH('')), 1, 1, '')  
	INTO #tmpMultiVouchersImport
	FROM tblAPImportPaidVouchersForPayment I
	INNER JOIN tblGLVendorMappingDetail md ON I.strEntityVendorName = md.strMapVendorName
 	GROUP BY dtmDatePaid, md.intEntityVendorId, strCheckNumber, intCustomPartition , md.strMapVendorName 
	--GROUP BY dtmDatePaid, intEntityVendorId, strCheckNumber, intCustomPartition

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpMultiVouchersImport)
	BEGIN
		SELECT TOP 1 @datePaid = dtmDatePaid, @vendorId = intEntityVendorId, @checkNumber = strCheckNumber, @intIds = intIds, @billIds = '' FROM #tmpMultiVouchersImport

		SELECT TOP 1 @currencyId = intCurrencyId FROM vyuCMBankAccount WHERE intBankAccountId = @bankAccountId
		SELECT TOP 1 @paymentMethodId = intPaymentMethodId, @payToAddress = intDefaultLocationId FROM vyuAPVendor WHERE intEntityId = @vendorId

		SELECT @billIds = COALESCE(@billIds + ',', '') +  CONVERT(VARCHAR(12), intBillId)
		FROM dbo.fnAPGetPayVoucherForPayment(@currencyId, @paymentMethodId, @datePaid, 1, @vendorId, @payToAddress, 0, DEFAULT, DEFAULT)

		IF NULLIF(@billIds, '') IS NOT NULL
		BEGIN
			EXEC uspAPCreatePayment @userId, @bankAccountId, DEFAULT, DEFAULT, DEFAULT, DEFAULT, @datePaid, DEFAULT, DEFAULT, @billIds, @createdPaymentId OUTPUT
		
			UPDATE PD
			SET PD.dblDiscount = ISNULL(forPayment.dblDiscount, 0),
				PD.dblPayment = ISNULL(forPayment.dblPayment, 0),
				PD.dblInterest = ISNULL(forPayment.dblInterest, 0),
				PD.dblAmountDue = CASE WHEN forPayment.intId IS NOT NULL THEN ((forPayment.dblPayment + forPayment.dblDiscount) - PD.dblInterest) ELSE PD.dblAmountDue END,
				PD.dblTotal = CASE WHEN forPayment.intId IS NOT NULL THEN ((forPayment.dblPayment + forPayment.dblDiscount) - forPayment.dblInterest) ELSE PD.dblTotal END
			FROM tblAPPaymentDetail PD
			INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
			LEFT JOIN tblAPVoucherPaymentSchedule PS ON PS.intId = PD.intPayScheduleId
			OUTER APPLY (
				SELECT
					I.*
				FROM tblAPImportPaidVouchersForPayment I 
				WHERE 
					I.strBillId = B.strBillId 
				AND I.strVendorOrderNumber = LTRIM(RTRIM(ISNULL(PS.strPaymentScheduleNumber, B.strVendorOrderNumber)))
				AND ((I.dblPayment + I.dblDiscount) - I.dblInterest) = ISNULL(PS.dblPayment, B.dblAmountDue * (CASE WHEN B.intTransactionType = 1 THEN 1 ELSE  -1 END))
				AND I.intId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@intIds))
			) forPayment
			WHERE 
				PD.intPaymentId = @createdPaymentId
			AND PD.dblPayment > 0;

			UPDATE PD
			SET PD.dblDiscount = ISNULL(forPayment.dblDiscount, 0),
				PD.dblPayment = ISNULL(forPayment.dblPayment, 0),
				PD.dblInterest = ISNULL(forPayment.dblInterest, 0),
				PD.dblAmountDue = CASE WHEN forPayment.intId IS NOT NULL THEN ((forPayment.dblPayment + forPayment.dblDiscount) - PD.dblInterest) ELSE PD.dblAmountDue END,
				PD.dblTotal = CASE WHEN forPayment.intId IS NOT NULL THEN ((forPayment.dblPayment + forPayment.dblDiscount) - forPayment.dblInterest) ELSE PD.dblTotal END
			FROM tblAPPaymentDetail PD
			INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
			LEFT JOIN tblAPVoucherPaymentSchedule PS ON PS.intId = PD.intPayScheduleId
			OUTER APPLY (
				SELECT
					I.*
				FROM tblAPImportPaidVouchersForPayment I 
				WHERE 
					I.strBillId = B.strBillId 
				--AND I.strVendorOrderNumber = LTRIM(RTRIM(ISNULL(PS.strPaymentScheduleNumber, B.strVendorOrderNumber)))
				AND ((I.dblPayment + I.dblDiscount) - I.dblInterest) = ISNULL(PS.dblPayment, B.dblAmountDue * (CASE WHEN B.intTransactionType = 1 THEN 1 ELSE  -1 END))
				AND I.intId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@intIds))
			) forPayment
			WHERE PD.intPaymentId = @createdPaymentId
			AND PD.dblPayment < 0;

			--UNPAY THOSE DUPLICATE, THE SAME AMOUNT AND INVOICE #, SELECT ONLY THE EARLIEST DUE DATE
			;WITH cteDup (
				intId,
				intBillId,
				intEarliestDue,
				intCSVIdCount
			) AS (
				SELECT 
					PS.intId,
					PS.intBillId,
					--PS.strPaymentScheduleNumber,
					ROW_NUMBER() OVER (PARTITION BY PS.intBillId, PS.dblPayment, PS.strPaymentScheduleNumber ORDER BY PS.dtmDueDate DESC) intEarliestDue,
					csvRec.intCSVIdCount
				FROM tblAPVoucherPaymentSchedule PS 
				INNER JOIN (tblAPPaymentDetail payDetail INNER JOIN tblAPPayment pay ON pay.intPaymentId = payDetail.intPaymentId)
					ON PS.intBillId = payDetail.intBillId
				INNER JOIN tblAPBill bill
					ON PS.intBillId = bill.intBillId
				OUTER APPLY (
					--query only those PS with duplicate
					SELECT COUNT(paySched.intId) intIdCount
					FROM tblAPVoucherPaymentSchedule paySched
					WHERE paySched.intBillId = payDetail.intBillId
					AND paySched.ysnPaid = 0
					GROUP BY paySched.dblPayment, paySched.strPaymentScheduleNumber
					HAVING COUNT(paySched.intId) > 1
				) dupPS
				OUTER APPLY (
					SELECT	COUNT(csv.intId) intCSVIdCount
					FROM tblAPImportPaidVouchersForPayment csv
					WHERE 
						csv.strBillId = bill.strBillId
					AND csv.dblPayment = payDetail.dblPayment
					AND csv.strVendorOrderNumber = PS.strPaymentScheduleNumber
				) csvRec
				WHERE PS.ysnPaid = 0
				AND payDetail.dblPayment != 0
				AND pay.intPaymentId = @createdPaymentId
				AND dupPS.intIdCount IS NOT NULL
				AND dupPS.intIdCount > csvRec.intCSVIdCount --PS Selected is greater than the csv rec
			)

			UPDATE PD
			SET
				PD.dblPayment = 0,
				PD.dblAmountDue = PD.dblTotal
			FROM tblAPPaymentDetail PD
			INNER JOIN (
				SELECT A.intBillId, A.intId, A.intEarliestDue, A.intCSVIdCount
				FROM cteDup A
				--INNER JOIN cteDup B ON A.intBillId = B.intBillId
				--WHERE 
				--	A.intEarliestDue > 1
			) dupPay
			ON dupPay.intBillId = PD.intBillId --AND dupPay.intEarliestDue = 1
			AND PD.intPayScheduleId = dupPay.intId
			WHERE PD.intPaymentId = @createdPaymentId
			AND dupPay.intEarliestDue <= dupPay.intCSVIdCount
			--END

			EXEC uspAPUpdateVoucherPayment @createdPaymentId, NULL

			UPDATE P
			SET P.intBankAccountId = @bankAccountId,
				P.intCompanyLocationId = @locationId,
				P.strNotes = @checkNumber, 
				P.ysnEFTImported = 1,
				P.dblAmountPaid = PD.dblPayment,
				P.intPaymentMethodId = CASE WHEN PD.dblPayment = 0 AND PC.intPaymentCount > 1 THEN 3 ELSE (CASE WHEN @templateId = 5 THEN 6 ELSE P.intPaymentMethodId END) END
			FROM tblAPPayment P
			OUTER APPLY (
				SELECT SUM(dblPayment) dblPayment FROM tblAPPaymentDetail WHERE intPaymentId = P.intPaymentId
			) PD
			OUTER APPLY (
				SELECT COUNT(*) intPaymentCount FROM tblAPPaymentDetail WHERE dblPayment <> 0
				AND intPaymentId = P.intPaymentId
			) PC
			WHERE P.intPaymentId = @createdPaymentId

			SET @createdPayments = @createdPayments + CASE WHEN @createdPayments = '' THEN '' ELSE ', ' END + CONVERT(VARCHAR(12), @createdPaymentId)
		END

		DELETE FROM #tmpMultiVouchersImport WHERE intIds = @intIds
	END

	TRUNCATE TABLE tblAPImportPaidVouchersForPayment

	SET @createdPaymentIds = @createdPayments

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