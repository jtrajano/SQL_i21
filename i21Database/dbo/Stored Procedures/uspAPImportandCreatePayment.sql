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

	DELETE FROM tblAPImportPaidVouchersForPayment WHERE strNotes IS NOT NULL

	IF OBJECT_ID('tempdb..#tmpMultiVouchersImport') IS NOT NULL DROP TABLE #tmpMultiVouchersImport
	SELECT dtmDatePaid,
		   intEntityVendorId,
		   strCheckNumber,
		   intIds = STUFF((SELECT ',' + CONVERT(VARCHAR(12), I2.intId) FROM tblAPImportPaidVouchersForPayment I2 WHERE I2.dtmDatePaid = I.dtmDatePaid AND I2.intEntityVendorId = I.intEntityVendorId AND (I2.strCheckNumber = I.strCheckNumber OR (I2.strCheckNumber IS NULL AND I.strCheckNumber IS NULL)) AND I2.intCustomPartition = I.intCustomPartition FOR XML PATH('')), 1, 1, '')
	INTO #tmpMultiVouchersImport
	FROM tblAPImportPaidVouchersForPayment I
	GROUP BY dtmDatePaid, intEntityVendorId, strCheckNumber, intCustomPartition

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpMultiVouchersImport)
	BEGIN
		SELECT TOP 1 @datePaid = dtmDatePaid, @vendorId = intEntityVendorId, @checkNumber = strCheckNumber, @intIds = intIds, @billIds = '' FROM #tmpMultiVouchersImport

		IF @templateId NOT IN (1, 2, 3)
		BEGIN
			SELECT @billIds = COALESCE(@billIds + ',', '') +  CONVERT(VARCHAR(12), B.intBillId)
			FROM dbo.fnGetRowsFromDelimitedValues(@intIds) IDS
			INNER JOIN tblAPImportPaidVouchersForPayment I ON I.intId = IDS.intID
			INNER JOIN tblAPBill B ON B.strBillId = I.strBillId
		END
		ELSE
		BEGIN
			SELECT TOP 1 @currencyId = intCurrencyId FROM vyuCMBankAccount WHERE intBankAccountId = @bankAccountId
			SELECT TOP 1 @paymentMethodId = intPaymentMethodId, @payToAddress = intDefaultLocationId FROM vyuAPVendor WHERE intEntityId = @vendorId

			SELECT @billIds = COALESCE(@billIds + ',', '') +  CONVERT(VARCHAR(12), intBillId)
			FROM dbo.fnAPGetPayVoucherForPayment(@currencyId, @paymentMethodId, @datePaid, 1, @vendorId, @payToAddress, 0)
		END

		EXEC uspAPCreatePayment @userId, @bankAccountId, DEFAULT, DEFAULT, DEFAULT, DEFAULT, @datePaid, DEFAULT, DEFAULT, @billIds, @createdPaymentId OUTPUT

		IF @templateId NOT IN (1, 2, 3)
		BEGIN
			DELETE PD
			FROM tblAPPaymentDetail PD
			INNER JOIN tblAPVoucherPaymentSchedule PS ON PS.intId = PD.intPayScheduleId
			LEFT JOIN tblAPImportPaidVouchersForPayment I ON I.strVendorOrderNumber = PS.strPaymentScheduleNumber
			WHERE PD.intPaymentId = @createdPaymentId AND PD.intPayScheduleId IS NOT NULL AND (I.intId IS NULL OR I.intId NOT IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@intIds)))
		END
		
		UPDATE PD
		SET PD.dblDiscount = ISNULL(I.dblDiscount, 0),
			PD.dblPayment = ISNULL(I.dblPayment, 0),
			PD.dblInterest = ISNULL(I.dblInterest, 0),
			PD.dblAmountDue = CASE WHEN I.intId IS NOT NULL THEN ((I.dblPayment + I.dblDiscount) - PD.dblInterest) ELSE PD.dblAmountDue END,
			PD.dblTotal = CASE WHEN I.intId IS NOT NULL THEN ((I.dblPayment + I.dblDiscount) - I.dblInterest) ELSE PD.dblTotal END
		FROM tblAPPaymentDetail PD
		INNER JOIN tblAPPayment P ON P.intPaymentId = PD.intPaymentId
		INNER JOIN tblAPBill B ON B.intBillId = PD.intBillId
		LEFT JOIN tblAPVoucherPaymentSchedule PS ON PS.intId = PD.intPayScheduleId
		LEFT JOIN tblAPImportPaidVouchersForPayment I ON I.strBillId = B.strBillId AND I.strVendorOrderNumber = ISNULL(PS.strPaymentScheduleNumber, B.strVendorOrderNumber)
		WHERE PD.intPaymentId = @createdPaymentId

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
		) PC
		WHERE P.intPaymentId = @createdPaymentId
		
		EXEC uspAPUpdateVoucherPayment @createdPaymentId, 1

		DELETE FROM #tmpMultiVouchersImport WHERE intIds = @intIds

		SET @createdPayments = @createdPayments + CASE WHEN @createdPayments = '' THEN '' ELSE ', ' END + CONVERT(VARCHAR(12), @createdPaymentId)
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