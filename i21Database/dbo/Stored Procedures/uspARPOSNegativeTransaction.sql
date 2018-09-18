CREATE PROCEDURE [dbo].[uspARPOSNegativeTransaction]
	 @intPOSId				INT
	,@intEntityUserId		INT
	,@ErrorMessage			NVARCHAR(250) OUTPUT
	,@CreatedIvoices		NVARCHAR(MAX)  = NULL OUTPUT
AS
BEGIN

	DECLARE  @strPaymentMethod		VARCHAR(20)
	DECLARE  @EntriesForInvoice 	InvoiceIntegrationStagingTable
			,@TaxDetails 			LineItemTaxDetailStagingTable
			,@intNewInvoiceId		INT = NULL


	BEGIN TRANSACTION

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

	SELECT TOP 1 @strPaymentMethod = strPaymentMethod
	FROM tblARPOSPayment
	WHERE intPOSId = @intPOSId

--CREATE INVOICE *IF CASH PAYMENT THEN CASH REFUND ELSE CREDIT MEMO (On Account)

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
,[strPONumber]
)
SELECT
	 [strTransactionType]					= CASE WHEN @strPaymentMethod = 'Cash' THEN 'Cash Refund' ELSE 'Credit Memo' END
	,[strType]								= 'POS'
	,[strSourceTransaction]					= 'POS'
	,[intSourceId]							= POS.intPOSId
	,[strSourceId]							= POS.strReceiptNumber
	,[intEntityCustomerId]					= POS.intEntityCustomerId
	,[intCompanyLocationId]					= POS.intCompanyLocationId
	,[intCurrencyId]						= POS.intCurrencyId
	,[dtmDate]								= POS.dtmDate
	,[dtmShipDate]							= POS.dtmDate
	,[strComments]							= POS.strComment
	,[intEntityId]							= POS.intEntityUserId
	,[ysnPost]								= 1
	,[intItemId]							= DETAILS.intItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= DETAILS.strItemDescription 
	,[intItemUOMId]							= DETAILS.intItemUOMId
	,[dblQtyShipped]						= DETAILS.dblQuantity 
	,[dblDiscount]							= DETAILS.dblDiscountPercent
	,[dblPrice]								= DETAILS.dblPrice
	,[ysnRefreshPrice]						= 0
	,[ysnRecomputeTax]						= 1
	,[ysnClearDetailTaxes]					= 1
	,[intTempDetailIdForTaxes]				= @intPOSId
	,[dblCurrencyExchangeRate]				= 1.000000
	,[dblSubCurrencyRate]					= 1.000000
	,[intSalesAccountId]					= NULL
	,[strPONumber]							= POS.strPONumber
FROM tblARPOS POS 
INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
WHERE POS.intPOSId = @intPOSId

UNION ALL

SELECT TOP 1
	 [strTransactionType]					= 'Cash'--'CASE WHEN @strPaymentMethod = 'Cash' THEN 'Cash Refund' ELSE 'Credit Memo' END
	,[strType]								= 'POS'
	,[strSourceTransaction]					= 'POS'
	,[intSourceId]							= POS.intPOSId
	,[strSourceId]							= POS.strReceiptNumber
	,[intEntityCustomerId]					= POS.intEntityCustomerId
	,[intCompanyLocationId]					= POS.intCompanyLocationId
	,[intCurrencyId]						= POS.intCurrencyId
	,[dtmDate]								= POS.dtmDate
	,[dtmShipDate]							= POS.dtmDate
	,[strComments]							= POS.strComment
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
	,[strPONumber]							= POS.strPONumber
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

IF(@strPaymentMethod = 'Cash')
BEGIN
	IF ISNULL(@CreatedIvoices, '') <> '' AND ISNULL(@ErrorMessage, '') = ''
	BEGIN
		DECLARE @dblInvoiceTotal	NUMERIC(18, 6) = 0
			  , @dblTotalAmountPaid	NUMERIC(18, 6) = 0
			  , @dblCounter			NUMERIC(18, 6) = 0

		SELECT TOP 1 @intNewInvoiceId = intInvoiceId
				   , @dblInvoiceTotal = dblInvoiceTotal
		FROM tblARInvoice I 
		INNER JOIN fnGetRowsFromDelimitedValues(@CreatedIvoices) CI ON I.intInvoiceId = CI.intID

		DECLARE   @EntriesForPayment	PaymentIntegrationStagingTable
				, @LogId				INT	= NULL
				, @newPaymentId			INT = NULL

		INSERT INTO @EntriesForPayment(
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
				,ysnPost
			)
			SELECT
					 intId							= PAYMENT.intPOSPaymentId
					,strSourceTransaction			= 'Direct'
					,intSourceId					= IFP.intInvoiceId
					,strSourceId					= IFP.strInvoiceNumber
					,intEntityCustomerId			= IFP.intEntityCustomerId
					,intCompanyLocationId			= IFP.intCompanyLocationId
					,intCurrencyId					= IFP.intCurrencyId
					,dtmDatePaid					= GETDATE()
					,intPaymentMethodId				= PM.intPaymentMethodId
					,strPaymentMethod				= PM.strPaymentMethod
					,strPaymentInfo					= PAYMENT.strPaymentMethod
					,intBankAccountId				= BANK.intBankAccountId
					,dblAmountPaid					= ISNULL(PAYMENT.dblAmount, 0)
					,intEntityId					= @intEntityUserId
					,intInvoiceId					= IFP.intInvoiceId
					,strTransactionType				= IFP.strTransactionType
					,strTransactionNumber			= IFP.strInvoiceNumber
					,intTermId						= IFP.intTermId
					,intInvoiceAccountId			= IFP.intAccountId
					,dblInvoiceTotal				= IFP.dblInvoiceTotal
					,dblBaseInvoiceTotal			= IFP.dblBaseInvoiceTotal
					,dblPayment						= ISNULL(PAYMENT.dblAmount, 0)
					,dblAmountDue					= 0
					,dblBaseAmountDue				= 0
					,strInvoiceReportNumber			= IFP.strInvoiceNumber
					,intCurrencyExchangeRateTypeId	= IFP.intCurrencyExchangeRateTypeId
					,intCurrencyExchangeRateId		= IFP.intCurrencyExchangeRateId
					,dblCurrencyExchangeRate		= IFP.dblCurrencyExchangeRate
					,ysnPost						= 1
			FROM tblARPOSPayment PAYMENT
			INNER JOIN tblARPOS POS ON PAYMENT.intPOSId = POS.intPOSId
			INNER JOIN vyuARInvoicesForPayment IFP ON POS.intInvoiceId = IFP.intInvoiceId
			INNER JOIN tblSMCompanyLocation LOC ON IFP.intCompanyLocationId = LOC.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BANK ON LOC.intCashAccount = BANK.intGLAccountId
			CROSS APPLY (
				SELECT TOP 1
						 intPaymentMethodId
						,strPaymentMethod
				FROM tblSMPaymentMethod WITH (NOLOCK)
				WHERE (
						(PAYMENT.strPaymentMethod = 'Debit Card' AND strPaymentMethod LIKE '%debit%')
					OR  (PAYMENT.strPaymentMethod <> 'Debit Card' AND strPaymentMethod = PAYMENT.strPaymentMethod))
			) PM
			WHERE IFP.ysnExcludeForPayment = 0
				AND IFP.ysnPosted = 1
				AND IFP.ysnPaid = 0

			--CREATE RCV FOR Cash Refund Invoice
			EXEC [dbo].[uspARProcessPayments]
						 @PaymentEntries	= @EntriesForPayment
						, @UserId			= 1
						, @GroupingOption	= 5
						, @RaiseError		= 1
						, @ErrorMessage		= @ErrorMessage OUTPUT
						, @LogId			= @LogId OUTPUT
			
			--GET CREATED PAYMENT ID
			SELECT @newPaymentId = intPaymentId
			FROM tblARPaymentIntegrationLogDetail 
			WHERE intIntegrationLogId = @LogId 
				AND ysnSuccess = 1 
				AND ysnHeader = 1

			
			UPDATE tblARPOSPayment
				SET intPaymentId = @newPaymentId
			WHERE intPOSId = @intPOSId

			UPDATE EOD
			SET dblExpectedEndingBalance = ISNULL(EOD.dblExpectedEndingBalance, 0) + PAYMENT.dblAmount
			FROM tblARPOSEndOfDay EOD
			INNER JOIN(   
				SELECT
					intPOSLogId
					,intPOSEndOfDayId
				FROM tblARPOSLog
			) POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
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
			) PAYMENT
			WHERE POS.intPOSId = @intPOSId 
	END

END

END