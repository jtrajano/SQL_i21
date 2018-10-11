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
			,@intPaymentMethodID	INT = NULL


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

	SELECT TOP 1 @strPaymentMethod = strPaymentMethod
	FROM tblARPOSPayment
	WHERE intPOSId = @intPOSId

	SELECT @intPaymentMethodID = intPaymentMethodID 
	FROM tblSMPaymentMethod
	WHERE strPaymentMethod = @strPaymentMethod

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
	 [strTransactionType]					= 'Credit Memo'--CASE WHEN @strPaymentMethod = 'Cash' THEN 'Cash Refund' ELSE 'Credit Memo' END
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
	,[intItemId]							= DETAILS.intItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= DETAILS.strItemDescription 
	,[intItemUOMId]							= DETAILS.intItemUOMId
	,[dblQtyShipped]						= ABS(DETAILS.dblQuantity)
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
	 [strTransactionType]					= 'Credit Memo'--CASE WHEN @strPaymentMethod = 'Cash' THEN 'Cash Refund' ELSE 'Credit Memo' END
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
								, @GroupingOption		= 12
								, @RaiseError			= 1
								, @ErrorMessage			= @ErrorMessage OUTPUT
								, @CreatedIvoices		= @CreatedIvoices OUTPUT

								
IF ISNULL(@ErrorMessage, '') = ''
	BEGIN
		COMMIT TRANSACTION
		
		UPDATE I
		SET dblDiscountAvailable = 0.000000
			,dblBaseDiscountAvailable = 0.000000
		FROM tblARInvoice I 
		INNER JOIN (
			SELECT intID
			FROM fnGetRowsFromDelimitedValues(@CreatedIvoices)
		)CI ON I.intInvoiceId = CI.intID

		DECLARE @createdCreditMemoId AS INT = 0,
				@createdCreditMemoType AS VARCHAR(50),
				@createdCreditMemoTransactionType AS VARCHAR(20),
				@intCompanyLocationId AS INT,
				@strMessage	AS VARCHAR(100)

		SELECT TOP 1
				@createdCreditMemoId				= intInvoiceId,
				@createdCreditMemoType				= strType,
				@createdCreditMemoTransactionType	= strTransactionType,
				@intCompanyLocationId				= intCompanyLocationId
		FROM tblARInvoice
		WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))
			
		EXEC uspARPostInvoice @param = @createdCreditMemoId, @post = 1
		
		UPDATE tblARInvoice
		SET ysnProcessed = 1
		FROM tblARInvoice
		WHERE intInvoiceId = @createdCreditMemoId
			
		IF(@strPaymentMethod = 'Cash')
		BEGIN
			EXEC uspARPOSCreateNegativeCashReceipts 
						 @intInvoiceId			= @createdCreditMemoId
						,@intUserId				= @intEntityUserId
						,@intCompanyLocationId	= @intCompanyLocationId
						,@intPaymentMethodID	= @intPaymentMethodID
						,@strErrorMessage		= @strMessage	OUTPUT
		END

		IF(LEN(ISNULL(@strMessage, '')) <= 0)
		BEGIN
			UPDATE tblARPOS
			SET ysnReturn = 1
			WHERE intPOSId = @intPOSId
				
			SET @strMessage = NULL
		END


	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

END