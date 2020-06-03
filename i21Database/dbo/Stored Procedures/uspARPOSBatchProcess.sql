CREATE PROCEDURE [dbo].[uspARPOSBatchProcess]
	  @intPOSEndOfDayId	INT
	, @intPOSId			INT = NULL
	, @intEntityUserId	INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @EntriesForInvoice 				InvoiceStagingTable
DECLARE @TaxDetails 					LineItemTaxDetailStagingTable
DECLARE @EntriesForPayment				PaymentIntegrationStagingTable
DECLARE @intDiscountAccountId			INT = NULL
	  , @intCashPaymentMethodId			INT = NULL
	  , @intDebitMemoPaymentMethodId	INT = NULL
	  , @dblCashReceipt					NUMERIC(18, 6) = 0
	  , @dblCashReturn					NUMERIC(18, 6) = 0

SET @intPOSId = NULLIF(@intPOSId, 0)
SET @intEntityUserId = NULLIF(@intEntityUserId, 0)

IF @intEntityUserId IS NULL
	SELECT TOP 1 @intEntityUserId = intEntityId FROM tblSMUserSecurity

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
IF NOT EXISTS (SELECT TOP 1 NULL FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'DEBIT MEMOS AND PAYMENTS')
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			  strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = 'Debit Memos and Payments'
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1
	END

SELECT TOP 1 @intDiscountAccountId = intDiscountAccountId FROM tblARCompanyPreference WITH (NOLOCK)
SELECT TOP 1 @intCashPaymentMethodId = intPaymentMethodID FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'CASH'
SELECT TOP 1 @intDebitMemoPaymentMethodId = intPaymentMethodID FROM dbo.tblSMPaymentMethod WITH (NOLOCK) WHERE UPPER(strPaymentMethod) = 'DEBIT MEMOS AND PAYMENTS'

--TEMP TABLES
IF(OBJECT_ID('tempdb..#POSTRANSACTIONS') IS NOT NULL)
BEGIN
	DROP TABLE #POSTRANSACTIONS
END

IF(OBJECT_ID('tempdb..#POSPAYMENTS') IS NOT NULL)
BEGIN
	DROP TABLE #POSPAYMENTS
END

CREATE TABLE #POSTRANSACTIONS (
	  intPOSId			INT
	, intEntityUserId	INT
	, strPOSType		NVARCHAR(100)
)

--GET POS TRANSACTIONS
INSERT INTO #POSTRANSACTIONS (
	   intPOSId
	, intEntityUserId
	, strPOSType
)
SELECT intPOSId			= POS.intPOSId
	, intEntityUserId	= POS.intEntityUserId
	, strPOSType		= 'Regular'
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
OUTER APPLY (
	SELECT TOP 1 POSD.intPOSId
	FROM tblARPOSDetail POSD
	WHERE POSD.dblQuantity < 0 
	  AND POSD.intPOSId = POS.intPOSId
	GROUP BY intPOSId	
) NEGQTY
WHERE POS.ysnHold = 0
  AND POS.intInvoiceId IS NULL
  AND POS.intCreditMemoId IS NULL
  AND POS.dblTotal > 0
  AND NEGQTY.intPOSId IS NULL
  AND EOD.intPOSEndOfDayId = @intPOSEndOfDayId
  AND (@intPOSId IS NULL OR POS.intPOSId = @intPOSId)

UNION ALL

SELECT intPOSId			= POS.intPOSId
	 , intEntityUserId	= POS.intEntityUserId
	 , strPOSType		= 'Returned'
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
WHERE ((POS.ysnReturn = 1 AND POS.intOriginalPOSTransactionId IS NOT NULL) OR (POS.ysnReturn = 0 AND POS.intItemCount = 0))
  AND POS.ysnHold = 0
  AND POS.intInvoiceId IS NULL
  AND POS.intCreditMemoId IS NULL
  AND POS.dblTotal < 0
  AND EOD.intPOSEndOfDayId = @intPOSEndOfDayId
  AND (@intPOSId IS NULL OR POS.intPOSId = @intPOSId)

UNION ALL

SELECT intPOSId			= POS.intPOSId
	 , intEntityUserId	= POS.intEntityUserId
	 , strPOSType		= 'Mixed'
FROM tblARPOS POS
INNER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
INNER JOIN tblARPOSEndOfDay EOD ON POSLOG.intPOSEndOfDayId = EOD.intPOSEndOfDayId
CROSS APPLY (
	SELECT TOP 1 POSD.intPOSId
	FROM tblARPOSDetail POSD
	WHERE POSD.dblQuantity < 0 
	  AND POSD.intPOSId = POS.intPOSId
	GROUP BY intPOSId	
) NEGQTY
CROSS APPLY (
	SELECT TOP 1 POSD.intPOSId
	FROM tblARPOSDetail POSD
	WHERE POSD.dblQuantity > 0 
	  AND POSD.intPOSId = POS.intPOSId
	GROUP BY intPOSId	
) POSQTY
WHERE POS.ysnReturn = 0
  AND POS.ysnHold = 0
  AND POS.intInvoiceId IS NULL
  AND POS.intCreditMemoId IS NULL
  AND EOD.intPOSEndOfDayId = @intPOSEndOfDayId
  AND (@intPOSId IS NULL OR POS.intPOSId = @intPOSId)

--CLEAR BATCH PROCESS LOG
DELETE BP
FROM tblARPOSBatchProcessLog BP
INNER JOIN #POSTRANSACTIONS REG ON BP.intPOSId = REG.intPOSId

--PROCESS REGULAR TRANSACTIONS
IF EXISTS (SELECT TOP 1 NULL FROM #POSTRANSACTIONS)
	BEGIN
		DECLARE @InitTranCount		INT = NULL
			  , @intInvoiceLogId	INT = NULL
			  , @intPaymentLogId	INT = NULL
			  , @strErrorMsg		NVARCHAR(MAX) = NULL			  
			  , @Savepoint			NVARCHAR(32)  = NULL

		SET @InitTranCount = @@TRANCOUNT
		SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

		IF @InitTranCount = 0
			BEGIN TRANSACTION
		ELSE
			SAVE TRANSACTION @Savepoint
		
		BEGIN TRY
			--GET INVOICES AND DISCOUNTS (FOR REGULAR AND RETURN TRANSACTIONS)
			INSERT INTO @EntriesForInvoice(
				 [intId]
				,[strTransactionType]
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
				,[intFreightTermId]
				,[strInvoiceOriginId]
				,[ysnUseOriginIdAsInvoiceNumber]
			)
			SELECT [intId]								= POS.intPOSId
				,[strTransactionType]					= CASE WHEN strPOSType = 'Returned' THEN 'Credit Memo' ELSE 'Invoice' END
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
				,[ysnPost]								= 1
				,[intItemId]							= DETAILS.intItemId
				,[ysnInventory]							= 1
				,[strItemDescription]					= DETAILS.strItemDescription 
				,[intItemUOMId]							= DETAILS.intItemUOMId
				,[dblQtyShipped]						= ABS(DETAILS.dblQuantity)
				,[dblDiscount]							= 0
				,[dblPrice]								= ABS((DETAILS.dblExtendedPrice / DETAILS.dblQuantity))
				,[ysnRefreshPrice]						= 0
				,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
				,[ysnClearDetailTaxes]					= 1
				,[intTempDetailIdForTaxes]				= POS.intPOSId
				,[dblCurrencyExchangeRate]				= 1.000000
				,[dblSubCurrencyRate]					= 1.000000
				,[intSalesAccountId]					= NULL
				,[strPONumber]							= POS.strPONumber
				,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
				,[strInvoiceOriginId]					= CASE WHEN strPOSType = 'Returned' THEN ISNULL(POS.strCreditMemoNumber, POS.strInvoiceNumber) ELSE POS.strInvoiceNumber END
				,[ysnUseOriginIdAsInvoiceNumber]		= CAST(1 AS BIT)
			FROM tblARPOS POS 
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			WHERE RT.strPOSType NOT IN ('Mixed')

			UNION ALL

			SELECT TOP 1 [intId]						= POS.intPOSId
				,[strTransactionType]					= CASE WHEN strPOSType = 'Returned' THEN 'Credit Memo' ELSE 'Invoice' END
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
				,[ysnPost]								= 1
				,[intItemId]							= NULL
				,[ysnInventory]							= 0
				,[strItemDescription]					= 'POS Discount - ' + CAST(CAST(POS.dblDiscountPercent AS INT) AS VARCHAR(3)) + '%'
				,[intItemUOMId]							= NULL
				,[dblQtyShipped]						= 1.000000
				,[dblDiscount]							= NULL
				,[dblPrice]								= POS.dblDiscount * -1
				,[ysnRefreshPrice]						= 0
				,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
				,[ysnClearDetailTaxes]					= 1
				,[intTempDetailIdForTaxes]				= POS.intPOSId
				,[dblCurrencyExchangeRate]				= 1.000000
				,[dblSubCurrencyRate]					= 1.000000
				,[intSalesAccountId]					= ISNULL(CL.intSalesDiscounts, @intDiscountAccountId)
				,[strPONumber]							= POS.strPONumber
				,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
				,[strInvoiceOriginId]					= CASE WHEN strPOSType = 'Returned' THEN ISNULL(POS.strCreditMemoNumber, POS.strInvoiceNumber) ELSE POS.strInvoiceNumber END
				,[ysnUseOriginIdAsInvoiceNumber]		= CAST(1 AS BIT)
			FROM tblARPOS POS
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			WHERE ISNULL(POS.dblDiscountPercent, 0) > 0
			   AND RT.strPOSType NOT IN ('Mixed')

			--GET INVOICES AND DISCOUNTS (INVOICE FOR MIXED TRANSACTIONS)
			INSERT INTO @EntriesForInvoice(
				 [intId]
				,[strTransactionType]
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
				,[intFreightTermId]
				,[strInvoiceOriginId]
				,[ysnUseOriginIdAsInvoiceNumber]
			)
			SELECT [intId]								= POS.intPOSId
				,[strTransactionType]					= 'Invoice'
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
				,[dblDiscount]							= 0
				,[dblPrice]								= (DETAILS.dblExtendedPrice / DETAILS.dblQuantity)
				,[ysnRefreshPrice]						= 0
				,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
				,[ysnClearDetailTaxes]					= 1
				,[intTempDetailIdForTaxes]				= POS.intPOSId
				,[dblCurrencyExchangeRate]				= 1.000000
				,[dblSubCurrencyRate]					= 1.000000
				,[intSalesAccountId]					= NULL
				,[strPONumber]							= POS.strPONumber
				,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
				,[strInvoiceOriginId]					= POS.strInvoiceNumber
				,[ysnUseOriginIdAsInvoiceNumber]		= CAST(1 AS BIT)
			FROM tblARPOS POS
			INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			WHERE DETAILS.dblQuantity > 0
			  AND RT.strPOSType = 'Mixed'

			UNION ALL

			SELECT TOP 1
				 [intId]								= POS.intPOSId
				,[strTransactionType]					= 'Invoice'
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
				,[dblPrice]								= ABS(POS.dblDiscount) * -1
				,[ysnRefreshPrice]						= 0
				,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
				,[ysnClearDetailTaxes]					= 1
				,[intTempDetailIdForTaxes]				= POS.intPOSId
				,[dblCurrencyExchangeRate]				= 1.000000
				,[dblSubCurrencyRate]					= 1.000000
				,[intSalesAccountId]					= ISNULL(CL.intSalesDiscounts, @intDiscountAccountId)
				,[strPONumber]							= POS.strPONumber
				,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
				,[strInvoiceOriginId]					= POS.strInvoiceNumber
				,[ysnUseOriginIdAsInvoiceNumber]		= CAST(1 AS BIT)
			FROM tblARPOS POS
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			WHERE ISNULL(dblDiscountPercent, 0) > 0
			  AND RT.strPOSType = 'Mixed'

			--GET INVOICES (CREDIT MEMO FOR MIXED TRANSACTIONS)
			INSERT INTO @EntriesForInvoice(
				 [intId]
				,[strTransactionType]
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
				,[intFreightTermId]
				,[strInvoiceOriginId]
				,[ysnUseOriginIdAsInvoiceNumber]
			)
			SELECT [intId]								= POS.intPOSId + 10000 --TEMPORARAY FIX
				,[strTransactionType]					= 'Credit Memo'
				,[strType]								= 'POS'
				,[strSourceTransaction]					= 'POS'
				,[intSourceId]							= POS.intPOSId
				,[strSourceId]							= POS.strReceiptNumber
				,[intEntityCustomerId]					= POS.intEntityCustomerId
				,[intCompanyLocationId]					= POS.intCompanyLocationId
				,[intCurrencyId]						= POS.intCurrencyId
				,[dtmDate]								= POS.dtmDate
				,[dtmShipDate]							= POS.dtmDate
				,[strComments]							= 'POS Return:' + ISNULL(POS.strComment, '')
				,[intEntityId]							= POS.intEntityUserId
				,[ysnPost]								= 1
				,[intItemId]							= DETAILS.intItemId
				,[ysnInventory]							= 1
				,[strItemDescription]					= DETAILS.strItemDescription 
				,[intItemUOMId]							= DETAILS.intItemUOMId
				,[dblQtyShipped]						= ABS(DETAILS.dblQuantity)
				,[dblDiscount]							= 0
				,[dblPrice]								= (DETAILS.dblExtendedPrice / DETAILS.dblQuantity)
				,[ysnRefreshPrice]						= 0
				,[ysnRecomputeTax]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN 1 ELSE 0 END
				,[ysnClearDetailTaxes]					= 1
				,[intTempDetailIdForTaxes]				= POS.intPOSId
				,[dblCurrencyExchangeRate]				= 1.000000
				,[dblSubCurrencyRate]					= 1.000000
				,[intSalesAccountId]					= NULL
				,[strPONumber]							= POS.strPONumber
				,[intFreightTermId]						= CASE WHEN ISNULL(POS.ysnTaxExempt,0) = 0 THEN CL.intFreightTermId ELSE NULL END
				,[strInvoiceOriginId]					= POS.strCreditMemoNumber
				,[ysnUseOriginIdAsInvoiceNumber]		= CAST(1 AS BIT)
			FROM tblARPOS POS 
			INNER JOIN tblARPOSDetail DETAILS ON POS.intPOSId = DETAILS.intPOSId
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			WHERE DETAILS.dblQuantity < 0
			  AND RT.strPOSType = 'Mixed'

			--PROCESS TO INVOICE
			EXEC dbo.uspARProcessInvoicesByBatch @InvoiceEntries		= @EntriesForInvoice
											   , @LineItemTaxEntries	= @TaxDetails
											   , @UserId				= @intEntityUserId
											   , @GroupingOption		= 11
											   , @RaiseError			= 0
											   , @ErrorMessage			= @strErrorMsg OUT
											   , @LogId					= @intInvoiceLogId OUT

			--UPDATE POS BATCH LOG
			INSERT INTO tblARPOSBatchProcessLog (
				   intPOSId
				 , strDescription
				 , ysnSuccess
				 , dtmDateProcessed
			) 
			SELECT intPOSId				= POS.intPOSId
				 , strMessage			= CASE WHEN ISNULL(ysnSuccess, 0) = 1 AND ISNULL(ysnPosted, 0) = 1 
											   THEN 'Successfully Processed.' 
											   ELSE 
													CASE WHEN ISNULL(ysnSuccess, 0) = 0 
													     THEN I.strMessage
														 WHEN ISNULL(ysnPosted, 0) = 0
														 THEN I.strPostingMessage
													END													 
										  END
				 , ysnSuccess			= CASE WHEN ISNULL(ysnSuccess, 0) = 1 AND ISNULL(ysnPosted, 0) = 1 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
				 , dtmDateProcessed		= GETDATE()
			FROM tblARPOS POS
			INNER JOIN tblARInvoiceIntegrationLogDetail I ON POS.intPOSId = I.intSourceId AND POS.strReceiptNumber = I.strSourceId
			WHERE intIntegrationLogId = @intInvoiceLogId
			  AND ISNULL(ysnHeader, 0) = 1

			--UPDATE INVOICE REFERENCE TO POS
			UPDATE POS
			SET intInvoiceId	= II.intInvoiceId
			FROM tblARPOS POS
			INNER JOIN tblARInvoiceIntegrationLogDetail II ON POS.intPOSId = II.intSourceId AND POS.strReceiptNumber = II.strSourceId
			WHERE II.intIntegrationLogId = @intInvoiceLogId
			  AND ISNULL(II.ysnHeader, 0) = 1
			  AND ISNULL(II.ysnSuccess, 0) = 1
			  AND II.strTransactionType = 'Invoice'

			UPDATE POS
			SET intCreditMemoId	= II.intInvoiceId
			FROM tblARPOS POS
			INNER JOIN tblARInvoiceIntegrationLogDetail II ON POS.intPOSId = II.intSourceId AND POS.strReceiptNumber = II.strSourceId
			WHERE II.intIntegrationLogId = @intInvoiceLogId
			  AND ISNULL(II.ysnHeader, 0) = 1
			  AND ISNULL(II.ysnSuccess, 0) = 1
			  AND II.strTransactionType = 'Credit Memo'

			--GET POS PAYMENTS
			SELECT intPOSId				= POS.intPOSId
				 , intPOSPaymentId		= POSP.intPOSPaymentId
				 , strPaymentMethod		= CASE WHEN POSP.strPaymentMethod = 'Credit Card' THEN 'Manual Credit Card' ELSE POSP.strPaymentMethod END
				 , strReferenceNo		= POSP.strReferenceNo
				 , dblAmount			= POSP.dblAmount
			INTO #POSPAYMENTS
			FROM tblARPOS POS
			INNER JOIN 
			(SELECT DISTINCT intSourceId,
							 strSourceId, 
							 intIntegrationLogId, 
							 ysnHeader, 
							 ysnSuccess, 
							 ysnPosted 
			FROM  tblARInvoiceIntegrationLogDetail) I ON POS.intPOSId = I.intSourceId AND POS.strReceiptNumber = I.strSourceId
			INNER JOIN tblARPOSPayment POSP ON POS.intPOSId = POSP.intPOSId
			WHERE intIntegrationLogId = @intInvoiceLogId
			  AND ISNULL(ysnHeader, 0) = 1
			  AND ISNULL(ysnSuccess, 0) = 1
			  AND ISNULL(ysnPosted, 0) = 1
			  AND ISNULL(strPaymentMethod, '') <> 'On Account'

			--GET POS PAYMENTS (FOR REGULAR AND RETURN TRANSACTIONS) 
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
				,strNotes
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
				,dblCurrencyExchangeRate
				,ysnPost
			)
			SELECT intId						= POSPAYMENTS.intPOSPaymentId
			    ,strSourceTransaction			= 'Direct'
				,intSourceId					= IFP.intInvoiceId
				,strSourceId					= IFP.strInvoiceNumber
				,intEntityCustomerId			= IFP.intEntityCustomerId
				,intCompanyLocationId			= IFP.intCompanyLocationId
				,intCurrencyId					= IFP.intCurrencyId
				,dtmDatePaid					= DATEADD(dd, DATEDIFF(dd, 0, POS.dtmDate), 0)
				,intPaymentMethodId				= PM.intPaymentMethodID
				,strPaymentMethod				= PM.strPaymentMethod
				,strPaymentInfo					= CASE WHEN POSPAYMENTS.strPaymentMethod IN ('Check' ,'Debit Card', 'Manual Credit Card') THEN POSPAYMENTS.strReferenceNo ELSE NULL END
				,strNotes						= CASE WHEN IFP.strTransactionType = 'Credit Memo' THEN 'POS Return' ELSE POS.strReceiptNumber END 
				,intBankAccountId				= BA.intBankAccountId
				,dblAmountPaid					= ABS(ISNULL(POSPAYMENTS.dblAmount, 0)) * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,intEntityId					= @intEntityUserId
				,intInvoiceId					= IFP.intInvoiceId
				,strTransactionType				= IFP.strTransactionType
				,strTransactionNumber			= IFP.strInvoiceNumber
				,intTermId						= IFP.intTermId
				,intInvoiceAccountId			= IFP.intAccountId
				,dblInvoiceTotal				= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblBaseInvoiceTotal			= IFP.dblBaseInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblPayment						= ABS(ISNULL(POSPAYMENTS.dblAmount, 0)) * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblAmountDue					= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblBaseAmountDue				= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,strInvoiceReportNumber			= IFP.strInvoiceNumber
				,dblCurrencyExchangeRate		= IFP.dblCurrencyExchangeRate
				,ysnPost						= CAST(1 AS BIT)
			FROM #POSPAYMENTS POSPAYMENTS
			INNER JOIN tblARPOS POS ON POSPAYMENTS.intPOSId = POS.intPOSId
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblARInvoiceIntegrationLogDetail II ON POS.intPOSId = II.intSourceId AND POS.strReceiptNumber = II.strSourceId
			INNER JOIN tblARInvoice IFP ON IFP.intInvoiceId = CASE WHEN II.strTransactionType = 'Credit Memo' THEN POS.intCreditMemoId ELSE POS.intInvoiceId END
			INNER JOIN tblSMCompanyLocation CL ON IFP.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			CROSS APPLY (
				SELECT TOP 1 intPaymentMethodID
						   , strPaymentMethod
				FROM tblSMPaymentMethod WITH (NOLOCK)
				WHERE ((POSPAYMENTS.strPaymentMethod = 'Debit Card' AND strPaymentMethod = 'Debit Card') OR (POSPAYMENTS.strPaymentMethod <> 'Debit Card' AND strPaymentMethod = POSPAYMENTS.strPaymentMethod))
			) PM
			WHERE IFP.ysnPosted = 1
			  AND IFP.ysnPaid = 0
			  AND II.intIntegrationLogId = @intInvoiceLogId
			  AND ISNULL(II.ysnHeader, 0) = 1
			  AND ISNULL(II.ysnSuccess, 0) = 1
			  AND ISNULL(II.ysnPosted, 0) = 1
			  AND RT.strPOSType <> 'Mixed'


			-- --GET POS PAYMENTS (FOR MIXED TRANSACTIONS)
			-- --IF INV > CM = 2 RCVs (OFFSET [DEBIT MEMO] AND + AMOUNT DUE [CASH])
			-- --IF CM > INV = 2 RCVs (OFFSET [DEBIT MEMO] AND - AMOUNT DUE [CASH])
			INSERT INTO @EntriesForPayment (
				   intId
				 , strSourceTransaction
				 , intSourceId
				 , strSourceId
				 , intEntityCustomerId
				 , intCompanyLocationId
				 , intCurrencyId
				 , dtmDatePaid
				 , intPaymentMethodId
				 , strPaymentMethod
				 , strPaymentInfo
				 , strNotes
				 , intBankAccountId
				 , dblAmountPaid
				 , intEntityId
				 , intInvoiceId
				 , strTransactionType
				 , strTransactionNumber
				 , intTermId
				 , intInvoiceAccountId
				 , dblInvoiceTotal
				 , dblBaseInvoiceTotal
				 , dblPayment
				 , dblAmountDue
				 , dblBaseAmountDue
				 , strInvoiceReportNumber
				 , dblCurrencyExchangeRate
				 , ysnPost
			)
			SELECT intId							= POS.intPOSId
				 , strSourceTransaction				= 'Direct'
				 , intSourceId						= INV.intInvoiceId
				 , strSourceId						= INV.strInvoiceNumber
				 , intEntityCustomerId				= INV.intEntityCustomerId
				 , intCompanyLocationId				= INV.intCompanyLocationId
				 , intCurrencyId					= INV.intCurrencyId
				 , dtmDatePaid						= DATEADD(dd, DATEDIFF(dd, 0, POS.dtmDate), 0)
				 , intPaymentMethodId				= @intDebitMemoPaymentMethodId
				 , strPaymentMethod					= 'Debit Memos and Payments'
				 , strPaymentInfo					= 'POS Exchange Item Transaction'
				 , strNotes							= POS.strReceiptNumber
				 , intBankAccountId					= BA.intBankAccountId
				 , dblAmountPaid					= 0.00
				 , intEntityId						= @intEntityUserId
				 , intInvoiceId						= INV.intInvoiceId
				 , strTransactionType				= INV.strTransactionType
				 , strTransactionNumber				= INV.strInvoiceNumber
				 , intTermId						= INV.intTermId
				 , intInvoiceAccountId				= INV.intAccountId
				 , dblInvoiceTotal					= INV.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)
				 , dblBaseInvoiceTotal				= INV.dblBaseInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)
				 , dblPayment						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN CM.dblAmountDue ELSE INV.dblAmountDue END
				 , dblAmountDue						= INV.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)
				 , dblBaseAmountDue					= INV.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)
				 , strInvoiceReportNumber			= INV.strInvoiceNumber
				 , dblCurrencyExchangeRate			= INV.dblCurrencyExchangeRate
				 , ysnPost							= CAST(1 AS BIT)
			FROM tblARPOS POS 
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblARInvoice INV ON POS.intInvoiceId = INV.intInvoiceId AND INV.strTransactionType = 'Invoice'
			INNER JOIN tblARInvoice CM ON POS.intCreditMemoId = CM.intInvoiceId AND CM.strTransactionType = 'Credit Memo'
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId			
			WHERE POS.intCreditMemoId IS NOT NULL
			  AND POS.intInvoiceId IS NOT NULL
			  AND INV.ysnPosted = 1
			  AND INV.ysnPaid = 0
			  AND RT.strPOSType = 'Mixed'

			UNION ALL

			SELECT intId							= POS.intPOSId
				 , strSourceTransaction				= 'Direct'
				 , intSourceId						= CM.intInvoiceId
				 , strSourceId						= CM.strInvoiceNumber
				 , intEntityCustomerId				= CM.intEntityCustomerId
				 , intCompanyLocationId				= CM.intCompanyLocationId
				 , intCurrencyId					= CM.intCurrencyId
				 , dtmDatePaid						= DATEADD(dd, DATEDIFF(dd, 0, POS.dtmDate), 0)
				 , intPaymentMethodId				= @intDebitMemoPaymentMethodId
				 , strPaymentMethod					= 'Debit Memos and Payments'
				 , strPaymentInfo					= 'POS Exchange Item Transaction'
				 , strNotes							= POS.strReceiptNumber
				 , intBankAccountId					= BA.intBankAccountId
				 , dblAmountPaid					= 0.00
				 , intEntityId						= @intEntityUserId
				 , intInvoiceId						= CM.intInvoiceId
				 , strTransactionType				= CM.strTransactionType
				 , strTransactionNumber				= CM.strInvoiceNumber
				 , intTermId						= CM.intTermId
				 , intInvoiceAccountId				= CM.intAccountId
				 , dblInvoiceTotal					= CM.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(CM.strTransactionType)
				 , dblBaseInvoiceTotal				= CM.dblBaseInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType)
				 , dblPayment						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN CM.dblAmountDue ELSE INV.dblAmountDue END
				 , dblAmountDue						= CM.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(CM.strTransactionType)
				 , dblBaseAmountDue					= CM.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(CM.strTransactionType)
				 , strInvoiceReportNumber			= CM.strInvoiceNumber
				 , dblCurrencyExchangeRate			= CM.dblCurrencyExchangeRate
				 , ysnPost							= CAST(1 AS BIT)
			FROM tblARPOS POS 
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblARInvoice INV ON POS.intInvoiceId = INV.intInvoiceId AND INV.strTransactionType = 'Invoice'
			INNER JOIN tblARInvoice CM ON POS.intCreditMemoId = CM.intInvoiceId AND CM.strTransactionType = 'Credit Memo'
			INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId			
			WHERE POS.intCreditMemoId IS NOT NULL
			  AND POS.intInvoiceId IS NOT NULL
			  AND INV.ysnPosted = 1
			  AND INV.ysnPaid = 0
			  AND RT.strPOSType = 'Mixed'

			-- UNION ALL

			-- SELECT intId							= POS.intPOSId + 10000
			-- 	 , strSourceTransaction				= 'Direct'
			-- 	 , intSourceId						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.intInvoiceId ELSE CM.intInvoiceId END
			-- 	 , strSourceId						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.strInvoiceNumber ELSE CM.strInvoiceNumber END
			-- 	 , intEntityCustomerId				= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.intEntityCustomerId ELSE CM.intEntityCustomerId END
			-- 	 , intCompanyLocationId				= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.intCompanyLocationId ELSE CM.intCompanyLocationId END
			-- 	 , intCurrencyId					= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.intCurrencyId ELSE CM.intCurrencyId END
			-- 	 , dtmDatePaid						= DATEADD(dd, DATEDIFF(dd, 0, POS.dtmDate), 0)
			-- 	 , intPaymentMethodId				= @intCashPaymentMethodId
			-- 	 , strPaymentMethod					= 'Cash'
			-- 	 , strPaymentInfo					= 'POS Settle Amount Due of Exchange Transaction'
			-- 	 , strNotes							= POS.strReceiptNumber
			-- 	 , intBankAccountId					= BA.intBankAccountId
			-- 	 , dblAmountPaid					= INV.dblAmountDue - CM.dblAmountDue
			-- 	 , intEntityId						= @intEntityUserId
			-- 	 , intInvoiceId						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.intInvoiceId ELSE CM.intInvoiceId END
			-- 	 , strTransactionType				= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.strTransactionType ELSE CM.strTransactionType END
			-- 	 , strTransactionNumber				= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.strInvoiceNumber ELSE CM.strInvoiceNumber END
			-- 	 , intTermId						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.intTermId ELSE CM.intTermId END
			-- 	 , intInvoiceAccountId				= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.intAccountId ELSE CM.intAccountId END
			-- 	 , dblInvoiceTotal					= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.dblInvoiceTotal ELSE CM.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(CM.strTransactionType) END
			-- 	 , dblBaseInvoiceTotal				= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.dblBaseInvoiceTotal ELSE CM.dblBaseInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(INV.strTransactionType) END
			-- 	 , dblPayment						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.dblAmountDue - CM.dblAmountDue ELSE CM.dblAmountDue - INV.dblAmountDue END
			-- 	 , dblAmountDue						= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.dblInvoiceTotal ELSE CM.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(CM.strTransactionType) END
			-- 	 , dblBaseAmountDue					= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.dblInvoiceTotal ELSE CM.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(CM.strTransactionType) END
			-- 	 , strInvoiceReportNumber			= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.strInvoiceNumber ELSE CM.strInvoiceNumber END
			-- 	 , dblCurrencyExchangeRate			= CASE WHEN INV.dblAmountDue > CM.dblAmountDue THEN INV.dblCurrencyExchangeRate ELSE CM.dblCurrencyExchangeRate END
			-- 	 , ysnPost							= CAST(1 AS BIT)
			-- FROM tblARPOS POS 
			-- INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			-- INNER JOIN tblARInvoice INV ON POS.intInvoiceId = INV.intInvoiceId AND INV.strTransactionType = 'Invoice'
			-- INNER JOIN tblARInvoice CM ON POS.intCreditMemoId = CM.intInvoiceId AND CM.strTransactionType = 'Credit Memo'
			-- INNER JOIN tblSMCompanyLocation CL ON POS.intCompanyLocationId = CL.intCompanyLocationId
			-- LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId			
			-- WHERE POS.intCreditMemoId IS NOT NULL
			--   AND POS.intInvoiceId IS NOT NULL			  
			--   AND INV.ysnPosted = 1
			--   AND INV.ysnPaid = 0
			--   AND CM.dblAmountDue <> INV.dblAmountDue 
			--   AND RT.strPOSType = 'Mixed'
			

			--GET PAYMENTS for SETTLE AMOUNT DUE FOR INVOICE > CREDIT MEMO
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
				,strNotes
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
				,dblCurrencyExchangeRate
				,ysnPost
			)
			SELECT intId						= POSPAYMENTS.intPOSPaymentId
			    ,strSourceTransaction			= 'Direct'
				,intSourceId					= IFP.intInvoiceId
				,strSourceId					= IFP.strInvoiceNumber
				,intEntityCustomerId			= IFP.intEntityCustomerId
				,intCompanyLocationId			= IFP.intCompanyLocationId
				,intCurrencyId					= IFP.intCurrencyId
				,dtmDatePaid					= DATEADD(dd, DATEDIFF(dd, 0, POS.dtmDate), 0)
				,intPaymentMethodId				= PM.intPaymentMethodID
				,strPaymentMethod				= PM.strPaymentMethod
				,strPaymentInfo					= 'POS Settle Amount Due of Exchange Transaction'
				,strNotes						= CASE WHEN IFP.strTransactionType = 'Credit Memo' THEN 'POS Return' ELSE POS.strReceiptNumber END 
				,intBankAccountId				= BA.intBankAccountId
				,dblAmountPaid					= ABS(ISNULL(POSPAYMENTS.dblAmount, 0)) * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,intEntityId					= @intEntityUserId
				,intInvoiceId					= IFP.intInvoiceId
				,strTransactionType				= IFP.strTransactionType
				,strTransactionNumber			= IFP.strInvoiceNumber
				,intTermId						= IFP.intTermId
				,intInvoiceAccountId			= IFP.intAccountId
				,dblInvoiceTotal				= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblBaseInvoiceTotal			= IFP.dblBaseInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblPayment						= ABS(ISNULL(POSPAYMENTS.dblAmount, 0)) * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblAmountDue					= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblBaseAmountDue				= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,strInvoiceReportNumber			= IFP.strInvoiceNumber
				,dblCurrencyExchangeRate		= IFP.dblCurrencyExchangeRate
				,ysnPost						= CAST(1 AS BIT)
			FROM #POSPAYMENTS POSPAYMENTS
			INNER JOIN tblARPOS POS ON POSPAYMENTS.intPOSId = POS.intPOSId
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblARInvoiceIntegrationLogDetail II ON POS.intPOSId = II.intSourceId AND POS.strReceiptNumber = II.strSourceId
			INNER JOIN (SELECT * FROM tblARInvoice WHERE strTransactionType = 'Invoice' ) IFP ON IFP.intInvoiceId =  POS.intInvoiceId 
			OUTER APPLY (
				SELECT * FROM tblARInvoice 
				WHERE strTransactionType = 'Credit Memo'
				AND intInvoiceId = POS.intCreditMemoId
			) CREDITMEMO
			INNER JOIN tblSMCompanyLocation CL ON IFP.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			CROSS APPLY (
				SELECT TOP 1 intPaymentMethodID
						   , strPaymentMethod
				FROM tblSMPaymentMethod WITH (NOLOCK)
				WHERE ((POSPAYMENTS.strPaymentMethod = 'Debit Card' AND strPaymentMethod = 'Debit Card') OR (POSPAYMENTS.strPaymentMethod <> 'Debit Card' AND strPaymentMethod = POSPAYMENTS.strPaymentMethod))
			) PM
			WHERE IFP.ysnPosted = 1
			  AND IFP.ysnPaid = 0
			  AND II.intIntegrationLogId = @intInvoiceLogId
			  AND ISNULL(II.ysnHeader, 0) = 1
			  AND ISNULL(II.ysnSuccess, 0) = 1
			  AND ISNULL(II.ysnPosted, 0) = 1
			  AND IFP.dblInvoiceTotal > CREDITMEMO.dblInvoiceTotal
			  AND RT.strPOSType = 'Mixed'

			--GET PAYMENTS for SETTLE AMOUNT DUE FOR INVOICE < CREDIT MEMO
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
				,strNotes
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
				,dblCurrencyExchangeRate
				,ysnPost
			)
			SELECT intId						= POSPAYMENTS.intPOSPaymentId
			    ,strSourceTransaction			= 'Direct'
				,intSourceId					= IFP.intInvoiceId
				,strSourceId					= IFP.strInvoiceNumber
				,intEntityCustomerId			= IFP.intEntityCustomerId
				,intCompanyLocationId			= IFP.intCompanyLocationId
				,intCurrencyId					= IFP.intCurrencyId
				,dtmDatePaid					= DATEADD(dd, DATEDIFF(dd, 0, POS.dtmDate), 0)
				,intPaymentMethodId				= PM.intPaymentMethodID
				,strPaymentMethod				= PM.strPaymentMethod
				,strPaymentInfo					= 'POS Settle Amount Due of Exchange Transaction'
				,strNotes						= CASE WHEN IFP.strTransactionType = 'Credit Memo' THEN 'POS Return' ELSE POS.strReceiptNumber END 
				,intBankAccountId				= BA.intBankAccountId
				,dblAmountPaid					= ABS(ISNULL(POSPAYMENTS.dblAmount, 0)) * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,intEntityId					= @intEntityUserId
				,intInvoiceId					= IFP.intInvoiceId
				,strTransactionType				= IFP.strTransactionType
				,strTransactionNumber			= IFP.strInvoiceNumber
				,intTermId						= IFP.intTermId
				,intInvoiceAccountId			= IFP.intAccountId
				,dblInvoiceTotal				= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblBaseInvoiceTotal			= IFP.dblBaseInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblPayment						= ABS(ISNULL(POSPAYMENTS.dblAmount, 0)) * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblAmountDue					= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,dblBaseAmountDue				= IFP.dblInvoiceTotal * dbo.fnARGetInvoiceAmountMultiplier(IFP.strTransactionType)
				,strInvoiceReportNumber			= IFP.strInvoiceNumber
				,dblCurrencyExchangeRate		= IFP.dblCurrencyExchangeRate
				,ysnPost						= CAST(1 AS BIT)
			FROM #POSPAYMENTS POSPAYMENTS
			INNER JOIN tblARPOS POS ON POSPAYMENTS.intPOSId = POS.intPOSId
			INNER JOIN #POSTRANSACTIONS RT ON POS.intPOSId = RT.intPOSId
			INNER JOIN tblARInvoiceIntegrationLogDetail II ON POS.intPOSId = II.intSourceId AND POS.strReceiptNumber = II.strSourceId
			INNER JOIN (SELECT * FROM tblARInvoice WHERE strTransactionType = 'Credit Memo' ) IFP ON IFP.intInvoiceId =  POS.intCreditMemoId 
			OUTER APPLY (
				SELECT * FROM tblARInvoice 
				WHERE strTransactionType = 'Invoice'
				AND intInvoiceId = POS.intInvoiceId
			) INVOICES
			INNER JOIN tblSMCompanyLocation CL ON IFP.intCompanyLocationId = CL.intCompanyLocationId
			LEFT JOIN tblCMBankAccount BA ON CL.intCashAccount = BA.intGLAccountId
			CROSS APPLY (
				SELECT TOP 1 intPaymentMethodID
						   , strPaymentMethod
				FROM tblSMPaymentMethod WITH (NOLOCK)
				WHERE ((POSPAYMENTS.strPaymentMethod = 'Debit Card' AND strPaymentMethod = 'Debit Card') OR (POSPAYMENTS.strPaymentMethod <> 'Debit Card' AND strPaymentMethod = POSPAYMENTS.strPaymentMethod))
			) PM
			WHERE IFP.ysnPosted = 1
			  AND IFP.ysnPaid = 0
			  AND II.intIntegrationLogId = @intInvoiceLogId
			  AND ISNULL(II.ysnHeader, 0) = 1
			  AND ISNULL(II.ysnSuccess, 0) = 1
			  AND ISNULL(II.ysnPosted, 0) = 1
			  AND IFP.dblInvoiceTotal > INVOICES.dblInvoiceTotal
			  AND RT.strPOSType = 'Mixed'
			
		

			--PROCESS TO RCV
			EXEC [dbo].[uspARProcessPayments] @PaymentEntries	= @EntriesForPayment
											, @UserId			= @intEntityUserId
											, @GroupingOption	= 7
											, @RaiseError		= 0
											, @ErrorMessage		= @strErrorMsg OUTPUT
											, @LogId			= @intPaymentLogId OUTPUT

			--UPDATE PAYMENT REFERENCE TO POS PAYMENTS
			UPDATE POSPAYMENT
			SET intPaymentId = IP.intPaymentId
			FROM tblARPOSPayment POSPAYMENT
			INNER JOIN tblARPOS POS ON POSPAYMENT.intPOSId = POS.intPOSId		
			INNER JOIN tblARInvoice I ON POS.intInvoiceId = I.intInvoiceId OR POS.intCreditMemoId = I.intInvoiceId
            INNER JOIN tblARPaymentDetail PD ON PD.intInvoiceId = I.intInvoiceId
            INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId	
			--INNER JOIN tblARPayment P ON CASE WHEN P.strPaymentMethod = 'Manual Credit Card' THEN 'Credit Card' ELSE P.strPaymentMethod END = POSPAYMENT.strPaymentMethod AND P.strNotes = POS.strReceiptNumber
			INNER JOIN tblARPaymentIntegrationLogDetail IP ON IP.intPaymentId = P.intPaymentId			
			WHERE IP.intIntegrationLogId = @intPaymentLogId
			  AND ISNULL(IP.ysnHeader, 0) = 1
			  AND ISNULL(IP.ysnSuccess, 0) = 1

			--UPDATE POS ENDING BALANCE
			SELECT @dblCashReceipt = SUM(POSP.dblAmount)
			FROM #POSPAYMENTS POSP
			INNER JOIN #POSTRANSACTIONS POS ON POSP.intPOSId = POS.intPOSId
			WHERE POSP.strPaymentMethod IN ('Cash', 'Check') 
			  AND (POS.strPOSType = 'Regular'
			        OR ( POS.strPOSType = 'Mixed' AND POSP.dblAmount > 0 )
			  )

			SELECT @dblCashReturn = SUM(POSP.dblAmount)
			FROM #POSPAYMENTS POSP
			INNER JOIN #POSTRANSACTIONS POS ON POSP.intPOSId = POS.intPOSId
			WHERE POSP.strPaymentMethod IN ('Cash', 'Check')
			  AND ( (POS.strPOSType = 'Returned' OR POS.strPOSType = 'Return')
					OR POS.strPOSType = 'Mixed' AND POSP.dblAmount < 0 )
			UPDATE tblARPOSEndOfDay
			SET dblExpectedEndingBalance = ISNULL(dblExpectedEndingBalance, 0) + ISNULL(@dblCashReceipt, 0)
			  , dblCashReturn			 = ISNULL(dblCashReturn, 0) + ISNULL(@dblCashReturn, 0)
			WHERE intPOSEndOfDayId = @intPOSEndOfDayId

		END TRY
		BEGIN CATCH
			SELECT @strErrorMsg = ERROR_MESSAGE()					
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
		END CATCH
	END