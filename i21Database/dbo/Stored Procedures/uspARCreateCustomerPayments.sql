CREATE PROCEDURE [dbo].[uspARCreateCustomerPayments]
	 @PaymentEntries	PaymentIntegrationStagingTable	READONLY
	,@IntegrationLogId	INT					= NULL
	,@GroupingOption	INT					= 0
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal		NUMERIC(18, 6)	= 0.000000
		,@DateNow			DATETIME		= CAST(GETDATE() AS DATE)
		,@DefaultCurrency	INT				= NULL

SET @DefaultCurrency = ISNULL((SELECT TOP 1 SMCP.[intDefaultCurrencyId] FROM tblSMCompanyPreference SMCP INNER JOIN (SELECT [intCurrencyID] FROM tblSMCurrency) SMC ON SMCP.[intDefaultCurrencyId] = SMC.[intCurrencyID] WHERE SMCP.[intDefaultCurrencyId] IS NOT NULL),0)


DECLARE @PaymentsToGenerate AS PaymentIntegrationStagingTable
DELETE FROM @PaymentsToGenerate
INSERT INTO @PaymentsToGenerate (
	 [intId]
	,[strSourceTransaction]
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
)
SELECT
	 [intId]								= [intId]
	,[strSourceTransaction]					= [strSourceTransaction]
	,[intSourceId]							= [intSourceId]
	,[strSourceId]							= [strSourceId]
	,[intPaymentId]							= [intPaymentId]
	,[intEntityCustomerId]					= [intEntityCustomerId]
	,[intCompanyLocationId]					= [intCompanyLocationId]
	,[intCurrencyId]						= [intCurrencyId]
	,[dtmDatePaid]							= [dtmDatePaid]
	,[intPaymentMethodId]					= [intPaymentMethodId]
	,[strPaymentMethod]						= [strPaymentMethod]
	,[strPaymentInfo]						= [strPaymentInfo]
	,[strNotes]								= [strNotes]
	,[intAccountId]							= [intAccountId]
	,[intBankAccountId]						= [intBankAccountId]
	,[intWriteOffAccountId]					= [intWriteOffAccountId]
	,[dblAmountPaid]						= [dblAmountPaid]
	,[strPaymentOriginalId]					= [strPaymentOriginalId]
	,[ysnUseOriginalIdAsPaymentNumber]		= [ysnUseOriginalIdAsPaymentNumber]
	,[ysnApplytoBudget]						= [ysnApplytoBudget]
	,[ysnApplyOnAccount]					= [ysnApplyOnAccount]
	,[ysnInvoicePrepayment]					= [ysnInvoicePrepayment]
	,[ysnImportedFromOrigin]				= [ysnImportedFromOrigin]
	,[ysnImportedAsPosted]					= [ysnImportedAsPosted]
	,[ysnAllowPrepayment]					= [ysnAllowPrepayment]
	,[ysnPost]								= [ysnPost]
	,[ysnRecap]								= [ysnRecap]
	,[intEntityId]							= [intEntityId]
	,[intPaymentDetailId]					= [intPaymentDetailId]
	,[intInvoiceId]							= [intInvoiceId]
	,[intBillId]							= [intBillId]
	,[strTransactionNumber]					= [strTransactionNumber]
	,[intTermId]							= [intTermId]
	,[ysnApplyTermDiscount]					= [ysnApplyTermDiscount]
	,[dblDiscount]							= [dblDiscount]
	,[dblDiscountAvailable]					= [dblDiscountAvailable]
	,[dblInterest]							= [dblInterest]
	,[dblPayment]							= [dblPayment]
	,[strInvoiceReportNumber]				= [strInvoiceReportNumber]
	,[intCurrencyExchangeRateTypeId]		= [intCurrencyExchangeRateTypeId]
	,[intCurrencyExchangeRateId]			= [intCurrencyExchangeRateId]
	,[dblCurrencyExchangeRate]				= [dblCurrencyExchangeRate]
	,[ysnAllowOverpayment]					= [ysnAllowOverpayment]
FROM
	@PaymentEntries 


DECLARE @InvalidRecords AS TABLE (
	 [intId]				INT
	,[strMessage]			NVARCHAR(500)	COLLATE Latin1_General_CI_AS	NULL
	,[strSourceTransaction]	NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intSourceId]			INT												NULL
	,[strSourceId]			NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NOT NULL
	,[intPaymentId]			INT												NULL
)

INSERT INTO @InvalidRecords(
	 [intId]
	,[strMessage]			
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intPaymentId]
)
SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The company location Id provided does not exists!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation SMCL WITH (NOLOCK) WHERE SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The company location provided is not active!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMCompanyLocation SMCL WITH (NOLOCK) WHERE SMCL.[intCompanyLocationId] IS NOT NULL AND SMCL.[intCompanyLocationId] = ITG.[intCompanyLocationId] AND SMCL.[ysnLocationActive] = 1)

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The customer Id provided does not exists!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intEntityCustomerId] = ITG.[intEntityCustomerId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The customer provided is not active!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intEntityCustomerId] = ITG.[intEntityCustomerId] AND ARC.[ysnActive] = 1)


UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The entity Id provided does not exists!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblEMEntity EME WITH (NOLOCK) WHERE EME.[intEntityId] = ITG.[intEntityId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The payment method Id provided does not exists!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMPaymentMethod SMPM WITH (NOLOCK) WHERE SMPM.[intPaymentMethodID] = ITG.[intPaymentMethodId] AND ISNULL(SMPM.[ysnActive], 0) = 1)

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The currency Id provided does not exists!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[intCurrencyId] IS NOT NULL
	AND NOT EXISTS (SELECT NULL FROM tblSMCurrency SMC WITH (NOLOCK) WHERE SMC.[intCurrencyID] = ITG.[intCurrencyId])
	AND @DefaultCurrency IS NOT NULL

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'There is no Functional Currency setup in Company Configuration!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	ITG.[intCurrencyId] IS NULL
	AND @DefaultCurrency IS NULL

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'The payment method provided is not active!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM
	@PaymentsToGenerate ITG --WITH (NOLOCK)
WHERE
	NOT EXISTS(SELECT NULL FROM tblSMPaymentMethod SMPM WITH (NOLOCK) WHERE SMPM.[intPaymentMethodID] = ITG.[intPaymentMethodId] AND ISNULL(SMPM.[ysnActive], 0) = 1)

--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'This will create a prepayment which has not been allowed!'
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intPaymentId]			= ITG.[intPaymentId]
--FROM
--	@PaymentsToGenerate ITG --WITH (NOLOCK)
--WHERE	
--	ITG.[ysnAllowPrepayment] = 0
--	AND ITG.[intInvoiceId] IS NULL
--	AND ITG.[dblAmountPaid] > @ZeroDecimal


--UNION ALL

--SELECT
--	 [intId]				= ITG.[intId]
--	,[strMessage]			= 'This will create a overpayment which has not been allowed!'
--	,[strSourceTransaction]	= ITG.[strSourceTransaction]
--	,[intSourceId]			= ITG.[intSourceId]
--	,[strSourceId]			= ITG.[strSourceId]
--	,[intPaymentId]			= ITG.[intPaymentId]
--FROM
--	@PaymentsToGenerate ITG --WITH (NOLOCK)
--WHERE	
--	ITG.[ysnAllowOverpayment] = 0
--	AND ITG.[intInvoiceId] IS NOT NULL
--	AND ITG.[dblAmountPaid] > ([dblPayment] + [dblDiscount] - [dblInterest])


DELETE FROM V
FROM @PaymentsToGenerate V
WHERE EXISTS(SELECT NULL FROM @InvalidRecords I WHERE V.[intId] = I.[intId])


IF ISNULL(@RaiseError,0) = 1 AND EXISTS(SELECT TOP 1 NULL FROM @InvalidRecords)
BEGIN
	SET @ErrorMessage = (SELECT TOP 1 [strMessage] FROM @InvalidRecords ORDER BY [intId])
	RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END


IF ISNULL(@RaiseError,0) = 0	
	BEGIN TRANSACTION

DECLARE  @AddDetailError NVARCHAR(MAX)
		,@IntegrationLog PaymentIntegrationLogStagingTable

INSERT INTO @IntegrationLog
	([intIntegrationLogId]
	,[dtmDate]
	,[intEntityId]
	,[intGroupingOption]
	,[strMessage]
	,[strBatchIdForNewPost]
	,[intPostedNewCount]
	,[strBatchIdForNewPostRecap]
	,[intRecapNewCount]
	,[strBatchIdForExistingPost]
	,[intPostedExistingCount]
	,[strBatchIdForExistingRecap]
	,[intRecapPostExistingCount]
	,[strBatchIdForExistingUnPost]
	,[intUnPostedExistingCount]
	,[strBatchIdForExistingUnPostRecap]
	,[intRecapUnPostedExistingCount]
	,[intIntegrationLogDetailId]
	,[intPaymentId]
	,[intPaymentDetailId]
	,[intId]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[ysnPost]
	,[ysnInsert]
	,[ysnHeader]
	,[ysnSuccess])
SELECT
	 [intIntegrationLogId]					= @IntegrationLogId
	,[dtmDate]								= @DateNow
	,[intEntityId]							= @UserId
	,[intGroupingOption]					= @GroupingOption
	,[strMessage]							= [strMessage]
	,[strBatchIdForNewPost]					= ''
	,[intPostedNewCount]					= 0
	,[strBatchIdForNewPostRecap]			= ''
	,[intRecapNewCount]						= 0
	,[strBatchIdForExistingPost]			= ''
	,[intPostedExistingCount]				= 0
	,[strBatchIdForExistingRecap]			= ''
	,[intRecapPostExistingCount]			= 0
	,[strBatchIdForExistingUnPost]			= ''
	,[intUnPostedExistingCount]				= 0
	,[strBatchIdForExistingUnPostRecap]		= ''
	,[intRecapUnPostedExistingCount]		= 0
	,[intIntegrationLogDetailId]			= 0
	,[intPaymentId]							= NULL
	,[intInvoiceDetailId]					= NULL
	,[intId]								= [intId]
	,[strSourceTransaction]					= [strSourceTransaction]
	,[intSourceId]							= [intSourceId]
	,[strSourceId]							= [strSourceId]
	,[ysnPost]								= NULL
	,[ysnInsert]							= 1
	,[ysnHeader]							= 1
	,[ysnSuccess]							= 0
FROM
	@InvalidRecords

BEGIN TRY
MERGE INTO tblARPayment AS Target
USING 
	(
	SELECT
		 [intEntityCustomerId]		= ARC.[intEntityCustomerId]
		,[intCurrencyId]			= ISNULL(ITG.[intCurrencyId], ISNULL(ARC.[intCurrencyId], @DefaultCurrency))	
		,[dtmDatePaid]				= ISNULL(ITG.[dtmDatePaid], @DateNow)
		,[intAccountId]				= ITG.[intAccountId]
		,[intBankAccountId]			= ITG.[intBankAccountId]
		,[intPaymentMethodId]		= ITG.[intPaymentMethodId]
		,[intLocationId]			= ITG.[intCompanyLocationId]
		,[dblAmountPaid]			= ITG.[dblAmountPaid]
		,[dblBaseAmountPaid]		= ITG.[dblAmountPaid]
		,[dblUnappliedAmount]		= ITG.[dblAmountPaid]
		,[dblBaseUnappliedAmount]	= ITG.[dblAmountPaid]
		,[dblOverpayment]			= @ZeroDecimal
		,[dblBaseOverpayment]		= @ZeroDecimal
		,[dblBalance]				= ARC.[dblARBalance]
		,[strRecordNumber]			= CASE WHEN ISNULL(ITG.ysnUseOriginalIdAsPaymentNumber, 0) = 1 THEN ITG.strPaymentOriginalId ELSE NULL END
		,[strPaymentInfo]			= ITG.[strPaymentInfo]
		,[strNotes]					= ITG.[strNotes]
		,[ysnApplytoBudget]			= ISNULL(ITG.[ysnApplytoBudget], 0)
		,[ysnApplyOnAccount]		= ISNULL(ITG.[ysnApplyOnAccount], 0)
		,[ysnInvoicePrepayment]		= ISNULL(ITG.[ysnInvoicePrepayment], 0)
		,[ysnImportedFromOrigin]	= ISNULL(ITG.[ysnImportedFromOrigin], 0)
		,[ysnImportedAsPosted]		= ISNULL(ITG.[ysnImportedAsPosted], 0)
		,[intEntityId]				= ITG.[intEntityId]
		,[intWriteOffAccountId]		= ITG.[intWriteOffAccountId]
		,[strPaymentMethod]			= ITG.[strPaymentMethod]
		,[dblTotalAR]				= @ZeroDecimal
		,[intConcurrencyId]			= 1
		,[intId]					= ITG.[intId]
		,[strSourceTransaction]		= ITG.[strSourceTransaction]
		,[intSourceId]				= ITG.[intSourceId]
		,[strSourceId]				= ITG.[strSourceId]
		,[ysnPost]					= ITG.[ysnPost]
		,[ysnRecap]					= ITG.[ysnRecap]
		,[intPaymentId]				= ITG.[intPaymentId]
		,[ysnPosted]				= ISNULL(ITG.[ysnImportedAsPosted], 0)
	FROM	
		@PaymentsToGenerate ITG --WITH (NOLOCK)
	INNER JOIN
		(SELECT intId FROM @PaymentsToGenerate) ITG2  --WITH (NOLOCK)) ITG2
			ON ITG.[intId] = ITG2.[intId]
	INNER JOIN
		(SELECT [intEntityCustomerId], [dblARBalance], [intCurrencyId] FROM tblARCustomer WITH (NOLOCK)) ARC
			ON ITG.[intEntityCustomerId] = ARC.[intEntityCustomerId] 	
	)
AS Source
ON Target.[intPaymentId] = Source.[intPaymentId]
WHEN NOT MATCHED BY TARGET THEN
INSERT(
	 [intEntityCustomerId]
	,[intCurrencyId]
	,[dtmDatePaid]
	,[intAccountId]
	,[intBankAccountId]
	,[intPaymentMethodId]
	,[intLocationId]
	,[dblAmountPaid]
	,[dblBaseAmountPaid]
	,[dblUnappliedAmount]
	,[dblBaseUnappliedAmount]
	,[dblOverpayment]
	,[dblBaseOverpayment]
	,[dblBalance]
	,[strRecordNumber]
	,[strPaymentInfo]
	,[strNotes]
	,[ysnApplytoBudget]
	,[ysnApplyOnAccount]
	,[ysnPosted]
	,[ysnInvoicePrepayment]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[intEntityId]
	,[intWriteOffAccountId]
	,[strPaymentMethod]
	,[dblTotalAR]
	,[intConcurrencyId]
	)
VALUES(
	 [intEntityCustomerId]
	,[intCurrencyId]
	,[dtmDatePaid]
	,[intAccountId]
	,[intBankAccountId]
	,[intPaymentMethodId]
	,[intLocationId]
	,[dblAmountPaid]
	,[dblBaseAmountPaid]
	,[dblUnappliedAmount]
	,[dblBaseUnappliedAmount]
	,[dblOverpayment]
	,[dblBaseOverpayment]
	,[dblBalance]
	,[strRecordNumber]
	,[strPaymentInfo]
	,[strNotes]
	,[ysnApplytoBudget]
	,[ysnApplyOnAccount]
	,[ysnPosted]
	,[ysnInvoicePrepayment]
	,[ysnImportedFromOrigin]
	,[ysnImportedAsPosted]
	,[intEntityId]
	,[intWriteOffAccountId]
	,[strPaymentMethod]
	,[dblTotalAR]
	,[intConcurrencyId]
)
	OUTPUT  
			@IntegrationLogId						--[intIntegrationLogId]
			,@DateNow								--[dtmDate]
			,INSERTED.[intEntityId]					--[intEntityId]
			,@GroupingOption						--[intGroupingOption]
			,'Payment was successfully created.'	--[strErrorMessage]
			,''										--[strBatchIdForNewPost]
			,0										--[intPostedNewCount]
			,''										--[strBatchIdForNewPostRecap]
			,0										--[intRecapNewCount]
			,''										--[strBatchIdForExistingPost]
			,0										--[intPostedExistingCount]
			,''										--[strBatchIdForExistingRecap]
			,0										--[intRecapPostExistingCount]
			,''										--[strBatchIdForExistingUnPost]
			,0										--[intUnPostedExistingCount]
			,''										--[strBatchIdForExistingUnPostRecap]
			,0										--[intRecapUnPostedExistingCount]
			,NULL									--[intIntegrationLogDetailId]
			,INSERTED.[intPaymentId]				--[[intPaymentId]]
			,INSERTED.[intEntityCustomerId]			--[intEntityCustomerId]
			,INSERTED.[intLocationId]				--[intCompanyLocationId]
			,INSERTED.[intCurrencyId]				--[intCurrencyId]
			,NULL									--[[intPaymentDetailId]]
			,Source.[intId]							--[intId]
			,Source.[strSourceTransaction]			--[strSourceTransaction]
			,Source.[intSourceId]					--[intSourceId]
			,Source.[strSourceId]					--[strSourceId]
			,Source.[ysnPost]						--[ysnPost]
			,1										--[ysnInsert]
			,1										--[ysnHeader]
			,1										--[ysnSuccess]
			,Source.[ysnRecap]						--[ysnRecap]
		INTO @IntegrationLog(
			 [intIntegrationLogId]
			,[dtmDate]
			,[intEntityId]
			,[intGroupingOption]
			,[strMessage]
			,[strBatchIdForNewPost]
			,[intPostedNewCount]
			,[strBatchIdForNewPostRecap]
			,[intRecapNewCount]
			,[strBatchIdForExistingPost]
			,[intPostedExistingCount]
			,[strBatchIdForExistingRecap]
			,[intRecapPostExistingCount]
			,[strBatchIdForExistingUnPost]
			,[intUnPostedExistingCount]
			,[strBatchIdForExistingUnPostRecap]
			,[intRecapUnPostedExistingCount]
			,[intIntegrationLogDetailId]
			,[intPaymentId]
			,[intEntityCustomerId]
			,[intCompanyLocationId]
			,[intCurrencyId]
			,[intPaymentDetailId]
			,[intId]
			,[strSourceTransaction]
			,[intSourceId]
			,[strSourceId]
			,[ysnPost]
			,[ysnInsert]
			,[ysnHeader]
			,[ysnSuccess]
			,[ysnRecap]
		);	
	
	IF ISNULL(@IntegrationLogId, 0) <> 0
		EXEC [uspARInsertPaymentIntegrationLogDetail] @IntegrationLogEntries = @IntegrationLog
	
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH



BEGIN TRY
	DECLARE @LineItems PaymentIntegrationStagingTable
	DELETE FROM @LineItems
	INSERT INTO @LineItems
		([intId]
		,[strSourceTransaction]
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
		,[ysnUnPostAndUpdate]
		,[intEntityId]
		--Detail																																															
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
		,[ysnAllowOverpayment])
	SELECT
		 [intId]							= IL.[intId]
		,[strSourceTransaction]				= IL.[strSourceTransaction]
		,[intSourceId]						= IL.[intSourceId]
		,[strSourceId]						= IL.[strSourceId]
		,[intPaymentId]						= IL.[intPaymentId]
		,[intEntityCustomerId]				= IL.[intEntityCustomerId]
		,[intCompanyLocationId]				= IL.[intCompanyLocationId]
		,[intCurrencyId]					= IL.[intCurrencyId]
		,[dtmDatePaid]						= ITG.[dtmDatePaid]
		,[intPaymentMethodId]				= ITG.[intPaymentMethodId]
		,[strPaymentMethod]					= ITG.[strPaymentMethod]
		,[strPaymentInfo]					= ITG.[strPaymentInfo]
		,[strNotes]							= ITG.[strNotes]
		,[intAccountId]						= ITG.[intAccountId]
		,[intBankAccountId]					= ITG.[intBankAccountId]
		,[intWriteOffAccountId]				= ITG.[intWriteOffAccountId]
		,[dblAmountPaid]					= ITG.[dblAmountPaid]
		,[strPaymentOriginalId]				= ITG.[strPaymentOriginalId]
		,[ysnUseOriginalIdAsPaymentNumber]	= ITG.[ysnUseOriginalIdAsPaymentNumber]
		,[ysnApplytoBudget]					= ITG.[ysnApplytoBudget]
		,[ysnApplyOnAccount]				= ITG.[ysnApplyOnAccount]
		,[ysnInvoicePrepayment]				= ITG.[ysnInvoicePrepayment]
		,[ysnImportedFromOrigin]			= ITG.[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]				= ITG.[ysnImportedAsPosted]
		,[ysnAllowPrepayment]				= ITG.[ysnAllowPrepayment]
		,[ysnPost]							= ITG.[ysnPost]
		,[ysnRecap]							= ITG.[ysnRecap]
		,[ysnUnPostAndUpdate]				= ITG.[ysnUnPostAndUpdate]
		,[intEntityId]						= ITG.[intEntityId]
		--Detail																																															
		,[intPaymentDetailId]				= ITG.[intPaymentDetailId]
		,[intInvoiceId]						= ITG.[intInvoiceId]
		,[intBillId]						= ITG.[intBillId]
		,[strTransactionNumber]				= ITG.[strTransactionNumber]
		,[intTermId]						= ITG.[intTermId]
		,[ysnApplyTermDiscount]				= ITG.[ysnApplyTermDiscount]
		,[dblDiscount]						= ITG.[dblDiscount]
		,[dblDiscountAvailable]				= ITG.[dblDiscountAvailable]
		,[dblInterest]						= ITG.[dblInterest]
		,[dblPayment]						= ITG.[dblPayment]
		,[strInvoiceReportNumber]			= ITG.[strInvoiceReportNumber]
		,[intCurrencyExchangeRateTypeId]	= ITG.[intCurrencyExchangeRateTypeId]
		,[intCurrencyExchangeRateId]		= ITG.[intCurrencyExchangeRateId]
		,[dblCurrencyExchangeRate]			= CASE WHEN ISNULL(ITG.[dblCurrencyExchangeRate], @ZeroDecimal) = @ZeroDecimal THEN 1.000000 ELSE ITG.[dblCurrencyExchangeRate] END
		,[ysnAllowOverpayment]				= ITG.[ysnAllowOverpayment]
	FROM
		@PaymentsToGenerate ITG
	INNER JOIN
		@IntegrationLog IL
			ON ITG.[intId] = IL.[intId]
			AND IL.[ysnSuccess] = 1
	WHERE
		ITG.[intInvoiceId] IS NOT NULL

	EXEC [dbo].[uspARAddToInvoicesToPayments]
		 @PaymentEntries	= @LineItems
		,@IntegrationLogId	= @IntegrationLogId
		,@UserId			= @UserId
		,@RaiseError		= @RaiseError
		,@ErrorMessage		= @AddDetailError	OUTPUT

		IF LEN(ISNULL(@AddDetailError,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
					ROLLBACK TRANSACTION
				SET @ErrorMessage = @AddDetailError;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

	
BEGIN TRY
	DECLARE @CreatedPaymentIds PaymentId	
	DELETE FROM @CreatedPaymentIds

	INSERT INTO @CreatedPaymentIds(
		 [intHeaderId]
		,[intDetailId])
	SELECT 
		 [intHeaderId]						= [intPaymentId]
		,[intDetailId]						= NULL
	 FROM @IntegrationLog WHERE [ysnSuccess] = 1

	EXEC [dbo].[uspARReComputePaymentAmounts] @PaymentIds = @CreatedPaymentIds

	DECLARE @InvoiceLog AuditLogStagingTable	
	DELETE FROM @InvoiceLog

	INSERT INTO @InvoiceLog(
		 [strScreenName]
		,[intKeyValueId]
		,[intEntityId]
		,[strActionType]
		,[strDescription]
		,[strActionIcon]
		,[strChangeDescription]
		,[strFromValue]
		,[strToValue]
		,[strDetails]
	)
	SELECT 
		 [strScreenName]			= 'AccountsReceivable.view.ReceivePaymentsDetail'
		,[intKeyValueId]			= ARP.[intPaymentId]
		,[intEntityId]				= IL.[intEntityId]
		,[strActionType]			= 'Processed'
		,[strDescription]			= IL.[strSourceTransaction] + ' to Payment'
		,[strActionIcon]			= NULL
		,[strChangeDescription]		= IL.[strSourceTransaction] + ' to Payment'
		,[strFromValue]				= IL.[strSourceId]
		,[strToValue]				= ARP.[strRecordNumber]
		,[strDetails]				= NULL
	 FROM @IntegrationLog IL
	INNER JOIN
		(SELECT [intPaymentId], [strRecordNumber] FROM tblARPayment) ARP
			ON IL.[intPaymentId] = ARP.[intPaymentId]
	 WHERE
		[ysnSuccess] = 1 
		AND [ysnInsert] = 1

	EXEC [dbo].[uspSMInsertAuditLogs] @LogEntries = @InvoiceLog

END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
		ROLLBACK TRANSACTION
	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

IF ISNULL(@RaiseError,0) = 0
	COMMIT TRANSACTION
SET @ErrorMessage = NULL;
RETURN 1;
	
END
GO
