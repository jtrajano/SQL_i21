CREATE PROCEDURE [dbo].[uspAPCreateAndPostPaymentFromVouchers]
	@userId INT,
	@recap BIT,
	@bankAccount INT,
	@paymentMethod INT,
	@datePaid DATETIME,
	@voucherIds NVARCHAR(MAX),
	@sort NVARCHAR(500),
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

	BEGIN TRY

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
	DECLARE @script NVARCHAR(MAX);
	DECLARE @clientSort NVARCHAR(500) = @sort;

	IF OBJECT_ID('tempdb..#tmpMultiVouchers') IS NOT NULL DROP TABLE #tmpMultiVouchers
	CREATE TABLE #tmpMultiVouchers
	(
		intBillId INT,
		intPayToAddressId INT,
		intEntityVendorId INT,
		intPaymentId INT,
		intPartitionId INT,
		ysnLienExists BIT,
		dblAmountPaid DECIMAL(18,2),
		dblWithheld DECIMAL(18,2),
		strPaymentInfo NVARCHAR(50),
		strPayee NVARCHAR (300)   COLLATE Latin1_General_CI_AS NULL,
		intSortId INT IDENTITY(1,1)
	);

	IF OBJECT_ID('tempdb..#tmpMultiVouchersCreatedPayment') IS NOT NULL DROP TABLE #tmpMultiVouchersCreatedPayment
	CREATE TABLE #tmpMultiVouchersCreatedPayment(intPartitionId INT, intCreatePaymentId INT);

	IF OBJECT_ID('tempdb..#tmpMultiVouchersAndPayment') IS NOT NULL DROP TABLE #tmpMultiVouchersAndPayment
	CREATE TABLE #tmpMultiVouchersAndPayment(intBillId INT, intCreatePaymentId INT);

	IF OBJECT_ID('tempdb..#tmpPayableInvalidData') IS NOT NULL DROP TABLE  #tmpPayableInvalidData
	CREATE TABLE #tmpPayableInvalidData (
		[strError] [NVARCHAR](1000),
		[strTransactionType] [NVARCHAR](50),
		[strTransactionId] [NVARCHAR](50),
		[intTransactionId] INT
	);

	INSERT INTO @ids
	--USE DISTINCT TO REMOVE DUPLICATE BILL ID FOR SCHEDULE PAYMENT
	SELECT DISTINCT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

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

	IF OBJECT_ID('tempdb..#tmpPartitionedVouchers') IS NOT NULL DROP TABLE  #tmpPartitionedVouchers
	SELECT 
		result.* 
		,voucher.ysnReadyForPayment
		,vendor.strVendorId
		,entity.strName
		,payTo.strCheckPayeeName
		,voucher.dtmDueDate
		,voucher.strBillId
		,voucher.strVendorOrderNumber
		,commodity.strCommodityCode
		,term.strTerm
		,voucher.dblTotal
		,voucher.dblTempDiscount
		,voucher.dblTempInterest
		,voucher.dblAmountDue
		,payMethod.strPaymentMethod
		,ysnLienExists = CAST(CASE WHEN lienInfo.strPayee IS NULL THEN 0 ELSE 1 END AS BIT)
		,strPayee = payTo.strCheckPayeeName + ' ' + ISNULL(lienInfo.strPayee,'') 
					+ CHAR(13) + CHAR(10) + ISNULL(dbo.fnConvertToFullAddress(payTo.strAddress, payTo.strCity, payTo.strState, payTo.strZipCode),'')
	INTO #tmpPartitionedVouchers 
	FROM dbo.fnAPPartitonPaymentOfVouchers(@ids) result
	INNER JOIN tblAPBill voucher ON result.intBillId = voucher.intBillId
	INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
		ON vendor.intEntityId = voucher.intEntityVendorId
	LEFT JOIN tblEMEntityLocation payTo ON voucher.intPayToAddressId = payTo.intEntityLocationId
	LEFT JOIN tblSMTerm term ON voucher.intTermsId = term.intTermID
	LEFT JOIN vyuAPVoucherCommodity commodity ON voucher.intBillId = commodity.intBillId
	LEFT JOIN tblSMPaymentMethod payMethod ON vendor.intPaymentMethodId = payMethod.intPaymentMethodID 
	OUTER APPLY (
		SELECT STUFF((
			SELECT DISTINCT ' and ' + strName
			FROM tblAPVendorLien LIEN
			INNER JOIN tblEMEntity ENT ON LIEN.intEntityLienId = ENT.intEntityId
			WHERE 
				LIEN.intEntityVendorId = vendor.intEntityId AND LIEN.ysnActive = 1 AND @datePaid BETWEEN LIEN.dtmStartDate AND LIEN.dtmEndDate
			AND ISNULL(LIEN.intCommodityId,-1) IN (SELECT ISNULL(intCommodityId,-1) FROM
										vyuAPVoucherCommodity VC 
										WHERE voucher.intBillId = VC.intBillId)
			FOR XML PATH('')), 
			1, 1, '') AS strPayee
	) lienInfo

	--ALL TRANSACTIONS THAT VENDOR IS NOT ONE BILL PER PAYMENT
	SET @script = 
	'
	INSERT INTO #tmpMultiVouchers
	(
		intBillId,
		intPayToAddressId,
		intEntityVendorId,
		intPaymentId,
		dblAmountPaid,
		dblWithheld,
		strPaymentInfo,
		strPayee,
		ysnLienExists,
		intPartitionId
	)
	SELECT
		intBillId, intPayToAddressId, intEntityVendorId, intPaymentId, dblTempPayment, dblTempWithheld, strTempPaymentInfo, strPayee, ysnLienExists, intPartitionId
	FROM
	(
		SELECT 
			* 
		FROM 
		#tmpPartitionedVouchers
	) sortedVouchers ORDER BY ' +  CASE WHEN @clientSort = 'undefined' THEN  'strBillId ASC' ELSE @clientSort END
	
	EXECUTE sp_executesql @script
	
	DECLARE @transCount INT = @@TRANCOUNT;
	IF @transCount = 0 BEGIN TRANSACTION
	--SELECT * FROM #tmpMultiVouchers
	-- --INVOICE

	IF EXISTS(SELECT TOP 1 1 FROM #tmpMultiVouchers)
	BEGIN
		--lock the starting number so we would not clash with the same starting number
		--if use location config is to be implemented, ask the SM dev to provide a way to generate by batch
		SELECT
			@payStartingNumber = intNumber
			,@payPrefix = strPrefix
		FROM tblSMStartingNumber
		WHERE intStartingNumberId = 8 AND strTransactionType = 'Payable'

		--update inconcurrency to lock the record by sql
		UPDATE A
			SET A.intConcurrencyId = A.intConcurrencyId + 1
		FROM tblSMStartingNumber A
		WHERE intStartingNumberId = 8 AND strTransactionType = 'Payable'

		IF OBJECT_ID('dbo.[UK_dbo.tblAPPayment_strPaymentRecordNum]', 'UQ') IS NOT NULL 
		BEGIN
			ALTER TABLE tblAPPayment DROP CONSTRAINT [UK_dbo.tblAPPayment_strPaymentRecordNum];
		END

		MERGE INTO tblAPPayment AS destination
		USING
		(
			SELECT TOP 100 PERCENT
				[intAccountId]						= 	@bankGLAccountId,
				[intBankAccountId]					= 	@bankAccount,
				[intPaymentMethodId]				= 	CASE WHEN (vouchersPay.dblAmountPaid - vouchersPay.dblWithheld) = 0 
														THEN 3 --Debit Memos and Payments
														ELSE @paymentMethod END,
				[intPayToAddressId]					= 	vouchersPay.intPayToAddressId,
				[intCompanyLocationId]  			= 	@paymentCompanyLocation,
				[intCurrencyId]						= 	@currency,
				[intEntityVendorId]					= 	vouchersPay.intEntityVendorId,
				[intCurrencyExchangeRateTypeId]		=	@rateType,
				[strPaymentInfo]					= 	vouchersPay.strPaymentInfo,
				[strPaymentRecordNum]				= 	NULL,
				[strNotes]							= 	NULL,
				[strPayee]							= 	vouchersPay.strPayee,
				[strOverridePayee]					= 	NULL,
				[dtmDatePaid]						= 	@datePaid,
				[dblAmountPaid]						= 	vouchersPay.dblAmountPaid - vouchersPay.dblWithheld,
				[dblUnapplied]						= 	0,
				[dblExchangeRate]					= 	@rate,
				[ysnPosted]							= 	0,
				[ysnLienExists]						= 	vouchersPay.ysnLienExists,
				[ysnOverrideCheckPayee]				= 	0,
				[dblWithheld]						= 	vouchersPay.dblWithheld,
				[intEntityId]						= 	@currentUser,
				[intConcurrencyId]					= 	0,
				[strBatchId]						=	@batchId,
				[intPaymentId]						=	vouchersPay.intPaymentId,
				[intPartitionId]					=	vouchersPay.intPartitionId
				-- [strBillIds]						=	STUFF((
				-- 											SELECT ',' + CAST(tbl.intBillId AS NVARCHAR)
				-- 											FROM #tmpMultiVouchers tbl
				-- 											WHERE tbl.intBillId = vouchersPay.intBillId
				-- 											FOR XML PATH('')),1,1,''
				-- 										)
			FROM #tmpMultiVouchers vouchersPay
			GROUP BY 
				vouchersPay.intPaymentId,
				vouchersPay.dblAmountPaid,
				vouchersPay.intPayToAddressId,
				vouchersPay.intEntityVendorId,
				vouchersPay.strPaymentInfo,
				vouchersPay.strPayee,
				vouchersPay.dblWithheld,
				vouchersPay.ysnLienExists,
				vouchersPay.intPartitionId
			ORDER BY MIN(vouchersPay.intSortId)
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
			[strPayee],
			[strOverridePayee],
			[dtmDatePaid],
			[dblAmountPaid],
			[dblUnapplied],
			[dblExchangeRate],
			[ysnPosted],
			[ysnLienExists],
			[ysnOverrideCheckPayee],
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
			[strPayee],
			[strOverridePayee],
			[dtmDatePaid],
			[dblAmountPaid],
			[dblUnapplied],
			[dblExchangeRate],
			[ysnPosted],
			[ysnLienExists],
			[ysnOverrideCheckPayee],
			[dblWithheld],
			[intEntityId],
			[intConcurrencyId],
			[strBatchId]
		)
		OUTPUT SourceData.intPartitionId, inserted.intPaymentId INTO #tmpMultiVouchersCreatedPayment;

		--UPDATE STARTING NUMBER
		UPDATE pay
			SET 
				strPaymentRecordNum = @payPrefix + CAST(@payStartingNumber - 1 AS NVARCHAR)
				-- ,strPayee = dbo.fnAPGetCheckPayee(@payPrefix + CAST(@payStartingNumber - 1 AS NVARCHAR), pay.dtmDatePaid , pay.intEntityVendorId, pay.intPayToAddressId)
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
		INNER JOIN #tmpMultiVouchers vouchers ON tmpPay.intPartitionId = vouchers.intPartitionId 

		INSERT INTO tblAPPaymentDetail(
			[intPaymentId],
			[intBillId],
			[intAccountId],
			[dblDiscount],
			[dblWithheld],
			[dblAmountDue],
			[dblPayment],
			[dblInterest],
			[dblTotal],
			[ysnOffset],
			[intPayScheduleId])
		SELECT 
			[intPaymentId]		=	tmpVoucherAndPay.intCreatePaymentId,
			[intBillId]			=	tmp.intBillId,
			[intAccountId]		=	CASE WHEN vouchers.ysnPrepayHasPayment = 0 AND vouchers.intTransactionType IN (2, 13) THEN details.intAccountId ELSE vouchers.intAccountId END,
			[dblDiscount]		=	ISNULL(paySched.dblDiscount, vouchers.dblTempDiscount),
			[dblWithheld]		=	vouchers.dblTempWithheld,
			[dblAmountDue]		=	ISNULL(paySched.dblPayment,vouchers.dblAmountDue)
									* (CASE WHEN vouchers.intTransactionType IN (3) OR (vouchers.intTransactionType IN (2, 13) AND vouchers.ysnPrepayHasPayment = 1) THEN -1 ELSE 1 END),
			[dblPayment]		=	ISNULL(paySched.dblPayment - paySched.dblDiscount, vouchers.dblTempPayment)
									* (CASE WHEN vouchers.intTransactionType IN (3) OR (vouchers.intTransactionType IN (2, 13) AND vouchers.ysnPrepayHasPayment = 1) THEN -1 ELSE 1 END),
			[dblInterest]		=	vouchers.dblTempInterest,
			[dblTotal]			=	ISNULL(paySched.dblPayment, vouchers.dblTotal)
									* (CASE WHEN vouchers.intTransactionType IN (3) OR (vouchers.intTransactionType IN (2, 13) AND vouchers.ysnPrepayHasPayment = 1) THEN -1 ELSE 1 END),
			[ysnOffset]			=	CASE WHEN vouchers.intTransactionType IN (1, 14) THEN 0
									ELSE
										(
											CASE WHEN vouchers.intTransactionType IN (2, 13) AND vouchers.ysnPrepayHasPayment = 0
												THEN 0
											ELSE 1
											END
										)
									END,
			[intPayScheduleId]	=	paySched.intId
		FROM tblAPBill vouchers
		INNER JOIN #tmpMultiVouchers tmp ON vouchers.intBillId = tmp.intBillId
		INNER JOIN #tmpMultiVouchersAndPayment tmpVoucherAndPay ON tmp.intBillId = tmpVoucherAndPay.intBillId
		CROSS APPLY
		(
			SELECT TOP 1 intAccountId, intBillId FROM tblAPBillDetail dtls WHERE dtls.intBillId = vouchers.intBillId
		) details
		LEFT JOIN tblAPVoucherPaymentSchedule paySched
			ON vouchers.intBillId = paySched.intBillId AND paySched.ysnReadyForPayment = 1 AND paySched.ysnPaid = 0
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
		DECLARE @spError NVARCHAR(100) = ERROR_MESSAGE()
		SELECT TOP 1
			@postError = strMessage
		FROM tblAPPostResult
		WHERE strBatchNumber = @batchIdUsed;

		SET @postError = ISNULL(@postError, @spError)
		IF @recap = 0
		BEGIN
			RAISERROR(@postError, 16, 1);
		END
		RETURN;
	END CATCH

	--IF RECAP ONLY, DELETE CREATED PAYMENT RECORDS
	IF @recap = 1
	BEGIN
		DELETE A
		FROM tblAPPayment A
		INNER JOIN #tmpMultiVouchersCreatedPayment B ON A.intPaymentId = B.intCreatePaymentId
		GOTO COMPLETEPROCESS;
	END
	ELSE
	BEGIN
		--IF SUCCESS POSTING BUT NO SUCCESSFUL COUNT, DELETE CREATED PAYMENT
		IF @unpostedCount > 0
		BEGIN
			GOTO DELETEUNPOSTEDPAYMENT;
		END
		ELSE GOTO COMPLETEPROCESS;
	END

	DELETEUNPOSTEDPAYMENT:
	DELETE A
	FROM tblAPPayment A
	INNER JOIN #tmpMultiVouchersCreatedPayment B ON A.intPaymentId = B.intCreatePaymentId
	WHERE A.ysnPosted = 0

	IF @postedCount > 0 GOTO COMPLETEPROCESS;
	ELSE GOTO DONE;

	COMPLETEPROCESS:
	--UPDATE BATCH PAY intNumber
	UPDATE A
		--include the unposted count here of failed on post, as it is part of the starting number that were used
		SET A.intNumber = A.intNumber + @postedCount + @unpostedCount 
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

	--UPDATE dblPaymentTemp and ysnInPayment
	DECLARE @paymentIds AS NVARCHAR(MAX);
	SELECT @paymentIds =  COALESCE(@paymentIds + ', ', '') + CONVERT(VARCHAR(12), P.intPaymentId)
	FROM tblAPPayment P
	INNER JOIN #tmpMultiVouchersCreatedPayment CP ON CP.intCreatePaymentId = P.intPaymentId
	WHERE P.ysnPosted = 1

	IF @paymentIds <> '' OR @paymentIds IS NOT NULL EXEC uspAPUpdateVoucherPayment @paymentIds, 1

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