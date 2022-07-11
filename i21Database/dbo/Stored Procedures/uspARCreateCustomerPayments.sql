﻿CREATE PROCEDURE [dbo].[uspARCreateCustomerPayments]
	 @PaymentEntries	PaymentIntegrationStagingTable	READONLY
	,@IntegrationLogId	INT					= NULL
	,@GroupingOption	INT					= 0
	,@UserId			INT
	,@RaiseError		BIT					= 0
	,@ErrorMessage		NVARCHAR(250)		= NULL	OUTPUT
	,@SkipRecompute     BIT                 = 0
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON

DECLARE @ZeroDecimal		NUMERIC(18, 6)	= 0.000000
		,@DateNow			DATETIME		= CAST(GETDATE() AS DATE)
		,@DefaultCurrency	INT				= NULL
		,@InitTranCount		INT
		,@Savepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARCreateCustomerPayments' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)


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
	,[intExchangeRateTypeId]
	,[dblExchangeRate]
	,[strReceivePaymentType]
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
	,[intWriteOffAccountDetailId]
	,[strTransactionNumber]
	,[intTermId]
	,[ysnApplyTermDiscount]
	,[dblDiscount]
	,[dblDiscountAvailable]
	,[dblWriteOffAmount]
	,[dblBaseWriteOffAmount]
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
	,[intExchangeRateTypeId]				= [intExchangeRateTypeId]
	,[dblExchangeRate]						= [dblExchangeRate]
	,[strReceivePaymentType]				= CASE WHEN RTRIM(LTRIM(ISNULL([strReceivePaymentType],''))) NOT IN ('Cash Receipts','Vendor Refund') THEN 'Cash Receipts' ELSE [strReceivePaymentType] END
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
	,[intWriteOffAccountDetailId]			= [intWriteOffAccountDetailId]
	,[strTransactionNumber]					= [strTransactionNumber]
	,[intTermId]							= [intTermId]
	,[ysnApplyTermDiscount]					= [ysnApplyTermDiscount]
	,[dblDiscount]							= [dblDiscount]
	,[dblDiscountAvailable]					= [dblDiscountAvailable]
	,[dblWriteOffAmount]					= [dblWriteOffAmount]
	,[dblBaseWriteOffAmount]				= [dblBaseWriteOffAmount]
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
	NOT EXISTS(SELECT NULL FROM tblARCustomer ARC WITH (NOLOCK) WHERE ARC.[intEntityId] = ITG.[intEntityCustomerId])

UNION ALL

SELECT
	 [intId]				= ITG.[intId]
	,[strMessage]			= 'Customer ' + ARC.strCustomerNumber + ' is not active!'
	,[strSourceTransaction]	= ITG.[strSourceTransaction]
	,[intSourceId]			= ITG.[intSourceId]
	,[strSourceId]			= ITG.[strSourceId]
	,[intPaymentId]			= ITG.[intPaymentId]
FROM @PaymentsToGenerate ITG
INNER JOIN tblARCustomer ARC ON ARC.[intEntityId] = ITG.[intEntityCustomerId]
WHERE ARC.[ysnActive] = 0 OR ARC.[ysnActive] IS NULL

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
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

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

UPDATE PTG
SET
	 PTG.[intEntityCustomerId]		= ARC.[intEntityId]
	,PTG.[intCurrencyId]			= ISNULL(PTG.[intCurrencyId], ISNULL(ARC.[intCurrencyId], @DefaultCurrency))	
	,PTG.[dtmDatePaid]				= ISNULL(PTG.[dtmDatePaid], @DateNow)
	,PTG.[dblAmountPaid]			= ISNULL(PTG.[dblAmountPaid], @ZeroDecimal)
	,PTG.[dblBaseAmountPaid]		= [dbo].fnRoundBanker((ISNULL(PTG.[dblAmountPaid], @ZeroDecimal) * (CASE WHEN ISNULL(PTG.[dblExchangeRate],@ZeroDecimal) = @ZeroDecimal THEN CER.[dblCurrencyExchangeRate] ELSE PTG.[dblExchangeRate] END)), [dbo].[fnARGetDefaultDecimal]())	
	,PTG.[dblBalance]				= ARC.[dblARBalance]
	,PTG.[intExchangeRateTypeId]	= ISNULL(PTG.[intExchangeRateTypeId], CER.[intCurrencyExchangeRateTypeId])
	,PTG.[dblExchangeRate]			= (CASE WHEN ISNULL(PTG.[dblExchangeRate],@ZeroDecimal) = @ZeroDecimal THEN CER.[dblCurrencyExchangeRate] ELSE PTG.[dblExchangeRate] END)
	,PTG.[ysnApplytoBudget]			= ISNULL(PTG.[ysnApplytoBudget], 0)
	,PTG.[ysnApplyOnAccount]		= ISNULL(PTG.[ysnApplyOnAccount], 0)
	,PTG.[ysnInvoicePrepayment]		= ISNULL(PTG.[ysnInvoicePrepayment], 0)
	,PTG.[ysnImportedFromOrigin]	= ISNULL(PTG.[ysnImportedFromOrigin], 0)
	,PTG.[ysnImportedAsPosted]		= ISNULL(PTG.[ysnImportedAsPosted], 0)    
FROM
	@PaymentsToGenerate PTG
INNER JOIN
	(SELECT [intEntityId], [dblARBalance], [intCurrencyId] FROM tblARCustomer WITH (NOLOCK)) ARC
		ON PTG.[intEntityCustomerId] = ARC.[intEntityId]
CROSS APPLY
	dbo.[fnARGetDefaultForexRate](ISNULL(PTG.[dtmDatePaid], @DateNow), ISNULL(PTG.[intCurrencyId], ISNULL(ARC.[intCurrencyId], @DefaultCurrency)), PTG.[intExchangeRateTypeId])	CER

BEGIN TRY
MERGE INTO tblARPayment AS Target
USING 
	(
	SELECT
		 [intEntityCustomerId]				= ITG.[intEntityCustomerId]
		,[intCurrencyId]					= ITG.[intCurrencyId]    
		,[dtmDatePaid]						= ITG.[dtmDatePaid]
		,[intAccountId]						= ITG.[intAccountId]
		,[intBankAccountId]					= ITG.[intBankAccountId]
		,[intPaymentMethodId]				= ITG.[intPaymentMethodId]
		,[intLocationId]					= ITG.[intCompanyLocationId]
		,[dblAmountPaid]					= ITG.[dblAmountPaid]
		,[dblBaseAmountPaid]				= ITG.[dblBaseAmountPaid]	
		,[dblUnappliedAmount]				= @ZeroDecimal
		,[dblBaseUnappliedAmount]			= @ZeroDecimal
		,[dblOverpayment]					= @ZeroDecimal
		,[dblBaseOverpayment]				= @ZeroDecimal
		,[dblBalance]						= ITG.[dblBalance]
		,[intCurrencyExchangeRateTypeId]	= ITG.[intExchangeRateTypeId]
		,[dblExchangeRate]					= ITG.[dblExchangeRate]
		,[strReceivePaymentType]			= ITG.[strReceivePaymentType]
		,[strRecordNumber]					= CASE WHEN ISNULL(ITG.ysnUseOriginalIdAsPaymentNumber, 0) = 1 THEN ITG.strPaymentOriginalId ELSE NULL END
		,[strPaymentInfo]					= ITG.[strPaymentInfo]
		,[strNotes]							= ITG.[strNotes]
		,[ysnApplytoBudget]					= ITG.[ysnApplytoBudget]
		,[ysnApplyOnAccount]				= ITG.[ysnApplyOnAccount]
		,[ysnInvoicePrepayment]				= ITG.[ysnInvoicePrepayment]
		,[ysnImportedFromOrigin]			= ITG.[ysnImportedFromOrigin]
		,[ysnImportedAsPosted]				= ITG.[ysnImportedAsPosted]
		,[intEntityId]						= ITG.[intEntityId]
		,[intWriteOffAccountId]				= ITG.[intWriteOffAccountId]
		,[strPaymentMethod]					= ITG.[strPaymentMethod]
		,[dblTotalAR]						= @ZeroDecimal
		,[intConcurrencyId]					= 1
		,[intId]							= ITG.[intId]
		,[strSourceTransaction]				= ITG.[strSourceTransaction]
		,[intSourceId]						= ITG.[intSourceId]
		,[strSourceId]						= ITG.[strSourceId]
		,[ysnPost]							= ITG.[ysnPost]
		,[ysnRecap]							= ITG.[ysnRecap]
		,[intPaymentId]						= ITG.[intPaymentId]
		,[ysnPosted]						= ITG.[ysnImportedAsPosted]	
	FROM	
		@PaymentsToGenerate ITG --WITH (NOLOCK)
	-- INNER JOIN
	-- 	(SELECT intId FROM @PaymentsToGenerate) ITG2  --WITH (NOLOCK)) ITG2
	-- 		ON ITG.[intId] = ITG2.[intId]
	--INNER JOIN
	--	(SELECT [intEntityId], [dblARBalance], [intCurrencyId] FROM tblARCustomer WITH (NOLOCK)) ARC
	--		ON ITG.[intEntityCustomerId] = ARC.[intEntityId] 	
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
	,[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]
	,[strReceivePaymentType]
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
	,[intCurrencyExchangeRateTypeId]
	,[dblExchangeRate]
	,[strReceivePaymentType]
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
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

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
		,[intExchangeRateTypeId]
		,[dblExchangeRate]
		,[strReceivePaymentType]
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
		,[intWriteOffAccountDetailId]
		,[strTransactionNumber]
		,[intTermId]
		,[ysnApplyTermDiscount]
		,[dblDiscount]
		,[dblDiscountAvailable]
		,[dblWriteOffAmount]
		,[dblBaseWriteOffAmount]
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
		,[intExchangeRateTypeId]			= ITG.[intExchangeRateTypeId]
		,[dblExchangeRate]					= ITG.[dblExchangeRate]
		,[strReceivePaymentType]			= ITG.[strReceivePaymentType]
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
		,[intWriteOffAccountDetailId]		= ITG.[intWriteOffAccountDetailId]
		,[strTransactionNumber]				= ITG.[strTransactionNumber]
		,[intTermId]						= ITG.[intTermId]
		,[ysnApplyTermDiscount]				= ITG.[ysnApplyTermDiscount]
		,[dblDiscount]						= ITG.[dblDiscount]
		,[dblDiscountAvailable]				= ITG.[dblDiscountAvailable]
		,[dblWriteOffAmount]				= ITG.[dblWriteOffAmount]
		,[dblBaseWriteOffAmount]			= ITG.[dblBaseWriteOffAmount]
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
		,@SkipRecompute     = @SkipRecompute

		IF LEN(ISNULL(@AddDetailError,'')) > 0
			BEGIN
				IF ISNULL(@RaiseError,0) = 0
				BEGIN
					IF @InitTranCount = 0
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION
					ELSE
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION @Savepoint
				END

				SET @ErrorMessage = @AddDetailError;
				IF ISNULL(@RaiseError,0) = 1
					RAISERROR(@ErrorMessage, 16, 1);
				RETURN 0;
			END
END TRY
BEGIN CATCH
	IF ISNULL(@RaiseError,0) = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

	
BEGIN TRY
	DECLARE @CreatedPaymentIds PaymentId	
	IF ISNULL(@SkipRecompute, 0) = 0
	BEGIN
			
		DELETE FROM @CreatedPaymentIds

		INSERT INTO @CreatedPaymentIds(
			[intHeaderId]
		,[intDetailId])
		SELECT 
			[intHeaderId]						= [intPaymentId]
		,[intDetailId]						= NULL
		FROM @IntegrationLog WHERE [ysnSuccess] = 1

		EXEC [dbo].[uspARReComputePaymentAmounts] @PaymentIds = @CreatedPaymentIds
	END
	

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
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END

	SET @ErrorMessage = ERROR_MESSAGE();
	IF ISNULL(@RaiseError,0) = 1
		RAISERROR(@ErrorMessage, 16, 1);
	RETURN 0;
END CATCH

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END

SET @ErrorMessage = NULL;
RETURN 1;
	
END
GO
