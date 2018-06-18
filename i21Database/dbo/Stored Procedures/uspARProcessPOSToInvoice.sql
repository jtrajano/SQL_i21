CREATE PROCEDURE [dbo].[uspARProcessPOSToInvoice]
	 @intPOSId			INT
	,@intEntityUserId	INT	
	,@strTransactionType NVARCHAR(25)
	,@ErrorMessage		NVARCHAR(250) OUTPUT
	,@CreatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
AS	

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @EntriesForInvoice 		InvoiceIntegrationStagingTable
DECLARE @TaxDetails 			LineItemTaxDetailStagingTable
DECLARE @intNewInvoiceId		INT = NULL

BEGIN TRANSACTION

--CREATE DEFAULT PAYMENT METHODS IF DOES NOT EXISTS
IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'CASH')
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			  strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = 'Cash'
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1
	END
IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'CHECK')
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			  strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = 'Check'
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1
	END
IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'CREDIT CARD')
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			  strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = 'Credit Card'
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1
	END
IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'DEBIT CARD')
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			  strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = 'Debit Card'
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1
	END

--INSERT LINE ITEMS AND DISCOUNT INTO INVOICE
INSERT INTO @EntriesForInvoice(
	 [strTransactionType]
	,[strType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[dtmDate]
	,[dtmShipDate]
	,[strComments]
	,[intEntityId]
	,[ysnPost]
	,[intItemId]
	,[ysnInventory]
	,[strItemDescription]
	,[intItemUOMId]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblPrice]
	,[ysnRefreshPrice]
	,[ysnRecomputeTax]
	,[ysnClearDetailTaxes]					
	,[intTempDetailIdForTaxes]
	,[dblCurrencyExchangeRate]
	,[dblSubCurrencyRate]
	,[intSalesAccountId]
)
SELECT
	 [strTransactionType]					= @strTransactionType
	,[strType]								= 'POS'
	,[strSourceTransaction]					= 'POS'
	,[intSourceId]							= POS.intPOSId
	,[strSourceId]							= POS.strReceiptNumber
	,[intEntityCustomerId]					= POS.intEntityCustomerId
	,[intCompanyLocationId]					= POS.intCompanyLocationId
	,[intCurrencyId]						= POS.intCurrencyId
	,[dtmDate]								= POS.dtmDate
	,[dtmShipDate]							= POS.dtmDate
	,[strComments]							= POS.strReceiptNumber
	,[intEntityId]							= POS.intEntityUserId
	,[ysnPost]								= 1
	,[intItemId]							= DETAILS.intItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= DETAILS.strItemDescription 
	,[intItemUOMId]							= DETAILS.intItemUOMId
	,[dblQtyShipped]						= DETAILS.dblQuantity 
	,[dblDiscount]							= DETAILS.dblDiscount
	,[dblPrice]								= DETAILS.dblPrice
	,[ysnRefreshPrice]						= 0
	,[ysnRecomputeTax]						= 1
	,[ysnClearDetailTaxes]					= 1
	,[intTempDetailIdForTaxes]				= @intPOSId
	,[dblCurrencyExchangeRate]				= 1.000000
	,[dblSubCurrencyRate]					= 1.000000
	,[intSalesAccountId]					= NULL
FROM tblARPOS POS 
INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
WHERE POS.intPOSId = @intPOSId

UNION ALL

SELECT TOP 1
	 [strTransactionType]					= @strTransactionType
	,[strType]								= 'POS'
	,[strSourceTransaction]					= 'POS'
	,[intSourceId]							= POS.intPOSId
	,[strSourceId]							= POS.strReceiptNumber
	,[intEntityCustomerId]					= POS.intEntityCustomerId
	,[intCompanyLocationId]					= POS.intCompanyLocationId
	,[intCurrencyId]						= POS.intCurrencyId
	,[dtmDate]								= POS.dtmDate
	,[dtmShipDate]							= POS.dtmDate
	,[strComments]							= POS.strReceiptNumber
	,[intEntityId]							= POS.intEntityUserId
	,[ysnPost]								= 1
	,[intItemId]							= NULL
	,[ysnInventory]							= 0
	,[strItemDescription]					= 'POS Discount - ' + CAST(CAST(POS.dblDiscountPercent AS INT) AS VARCHAR(3)) + '%'
	,[intItemUOMId]							= NULL
	,[dblQtyShipped]						= 1.000000
	,[dblDiscount]							= NULL
	,[dblPrice]								= POS.dblDiscount * -1
	,[ysnRefreshPrice]						= 0
	,[ysnRecomputeTax]						= 0
	,[ysnClearDetailTaxes]					= 1
	,[intTempDetailIdForTaxes]				= @intPOSId
	,[dblCurrencyExchangeRate]				= 1.000000
	,[dblSubCurrencyRate]					= 1.000000
	,[intSalesAccountId]					= ISNULL(COMPANYLOC.intDiscountAccountId, COMPANYPREF.intDiscountAccountId)
FROM tblARPOS POS
OUTER APPLY (
	SELECT TOP 1 intDiscountAccountId 
	FROM tblARCompanyPreference WITH (NOLOCK)
) COMPANYPREF
LEFT JOIN (
	SELECT intDiscountAccountId
	     , intCompanyLocationId
	FROM tblSMCompanyLocation WITH (NOLOCK)
) COMPANYLOC ON POS.intCompanyLocationId = COMPANYLOC.intCompanyLocationId
WHERE POS.intPOSId = @intPOSId
  AND ISNULL(dblDiscountPercent, 0) > 0

--PROCESS TO INVOICE
EXEC [dbo].[uspARProcessInvoices] @InvoiceEntries		= @EntriesForInvoice
								, @LineItemTaxEntries 	= @TaxDetails
								, @UserId				= @intEntityUserId
								, @GroupingOption		= 11
								, @RaiseError			= 1
								, @ErrorMessage			= @ErrorMessage OUTPUT
								, @CreatedIvoices		= @CreatedIvoices OUTPUT

IF ISNULL(@ErrorMessage, '') = ''
	BEGIN
		COMMIT TRANSACTION
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

--CREATE PAYMENTS
IF ISNULL(@CreatedIvoices, '') <> '' AND ISNULL(@ErrorMessage, '') = ''
BEGIN
	SELECT TOP 1 @intNewInvoiceId = intInvoiceId
	FROM tblARInvoice I 
	INNER JOIN fnGetRowsFromDelimitedValues(@CreatedIvoices) CI ON I.intInvoiceId = CI.intID

	UPDATE tblARPOS 
	SET intInvoiceId = @intNewInvoiceId
	  , ysnHold 	 = 0
	WHERE intPOSId = @intPOSId

	DECLARE @EntriesForPayment		PaymentIntegrationStagingTable
		  , @LogId 					INT 			= NULL
		  , @strPaymentIds 			NVARCHAR(MAX)	= NULL
		  , @dblOnAccountAmount		NUMERIC(18,6) 	= 0		  

	--GET POS PAYMENTS
	IF(OBJECT_ID('tempdb..#POSPAYMENTS') IS NOT NULL)
	BEGIN
		DROP TABLE #POSPAYMENTS
	END

	--REMOVE ON ACCOUNT PAYMENTS
	SELECT intPOSId
		 , intPOSPaymentId
		 , strPaymentMethod
		 , strReferenceNo
		 , dblAmount
	INTO #POSPAYMENTS
	FROM dbo.tblARPOSPayment WITH (NOLOCK)
	WHERE intPOSId = @intPOSId
	  AND ISNULL(strPaymentMethod, '') <> 'On Account'

	IF EXISTS (SELECT TOP 1 NULL FROM #POSPAYMENTS)
		BEGIN
			SELECT @dblOnAccountAmount = SUM(dblAmount)
			FROM dbo.tblARPOSPayment WITH (NOLOCK)
			WHERE intPOSId = @intPOSId
			AND ISNULL(strPaymentMethod, '') = 'On Account'

			INSERT INTO @EntriesForPayment (
				 intId
				,strSourceTransaction
				,intSourceId
				,strSourceId
				,intEntityCustomerId
				,intCompanyLocationId
				,intCurrencyId
				,dtmDatePaid
				,intPaymentMethodId
				,strPaymentMethod
				,strPaymentInfo
				,intBankAccountId
				,dblAmountPaid
				,intEntityId
				,intInvoiceId
				,strTransactionType
				,strTransactionNumber
				,intTermId
				,intInvoiceAccountId
				,dblInvoiceTotal
				,dblBaseInvoiceTotal
				,dblPayment
				,dblAmountDue
				,dblBaseAmountDue
				,strInvoiceReportNumber
				,intCurrencyExchangeRateTypeId
				,intCurrencyExchangeRateId
				,dblCurrencyExchangeRate
			)
			SELECT intId						= POSPAYMENTS.intPOSPaymentId
			    ,strSourceTransaction			= 'Direct'
				,intSourceId					= IFP.intInvoiceId
				,strSourceId					= IFP.strInvoiceNumber
				,intEntityCustomerId			= IFP.intEntityCustomerId
				,intCompanyLocationId			= IFP.intCompanyLocationId
				,intCurrencyId					= IFP.intCurrencyId
				,dtmDatePaid					= GETDATE()
				,intPaymentMethodId				= PM.intPaymentMethodID
				,strPaymentMethod				= PM.strPaymentMethod
				,strPaymentInfo					= CASE WHEN POSPAYMENTS.strPaymentMethod IN ('Check' ,'Debit Card') THEN strReferenceNo ELSE NULL END
				,intBankAccountId				= BA.intBankAccountId
				,dblAmountPaid					= ISNULL(POSPAYMENTS.dblAmount, 0)
				,intEntityId					= @intEntityUserId
				,intInvoiceId					= IFP.intInvoiceId
				,strTransactionType				= IFP.strTransactionType
				,strTransactionNumber			= IFP.strInvoiceNumber
				,intTermId						= IFP.intTermId
				,intInvoiceAccountId			= IFP.intAccountId
				,dblInvoiceTotal				= IFP.dblInvoiceTotal
				,dblBaseInvoiceTotal			= IFP.dblBaseInvoiceTotal
				,dblPayment						= ISNULL(POSPAYMENTS.dblAmount, 0)
				,dblAmountDue					= ISNULL(@dblOnAccountAmount, 0)
				,dblBaseAmountDue				= ISNULL(@dblOnAccountAmount, 0)
				,strInvoiceReportNumber			= IFP.strInvoiceNumber
				,intCurrencyExchangeRateTypeId	= IFP.intCurrencyExchangeRateTypeId
				,intCurrencyExchangeRateId		= IFP.intCurrencyExchangeRateId
				,dblCurrencyExchangeRate		= IFP.dblCurrencyExchangeRate
			FROM #POSPAYMENTS POSPAYMENTS
			INNER JOIN tblARPOS POS ON POSPAYMENTS.intPOSId = POS.intPOSId
			INNER JOIN vyuARInvoicesForPayment IFP ON POS.intInvoiceId = IFP.intInvoiceId
			INNER JOIN tblSMCompanyLocation CL ON IFP.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			CROSS APPLY (
				SELECT TOP 1 intPaymentMethodID
						   , strPaymentMethod
				FROM tblSMPaymentMethod WITH (NOLOCK)
				WHERE ((POSPAYMENTS.strPaymentMethod = 'Debit Card' AND strPaymentMethod LIKE '%debit%') OR (POSPAYMENTS.strPaymentMethod <> 'Debit Card' AND strPaymentMethod = POSPAYMENTS.strPaymentMethod))
			) PM
			WHERE IFP.ysnExcludeForPayment = 0
			  AND IFP.ysnPosted = 1
			  AND IFP.ysnPaid = 0

			--PROCESS TO RCV
			EXEC [dbo].[uspARProcessPayments] @PaymentEntries	= @EntriesForPayment
											, @UserId			= 1
											, @GroupingOption	= 5
											, @RaiseError		= 1
											, @ErrorMessage		= @ErrorMessage OUTPUT
											, @LogId			= @LogId OUTPUT

			--GET NEWLY CREATED PAYMENT IDs
			SELECT @strPaymentIds = LEFT(intPaymentId, LEN(intPaymentId) - 1)
			FROM (
				SELECT CAST(intPaymentId AS VARCHAR(200))  + ', '
				FROM tblARPaymentIntegrationLogDetail 
				WHERE intIntegrationLogId = @LogId 
				  AND ysnSuccess = 1 
				  AND ysnHeader = 1
			FOR XML PATH ('')
			) INV (intPaymentId)

			--POST PAYMENT
			EXEC [dbo].[uspARPostPayment] @post = 1
										, @recap = 0
										, @param = @strPaymentIds
										, @userId = @intEntityUserId
										, @raiseError = 1

			--UPDATE POS PAYMENTS REFERENCE
			UPDATE POSPAYMENT
			SET intPaymentId = CREATEDPAYMENTS.intPaymentId
			FROM tblARPOSPayment POSPAYMENT
			INNER JOIN (
				SELECT intPaymentId
					 , strPaymentMethod
				FROM tblARPayment P
				INNER JOIN fnGetRowsFromDelimitedValues(@strPaymentIds) CP ON P.intPaymentId = CP.intID
			) CREATEDPAYMENTS ON POSPAYMENT.strPaymentMethod = CREATEDPAYMENTS.strPaymentMethod
			INNER JOIN #POSPAYMENTS PP ON POSPAYMENT.intPOSPaymentId = PP.intPOSPaymentId

			--UPDATE POS ENDING BALANCE
			UPDATE POSLOG
			SET dblEndingBalance = ISNULL(POSLOG.dblEndingBalance,0) + POSTPAYMENT.dblAmount
			FROM tblARPOSLog POSLOG
			INNER JOIN (
				SELECT intPOSLogId
					, intPOSId
				FROM tblARPOS
			) POS ON POS.intPOSLogId = POSLOG.intPOSLogId
			CROSS APPLY (
				SELECT dblAmount = SUM(ISNULL(dblAmount, 0))
				FROM tblARPOSPayment PAY
				WHERE ISNULL(PAY.strPaymentMethod, '') <> 'On Account'
				  AND PAY.intPOSId = POS.intPOSId 
				GROUP BY intPOSId
			) POSTPAYMENT
			WHERE POS.intPOSId = @intPOSId 
		END
END