CREATE PROCEDURE [dbo].[uspARPOSNegativeTransaction]
	 @intPOSId				INT
	,@intEntityUserId		INT
	,@ErrorMessage			NVARCHAR(250) OUTPUT
	,@CreatedIvoices		NVARCHAR(MAX)  = NULL OUTPUT
AS
BEGIN

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


--CREATE CREDIT MEMO

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
,[ysnPost]
,[intFreightTermId]
)
SELECT
	 [strTransactionType]					= 'Credit Memo'
	,[strType]								= 'POS'
	,[strSourceTransaction]					= 'POS'
	,[intSourceId]							= POS.intPOSId
	,[strSourceId]							= POS.strReceiptNumber
	,[intEntityCustomerId]					= POS.intEntityCustomerId
	,[intCompanyLocationId]					= POS.intCompanyLocationId
	,[intCurrencyId]						= POS.intCurrencyId
	,[dtmDate]								= POS.dtmDate
	,[dtmShipDate]							= POS.dtmDate
	,[strComments]							= '<p><span style="font-family: Arial;">' + POS.strComment + '</span></p>'
	,[intEntityId]							= POS.intEntityUserId
	,[intItemId]							= DETAILS.intItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= DETAILS.strItemDescription 
	,[intItemUOMId]							= DETAILS.intItemUOMId
	,[dblQtyShipped]						= ABS(DETAILS.dblQuantity)
	,[dblDiscount]							= 0
	,[dblPrice]								= (DETAILS.dblExtendedPrice / DETAILS.dblQuantity)
	,[ysnRefreshPrice]						= 0
	,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt, 0) = 0 THEN 1 ELSE 0 END
	,[ysnClearDetailTaxes]					= 1
	,[intTempDetailIdForTaxes]				= @intPOSId
	,[dblCurrencyExchangeRate]				= 1.000000
	,[dblSubCurrencyRate]					= 1.000000
	,[intSalesAccountId]					= NULL
	,[strPONumber]							= POS.strPONumber
	,[ysnPost]								= 1
	,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
FROM tblARPOS POS 
INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
WHERE POS.intPOSId = @intPOSId

UNION ALL

SELECT TOP 1
	 [strTransactionType]					= 'Credit Memo'
	,[strType]								= 'POS'
	,[strSourceTransaction]					= 'POS'
	,[intSourceId]							= POS.intPOSId
	,[strSourceId]							= POS.strReceiptNumber
	,[intEntityCustomerId]					= POS.intEntityCustomerId
	,[intCompanyLocationId]					= POS.intCompanyLocationId
	,[intCurrencyId]						= POS.intCurrencyId
	,[dtmDate]								= POS.dtmDate
	,[dtmShipDate]							= POS.dtmDate
	,[strComments]							= '<p><span style="font-family: Arial;">' + POS.strComment + '</span></p>'
	,[intEntityId]							= POS.intEntityUserId
	,[intItemId]							= NULL
	,[ysnInventory]							= 0
	,[strItemDescription]					= 'POS Discount - ' + CAST(CAST(POS.dblDiscountPercent AS INT) AS VARCHAR(3)) + '%'
	,[intItemUOMId]							= NULL
	,[dblQtyShipped]						= 1.000000
	,[dblDiscount]							= NULL
	,[dblPrice]								= POS.dblDiscount * -1
	,[ysnRefreshPrice]						= 0
	,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt, 0) = 0 THEN 1 ELSE 0 END
	,[ysnClearDetailTaxes]					= 1
	,[intTempDetailIdForTaxes]				= @intPOSId
	,[dblCurrencyExchangeRate]				= 1.000000
	,[dblSubCurrencyRate]					= 1.000000
	,[intSalesAccountId]					= ISNULL(COMPANYLOC.intDiscountAccountId, COMPANYPREF.intDiscountAccountId)
	,[strPONumber]							= POS.strPONumber
	,[ysnPost]								= 1
	,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN COMPANYLOC.intFreightTermId ELSE NULL END
FROM tblARPOS POS
OUTER APPLY (
	SELECT TOP 1 intDiscountAccountId 
	FROM tblARCompanyPreference WITH (NOLOCK)
) COMPANYPREF
LEFT JOIN (
	SELECT intDiscountAccountId
	     , intCompanyLocationId
		 , intFreightTermId
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
			
		
		UPDATE tblARPOS
		SET ysnReturn = 1, intInvoiceId = @createdCreditMemoId
		WHERE intPOSId = @intPOSId
		
		-- UPDATE tblARInvoice
		-- SET ysnProcessed = 1
		-- FROM tblARInvoice
		-- WHERE intInvoiceId = @createdCreditMemoId

		IF(OBJECT_ID('tempdb..#POSRETURNPAYMENTS') IS NOT NULL)
		BEGIN
			DROP TABLE #POSRETURNPAYMENTS
		END

		SELECT intPOSId			= intPOSId
			 , intPOSPaymentId	= intPOSPaymentId
			 , strPaymentMethod	= CASE WHEN strPaymentMethod ='Credit Card' THEN 'Manual Credit Card' ELSE strPaymentMethod END
			 , strReferenceNo	= strReferenceNo
			 , dblAmount		= dblAmount
			 , ysnComputed		= CAST(0 AS BIT)
		INTO #POSRETURNPAYMENTS
		FROM dbo.tblARPOSPayment WITH (NOLOCK)
		WHERE intPOSId = @intPOSId
		AND ISNULL(strPaymentMethod, '')  <> 'On Account'

		IF EXISTS(SELECT TOP 1 NULL FROM #POSRETURNPAYMENTS)
		BEGIN
			EXEC uspARPOSCreateNegativeCashReceipts 
						 @intInvoiceId			= @createdCreditMemoId
						,@intUserId				= @intEntityUserId
						,@intCompanyLocationId	= @intCompanyLocationId
						,@strErrorMessage		= @strMessage	OUTPUT
		END

		IF(LEN(ISNULL(@strMessage, '')) <= 0)
		BEGIN
			SET @strMessage = NULL

			UPDATE tblARPOSEndOfDay
			SET dblCashReturn = ISNULL(dblCashReturn,0) + POSPAYMENT.dblAmount
			FROM tblARPOSEndOfDay EOD
			INNER JOIN (
				SELECT intPOSLogId
						,intPOSEndOfDayId
				FROM tblARPOSLog
			)POSLOG ON EOD.intPOSEndOfDayId = POSLOG.intPOSEndOfDayId
			INNER JOIN(
				SELECT intPOSId
						,intPOSLogId
				FROM tblARPOS
			)POS ON POSLOG.intPOSLogId = POS.intPOSLogId
			INNER JOIN(
				SELECT intPOSId
				, SUM(ABS(dblAmount)) AS dblAmount
				FROM tblARPOSPayment
				WHERE strPaymentMethod = 'Cash' OR strPaymentMethod = 'Check'
				GROUP BY intPOSId, dblAmount
			)POSPAYMENT ON POS.intPOSId = POSPAYMENT.intPOSId
			WHERE POS.intPOSId = @intPOSId
		END
		ELSE
		BEGIN
			DELETE FROM tblARPOSPayment
			WHERE intPOSId = @intPOSId
			RETURN 0;
		END


	END
ELSE
	BEGIN
		DELETE FROM tblARPOSPayment
		WHERE intPOSId = @intPOSId
		ROLLBACK TRANSACTION
		RETURN 0;
	END

END