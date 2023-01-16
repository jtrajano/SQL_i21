CREATE PROCEDURE [dbo].[uspAPCreateVendorRefund]
	@voucherIds NVARCHAR(MAX),
	@invoiceIds NVARCHAR(MAX),
	@paymentDate DATETIME,
	@userId INT,
	@bankAccountId INT,
	@bankDepositCreated NVARCHAR(100) OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @transCount INT = @@TRANCOUNT;
DECLARE @defaultCurrency INT;
DECLARE @rateType INT;
DECLARE @ids AS Id;
DECLARE @invoices AS Id;
DECLARE @error NVARCHAR(250);
DECLARE @paymentCreated NVARCHAR(MAX);
DECLARE @batchIdUsed NVARCHAR(50);
DECLARE @log INT;
DECLARE @bankGLAccount INT;
DECLARE @paymentDetail PaymentIntegrationStagingTable;
DECLARE @paymentIds AS Id;
DECLARE @totalPaymentCreated INT;
DECLARE @totalPostedPayment INT;
DECLARE @totalFailedPayment INT;
DECLARE @successPostingPayment BIT;
DECLARE @postingError NVARCHAR(200);

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBillsId')) DROP TABLE #tmpBillsId
SELECT [intID] INTO #tmpBillsId FROM [dbo].fnGetRowsFromDelimitedValues(@voucherIds)

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvoicesId')) DROP TABLE #tmpInvoicesId
SELECT [intID] INTO #tmpInvoicesId FROM [dbo].fnGetRowsFromDelimitedValues(@invoiceIds)

IF OBJECT_ID('tempdb..#tmpVouchersForPay') IS NOT NULL DROP TABLE #tmpVouchersForPay
CREATE TABLE #tmpVouchersForPay
(
	intBillId INT, intInvoiceId INT, intPaymentId INT, intEntityVendorId INT, dblAmountPaid DECIMAL(18,2)
);

INSERT INTO @ids
SELECT intID FROM #tmpBillsId

INSERT INTO @invoices
SELECT intID FROM #tmpInvoicesId

SELECT A.* 
 INTO #tmpPaymentIntegration 
 FROM tblAPPaymentIntegrationTransaction A
 INNER JOIN @invoices B ON A.intInvoiceId = B.intId    
 WHERE A.ysnRefundFromPayment = 1

 --Remove those records that created from Create Deposit - Pay Voucher Details Screen
 DELETE A
 FROM tblAPPaymentIntegrationTransaction A
 INNER JOIN @invoices B ON A.intInvoiceId = B.intId
 WHERE A.ysnRefundFromPayment = 1

INSERT INTO #tmpVouchersForPay
SELECT
	payVouchers.intBillId
	,payVouchers.intInvoiceId
	,payVouchers.intPaymentId
	,payVouchers.intEntityVendorId
	,ABS(payVouchers.dblTempPayment) 
FROM dbo.fnAPPartitonPaymentOfVouchers(@ids, @invoices) payVouchers
WHERE payVouchers.dblTempPayment < 0

IF NOT EXISTS(SELECT 1 FROM #tmpVouchersForPay)
BEGIN
	RAISERROR('No negative payment transaction to process.', 16, 1);
	RETURN;
END

SELECT TOP 1 @defaultCurrency = intDefaultCurrencyId FROM tblSMCompanyPreference
SELECT TOP 1 @rateType = intAccountsReceivableRateTypeId FROM tblSMMultiCurrency
SET @paymentDate = ISNULL(NULLIF(@paymentDate, ''), CAST(GETDATE() AS DATE))

SELECT 
	TOP 1 @bankGLAccount = intGLAccountId
FROM tblCMBankAccount bank WHERE intBankAccountId = @bankAccountId

INSERT INTO @paymentDetail(
	[intId]
	,[strSourceTransaction]
	,[strReceivePaymentType]
	,[intSourceId]
	,[strSourceId]
	,[intPaymentId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[dtmDatePaid]
	,[intPaymentMethodId]
	,[strPaymentMethod]
	,[strPaymentInfo]
	,[strNotes]
	,[intAccountId]
	,[intBankAccountId]
	,[intWriteOffAccountId]
	,[dblAmountPaid]
	,[dblAmountDue]
	,[strPaymentOriginalId]
	,[ysnUseOriginalIdAsPaymentNumber]
	,[ysnApplytoBudget]
	,[ysnApplyOnAccount]
	,[ysnInvoicePrepayment]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[ysnAllowPrepayment]
	,[ysnPost]
	,[ysnRecap]
	,[intEntityId]
	,[intPaymentDetailId]
	,[intInvoiceId]
	,[intBillId]
	,[strTransactionNumber]
	,[intTermId]
	,[ysnApplyTermDiscount]
	,[dblDiscount]
	,[dblDiscountAvailable]
	,[dblInterest]
	,[dblPayment]
	,[strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]
	,[ysnAllowOverpayment]
	,[ysnFromAP]
)
SELECT 
	[intId]									=	RANK() OVER(ORDER BY intPaymentId, intEntityCustomerId)
	,trans.*
FROM (
	SELECT
		[strSourceTransaction]				=	'Voucher'
		,[strReceivePaymentType]			=	'Vendor Refund'
		,[intSourceId]						=	A.intBillId
		,[strSourceId]						=	A.strBillId
		,[intPaymentId]						=	NULL
		,[intEntityCustomerId]				=	A.intEntityVendorId
		,[intCompanyLocationId]				=	A.intShipToId
		,[intCurrencyId]					=	A.intCurrencyId
		,[dtmDatePaid]						=	@paymentDate
		,[intPaymentMethodId]				=	2
		,[strPaymentMethod]					=	'ACH'
		,[strPaymentInfo]					=	NULL
		,[strNotes]							=	NULL
		,[intAccountId]						=	@bankGLAccount
		,[intBankAccountId]					=	@bankAccountId
		,[intWriteOffAccountId]				=	NULL
		,[dblAmountPaid]					=	payVouchers.dblAmountPaid
		,[dblAmountDue]						=	(A.dblTotal - A.dblTempDiscount + A.dblTempInterest)
												- (A.dblTempPayment)
		,[strPaymentOriginalId]				=	'Payment Origin Id ' + CAST(RANK() OVER(ORDER BY payVouchers.intPaymentId, payVouchers.intEntityVendorId) AS NVARCHAR(100))
		,[ysnUseOriginalIdAsPaymentNumber]	=	0
		,[ysnApplytoBudget]					=	0
		,[ysnApplyOnAccount]				=	0
		,[ysnInvoicePrepayment]				=	0
		,[ysnImportedFromOrigin]			=	0
		,[ysnImportedAsPosted]				=	0
		,[ysnAllowPrepayment]				=	0
		,[ysnPost]							=	0
		,[ysnRecap]							=	0
		,[intEntityId]						=	@userId
		,[intPaymentDetailId]				=	NULL
		,[intInvoiceId]						=	NULL
		,[intBillId]						=	A.intBillId
		,[strTransactionNumber]				=	A.strBillId
		,[intTermId]						=	A.intTermsId
		,[ysnApplyTermDiscount]				=	0
		,[dblDiscount]						=	A.dblTempDiscount
		,[dblDiscountAvailable]				=	0
		,[dblInterest]						=	A.dblTempInterest
		,[dblPayment]						=	A.dblTempPayment
		,[strInvoiceReportNumber]			=	NULL
		,[intCurrencyExchangeRateTypeId]	=	CASE WHEN @defaultCurrency != A.intCurrencyId THEN @rateType ELSE NULL END
		,[intCurrencyExchangeRateId]		=	NULL
		,[dblCurrencyExchangeRate]			=	CASE WHEN @defaultCurrency != A.intCurrencyId THEN rateInfo.dblRate ELSE 1 END
		,[ysnAllowOverpayment]				=	0
		,[ysnFromAP]						=	1
	FROM tblAPBill A
	INNER JOIN #tmpVouchersForPay payVouchers ON A.intBillId = payVouchers.intBillId
	INNER JOIN tblSMCompanyLocation B ON A.intShipToId = B.intCompanyLocationId
	OUTER APPLY (
		SELECT TOP 1
			exchangeRateDetail.dblRate
		FROM tblSMCurrencyExchangeRate exchangeRate
		INNER JOIN tblSMCurrencyExchangeRateDetail exchangeRateDetail ON exchangeRate.intCurrencyExchangeRateId = exchangeRateDetail.intCurrencyExchangeRateId
		WHERE exchangeRateDetail.intRateTypeId = @rateType
		AND exchangeRate.intFromCurrencyId = A.intCurrencyId AND exchangeRate.intToCurrencyId = @defaultCurrency
		AND exchangeRateDetail.dtmValidFromDate <= @paymentDate
		ORDER BY exchangeRateDetail.dtmValidFromDate DESC
	) rateInfo
	UNION ALL
	SELECT
		[strSourceTransaction]				=	'Invoice'
		,[strReceivePaymentType]			=	'Vendor Refund'
		,[intSourceId]						=	A.intInvoiceId
		,[strSourceId]						=	A.strInvoiceNumber
		,[intPaymentId]						=	NULL
		,[intEntityCustomerId]				=	A.intEntityCustomerId
		,[intCompanyLocationId]				=	A.intCompanyLocationId
		,[intCurrencyId]					=	A.intCurrencyId
		,[dtmDatePaid]						=	@paymentDate
		,[intPaymentMethodId]				=	2
		,[strPaymentMethod]					=	'ACH'
		,[strPaymentInfo]					=	NULL
		,[strNotes]							=	NULL
		,[intAccountId]						=	@bankGLAccount
		,[intBankAccountId]					=	@bankAccountId
		,[intWriteOffAccountId]				=	NULL
		,[dblAmountPaid]					=	payVouchers.dblAmountPaid
		,[dblAmountDue]						=	(A.dblInvoiceTotal - C.dblTempDiscount + C.dblTempInterest) - (C.dblTempPayment) --(A.dblTotal - A.dblTempDiscount + A.dblTempInterest) - (A.dblTempPayment)
		,[strPaymentOriginalId]				=	'Payment Origin Id ' + CAST(RANK() OVER(ORDER BY payVouchers.intPaymentId, payVouchers.intEntityVendorId) AS NVARCHAR(100))
		,[ysnUseOriginalIdAsPaymentNumber]	=	0
		,[ysnApplytoBudget]					=	0
		,[ysnApplyOnAccount]				=	0
		,[ysnInvoicePrepayment]				=	0
		,[ysnImportedFromOrigin]			=	0
		,[ysnImportedAsPosted]				=	0
		,[ysnAllowPrepayment]				=	0
		,[ysnPost]							=	0
		,[ysnRecap]							=	0
		,[intEntityId]						=	@userId
		,[intPaymentDetailId]				=	NULL
		,[intInvoiceId]						=	A.intInvoiceId
		,[intBillId]						=	NULL
		,[strTransactionNumber]				=	A.strInvoiceNumber
		,[intTermId]						=	A.intTermId
		,[ysnApplyTermDiscount]				=	0
		,[dblDiscount]						=	 C.dblTempDiscount
		,[dblDiscountAvailable]				=	0
		,[dblInterest]					=	C.dblTempInterest
		,[dblPayment]						=	C.dblTempPayment
		,[strInvoiceReportNumber]			=	NULL
		,[intCurrencyExchangeRateTypeId]	=	CASE WHEN @defaultCurrency != A.intCurrencyId THEN @rateType ELSE NULL END
		,[intCurrencyExchangeRateId]		=	NULL
		,[dblCurrencyExchangeRate]			=	CASE WHEN @defaultCurrency != A.intCurrencyId THEN rateInfo.dblRate ELSE 1 END
		,[ysnAllowOverpayment]				=	0
		,[ysnFromAP]						=	0
	FROM tblARInvoice A
	INNER JOIN #tmpVouchersForPay payVouchers ON A.intInvoiceId = payVouchers.intInvoiceId
	INNER JOIN tblSMCompanyLocation B ON A.intCompanyLocationId = B.intCompanyLocationId
	INNER JOIN #tmpPaymentIntegration C ON A.intInvoiceId = C.intInvoiceId AND C.intInvoiceId IS NOT NULL
	OUTER APPLY (
		SELECT TOP 1
			exchangeRateDetail.dblRate
		FROM tblSMCurrencyExchangeRate exchangeRate
		INNER JOIN tblSMCurrencyExchangeRateDetail exchangeRateDetail ON exchangeRate.intCurrencyExchangeRateId = exchangeRateDetail.intCurrencyExchangeRateId
		WHERE exchangeRateDetail.intRateTypeId = @rateType
		AND exchangeRate.intFromCurrencyId = A.intCurrencyId AND exchangeRate.intToCurrencyId = @defaultCurrency
		AND exchangeRateDetail.dtmValidFromDate <= @paymentDate
		ORDER BY exchangeRateDetail.dtmValidFromDate DESC
	) rateInfo
) trans

IF @transCount = 0 BEGIN TRANSACTION

EXEC uspARProcessPayments @PaymentEntries = @paymentDetail, @UserId = @userId, @GroupingOption = 1, @RaiseError = 1, @ErrorMessage = @error OUTPUT, @LogId = @log OUTPUT

IF @error IS NOT NULL
BEGIN
	RAISERROR(@error, 16, 1);
	RETURN;
END

INSERT INTO @paymentIds
SELECT
	DISTINCT intPaymentId
FROM tblARPaymentIntegrationLogDetail
WHERE intIntegrationLogId = @log
AND intPaymentId IS NOT NULL
AND ysnHeader = 1

SELECT @totalPaymentCreated = COUNT(*) FROM @paymentIds

IF @totalPaymentCreated > 0
BEGIN
	--UPDATE A
	--	SET A.strReceivePaymentType = 'Vendor Refund'
	--FROM tblARPayment A
	--INNER JOIN @paymentIds B ON A.intPaymentId = B.intId

	SELECT
		@paymentCreated = COALESCE(@paymentCreated + ',', '') +  CONVERT(VARCHAR(12),intId)
	FROM @paymentIds

	--POST AR PAYMENT CREATED
	EXEC uspARPostPayment 
		@batchId = NULL,
		@post = 1,
		@recap = 0,
		@param = @paymentCreated,
		@userId = @userId,
		@successfulCount = @totalPostedPayment OUTPUT,
		@batchIdUsed = @batchIdUsed OUTPUT,
		@invalidCount = @totalFailedPayment  OUTPUT,
		@success = @successPostingPayment OUTPUT

	IF @successPostingPayment = 1 AND @totalPostedPayment = @totalPaymentCreated
	BEGIN
		EXEC uspARProcessACHPayments @strPaymentIds = @paymentCreated, @intBankAccountId = @bankAccountId, @intUserId = @userId, @strNewTransactionId = @bankDepositCreated OUTPUT
		IF @bankDepositCreated IS NOT NULL
		BEGIN
			DELETE A
			FROM tblAPPaymentIntegrationTransaction A
			INNER JOIN #tmpInvoicesId B ON A.intInvoiceId = B.intId
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1
			@postingError = strMessage
		FROM tblARPostResult
		WHERE strBatchNumber = @batchIdUsed
		AND strMessage NOT LIKE '%success%'
		RAISERROR(@postingError, 16, 1);
		RETURN;
	END
END
ELSE
BEGIN
	RAISERROR('No receive payment created.', 16, 1);
	RETURN;
END

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