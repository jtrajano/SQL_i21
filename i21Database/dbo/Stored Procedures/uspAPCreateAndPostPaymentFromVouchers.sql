CREATE PROCEDURE [dbo].[uspAPCreateAndPostPaymentFromVouchers]
	@userId INT,
	@recap BIT,
	@bankAccount INT,
	@paymentMethod INT,
	@datePaid DATETIME,
	@voucherIds NVARCHAR(MAX),
	@batchPaymentId NVARCHAR(255) OUTPUT,
	@postedCount INT OUTPUT,
	@unpostedCount INT OUTPUT,
	@batchIdUsed AS NVARCHAR(40) = NULL OUTPUT
AS

BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @currentUser INT = @userId;
	DECLARE @functionalCurrency INT;
	DECLARE @foreignCurrency INT;
	DECLARE @rateType INT;
	DECLARE @withHoldAccount INT = NULL;
	DECLARE @withholdPercent DECIMAL(18,6);
	DECLARE @paymentCompanyLocation INT;
	DECLARE @bankGLAccountId INT;
	DECLARE @rate DECIMAL(18,6) = 1;
	DECLARE @currency INT;
	DECLARE @vendorEnableWithhold BIT = 0;
	DECLARE @createdPaymentIds AS NVARCHAR(MAX);
	DECLARE @batchId NVARCHAR(255) = NEWID();
	DECLARE @vendorWithhold NVARCHAR(500);
	DECLARE @totalInvalid INT;
	DECLARE @payStartingNumber INT;
	DECLARE @postError NVARCHAR(500);
	DECLARE @payPrefix NVARCHAR(50);
	DECLARE @ids AS Id;
	DECLARE @successPostPayment BIT;
	DECLARE @totalUnpostedPayment INT = 0;
	DECLARE @totalPostedPayment INT = 0;

	IF OBJECT_ID('tempdb..#tmpMultiVouchers') IS NOT NULL DROP TABLE #tmpMultiVouchers
	CREATE TABLE #tmpMultiVouchers(intBillId INT,
		 intPayToAddressId INT,
		 intEntityVendorId INT,
		 intPaymentId INT,
		 dblAmountPaid DECIMAL(18,2),
		 dblWithheld DECIMAL(18,2),
		 strPaymentInfo NVARCHAR(50));

	IF OBJECT_ID('tempdb..#tmpMultiVouchersCreatedPayment') IS NOT NULL DROP TABLE #tmpMultiVouchersCreatedPayment
	CREATE TABLE #tmpMultiVouchersCreatedPayment(intPaymentId INT, intCreatePaymentId INT);

	IF OBJECT_ID('tempdb..#tmpMultiVouchersAndPayment') IS NOT NULL DROP TABLE #tmpMultiVouchersAndPayment
	CREATE TABLE #tmpMultiVouchersAndPayment(intBillId INT, intCreatePaymentId INT);

	IF OBJECT_ID('tempdb.. #tmpPayableInvalidData') IS NOT NULL DROP TABLE  #tmpPayableInvalidData
	CREATE TABLE #tmpPayableInvalidData (
		[strError] [NVARCHAR](1000),
		[strTransactionType] [NVARCHAR](50),
		[strTransactionId] [NVARCHAR](50),
		[intTransactionId] INT
	);

	INSERT INTO @ids
	SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

	SELECT TOP 1
		@currency = bank.intCurrencyId
		,@bankGLAccountId = bank.intGLAccountId
	FROM tblCMBankAccount bank
	WHERE bank.intBankAccountId = @bankAccount

	SELECT TOP 1 
		@functionalCurrency = intDefaultCurrencyId 
		,@foreignCurrency = CASE WHEN intDefaultCurrencyId != @currency THEN 1 ELSE 0 END
	FROM tblSMCompanyPreference

	IF @foreignCurrency = 1
	BEGIN
		SELECT TOP 1
			@rateType = intAccountsPayableRateTypeId
		FROM tblSMMultiCurrency
		 
		SELECT TOP 1
			@rate = exchangeRateDetail.dblRate
		FROM tblSMCurrencyExchangeRate exchangeRate
		INNER JOIN tblSMCurrencyExchangeRateDetail exchangeRateDetail 
				ON exchangeRate.intCurrencyExchangeRateId = exchangeRateDetail.intCurrencyExchangeRateId
		WHERE exchangeRateDetail.intRateTypeId = @rateType
		AND exchangeRate.intFromCurrencyId = @currency AND exchangeRate.intToCurrencyId = @functionalCurrency
		AND exchangeRateDetail.dtmValidFromDate <= GETDATE()
		ORDER BY exchangeRateDetail.dtmValidFromDate DESC

		IF @rateType IS NULL 
		BEGIN
			RAISERROR('PAYVOUCHERNOEXCHANGERATETYPE', 16, 1);
			RETURN;
		END
		
		IF @rate IS NULL OR @rate < 0
		BEGIN
			RAISERROR('PAYVOUCHERNOEXCHANGERATE', 16, 1);
			RETURN;
		END
	END

	--VALIDATION
	--Make sure there is user to use
	IF @currentUser IS NULL
	BEGIN
		RAISERROR('User is required.', 16, 1);
		RETURN;
	END

	SELECT
		@paymentCompanyLocation = intCompanyLocationId
	FROM tblSMUserSecurity
	WHERE intEntityId = @currentUser;

	SELECT TOP 1
		@withHoldAccount = B.intWithholdAccountId
		,@withholdPercent = B.dblWithholdPercent
		,@vendorEnableWithhold = vendor.ysnWithholding
		,@vendorWithhold = vendor.strVendorId
	FROM tblAPBill A 
	INNER JOIN @ids ids ON A.intBillId = ids.intId
	INNER JOIN tblSMCompanyLocation B ON A.intShipToId = B.intCompanyLocationId
	INNER JOIN tblAPVendor vendor ON A.intEntityVendorId = vendor.intEntityId
	WHERE vendor.ysnWithholding = 1 AND B.intWithholdAccountId IS NULL

	IF @withHoldAccount IS NULL AND @vendorEnableWithhold = 1
	BEGIN
		SET @vendorWithhold = @vendorWithhold + ' vendor enables withholding but there is no setup of withhold account.';
		RAISERROR(@vendorWithhold,16,1);
		RETURN;
	END

	BEGIN TRY

	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION

	--ALL TRANSACTIONS THAT VENDOR IS NOT ONE BILL PER PAYMENT
	INSERT INTO #tmpMultiVouchers(intBillId, intPayToAddressId, intEntityVendorId, intPaymentId, dblAmountPaid, dblWithheld, strPaymentInfo)
	SELECT * FROM dbo.fnAPPartitonPaymentOfVouchers(@ids) result
	
	-- --INVOICE

	IF EXISTS(SELECT TOP 1 1 FROM #tmpMultiVouchers)
	BEGIN
		--lock the starting number so we would not clash with the same starting number
		--if use location config is to be implemented, ask the SM dev to provide a way to generate by batch
		SELECT
			@payStartingNumber = intNumber
			,@payPrefix = strPrefix
		FROM tblSMStartingNumber
		WITH (UPDLOCK, ROWLOCK)
		WHERE intStartingNumberId = 8 AND strTransactionType = 'Payable'

		IF OBJECT_ID('dbo.[UK_dbo.tblAPPayment_strPaymentRecordNum]', 'UQ') IS NOT NULL 
		BEGIN
			ALTER TABLE tblAPPayment DROP CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum];
		END

		MERGE INTO tblAPPayment AS destination
		USING
		(
			SELECT
				[intAccountId]						= 	@bankGLAccountId,
				[intBankAccountId]					= 	@bankAccount,
				[intPaymentMethodId]				= 	@paymentMethod,
				[intPayToAddressId]					= 	vouchersPay.intPayToAddressId,
				[intCompanyLocationId]  			= 	@paymentCompanyLocation,
				[intCurrencyId]						= 	@currency,
				[intEntityVendorId]					= 	vouchersPay.intEntityVendorId,
				[intCurrencyExchangeRateTypeId]		=	@rateType,
				[strPaymentInfo]					= 	vouchersPay.strPaymentInfo,
				[strPaymentRecordNum]				= 	NULL,
				[strNotes]							= 	NULL,
				[dtmDatePaid]						= 	@datePaid,
				[dblAmountPaid]						= 	vouchersPay.dblAmountPaid - vouchersPay.dblWithheld,
				[dblUnapplied]						= 	0,
				[dblExchangeRate]					= 	@rate,
				[ysnPosted]							= 	0,
				[dblWithheld]						= 	vouchersPay.dblWithheld,
				[intEntityId]						= 	@currentUser,
				[intConcurrencyId]					= 	0,
				[strBatchId]						=	@batchId,
				[intPaymentId]						=	vouchersPay.intPaymentId
				-- [strBillIds]						=	STUFF((
				-- 											SELECT ',' + CAST(tbl.intBillId AS NVARCHAR)
				-- 											FROM #tmpMultiVouchers tbl
				-- 											WHERE tbl.intBillId = vouchersPay.intBillId
				-- 											FOR XML PATH('')),1,1,''
				-- 										)
			FROM #tmpMultiVouchers vouchersPay
			GROUP BY vouchersPay.intPaymentId,
			vouchersPay.dblAmountPaid,
			vouchersPay.intPayToAddressId,
			vouchersPay.intEntityVendorId,
			vouchersPay.strPaymentInfo,
			vouchersPay.dblWithheld
		) AS SourceData
		ON (1=0)
		WHEN NOT MATCHED THEN
		INSERT
		(
			[intAccountId],
			[intBankAccountId],
			[intPaymentMethodId],
			[intPayToAddressId],
			[intCompanyLocationId],
			[intCurrencyId],
			[intEntityVendorId],
			[intCurrencyExchangeRateTypeId],
			[strPaymentInfo],
			[strPaymentRecordNum],
			[strNotes],
			[dtmDatePaid],
			[dblAmountPaid],
			[dblUnapplied],
			[dblExchangeRate],
			[ysnPosted],
			[dblWithheld],
			[intEntityId],
			[intConcurrencyId],
			[strBatchId]
		)
		VALUES(
			[intAccountId],
			[intBankAccountId],
			[intPaymentMethodId],
			[intPayToAddressId],
			[intCompanyLocationId],
			[intCurrencyId],
			[intEntityVendorId],
			[intCurrencyExchangeRateTypeId],
			[strPaymentInfo],
			[strPaymentRecordNum],
			[strNotes],
			[dtmDatePaid],
			[dblAmountPaid],
			[dblUnapplied],
			[dblExchangeRate],
			[ysnPosted],
			[dblWithheld],
			[intEntityId],
			[intConcurrencyId],
			[strBatchId]
		)
		OUTPUT SourceData.intPaymentId, inserted.intPaymentId INTO #tmpMultiVouchersCreatedPayment;

		--UPDATE STARTING NUMBER
		UPDATE pay
			SET 
				strPaymentRecordNum = @payPrefix + CAST(@payStartingNumber AS NVARCHAR)
				,@payStartingNumber = @payStartingNumber + 1
		FROM tblAPPayment pay
		INNER JOIN #tmpMultiVouchersCreatedPayment createdPay ON pay.intPaymentId = createdPay.intCreatePaymentId

		IF OBJECT_ID('dbo.[UK_dbo.tblAPPayment_strPaymentRecordNum]', 'UQ') IS NULL 
		BEGIN
			ALTER TABLE tblAPPayment ADD CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum] UNIQUE (strPaymentRecordNum);
		END

		INSERT INTO #tmpMultiVouchersAndPayment(intBillId, intCreatePaymentId)
		SELECT 
			vouchers.intBillId
			,tmpPay.intCreatePaymentId
		FROM #tmpMultiVouchersCreatedPayment tmpPay
		INNER JOIN #tmpMultiVouchers vouchers ON tmpPay.intPaymentId = vouchers.intPaymentId
		-- CROSS APPLY dbo.fnGetRowsFromDelimitedValues(tmpPay.strBillIds) ids
		
		INSERT INTO tblAPPaymentDetail(
			[intPaymentId],
			[intBillId],
			[intAccountId],
			[dblDiscount],
			[dblWithheld],
			[dblAmountDue],
			[dblPayment],
			[dblInterest],
			[dblTotal])
		SELECT 
			[intPaymentId]		=	tmpVoucherAndPay.intCreatePaymentId,
			[intBillId]			=	tmp.intBillId,
			[intAccountId]		=	vouchers.intAccountId,
			[dblDiscount]		=	vouchers.dblTempDiscount,
			[dblWithheld]		=	vouchers.dblTempWithheld,
			[dblAmountDue]		=	vouchers.dblAmountDue,
			[dblPayment]		=	vouchers.dblTempPayment,
			[dblInterest]		=	vouchers.dblTempInterest,
			[dblTotal]			=	vouchers.dblTotal
		FROM tblAPBill vouchers
		INNER JOIN #tmpMultiVouchers tmp ON vouchers.intBillId = tmp.intBillId
		INNER JOIN #tmpMultiVouchersAndPayment tmpVoucherAndPay ON tmp.intBillId = tmpVoucherAndPay.intBillId
	END

	SET @batchPaymentId = @batchId;

	SELECT @createdPaymentIds = COALESCE(@createdPaymentIds + ',', '') +  CONVERT(VARCHAR(12),intCreatePaymentId)
	FROM #tmpMultiVouchersCreatedPayment
	ORDER BY intCreatePaymentId

	BEGIN TRY
		EXEC uspAPPostPayment @userId = @userId,
				@recap = @recap,
				@post = 1,
				@param = @createdPaymentIds,
				@success = @successPostPayment OUT,
				@batchIdUsed = @batchIdUsed OUT,
				@successfulCount = @totalPostedPayment OUT,
				@invalidCount = @totalUnpostedPayment OUT

		SET @postedCount = @totalPostedPayment;
		SET @unpostedCount = @totalUnpostedPayment;
	END TRY
	BEGIN CATCH
		SELECT TOP 1
			@postError = strMessage
		FROM tblAPPostResult
		WHERE strBatchNumber = @batchIdUsed;
		RAISERROR(@postError, 16, 1);
		RETURN;
	END CATCH

	--IF RECAP ONLY DELETE CREATED PAYMENT RECORDS
	IF @recap = 1
	BEGIN
		GOTO DELETECREATEDPAYMENT;
	END
	ELSE
	BEGIN
		--IF SUCCESS POSTING BUT NO SUCCESSFUL COUNT, DELETE CREATED PAYMENT
		IF @successPostPayment = 1 AND @totalPostedPayment = 0 
		BEGIN
			GOTO DELETECREATEDPAYMENT;
		END
		ELSE GOTO COMPLETEPROCESS;
	END

	DELETECREATEDPAYMENT:
	DELETE A
	FROM tblAPPayment A
	INNER JOIN #tmpMultiVouchersCreatedPayment B ON A.intPaymentId = B.intCreatePaymentId
	GOTO DONE;

	COMPLETEPROCESS:
	--UPDATE BATCH PAY intNumber
	UPDATE A
		SET A.intNumber = A.intNumber + @postedCount
	FROM tblSMStartingNumber A
	WHERE intStartingNumberId = 8 AND strTransactionType = 'Payable'

	--UPDATE ysnReadyForPayment for those successful post
	UPDATE voucher
		SET voucher.ysnReadyForPayment = 0,
			voucher.dblTempPayment = 0,
			voucher.dblTempWithheld = 0,
			voucher.strTempPaymentInfo = null,
			voucher.dblTempInterest = 0,
			voucher.dblTempDiscount = 0
	FROM tblAPBill voucher
	INNER JOIN tblAPPaymentDetail payDetail ON voucher.intBillId = payDetail.intBillId
	INNER JOIN  tblAPPayment A ON payDetail.intPaymentId = A.intPaymentId
	INNER JOIN #tmpMultiVouchersCreatedPayment createdPay ON A.intPaymentId = createdPay.intCreatePaymentId
	INNER JOIN tblAPPostResult B ON A.intPaymentId = B.intTransactionId 
		AND A.strPaymentRecordNum = B.strTransactionId
	WHERE B.strBatchNumber = @batchIdUsed AND B.strMessage LIKE '%successfully%'
	AND voucher.ysnReadyForPayment = 1

	DONE:
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
END