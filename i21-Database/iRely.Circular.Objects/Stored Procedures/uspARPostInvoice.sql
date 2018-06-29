CREATE PROCEDURE [dbo].[uspARPostInvoice]
	@batchId			AS NVARCHAR(40)		= NULL
	,@post				AS BIT				= 0
	,@recap				AS BIT				= 0
	,@param				AS NVARCHAR(MAX)	= NULL
	,@userId			AS INT				= 1
	,@beginDate			AS DATE				= NULL
	,@endDate			AS DATE				= NULL
	,@beginTransaction	AS NVARCHAR(50)		= NULL
	,@endTransaction	AS NVARCHAR(50)		= NULL
	,@exclude			AS NVARCHAR(MAX)	= NULL
	,@successfulCount	AS INT				= 0 OUTPUT
	,@invalidCount		AS INT				= 0 OUTPUT
	,@success			AS BIT				= 0 OUTPUT
	,@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
	,@transType			AS NVARCHAR(25)		= 'all'
	,@accrueLicense		AS BIT				= 0
	,@raiseError		AS BIT				= 0
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

IF @raiseError = 1
	SET XACT_ABORT ON
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   

DECLARE @totalRecords INT = 0
DECLARE @totalInvalid INT = 0
 
DECLARE @PostInvoiceData AS [InvoicePostingTable]
--DECLARE @PostProvisionalData AS [InvoicePostingTable]

DECLARE @InvalidInvoiceData AS TABLE(
	 [intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)

DECLARE @FinishedGoodItems TABLE(
	  intInvoiceDetailId		INT
	, intItemId					INT
	, dblQuantity				NUMERIC(18,6)
	, intItemUOMId				INT
	, intLocationId				INT
	, intSublocationId			INT
	, intStorageLocationId		INT
	, dtmDate					DATETIME
)

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType
		,@TempGLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

DECLARE @UserEntityID				INT
		,@DiscountAccountId			INT
		,@DeferredRevenueAccountId	INT
		,@AllowOtherUserToPost		BIT
		,@DefaultCurrencyId			INT
		,@HasImpactForProvisional   BIT
		,@ExcludeInvoiceFromPayment BIT
		,@InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)
		,@DefaultCurrencyExchangeRateTypeId INT

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@raiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM dbo.tblSMUserSecurity WITH (NOLOCK) WHERE [intEntityId] = @userId),@userId)
SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WITH (NOLOCK) WHERE intEntityUserSecurityId = @UserEntityID)
SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 intAccountsReceivableRateTypeId FROM tblSMMultiCurrency)

SELECT TOP 1
	@DiscountAccountId			= intDiscountAccountId 
	,@DeferredRevenueAccountId	= intDeferredRevenueAccountId
	,@HasImpactForProvisional	= ISNULL(ysnImpactForProvisional,0)
	,@ExcludeInvoiceFromPayment	= ISNULL(ysnExcludePaymentInFinalInvoice,0)
FROM dbo.tblARCompanyPreference WITH (NOLOCK)

DECLARE @ErrorMerssage NVARCHAR(MAX)

SET @recapId = '1'
SET @success = 1

DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Cost of Goods'
DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5
SELECT @INVENTORY_SHIPMENT_TYPE = [intTransactionTypeId] FROM dbo.tblICInventoryTransactionType WITH (NOLOCK) WHERE [strName] = @SCREEN_NAME

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33

SELECT	@INVENTORY_INVOICE_TYPE = intTransactionTypeId 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	strName = @SCREEN_NAME

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000

-- Ensure @post and @recap is not NULL  
SET @post = ISNULL(@post, 0)
SET @recap = ISNULL(@recap, 0)
SET @accrueLicense = ISNULL(@accrueLicense, 0)

IF(LEN(RTRIM(LTRIM(ISNULL(@batchId,'')))) = 0)
	EXEC dbo.uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId
 
-- Get Transaction to Post
IF (@transType IS NULL OR RTRIM(LTRIM(@transType)) = '')
	SET @transType = 'all'

IF (@param IS NOT NULL) 
	BEGIN
		IF(@param = 'all')
		BEGIN
			INSERT INTO @PostInvoiceData(
				 [intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[strType]
				,[dtmDate]
				,[dtmPostDate]
				,[dtmShipDate]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intAccountId]
				,[intDeferredRevenueAccountId]
				,[intCurrencyId]
				,[intTermId]
				,[dblInvoiceTotal]
				,[dblShipping]
				,[dblTax]
				,[strImportFormat]
				,[intSourceId]
				,[intOriginalInvoiceId]
				,[strInvoiceOriginId]
				,[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]
				,[intLoadId]
				,[intFreightTermId]
				,[strActualCostId]
				,[intPeriodsToAccrue]
				,[ysnAccrueLicense]
				,[intSplitId]
				,[dblSplitPercent]				
				,[ysnSplitted]
				,[ysnImpactInventory]
				,[intEntityId]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[intItemUOMId]
				,[intDiscountAccountId]
				,[intCustomerStorageId]
				,[intStorageScheduleTypeId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblQuantity]
				,[dblMaxQuantity]
				,[strOptionType]
				,[strSourceType]
				,[strBatchId]
				,[strPostingMessage]
				,[intUserId]
				,[ysnAllowOtherUserToPost]
				,[ysnImpactForProvisional]
				,[strDescription]
			)
			 SELECT
				 [intInvoiceId]					= ARI.[intInvoiceId]
				,[strInvoiceNumber]				= ARI.[strInvoiceNumber]
				,[strTransactionType]			= ARI.[strTransactionType]
				,[strType]						= ARI.[strType]
				,[dtmDate]						= ARI.[dtmDate]
				,[dtmPostDate]					= ARI.[dtmPostDate]
				,[dtmShipDate]					= ARI.[dtmShipDate]
				,[intEntityCustomerId]			= ARI.[intEntityCustomerId]
				,[intCompanyLocationId]			= ARI.[intCompanyLocationId]
				,[intAccountId]					= ARI.[intAccountId]
				,[intDeferredRevenueAccountId]	= @DeferredRevenueAccountId
				,[intCurrencyId]				= ARI.[intCurrencyId]
				,[intTermId]					= ARI.[intTermId]
				,[dblInvoiceTotal]				= ARI.[dblInvoiceTotal]
				,[dblShipping]					= ARI.[dblShipping]
				,[dblTax]						= ARI.[dblTax]
				,[strImportFormat]				= ARI.[strImportFormat]
				,[intSourceId]					= ARI.[intSourceId]
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
				,[strInvoiceOriginId]			= ARI.[strInvoiceOriginId]
				,[intDistributionHeaderId]		= ARI.[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]	= ARI.[intLoadDistributionHeaderId]
				,[intLoadId]					= ARI.[intLoadId]
				,[intFreightTermId]				= ARI.[intFreightTermId]
				,[strActualCostId]				= ARI.[strActualCostId]
				,[intPeriodsToAccrue]			= ARI.[intPeriodsToAccrue]
				,[ysnAccrueLicense]				= @accrueLicense
				,[intSplitId]					= ARI.[intSplitId]
				,[dblSplitPercent]				= ARI.[dblSplitPercent]			
				,[ysnSplitted]					= ARI.[ysnSplitted]
				,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
				,[intEntityId]					= ARI.[intEntityId]
				,[ysnPost]						= @post
				,[intInvoiceDetailId]			= NULL
				,[intItemId]					= NULL
				,[intItemUOMId]					= NULL
				,[intDiscountAccountId]			= @DiscountAccountId
				,[intCustomerStorageId]			= NULL
				,[intStorageScheduleTypeId]		= NULL
				,[intSubLocationId]				= NULL
				,[intStorageLocationId]			= NULL
				,[dblQuantity]					= @ZeroDecimal
				,[dblMaxQuantity]				= @ZeroDecimal
				,[strOptionType]				= NULL
				,[strSourceType]				= NULL
				,[strBatchId]					= @batchIdUsed
				,[strPostingMessage]			= ''
				,[intUserId]					= @UserEntityID
				,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost
				,[ysnImpactForProvisional]		= @HasImpactForProvisional
				,[strDescription]				= CASE WHEN ARI.[strType] = 'Provisional' AND @HasImpactForProvisional = 1 THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1, 255)
														WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1 , 255)
														ELSE ARI.[strComments]
												END
			FROM
				dbo.tblARInvoice ARI WITH (NOLOCK) 
			WHERE
				ARI.[ysnPosted] = 0 AND (ARI.[strTransactionType] = @transType OR @transType = 'all')
				AND NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
		END
		ELSE
		BEGIN
			INSERT INTO @PostInvoiceData(
				 [intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[strType]
				,[dtmDate]
				,[dtmPostDate]
				,[dtmShipDate]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intAccountId]
				,[intDeferredRevenueAccountId]
				,[intCurrencyId]
				,[intTermId]
				,[dblInvoiceTotal]
				,[dblShipping]
				,[dblTax]
				,[strImportFormat]
				,[intSourceId]
				,[intOriginalInvoiceId]
				,[strInvoiceOriginId]
				,[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]
				,[intLoadId]
				,[intFreightTermId]
				,[strActualCostId]
				,[intPeriodsToAccrue]
				,[ysnAccrueLicense]
				,[intSplitId]
				,[dblSplitPercent]				
				,[ysnSplitted]
				,[ysnImpactInventory]
				,[intEntityId]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[intItemUOMId]
				,[intDiscountAccountId]
				,[intCustomerStorageId]
				,[intStorageScheduleTypeId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblQuantity]
				,[dblMaxQuantity]
				,[strOptionType]
				,[strSourceType]
				,[strBatchId]
				,[strPostingMessage]
				,[intUserId]
				,[ysnAllowOtherUserToPost]
				,[ysnImpactForProvisional]
				,[strDescription]
			)
			 SELECT
				 [intInvoiceId]					= ARI.[intInvoiceId]
				,[strInvoiceNumber]				= ARI.[strInvoiceNumber]
				,[strTransactionType]			= ARI.[strTransactionType]
				,[strType]						= ARI.[strType]
				,[dtmDate]						= ARI.[dtmDate]
				,[dtmPostDate]					= ARI.[dtmPostDate]
				,[dtmShipDate]					= ARI.[dtmShipDate]
				,[intEntityCustomerId]			= ARI.[intEntityCustomerId]
				,[intCompanyLocationId]			= ARI.[intCompanyLocationId]
				,[intAccountId]					= ARI.[intAccountId]
				,[intDeferredRevenueAccountId]	= @DeferredRevenueAccountId
				,[intCurrencyId]				= ARI.[intCurrencyId]
				,[intTermId]					= ARI.[intTermId]
				,[dblInvoiceTotal]				= ARI.[dblInvoiceTotal]
				,[dblShipping]					= ARI.[dblShipping]
				,[dblTax]						= ARI.[dblTax]
				,[strImportFormat]				= ARI.[strImportFormat]
				,[intSourceId]					= ARI.[intSourceId]
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
				,[strInvoiceOriginId]			= ARI.[strInvoiceOriginId]
				,[intDistributionHeaderId]		= ARI.[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]	= ARI.[intLoadDistributionHeaderId]
				,[intLoadId]					= ARI.[intLoadId]
				,[intFreightTermId]				= ARI.[intFreightTermId]
				,[strActualCostId]				= ARI.[strActualCostId]
				,[intPeriodsToAccrue]			= ARI.[intPeriodsToAccrue]
				,[ysnAccrueLicense]				= @accrueLicense
				,[intSplitId]					= ARI.[intSplitId]
				,[dblSplitPercent]				= ARI.[dblSplitPercent]			
				,[ysnSplitted]					= ARI.[ysnSplitted]
				,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
				,[intEntityId]					= ARI.[intEntityId]
				,[ysnPost]						= @post
				,[intInvoiceDetailId]			= NULL
				,[intItemId]					= NULL
				,[intItemUOMId]					= NULL
				,[intDiscountAccountId]			= @DiscountAccountId
				,[intCustomerStorageId]			= NULL
				,[intStorageScheduleTypeId]		= NULL
				,[intSubLocationId]				= NULL
				,[intStorageLocationId]			= NULL
				,[dblQuantity]					= @ZeroDecimal
				,[dblMaxQuantity]				= @ZeroDecimal
				,[strOptionType]				= NULL
				,[strSourceType]				= NULL
				,[strBatchId]					= @batchIdUsed
				,[strPostingMessage]			= ''
				,[intUserId]					= @UserEntityID
				,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost
				,[ysnImpactForProvisional]		= @HasImpactForProvisional
				,[strDescription]				= CASE WHEN ARI.[strType] = 'Provisional' AND @HasImpactForProvisional = 1 THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1, 255)
														WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1 , 255)
														ELSE ARI.[strComments]
												END
			FROM
				dbo.tblARInvoice ARI WITH (NOLOCK) 
			WHERE
				EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@param) DV WHERE DV.[intID] = ARI.[intInvoiceId])
				AND NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
		END
	END

IF(@beginDate IS NOT NULL)
	BEGIN
		INSERT INTO @PostInvoiceData(
				 [intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[strType]
				,[dtmDate]
				,[dtmPostDate]
				,[dtmShipDate]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intAccountId]
				,[intDeferredRevenueAccountId]
				,[intCurrencyId]
				,[intTermId]
				,[dblInvoiceTotal]
				,[dblShipping]
				,[dblTax]
				,[strImportFormat]
				,[intSourceId]
				,[intOriginalInvoiceId]
				,[strInvoiceOriginId]
				,[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]
				,[intLoadId]
				,[intFreightTermId]
				,[strActualCostId]
				,[intPeriodsToAccrue]
				,[ysnAccrueLicense]
				,[intSplitId]
				,[dblSplitPercent]				
				,[ysnSplitted]
				,[ysnImpactInventory]
				,[intEntityId]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[intItemUOMId]
				,[intDiscountAccountId]
				,[intCustomerStorageId]
				,[intStorageScheduleTypeId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblQuantity]
				,[dblMaxQuantity]
				,[strOptionType]
				,[strSourceType]
				,[strBatchId]
				,[strPostingMessage]
				,[intUserId]
				,[ysnAllowOtherUserToPost]
				,[ysnImpactForProvisional]
				,[strDescription]
			)
			 SELECT
				 [intInvoiceId]					= ARI.[intInvoiceId]
				,[strInvoiceNumber]				= ARI.[strInvoiceNumber]
				,[strTransactionType]			= ARI.[strTransactionType]
				,[strType]						= ARI.[strType]
				,[dtmDate]						= ARI.[dtmDate]
				,[dtmPostDate]					= ARI.[dtmPostDate]
				,[dtmShipDate]					= ARI.[dtmShipDate]
				,[intEntityCustomerId]			= ARI.[intEntityCustomerId]
				,[intCompanyLocationId]			= ARI.[intCompanyLocationId]
				,[intAccountId]					= ARI.[intAccountId]
				,[intDeferredRevenueAccountId]	= @DeferredRevenueAccountId
				,[intCurrencyId]				= ARI.[intCurrencyId]
				,[intTermId]					= ARI.[intTermId]
				,[dblInvoiceTotal]				= ARI.[dblInvoiceTotal]
				,[dblShipping]					= ARI.[dblShipping]
				,[dblTax]						= ARI.[dblTax]
				,[strImportFormat]				= ARI.[strImportFormat]
				,[intSourceId]					= ARI.[intSourceId]
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
				,[strInvoiceOriginId]			= ARI.[strInvoiceOriginId]
				,[intDistributionHeaderId]		= ARI.[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]	= ARI.[intLoadDistributionHeaderId]
				,[intLoadId]					= ARI.[intLoadId]
				,[intFreightTermId]				= ARI.[intFreightTermId]
				,[strActualCostId]				= ARI.[strActualCostId]
				,[intPeriodsToAccrue]			= ARI.[intPeriodsToAccrue]
				,[ysnAccrueLicense]				= @accrueLicense
				,[intSplitId]					= ARI.[intSplitId]
				,[dblSplitPercent]				= ARI.[dblSplitPercent]			
				,[ysnSplitted]					= ARI.[ysnSplitted]
				,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
				,[intEntityId]					= ARI.[intEntityId]
				,[ysnPost]						= @post
				,[intInvoiceDetailId]			= NULL
				,[intItemId]					= NULL
				,[intItemUOMId]					= NULL
				,[intDiscountAccountId]			= @DiscountAccountId
				,[intCustomerStorageId]			= NULL
				,[intStorageScheduleTypeId]		= NULL
				,[intSubLocationId]				= NULL
				,[intStorageLocationId]			= NULL
				,[dblQuantity]					= @ZeroDecimal
				,[dblMaxQuantity]				= @ZeroDecimal
				,[strOptionType]				= NULL
				,[strSourceType]				= NULL
				,[strBatchId]					= @batchIdUsed
				,[strPostingMessage]			= ''
				,[intUserId]					= @UserEntityID
				,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost
				,[ysnImpactForProvisional]		= @HasImpactForProvisional
				,[strDescription]				= CASE WHEN ARI.[strType] = 'Provisional' AND @HasImpactForProvisional = 1 THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1, 255)
														WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1 , 255)
														ELSE ARI.[strComments]
												END
			FROM
				dbo.tblARInvoice ARI WITH (NOLOCK) 
			WHERE
				DATEADD(dd, DATEDIFF(dd, 0, ARI.[dtmDate]), 0) BETWEEN @beginDate AND @endDate
				AND (ARI.[strTransactionType] = @transType OR @transType = 'all')
				AND NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		INSERT INTO @PostInvoiceData(
				 [intInvoiceId]
				,[strInvoiceNumber]
				,[strTransactionType]
				,[strType]
				,[dtmDate]
				,[dtmPostDate]
				,[dtmShipDate]
				,[intEntityCustomerId]
				,[intCompanyLocationId]
				,[intAccountId]
				,[intDeferredRevenueAccountId]
				,[intCurrencyId]
				,[intTermId]
				,[dblInvoiceTotal]
				,[dblShipping]
				,[dblTax]
				,[strImportFormat]
				,[intSourceId]
				,[intOriginalInvoiceId]
				,[strInvoiceOriginId]
				,[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]
				,[intLoadId]
				,[intFreightTermId]
				,[strActualCostId]
				,[intPeriodsToAccrue]
				,[ysnAccrueLicense]
				,[intSplitId]
				,[dblSplitPercent]				
				,[ysnSplitted]
				,[ysnImpactInventory]
				,[intEntityId]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[intItemUOMId]
				,[intDiscountAccountId]
				,[intCustomerStorageId]
				,[intStorageScheduleTypeId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[dblQuantity]
				,[dblMaxQuantity]
				,[strOptionType]
				,[strSourceType]
				,[strBatchId]
				,[strPostingMessage]
				,[intUserId]
				,[ysnAllowOtherUserToPost]
				,[ysnImpactForProvisional]
				,[strDescription]
			)
			 SELECT
				 [intInvoiceId]					= ARI.[intInvoiceId]
				,[strInvoiceNumber]				= ARI.[strInvoiceNumber]
				,[strTransactionType]			= ARI.[strTransactionType]
				,[strType]						= ARI.[strType]
				,[dtmDate]						= ARI.[dtmDate]
				,[dtmPostDate]					= ARI.[dtmPostDate]
				,[dtmShipDate]					= ARI.[dtmShipDate]
				,[intEntityCustomerId]			= ARI.[intEntityCustomerId]
				,[intCompanyLocationId]			= ARI.[intCompanyLocationId]
				,[intAccountId]					= ARI.[intAccountId]
				,[intDeferredRevenueAccountId]	= @DeferredRevenueAccountId
				,[intCurrencyId]				= ARI.[intCurrencyId]
				,[intTermId]					= ARI.[intTermId]
				,[dblInvoiceTotal]				= ARI.[dblInvoiceTotal]
				,[dblShipping]					= ARI.[dblShipping]
				,[dblTax]						= ARI.[dblTax]
				,[strImportFormat]				= ARI.[strImportFormat]
				,[intSourceId]					= ARI.[intSourceId]
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
				,[strInvoiceOriginId]			= ARI.[strInvoiceOriginId]
				,[intDistributionHeaderId]		= ARI.[intDistributionHeaderId]
				,[intLoadDistributionHeaderId]	= ARI.[intLoadDistributionHeaderId]
				,[intLoadId]					= ARI.[intLoadId]
				,[intFreightTermId]				= ARI.[intFreightTermId]
				,[strActualCostId]				= ARI.[strActualCostId]
				,[intPeriodsToAccrue]			= ARI.[intPeriodsToAccrue]
				,[ysnAccrueLicense]				= @accrueLicense
				,[intSplitId]					= ARI.[intSplitId]
				,[dblSplitPercent]				= ARI.[dblSplitPercent]			
				,[ysnSplitted]					= ARI.[ysnSplitted]
				,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
				,[intEntityId]					= ARI.[intEntityId]
				,[ysnPost]						= @post
				,[intInvoiceDetailId]			= NULL
				,[intItemId]					= NULL
				,[intItemUOMId]					= NULL
				,[intDiscountAccountId]			= @DiscountAccountId
				,[intCustomerStorageId]			= NULL
				,[intStorageScheduleTypeId]		= NULL
				,[intSubLocationId]				= NULL
				,[intStorageLocationId]			= NULL
				,[dblQuantity]					= @ZeroDecimal
				,[dblMaxQuantity]				= @ZeroDecimal
				,[strOptionType]				= NULL
				,[strSourceType]				= NULL
				,[strBatchId]					= @batchIdUsed
				,[strPostingMessage]			= ''
				,[intUserId]					= @UserEntityID
				,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost
				,[ysnImpactForProvisional]		= @HasImpactForProvisional
				,[strDescription]				= CASE WHEN ARI.[strType] = 'Provisional' AND @HasImpactForProvisional = 1 THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1, 255)
														WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1 , 255)
														ELSE ARI.[strComments]
												END
			FROM
				dbo.tblARInvoice ARI WITH (NOLOCK) 
			WHERE
				ARI.[intInvoiceId] BETWEEN @beginTransaction AND @endTransaction
				AND (ARI.[strTransactionType] = @transType OR @transType = 'all')
				AND NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
	END

--Removed excluded Invoices to post/unpost
IF(@exclude IS NOT NULL)
	BEGIN
		DECLARE @InvoicesExclude TABLE  (
			intInvoiceId INT
		);

		INSERT INTO @InvoicesExclude
		SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@exclude)


		DELETE FROM A
		FROM @PostInvoiceData A
		WHERE EXISTS(SELECT NULL FROM @InvoicesExclude B WHERE A.[intInvoiceId] = B.[intInvoiceId])
	END

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
-- Create a unique transaction name for recap. 
DECLARE @TransactionName AS VARCHAR(500) = 'Invoice Transaction' + CAST(NEWID() AS NVARCHAR(100));
if @recap = 1 AND @raiseError = 0
	SAVE TRAN @TransactionName

DECLARE @InvoiceIds TABLE(
	id  	INT
)
INSERT INTO @InvoiceIds(id)
SELECT distinct intInvoiceId FROM @PostInvoiceData

WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceIds ORDER BY id)
BEGIN				
	DECLARE @InvoiceId1 INT
				
	SELECT TOP 1 @InvoiceId1 = id FROM @InvoiceIds ORDER BY id
	
	EXEC dbo.[uspARUpdateReservedStock] @InvoiceId1, 0, @userId, 1, @post

	-- EXEC [dbo].[uspICPostStockReservation]
	-- 	@intTransactionId		= @InvoiceId1
	-- 	,@intTransactionTypeId	= @INVENTORY_SHIPMENT_TYPE
	-- 	,@ysnPosted				= @post
		
	DELETE FROM @InvoiceIds WHERE id = @InvoiceId1
END		 


	
--------------------------------------------------------------------------------------------  
-- Validations  
----------------------------------------------------------------------------------------------
INSERT INTO @InvalidInvoiceData(
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError])
SELECT
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError]
FROM 
	[dbo].[fnARGetInvalidInvoicesForPosting](@PostInvoiceData, @post, @recap)
		
SELECT @totalInvalid = COUNT(*) FROM @InvalidInvoiceData

IF(@totalInvalid > 0)
	BEGIN
		--Insert Invalid Post transaction result
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 	
			 [strPostingError]
			,[strTransactionType]
			,[strInvoiceNumber]
			,[strBatchId]
			,[intInvoiceId]
		FROM
			@InvalidInvoiceData 
				ORDER BY strPostingError DESC

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE @PostInvoiceData
			FROM @PostInvoiceData A
				INNER JOIN @InvalidInvoiceData B
					ON A.intInvoiceId = B.intInvoiceId
				
		IF @raiseError = 1
			BEGIN
				SELECT TOP 1 @ErrorMerssage = [strPostingError] FROM @InvalidInvoiceData
				RAISERROR(@ErrorMerssage, 11, 1)							
				GOTO Post_Exit
			END					
	END

SELECT @totalRecords = COUNT(*) FROM @PostInvoiceData
			
IF(@totalInvalid >= 1 AND @totalRecords <= 0)
	BEGIN
		IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1 OR @recap = 1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1 OR @recap = 1
						ROLLBACK TRANSACTION  @Savepoint
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	

			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT 	
				[strPostingError]
				,[strTransactionType]
				,[strInvoiceNumber]
				,[strBatchId]
				,[intInvoiceId]
			FROM
				@InvalidInvoiceData 
					ORDER BY strPostingError DESC
		END

		IF @raiseError = 1
			BEGIN
				SELECT TOP 1 @ErrorMerssage = [strPostingError] FROM @InvalidInvoiceData
				RAISERROR(@ErrorMerssage, 11, 1)							
				GOTO Post_Exit
			END				
		GOTO Post_Exit	
	END
	

--Process Split Invoice
BEGIN TRY
	IF @post = 1 AND @recap = 0
	BEGIN
		DECLARE @SplitInvoiceData TABLE([intInvoiceId] INT)

		INSERT INTO @SplitInvoiceData
		SELECT 
			intInvoiceId
		FROM
			dbo.tblARInvoice ARI WITH (NOLOCK)
		WHERE
			ARI.[ysnSplitted] = 0 
			AND ISNULL(ARI.[intSplitId], 0) > 0
			AND EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
			AND ARI.strTransactionType IN ('Invoice', 'Cash', 'Debit Memo')

		WHILE EXISTS(SELECT NULL FROM @SplitInvoiceData)
			BEGIN
				DECLARE @invoicesToAdd NVARCHAR(MAX) = NULL, @intSplitInvoiceId INT

				SELECT TOP 1 @intSplitInvoiceId = intInvoiceId FROM @SplitInvoiceData ORDER BY intInvoiceId

				EXEC dbo.uspARProcessSplitInvoice @intSplitInvoiceId, @userId, @invoicesToAdd OUT

				DELETE FROM @PostInvoiceData WHERE intInvoiceId = @intSplitInvoiceId

				IF (ISNULL(@invoicesToAdd, '') <> '')
					BEGIN
						INSERT INTO @PostInvoiceData(
							 [intInvoiceId]
							,[strInvoiceNumber]
							,[strTransactionType]
							,[strType]
							,[dtmDate]
							,[dtmPostDate]
							,[dtmShipDate]
							,[intEntityCustomerId]
							,[intCompanyLocationId]
							,[intAccountId]
							,[intDeferredRevenueAccountId]
							,[intCurrencyId]
							,[intTermId]
							,[dblInvoiceTotal]
							,[dblShipping]
							,[dblTax]
							,[strImportFormat]
							,[intSourceId]
							,[intOriginalInvoiceId]
							,[strInvoiceOriginId]
							,[intDistributionHeaderId]
							,[intLoadDistributionHeaderId]
							,[intLoadId]
							,[intFreightTermId]
							,[strActualCostId]
							,[intPeriodsToAccrue]
							,[ysnAccrueLicense]
							,[intSplitId]
							,[dblSplitPercent]				
							,[ysnSplitted]
							,[ysnImpactInventory]
							,[intEntityId]
							,[ysnPost]
							,[intInvoiceDetailId]
							,[intItemId]
							,[intItemUOMId]
							,[intDiscountAccountId]
							,[intCustomerStorageId]
							,[intStorageScheduleTypeId]
							,[intSubLocationId]
							,[intStorageLocationId]
							,[dblQuantity]
							,[dblMaxQuantity]
							,[strOptionType]
							,[strSourceType]
							,[strBatchId]
							,[strPostingMessage]
							,[intUserId]
							,[ysnAllowOtherUserToPost]
							,[ysnImpactForProvisional]
							,[strDescription]
						)
						 SELECT DISTINCT
							 [intInvoiceId]					= ARI.[intInvoiceId]
							,[strInvoiceNumber]				= ARI.[strInvoiceNumber]
							,[strTransactionType]			= ARI.[strTransactionType]
							,[strType]						= ARI.[strType]
							,[dtmDate]						= ARI.[dtmDate]
							,[dtmPostDate]					= ARI.[dtmPostDate]
							,[dtmShipDate]					= ARI.[dtmShipDate]
							,[intEntityCustomerId]			= ARI.[intEntityCustomerId]
							,[intCompanyLocationId]			= ARI.[intCompanyLocationId]
							,[intAccountId]					= ARI.[intAccountId]
							,[intDeferredRevenueAccountId]	= @DeferredRevenueAccountId
							,[intCurrencyId]				= ARI.[intCurrencyId]
							,[intTermId]					= ARI.[intTermId]
							,[dblInvoiceTotal]				= ARI.[dblInvoiceTotal]
							,[dblShipping]					= ARI.[dblShipping]
							,[dblTax]						= ARI.[dblTax]
							,[strImportFormat]				= ARI.[strImportFormat]
							,[intSourceId]					= ARI.[intSourceId]
							,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
							,[strInvoiceOriginId]			= ARI.[strInvoiceOriginId]
							,[intDistributionHeaderId]		= ARI.[intDistributionHeaderId]
							,[intLoadDistributionHeaderId]	= ARI.[intLoadDistributionHeaderId]
							,[intLoadId]					= ARI.[intLoadId]
							,[intFreightTermId]				= ARI.[intFreightTermId]
							,[strActualCostId]				= ARI.[strActualCostId]
							,[intPeriodsToAccrue]			= ARI.[intPeriodsToAccrue]
							,[ysnAccrueLicense]				= @accrueLicense
							,[intSplitId]					= ARI.[intSplitId]
							,[dblSplitPercent]				= ARI.[dblSplitPercent]			
							,[ysnSplitted]					= ARI.[ysnSplitted]
							,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
							,[intEntityId]					= ARI.[intEntityId]
							,[ysnPost]						= @post
							,[intInvoiceDetailId]			= NULL
							,[intItemId]					= NULL
							,[intItemUOMId]					= NULL
							,[intDiscountAccountId]			= @DiscountAccountId
							,[intCustomerStorageId]			= NULL
							,[intStorageScheduleTypeId]		= NULL
							,[intSubLocationId]				= NULL
							,[intStorageLocationId]			= NULL
							,[dblQuantity]					= @ZeroDecimal
							,[dblMaxQuantity]				= @ZeroDecimal
							,[strOptionType]				= NULL
							,[strSourceType]				= NULL
							,[strBatchId]					= @batchIdUsed
							,[strPostingMessage]			= ''
							,[intUserId]					= @UserEntityID
							,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost
							,[ysnImpactForProvisional]		= @HasImpactForProvisional		
							,[strDescription]				= CASE WHEN ARI.[strType] = 'Provisional' AND @HasImpactForProvisional = 1 THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1, 255)
																	WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1 , 255)
																	ELSE ARI.[strComments]
															END			
						FROM dbo.tblARInvoice ARI WITH (NOLOCK)
						INNER JOIN dbo.fnGetRowsFromDelimitedValues(@invoicesToAdd) DV ON ARI.intInvoiceId = DV.intID
						WHERE ARI.[ysnPosted] = 0 
					
					END

				DELETE FROM @SplitInvoiceData WHERE intInvoiceId = @intSplitInvoiceId
			END
	END
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint
									
			EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param

			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

--Process Finished Good Items
INSERT INTO @FinishedGoodItems
SELECT ID.intInvoiceDetailId
		, ID.intItemId
		, ID.dblQtyShipped
		, ID.intItemUOMId
		, I.intCompanyLocationId
		, ISNULL(ID.intCompanyLocationSubLocationId, ICL.intSubLocationId)
		, ID.intStorageLocationId
		,I.dtmDate
FROM tblARInvoice I
	INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
	INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
	INNER JOIN tblICItemLocation ICL ON ID.intItemId = ICL.intItemId AND I.intCompanyLocationId = ICL.intLocationId
	LEFT OUTER JOIN tblICItemStock ICIS ON ICI.intItemId = ICIS.intItemId AND ICL.intItemLocationId = ICIS.intItemLocationId 
WHERE I.intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
AND ID.ysnBlended <> @post
AND ICI.ysnAutoBlend = 1
AND I.strTransactionType NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
AND 
	(
	@post = 0
	OR
		(
			@post = 1
		AND 
			ISNULL(ICIS.dblUnitOnHand,0.000000) = @ZeroDecimal
		AND 
			ICL.intAllowNegativeInventory = 3
		)
	)

BEGIN TRY
	IF @post = 1
		BEGIN
			WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
				BEGIN
					DECLARE @intInvoiceDetailId		INT
						  , @intItemId				INT
						  , @dblQuantity			NUMERIC(18,6)
						  , @dblMaxQuantity			NUMERIC(18,6) = 0
						  , @intItemUOMId			INT
						  , @intLocationId			INT
						  , @intSublocationId		INT
						  , @intStorageLocationId	INT
						  , @dtmDate			DATETIME
			
					SELECT TOP 1 
						  @intInvoiceDetailId	= intInvoiceDetailId
						, @intItemId			= intItemId
						, @dblQuantity			= dblQuantity				
						, @intItemUOMId			= intItemUOMId
						, @intLocationId		= intLocationId
						, @intSublocationId		= intSublocationId
						, @intStorageLocationId	= intStorageLocationId
						, @dtmDate				= dtmDate 
					FROM @FinishedGoodItems 
				  
					BEGIN TRY
					IF @post = 1
						BEGIN
							EXEC dbo.uspMFAutoBlend
								@intSalesOrderDetailId	= NULL,
								@intInvoiceDetailId		= @intInvoiceDetailId,
								@intItemId				= @intItemId,
								@dblQtyToProduce		= @dblQuantity,
								@intItemUOMId			= @intItemUOMId,
								@intLocationId			= @intLocationId,
								@intSubLocationId		= @intSublocationId,
								@intStorageLocationId	= @intStorageLocationId,
								@intUserId				= @userId,
								@dblMaxQtyToProduce		= @dblMaxQuantity OUT,
								@dtmDate				= @dtmDate

							IF ISNULL(@dblMaxQuantity, 0) > 0
								BEGIN
									EXEC dbo.uspMFAutoBlend
										@intSalesOrderDetailId	= NULL,
										@intInvoiceDetailId		= @intInvoiceDetailId,
										@intItemId				= @intItemId,
										@dblQtyToProduce		= @dblMaxQuantity,
										@intItemUOMId			= @intItemUOMId,
										@intLocationId			= @intLocationId,
										@intSubLocationId		= @intSublocationId,
										@intStorageLocationId	= @intStorageLocationId,
										@intUserId				= @userId,
										@dblMaxQtyToProduce		= @dblMaxQuantity OUT,
										@dtmDate				= @dtmDate
								END
						END
					
					END TRY
					BEGIN CATCH
						SELECT @ErrorMerssage = ERROR_MESSAGE()
						IF @raiseError = 0
							BEGIN
								IF @InitTranCount = 0
									IF (XACT_STATE()) <> 0
										ROLLBACK TRANSACTION
								ELSE
									IF (XACT_STATE()) <> 0
										ROLLBACK TRANSACTION @Savepoint
												
								SET @CurrentTranCount = @@TRANCOUNT
								SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
								IF @CurrentTranCount = 0
									BEGIN TRANSACTION
								ELSE
									SAVE TRANSACTION @CurrentSavepoint
									
								EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param

								IF @CurrentTranCount = 0
									BEGIN
										IF (XACT_STATE()) = -1
											ROLLBACK TRANSACTION
										IF (XACT_STATE()) = 1
											COMMIT TRANSACTION
									END		
								ELSE
									BEGIN
										IF (XACT_STATE()) = -1
											ROLLBACK TRANSACTION  @CurrentSavepoint
										--IF (XACT_STATE()) = 1
										--	COMMIT TRANSACTION  @Savepoint
									END	
							END						
						IF @raiseError = 1
							RAISERROR(@ErrorMerssage, 11, 1)
		
						GOTO Post_Exit
					END CATCH
					
					UPDATE tblARInvoiceDetail SET ysnBlended = 1 WHERE intInvoiceDetailId = @intInvoiceDetailId

					DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailId
				END	
		END	
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint
															
			EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param

			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH
--------------------------------------------------------------------------------------------  
-- GL ENTRIES START
--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------

IF @post = 1  
	BEGIN 
		BEGIN TRY 
			DECLARE @Ids AS Id
			INSERT INTO @Ids(intId)
			SELECT IP.intInvoiceId 
			FROM 
				@PostInvoiceData IP 

			EXEC	dbo.[uspARUpdateTransactionAccounts]  
						 @Ids				= @Ids
						,@TransactionType	= 1
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
		
		-- Accruals
		BEGIN TRY 
			DECLARE @Accruals AS Id
			INSERT INTO @Accruals(intId)
			SELECT IP.intInvoiceId 
			FROM 
				@PostInvoiceData IP 
			WHERE ISNULL(IP.intPeriodsToAccrue,0) > 1

			INSERT INTO @GLEntries(
				 [dtmDate]
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,[ysnIsUnposted]
				,[intUserId]
				,[intEntityId]
				,[strTransactionId]
				,[intTransactionId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
				,[intConcurrencyId]
				,[dblDebitForeign]
				,[dblDebitReport]
				,[dblCreditForeign]
				,[dblCreditReport]
				,[dblReportingRate]
				,[dblForeignRate]
				,[strRateType]
			)
			EXEC	dbo.uspARGenerateEntriesForAccrual  
						 @Invoices					= @Accruals
						,@DeferredRevenueAccountId	= @DeferredRevenueAccountId
						,@BatchId					= @batchIdUsed
						,@Code						= @CODE
						,@UserId					= @userId
						,@UserEntityId				= @UserEntityID
						,@ScreenName				= @SCREEN_NAME
						,@ModuleName				= @MODULE_NAME
						,@AccrueLicense				= @accrueLicense

		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH		
		
		BEGIN TRY
			-- Call the post routine 
			IF EXISTS(SELECT NULL FROM @PostInvoiceData WHERE intOriginalInvoiceId IS NOT NULL AND [intSourceId] IS NOT NULL AND intOriginalInvoiceId <> 0 AND [intSourceId] = 2)
				BEGIN
					SET @HasImpactForProvisional = 1
					INSERT INTO @GLEntries
						([dtmDate]
						,[strBatchId]
						,[intAccountId]
						,[dblDebit]
						,[dblCredit]
						,[dblDebitUnit]
						,[dblCreditUnit]
						,[strDescription]
						,[strCode]
						,[strReference]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[dtmDateEntered]
						,[dtmTransactionDate]
						,[strJournalLineDescription]
						,[intJournalLineNo]
						,[ysnIsUnposted]
						,[intUserId]
						,[intEntityId]
						,[strTransactionId]
						,[intTransactionId]
						,[strTransactionType]
						,[strTransactionForm]
						,[strModuleName]
						,[intConcurrencyId]
						,[dblDebitForeign]
						,[dblDebitReport]
						,[dblCreditForeign]
						,[dblCreditReport]
						,[dblReportingRate]
						,[dblForeignRate]
						,[strDocument]
						,[strComments]
						,[strSourceDocumentId]
						,[intSourceLocationId]
						,[intSourceUOMId]
						,[dblSourceUnitDebit]
						,[dblSourceUnitCredit]
						,[intCommodityId]
						,[intSourceEntityId])
                    SELECT 
						 [dtmDate]						= CAST(ISNULL(P.[dtmPostDate], P.[dtmDate]) AS DATE)
						,[strBatchId]					= @batchIdUsed
						,[intAccountId]					= GL.[intAccountId]
						,[dblDebit]						= GL.[dblCredit]
						,[dblCredit]					= GL.[dblDebit]
						,[dblDebitUnit]					= GL.[dblCreditUnit]
						,[dblCreditUnit]				= GL.[dblDebitUnit]
						,[strDescription]				= 'Reverse Provisional Invoice' + ISNULL((' - ' + GL.strDescription), '')
						,[strCode]						= @CODE
						,[strReference]					= GL.[strReference]
						,[intCurrencyId]				= GL.[intCurrencyId]
						,[dblExchangeRate]				= GL.[dblExchangeRate]
						,[dtmDateEntered]				= @PostDate
						,[dtmTransactionDate]			= P.[dtmDate]
						,[strJournalLineDescription]	= GL.[strJournalLineDescription]
						,[intJournalLineNo]				= P.[intOriginalInvoiceId]
						,[ysnIsUnposted]				= 0
						,[intUserId]					= @userId
						,[intEntityId]					= @UserEntityID
						,[strTransactionId]				= P.[strInvoiceNumber]
						,[intTransactionId]				= P.[intInvoiceId]
						,[strTransactionType]			= P.[strTransactionType]
						,[strTransactionForm]			= @SCREEN_NAME
						,[strModuleName]				= @MODULE_NAME
						,[intConcurrencyId]				= 1
						,[dblDebitForeign]				= GL.[dblCreditForeign]
						,[dblDebitReport]				= GL.[dblCreditReport]
						,[dblCreditForeign]				= GL.[dblDebitForeign]
						,[dblCreditReport]				= GL.[dblDebitReport]
						,[dblReportingRate]				= GL.[dblReportingRate]
						,[dblForeignRate]				= GL.[dblForeignRate]
						,[strDocument]					= GL.[strDocument]
						,[strComments]					= GL.[strComments]
						,[strSourceDocumentId]			= GL.[strSourceDocumentId]
						,[intSourceLocationId]			= GL.[intSourceLocationId]
						,[intSourceUOMId]				= GL.[intSourceUOMId]
						,[dblSourceUnitDebit]			= GL.[dblSourceUnitCredit]
						,[dblSourceUnitCredit]			= GL.[dblSourceUnitDebit]
						,[intCommodityId]				= GL.[intCommodityId]
						,[intSourceEntityId]			= GL.[intSourceEntityId]
                    FROM (
                        SELECT 
							 [intOriginalInvoiceId]
							,[intInvoiceId]
							,[dtmPostDate]
							,[dtmDate]
							,[strInvoiceNumber]
							,[strTransactionType]
							,[strInvoiceOriginId]
                        FROM
							@PostInvoiceData
                        WHERE
							[intOriginalInvoiceId] IS NOT NULL 
							AND [intSourceId] IS NOT NULL 
							AND intOriginalInvoiceId <> 0 
							AND [intSourceId] = 2
                    ) P
                    INNER JOIN (
                        SELECT 
							 [intAccountId]
							,[intGLDetailId]
							,[intTransactionId]
							,[strTransactionId]
							,[dblCredit]
							,[dblDebit]
							,[dblCreditUnit]
							,[dblDebitUnit]
							,[strReference]
							,[strDescription]
							,[strJournalLineDescription]
							,[intCurrencyId]
							,[dblExchangeRate]
							,[dblCreditForeign]
							,[dblCreditReport]
							,[dblDebitForeign]
							,[dblDebitReport]
							,[dblReportingRate]
							,[dblForeignRate]
							,[strDocument]
							,[strComments]
							,[strSourceDocumentId]
							,[intSourceLocationId]
							,[intSourceUOMId]
							,[dblSourceUnitDebit]
							,[dblSourceUnitCredit]
							,[intCommodityId]
							,[intSourceEntityId]
                        FROM
							tblGLDetail WITH (NOLOCK)
                        WHERE 
                            [ysnIsUnposted] = 0
                            AND [strModuleName] = @MODULE_NAME
                    ) GL ON P.[intOriginalInvoiceId] = GL.[intTransactionId]
                        AND P.[strInvoiceOriginId] = GL.[strTransactionId]
                    ORDER BY GL.intGLDetailId

					DECLARE @InTransitItemsForReversal AS TABLE(
						 [intId]						INT IDENTITY PRIMARY KEY CLUSTERED	
						,[intItemId]					INT NOT NULL
						,[intItemLocationId]			INT NULL
						,[intItemUOMId]					INT NOT NULL
						,[dtmDate]						DATETIME NOT NULL
						,[dblQty]						NUMERIC(38, 20) NOT NULL DEFAULT 0
						,[dblUOMQty]					NUMERIC(38, 20) NOT NULL DEFAULT 1
						,[dblCost]						NUMERIC(38, 20) NOT NULL DEFAULT 0
						,[dblValue]						NUMERIC(38, 20) NOT NULL DEFAULT 0
						,[dblSalesPrice]				NUMERIC(18, 6) NOT NULL DEFAULT 0
						,[intCurrencyId]				INT NULL
						,[dblExchangeRate]				NUMERIC (38, 20) DEFAULT 1 NOT NULL
						,[intTransactionId]				INT NOT NULL
						,[intTransactionDetailId]		INT NULL
						,[strTransactionId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
						,[intTransactionTypeId]			INT NOT NULL
						,[intLotId]						INT NULL
						,[intSourceTransactionId]		INT NULL
						,[strSourceTransactionId]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
						,[intSourceTransactionDetailId]	INT NULL
						,[intFobPointId]				TINYINT NULL
						,[intInTransitSourceLocationId]	INT NULL 
						,[intForexRateTypeId]			INT NULL
						,[dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1 
						,[intOriginalInvoiceId]			INT					NULL
						,[strInvoiceOriginId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
					)				
					INSERT INTO @InTransitItemsForReversal (
						 [intItemId] 
						,[intItemLocationId] 
						,[intItemUOMId] 
						,[dtmDate] 
						,[dblQty] 
						,[dblUOMQty] 
						,[dblCost] 
						,[dblValue] 
						,[dblSalesPrice] 
						,[intCurrencyId] 
						,[dblExchangeRate] 
						,[intTransactionId] 
						,[intTransactionDetailId] 
						,[strTransactionId] 
						,[intTransactionTypeId] 
						,[intLotId] 
						,[intSourceTransactionId] 
						,[strSourceTransactionId] 
						,[intSourceTransactionDetailId] 
						,[intFobPointId] 
						,[intInTransitSourceLocationId]
						,[intForexRateTypeId]
						,[dblForexRate]
						,[intOriginalInvoiceId]
						,[strInvoiceOriginId]
					)
					SELECT
						 [intItemId] 
						,[intItemLocationId] 
						,[intItemUOMId] 
						,[dtmDate] 
						,[dblQty] 
						,[dblUOMQty] 
						,[dblCost] 
						,[dblValue] 
						,[dblSalesPrice] 
						,[intCurrencyId] 
						,[dblExchangeRate] 
						,[intTransactionId] 
						,[intTransactionDetailId] 
						,[strTransactionId] 
						,[intTransactionTypeId] 
						,[intLotId] 
						,[intSourceTransactionId] 
						,[strSourceTransactionId] 
						,[intSourceTransactionDetailId] 
						,[intFobPointId] 
						,[intInTransitSourceLocationId]
						,[intForexRateTypeId]
						,[dblForexRate]
						,[intOriginalInvoiceId]
						,[strInvoiceOriginId]
					FROM 
						dbo.[fnARGetItemsForInTransitCostingForProvisionalReversal](@PostInvoiceData, @post)

					IF EXISTS (SELECT TOP 1 1 FROM @InTransitItemsForReversal)
					BEGIN
					    DECLARE @InTransitItemsForReversalForPassing AS ItemInTransitCostingTableType
						INSERT INTO @InTransitItemsForReversalForPassing (
							 [intItemId] 
							,[intItemLocationId] 
							,[intItemUOMId] 
							,[dtmDate] 
							,[dblQty] 
							,[dblUOMQty] 
							,[dblCost] 
							,[dblValue] 
							,[dblSalesPrice] 
							,[intCurrencyId] 
							,[dblExchangeRate] 
							,[intTransactionId] 
							,[intTransactionDetailId] 
							,[strTransactionId] 
							,[intTransactionTypeId] 
							,[intLotId] 
							,[intSourceTransactionId] 
							,[strSourceTransactionId] 
							,[intSourceTransactionDetailId] 
							,[intFobPointId] 
							,[intInTransitSourceLocationId]
							,[intForexRateTypeId]
							,[dblForexRate]							
						)
						SELECT
							 [intItemId] 
							,[intItemLocationId] 
							,[intItemUOMId] 
							,[dtmDate] 
							,[dblQty] 
							,[dblUOMQty] 
							,[dblCost] 
							,[dblValue] 
							,[dblSalesPrice] 
							,[intCurrencyId] 
							,[dblExchangeRate] 
							,[intTransactionId] 
							,[intTransactionDetailId] 
							,[strTransactionId] 
							,[intTransactionTypeId] 
							,[intLotId] 
							,[intSourceTransactionId] 
							,[strSourceTransactionId] 
							,[intSourceTransactionDetailId] 
							,[intFobPointId] 
							,[intInTransitSourceLocationId]
							,[intForexRateTypeId]
							,[dblForexRate]							
						FROM                 
							@InTransitItemsForReversal

						WHILE EXISTS(SELECT TOP 1 NULL FROM @InTransitItemsForReversal ORDER BY [intTransactionId])
						BEGIN
				
							DECLARE @OriginalInvoiceId INT
									,@InvoiceOriginId NVARCHAR(80)
									,@WStorageCount0 INT
									,@WOStorageCount0 INT
					
							SELECT TOP 1 @OriginalInvoiceId = [intOriginalInvoiceId], @InvoiceOriginId = [strInvoiceOriginId] 
							FROM	@InTransitItemsForReversal ORDER BY [intTransactionId]

							SELECT @WStorageCount0 = COUNT(1) FROM tblARInvoiceDetail WITH (NOLOCK) WHERE intInvoiceId = @OriginalInvoiceId AND (ISNULL(intItemId, 0) <> 0) AND (ISNULL(intStorageScheduleTypeId,0) <> 0)	
							SELECT @WOStorageCount0 = COUNT(1) FROM tblARInvoiceDetail WITH (NOLOCK) WHERE intInvoiceId = @OriginalInvoiceId AND (ISNULL(intItemId, 0) <> 0) AND (ISNULL(intStorageScheduleTypeId,0) = 0)
							IF @WStorageCount0 > 0
							BEGIN
								-- Unpost onhand stocks. 
								EXEC	dbo.uspICUnpostCosting
											@OriginalInvoiceId
											,@InvoiceOriginId
											,@batchIdUsed
											,@UserEntityID
											,@recap 
							END

							IF @WOStorageCount0 > 0 
							BEGIN 
								-- Unpost storage stocks. 
								EXEC	dbo.uspICUnpostStorage
										@OriginalInvoiceId
										,@InvoiceOriginId
										,@batchIdUsed
										,@UserEntityID
										,@recap
							END					
										
							DELETE FROM @InTransitItemsForReversal 
							WHERE	[intOriginalInvoiceId] = @OriginalInvoiceId 
									AND [strInvoiceOriginId] = @InvoiceOriginId 												
						END		

						DELETE FROM @TempGLEntries
						INSERT INTO @TempGLEntries (
							[dtmDate] 
							,[strBatchId]
							,[intAccountId]
							,[dblDebit]
							,[dblCredit]
							,[dblDebitUnit]
							,[dblCreditUnit]
							,[strDescription]
							,[strCode]
							,[strReference]
							,[intCurrencyId]
							,[dblExchangeRate]
							,[dtmDateEntered]
							,[dtmTransactionDate]
							,[strJournalLineDescription]
							,[intJournalLineNo]
							,[ysnIsUnposted]
							,[intUserId]
							,[intEntityId]
							,[strTransactionId]
							,[intTransactionId]
							,[strTransactionType]
							,[strTransactionForm]
							,[strModuleName]
							,[intConcurrencyId]
							,[dblDebitForeign]
							,[dblDebitReport]
							,[dblCreditForeign]
							,[dblCreditReport]
							,[dblReportingRate]
							,[dblForeignRate]
						)
						EXEC	dbo.uspICPostInTransitCosting  
								@InTransitItemsForReversalForPassing  
								,@batchIdUsed
								,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
								,@UserEntityID

						DELETE FROM ICIT
						FROM
							(SELECT [intTransactionId], [strTransactionId], [ysnIsUnposted] FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
						INNER JOIN
							@InTransitItemsForReversal SIFP
								ON ICIT.[intTransactionId] = SIFP.[intTransactionId]
								AND ICIT.[strTransactionId] = SIFP.[strTransactionId]
								AND ICIT.[ysnIsUnposted] <> 1
								AND @recap  = 1
								AND @post = 1


						UPDATE
							@TempGLEntries
						SET
							[strDescription] = SUBSTRING('Reverse Provisional Invoice' + ISNULL(' - ' + [strDescription],''), 1, 255)

						INSERT INTO @GLEntries
						SELECT * FROM @TempGLEntries					
					END

					
				END
			ELSE
				SET @HasImpactForProvisional = 0
						
			INSERT INTO @GLEntries (
				 [dtmDate]
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,[ysnIsUnposted]
				,[intUserId]
				,[intEntityId]
				,[strTransactionId]
				,[intTransactionId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
				,[intConcurrencyId]
				,[dblDebitForeign]
				,[dblDebitReport]
				,[dblCreditForeign]
				,[dblCreditReport]
				,[dblReportingRate]
				,[dblForeignRate]
				,[strRateType]
			)
			--DEBIT Total
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= A.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseInvoiceTotal ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblBaseInvoiceTotal END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
																								(
																									SELECT
																										SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
																									FROM
																										(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
																										 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
																									INNER JOIN
																										(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
																											ON ARID.intInvoiceId = ARI.intInvoiceId	
																									LEFT OUTER JOIN
																										(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
																											ON ARID.intItemId = I.intItemId
																									LEFT OUTER JOIN
																										(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
																											ON ARID.intItemId = IST.intItemId 
																											AND ARI.intCompanyLocationId = IST.intLocationId 
																									LEFT OUTER JOIN
																										(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON ARID.intItemId = ICIS.intItemId 
																											AND ARI.intCompanyLocationId = ICIS.intLocationId 
																									WHERE
																										ARI.intInvoiceId = A.intInvoiceId
																										AND ARID.dblQtyShipped <> @ZeroDecimal  
																								)
																							ELSE 
																								0
																							END
				,dblCreditUnit				=  CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
																								0
																							ELSE 
																								(
																								SELECT
																									SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
																								FROM
																									(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
																									 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
																								INNER JOIN
																									(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
																										ON ARID.intInvoiceId = ARI.intInvoiceId	
																								LEFT OUTER JOIN
																									(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
																										ON ARID.intItemId = I.intItemId
																								LEFT OUTER JOIN
																									(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
																										ON ARID.intItemId = IST.intItemId 
																										AND ARI.intCompanyLocationId = IST.intLocationId 
																								LEFT OUTER JOIN
																									(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
																										ON ARID.intItemId = ICIS.intItemId 
																										AND ARI.intCompanyLocationId = ICIS.intLocationId 
																								WHERE
																									ARI.intInvoiceId = A.intInvoiceId
																									AND ARID.dblQtyShipped <> @ZeroDecimal  
																								)
																							END																						
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(NULLIF(dblBaseInvoiceTotal, 0), 1)/ISNULL(NULLIF(dblInvoiceTotal, 0), 1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE 0 END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE 0 END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblInvoiceTotal - ISNULL(@ZeroDecimal, @ZeroDecimal) END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''
			FROM
				(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, dtmDate, dtmPostDate, strComments, dblInvoiceTotal, intAccountId, intPeriodsToAccrue, dblBaseInvoiceTotal, intSourceId, intOriginalInvoiceId
				 FROM tblARInvoice WITH (NOLOCK)) A
			LEFT JOIN 
				(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId				
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (
						A.dblInvoiceTotal <> @ZeroDecimal
						OR
						EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
					)
				AND NOT(A.intSourceId = 2 AND A.intOriginalInvoiceId IS NOT NULL)

			UNION ALL
			--DEBIT Amount Due - Final Invoice
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= A.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseAmountDue ELSE @ZeroDecimal END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblBaseAmountDue END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
																								(
																									SELECT
																										SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
																									FROM
																										(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
																										 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
																									INNER JOIN
																										(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
																											ON ARID.intInvoiceId = ARI.intInvoiceId	
																									LEFT OUTER JOIN
																										(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
																											ON ARID.intItemId = I.intItemId
																									LEFT OUTER JOIN
																										(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
																											ON ARID.intItemId = IST.intItemId 
																											AND ARI.intCompanyLocationId = IST.intLocationId 
																									LEFT OUTER JOIN
																										(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON ARID.intItemId = ICIS.intItemId 
																											AND ARI.intCompanyLocationId = ICIS.intLocationId 
																									WHERE
																										ARI.intInvoiceId = A.intInvoiceId
																										AND ARID.dblQtyShipped <> @ZeroDecimal  
																								)
																							ELSE 
																								0
																							END
				,dblCreditUnit				=  CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
																								0
																							ELSE 
																								(
																								SELECT
																									SUM(dbo.fnARCalculateQtyBetweenUOM(ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped, null, I.strType))
																								FROM
																									(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
																									 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
																								INNER JOIN
																									(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
																										ON ARID.intInvoiceId = ARI.intInvoiceId	
																								LEFT OUTER JOIN
																									(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
																										ON ARID.intItemId = I.intItemId
																								LEFT OUTER JOIN
																									(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
																										ON ARID.intItemId = IST.intItemId 
																										AND ARI.intCompanyLocationId = IST.intLocationId 
																								LEFT OUTER JOIN
																									(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
																										ON ARID.intItemId = ICIS.intItemId 
																										AND ARI.intCompanyLocationId = ICIS.intLocationId 
																								WHERE
																									ARI.intInvoiceId = A.intInvoiceId
																									AND ARID.dblQtyShipped <> @ZeroDecimal  
																								)
																							END																					
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(NULLIF(dblBaseInvoiceTotal, 0), 1)/ISNULL(NULLIF(dblInvoiceTotal, 0), 1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblAmountDue ELSE 0 END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblAmountDue ELSE 0 END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblAmountDue END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN @ZeroDecimal ELSE A.dblAmountDue END
				,[dblReportingRate]			= @ZeroDecimal
				,[dblForeignRate]			= @ZeroDecimal
				,[strRateType]				= ''
			FROM
				(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, dtmDate, dtmPostDate, strComments, dblAmountDue, intAccountId, intPeriodsToAccrue, dblBaseAmountDue, intSourceId, intOriginalInvoiceId, dblBaseInvoiceTotal,dblInvoiceTotal
				 FROM tblARInvoice WITH (NOLOCK)) A
			LEFT JOIN 
				(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId	
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (
						A.dblAmountDue <> @ZeroDecimal
						OR
						EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
					)
				AND A.intSourceId = 2 
				AND A.intOriginalInvoiceId IS NOT NULL

			UNION ALL
			--CREDIT - Provisional Invoice Amount + Sales
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= A.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblBaseAmountDue - A.dblBaseInvoiceTotal END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseAmountDue - A.dblBaseInvoiceTotal ELSE 0 END
				,dblDebitUnit				= @ZeroDecimal
				,dblCreditUnit				= @ZeroDecimal																				
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(NULLIF(dblBaseInvoiceTotal, 0), 1)/ISNULL(NULLIF(dblInvoiceTotal, 0), 1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Provisional Amount'
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblAmountDue - A.dblInvoiceTotal END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblAmountDue - A.dblInvoiceTotal END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblAmountDue - A.dblInvoiceTotal ELSE 0 END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblAmountDue - A.dblInvoiceTotal ELSE 0 END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''
			FROM
				(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, dtmDate, dtmPostDate, strComments, dblAmountDue, intAccountId, intPeriodsToAccrue, dblBaseAmountDue, intSourceId, intOriginalInvoiceId, dblInvoiceTotal, dblBaseInvoiceTotal
				 FROM tblARInvoice WITH (NOLOCK)) A
			LEFT JOIN 
				(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId	
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (
						(A.dblBaseAmountDue - A.dblBaseInvoiceTotal) <> @ZeroDecimal
						OR
						EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
					)
				AND A.intSourceId = 2 
				AND A.intOriginalInvoiceId IS NOT NULL

			UNION ALL
			--DEBIT Prepaids
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= ARPAC.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,dblDebitUnit				= @ZeroDecimal 
				,dblCreditUnit				= @ZeroDecimal
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Applied Prepaid - ' + ARPAC.[strInvoiceNumber] 
				,intJournalLineNo			= ARPAC.[intPrepaidAndCreditId]
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''	 
			FROM
				(SELECT I.strInvoiceNumber,PPC.[intInvoiceId],I.intAccountId, [intPrepaidAndCreditId], [intPrepaymentId], [ysnApplied], [dblAppliedInvoiceDetailAmount], [dblBaseAppliedInvoiceDetailAmount]
				 FROM tblARPrepaidAndCredit PPC WITH (NOLOCK)
				 INNER JOIN tblARInvoice I
				 ON I.intInvoiceId = PPC.intPrepaymentId) ARPAC
			INNER JOIN
				(SELECT [intInvoiceId],intAccountId, strInvoiceNumber, dtmDate, dtmPostDate, strTransactionType, intCurrencyId, [intEntityCustomerId], strComments, intPeriodsToAccrue
				 FROM tblARInvoice WITH (NOLOCK)) A
					ON ARPAC.[intInvoiceId] = A.[intInvoiceId] AND ISNULL(ARPAC.[ysnApplied],0) = 1 AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId FROM @PostInvoiceData ) P ON A.intInvoiceId = P.intInvoiceId
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1			
			
			UNION ALL

			--Debit Payment
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= SMCL.intUndepositedFundsId 
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblBasePayment - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblBasePayment - ISNULL(@ZeroDecimal, @ZeroDecimal) END
				,dblDebitUnit				= @ZeroDecimal
				,dblCreditUnit				= @ZeroDecimal					
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(NULLIF(dblBaseInvoiceTotal, 0), 1)/ISNULL(NULLIF(dblInvoiceTotal, 0), 1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE 0 END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) ELSE 0 END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal) END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''	  			
			FROM
				(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], intCompanyLocationId, dtmPostDate, dtmDate, strTransactionType, dblPayment, strComments, intCurrencyId, intPeriodsToAccrue, dblBasePayment, dblBaseInvoiceTotal,dblInvoiceTotal
				 FROM tblARInvoice WITH (NOLOCK)) A
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
			INNER JOIN
				(SELECT intCompanyLocationId, intUndepositedFundsId FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
					ON A.intCompanyLocationId = SMCL.intCompanyLocationId
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (A.dblPayment - ISNULL(@ZeroDecimal, @ZeroDecimal)) <> @ZeroDecimal
			
			--/*
			UNION ALL
			--Credit Prepaids
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= CASE WHEN ARPAC.strTransactionType IN('Customer Prepayment','Credit Memo') THEN SMCL.intAPAccount ELSE ARPAC.intAccountId END
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,dblDebitUnit				= @ZeroDecimal 
				,dblCreditForeign			= @ZeroDecimal
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Applied Prepaid - ' + ARPAC.[strInvoiceNumber] 
				,intJournalLineNo			= ARPAC.[intPrepaidAndCreditId]
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash', 'Cash Refund') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''
			FROM
				(SELECT  I.strInvoiceNumber, PPC.[intInvoiceId],I.strTransactionType,I.intAccountId, [intPrepaidAndCreditId], [intPrepaymentId], [ysnApplied], [dblAppliedInvoiceDetailAmount], [dblBaseAppliedInvoiceDetailAmount]
				 FROM tblARPrepaidAndCredit PPC WITH (NOLOCK)
				 INNER JOIN tblARInvoice I
				 ON I.intInvoiceId = PPC.intPrepaymentId) ARPAC
			INNER JOIN
				(SELECT [intInvoiceId],intAccountId, strInvoiceNumber, dtmPostDate, dtmDate, [intEntityCustomerId], strTransactionType, intCurrencyId, strComments, intPeriodsToAccrue, intCompanyLocationId
				 FROM tblARInvoice WITH (NOLOCK) ) A ON ARPAC.[intInvoiceId] = A.[intInvoiceId] AND  ISNULL(ARPAC.[ysnApplied],0) = 1 AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal				 
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId, strTransactionType FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				(SELECT [intCompanyLocationId], intAPAccount FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL ON SMCL.[intCompanyLocationId] = A.intCompanyLocationId
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND P.strTransactionType <> 'Cash Refund'
			
			--CREDIT MISC
			UNION ALL 

			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= B.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN 0 ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0  END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN 0 ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, ICIS.strType) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, ICIS.strType) ELSE 0 END				
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(B.dblCurrencyExchangeRate,1) 
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN 0 ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())  END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN 0 ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())  END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0  END
				,[dblReportingRate]			= B.dblCurrencyExchangeRate 
				,[dblForeignRate]			= B.dblCurrencyExchangeRate 
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			FROM
				(SELECT intInvoiceId, intInvoiceDetailId, intAccountId, intItemId, strItemDescription, intItemUOMId, dblQtyShipped, dblDiscount, dblPrice, dblTotal, intCurrencyExchangeRateTypeId, dblBaseTotal, dblBasePrice, dblCurrencyExchangeRate
				 FROM tblARInvoiceDetail WITH (NOLOCK)) B
			INNER JOIN
				(SELECT intInvoiceId, strInvoiceNumber, intCompanyLocationId, dtmDate, dtmPostDate, intCurrencyId, [intEntityCustomerId], strTransactionType, strComments, intPeriodsToAccrue, strType
				 FROM tblARInvoice WITH (NOLOCK)) A  ON B.intInvoiceId = A.intInvoiceId					
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]		
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId 	
			INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intCompanyLocationId
			LEFT OUTER JOIN 
				(SELECT intItemId, intLocationId, intStockUOMId, strType FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId AND A.intCompanyLocationId = ICIS.intLocationId 
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
			WHERE
				((B.intItemId IS NULL OR B.intItemId = 0)
					OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))))
				AND (A.strTransactionType <> 'Debit Memo' OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')))
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (B.dblTotal <> 0 OR B.dblQtyShipped <> 0)
				AND A.strTransactionType <> 'Cash Refund'

			--CREDIT Software -- License
			UNION ALL 

			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= B.intLicenseAccountId 
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																													
																										 END)
											  ELSE 0  END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) ELSE 0 END							
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(B.dblCurrencyExchangeRate,1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																													
																										 END)
											  ELSE 0  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																													
																										 END)
											  ELSE 0  END
				,[dblReportingRate]			= B.dblCurrencyExchangeRate 
				,[dblForeignRate]			= B.dblCurrencyExchangeRate 
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			FROM
				(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, strMaintenanceType, dblLicenseAmount, dblTotal, intItemUOMId, dblQtyShipped, dblDiscount, intCurrencyExchangeRateTypeId, 
					dblMaintenanceAmount, dblPrice, intLicenseAccountId, dblBasePrice, dblBaseTotal, dblCurrencyExchangeRate, dblBaseLicenseAmount, dblBaseMaintenanceAmount
				 FROM tblARInvoiceDetail WITH (NOLOCK)) B
			INNER JOIN
				(SELECT intInvoiceId, [intEntityCustomerId], intCompanyLocationId, dtmDate, dtmPostDate, intCurrencyId, strTransactionType, strInvoiceNumber, strComments, intPeriodsToAccrue 
				 FROM tblARInvoice WITH (NOLOCK)) A ON B.intInvoiceId = A.intInvoiceId
			INNER JOIN
				(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I ON B.intItemId = I.intItemId 				
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]		
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId 
			LEFT OUTER JOIN 
				(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId  AND A.intCompanyLocationId = ICIS.intLocationId
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
			WHERE
				B.dblLicenseAmount <> @ZeroDecimal
				AND B.strMaintenanceType IN ('License/Maintenance', 'License Only')
				AND ISNULL(I.strType,'') = 'Software'
				AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
				AND (ISNULL(A.intPeriodsToAccrue,0) <= 1 OR ( ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(@accrueLicense,0) = 0))

			--DEBIT Software -- License
			UNION ALL 

			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= @DeferredRevenueAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  ELSE 0  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)  ELSE 0 END				
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) END				
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(B.dblCurrencyExchangeRate,1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  ELSE 0  END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  ELSE 0  END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND @accrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,[dblReportingRate]			= B.dblCurrencyExchangeRate 
				,[dblForeignRate]			= B.dblCurrencyExchangeRate 
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType
			FROM
				(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, intItemUOMId, dblDiscount, dblTotal, dblLicenseAmount, dblQtyShipped, 
					strMaintenanceType, dblPrice, dblMaintenanceAmount, intCurrencyExchangeRateTypeId, dblCurrencyExchangeRate, dblBasePrice, dblBaseTotal, dblBaseLicenseAmount, dblBaseMaintenanceAmount
				 FROM tblARInvoiceDetail WITH (NOLOCK)) B
			INNER JOIN
				(SELECT intInvoiceId, dtmPostDate, strInvoiceNumber, intCurrencyId, dtmDate, [intEntityCustomerId], intCompanyLocationId, strTransactionType, strComments, intPeriodsToAccrue 
				 FROM tblARInvoice WITH (NOLOCK))  A 
					ON B.intInvoiceId = A.intInvoiceId
			INNER JOIN
				(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I ON B.intItemId = I.intItemId 				
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]		
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				(SELECT intItemId, intLocationId FROM vyuARGetItemAccount WITH (NOLOCK)) IST ON B.intItemId = IST.intItemId AND A.intCompanyLocationId = IST.intLocationId
			LEFT OUTER JOIN 
				(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId AND A.intCompanyLocationId = ICIS.intLocationId 					
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
			WHERE
				B.dblLicenseAmount <> @ZeroDecimal
				AND B.strMaintenanceType IN ('License/Maintenance', 'License Only')
				AND ISNULL(I.strType,'') = 'Software'
				AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
				AND (ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(@accrueLicense,0) = 0)

			--CREDIT Software -- Maintenance
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= B.intMaintenanceAccountId 
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																												END)
												END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																												END) 
											  ELSE 0  END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)) ELSE 0 END							
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(B.dblCurrencyExchangeRate,1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
																													ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																												END)
												END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
																													ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																												END)
												END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
																													ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																												END) 
											  ELSE 0  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType IN ('Maintenance Only', 'SaaS')  THEN 
																													ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																												END) 
											  ELSE 0  END
				,[dblReportingRate]			= B.dblCurrencyExchangeRate 
				,[dblForeignRate]			= B.dblCurrencyExchangeRate 
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			FROM
				(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, dblMaintenanceAmount, intMaintenanceAccountId, strMaintenanceType, intItemUOMId, dblQtyShipped, dblDiscount, 
					dblPrice, dblTotal, intCurrencyExchangeRateTypeId, dblBasePrice, dblBaseTotal, dblCurrencyExchangeRate, dblBaseMaintenanceAmount, dblBaseLicenseAmount
				 FROM tblARInvoiceDetail WITH (NOLOCK)) B
			INNER JOIN
				(SELECT intInvoiceId, strInvoiceNumber, strTransactionType, intCurrencyId, [intEntityCustomerId], strComments, dtmDate, dtmPostDate, intCompanyLocationId, intPeriodsToAccrue
				 FROM tblARInvoice WITH (NOLOCK))  A 
					ON B.intInvoiceId = A.intInvoiceId
			INNER JOIN
				(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I ON B.intItemId = I.intItemId 				
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]		
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS ON B.intItemId = ICIS.intItemId AND A.intCompanyLocationId = ICIS.intLocationId 
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
			WHERE
				B.dblMaintenanceAmount <> @ZeroDecimal
				AND B.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
				AND ISNULL(I.strType,'') = 'Software'
				AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT SALES
			UNION ALL 
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)  END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) ELSE 0 END							
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(B.dblCurrencyExchangeRate,1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,[dblReportingRate]			= B.dblCurrencyExchangeRate 
				,[dblForeignRate]			= B.dblCurrencyExchangeRate 
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			FROM
				(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, intItemUOMId, intSalesAccountId, dblQtyShipped, dblDiscount, dblPrice, dblTotal,
						intCurrencyExchangeRateTypeId, dblBaseTotal, dblBasePrice, dblCurrencyExchangeRate
				 FROM tblARInvoiceDetail WITH (NOLOCK)
				 WHERE (intItemId IS NOT NULL OR intItemId <> 0)) B
			INNER JOIN
				(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, intCompanyLocationId, strTransactionType, strComments, intCurrencyId, dtmPostDate, dtmDate, intPeriodsToAccrue, dblInvoiceTotal
				 FROM tblARInvoice WITH (NOLOCK)) A 
					ON B.intInvoiceId = A.intInvoiceId					
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]			
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P
					ON A.intInvoiceId = P.intInvoiceId
			INNER JOIN
				(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
					ON B.intItemId = I.intItemId
			INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = A.intCompanyLocationId
			LEFT OUTER JOIN
				(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
					ON B.intItemId = ICIS.intItemId 
					AND A.intCompanyLocationId = ICIS.intLocationId
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId 
			WHERE			 
				(B.intItemId IS NOT NULL OR B.intItemId <> 0)
				AND ISNULL(I.strType,'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
				AND A.strTransactionType NOT IN ('Debit Memo', 'Cash Refund')
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (
                        B.dblQtyShipped <> @ZeroDecimal
                    OR
                        (B.dblQtyShipped = @ZeroDecimal AND A.dblInvoiceTotal = @ZeroDecimal)
                    )

			--CREDIT SALES - Debit Memo
			UNION ALL 
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType)  END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN dbo.fnARCalculateQtyBetweenUOM(B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped, null, I.strType) ELSE 0 END							
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(B.dblCurrencyExchangeRate,1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,[dblReportingRate]			= B.dblCurrencyExchangeRate 
				,[dblForeignRate]			= B.dblCurrencyExchangeRate 
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType
			FROM
				(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, intSalesAccountId, dblTotal, intItemUOMId, dblQtyShipped, dblDiscount, dblPrice,
						intCurrencyExchangeRateTypeId, dblBaseTotal, dblBasePrice, dblCurrencyExchangeRate
				 FROM tblARInvoiceDetail WITH (NOLOCK)) B
			INNER JOIN
				(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], dtmPostDate, dtmDate, strTransactionType, strComments, intCurrencyId, intCompanyLocationId, intPeriodsToAccrue, strType
				 FROM tblARInvoice WITH (NOLOCK)) A 
					ON B.intInvoiceId = A.intInvoiceId					
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]			
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P
					ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				(SELECT intItemId, strType FROM tblICItem WITH (NOLOCK)) I
					ON B.intItemId = I.intItemId
			LEFT OUTER JOIN
				(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
					ON B.intItemId = ICIS.intItemId 
					AND A.intCompanyLocationId = ICIS.intLocationId
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON B.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId 
			WHERE
				B.dblQtyShipped <> @ZeroDecimal  
				AND A.strTransactionType = 'Debit Memo'
				AND A.strType NOT IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND ISNULL(I.strType,'') <> 'Comment'

			--CREDIT Shipping
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= L.intFreightIncome
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblBaseShipping END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseShipping ELSE 0  END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0							
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(NULLIF(dblBaseInvoiceTotal, 0), 1)/ISNULL(NULLIF(dblInvoiceTotal, 0), 1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblShipping END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblShipping END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblShipping ELSE 0  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblShipping ELSE 0  END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''
			FROM
				(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], intCompanyLocationId, dtmPostDate, dtmDate, dblShipping, strTransactionType, strComments, intCurrencyId, dblBaseShipping,dblBaseInvoiceTotal,dblInvoiceTotal
				 FROM tblARInvoice WITH (NOLOCK)) A 
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]	
			INNER JOIN
				(SELECT intCompanyLocationId, intFreightIncome FROM tblSMCompanyLocation WITH (NOLOCK)) L
					ON A.intCompanyLocationId = L.intCompanyLocationId	
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData)	P
					ON A.intInvoiceId = P.intInvoiceId	
			WHERE
				A.dblShipping <> @ZeroDecimal		
				
		UNION ALL 
			--CREDIT Tax
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId), SMCL.intProfitCenter),ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId))
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblBaseAdjustedTax < 0 THEN ABS(DT.dblBaseAdjustedTax) ELSE 0 END 
											  ELSE 
													CASE WHEN DT.dblBaseAdjustedTax < 0 THEN 0 ELSE DT.dblBaseAdjustedTax END
											  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblBaseAdjustedTax < 0 THEN 0 ELSE DT.dblBaseAdjustedTax END 
											  ELSE 
													CASE WHEN DT.dblBaseAdjustedTax < 0 THEN ABS(DT.dblBaseAdjustedTax) ELSE 0 END 
											  END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0								
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= ISNULL(NULLIF(dblBaseInvoiceTotal, 0), 1)/ISNULL(NULLIF(dblInvoiceTotal, 0), 1)
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= DT.intInvoiceDetailTaxId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblAdjustedTax < 0 THEN ABS(DT.dblAdjustedTax) ELSE 0 END 
											  ELSE 
													CASE WHEN DT.dblAdjustedTax < 0 THEN 0 ELSE DT.dblAdjustedTax END
											  END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblAdjustedTax < 0 THEN ABS(DT.dblAdjustedTax) ELSE 0 END 
											  ELSE 
													CASE WHEN DT.dblAdjustedTax < 0 THEN 0 ELSE DT.dblAdjustedTax END
											  END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblAdjustedTax < 0 THEN 0 ELSE DT.dblAdjustedTax END 
											  ELSE 
													CASE WHEN DT.dblAdjustedTax < 0 THEN ABS(DT.dblAdjustedTax) ELSE 0 END 
											  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblAdjustedTax < 0 THEN 0 ELSE DT.dblAdjustedTax END 
											  ELSE 
													CASE WHEN DT.dblAdjustedTax < 0 THEN ABS(DT.dblAdjustedTax) ELSE 0 END 
											  END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			FROM
				(SELECT intTaxCodeId, intInvoiceDetailId, intInvoiceDetailTaxId, intSalesTaxAccountId, dblAdjustedTax, dblBaseAdjustedTax
				 FROM tblARInvoiceDetailTax WITH (NOLOCK)) DT
			INNER JOIN
				(SELECT intInvoiceId, intInvoiceDetailId, intCurrencyExchangeRateTypeId FROM tblARInvoiceDetail WITH (NOLOCK)) D
					ON DT.intInvoiceDetailId = D.intInvoiceDetailId
			INNER JOIN			
				(SELECT intInvoiceId, dtmPostDate, dtmDate, intEntityCustomerId, strComments, strTransactionType, intCurrencyId, strInvoiceNumber, intPeriodsToAccrue, intCompanyLocationId,dblBaseInvoiceTotal,dblInvoiceTotal
				 FROM tblARInvoice WITH (NOLOCK)) A 
					ON D.intInvoiceId = A.intInvoiceId
			INNER JOIN
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.intEntityCustomerId = C.[intEntityId]
			INNER JOIN
				tblSMCompanyLocation SMCL
					ON A.intCompanyLocationId = SMCL.intCompanyLocationId 
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData )	P
					ON A.intInvoiceId = P.intInvoiceId				
			LEFT OUTER JOIN
				(SELECT intTaxCodeId, intSalesTaxAccountId FROM tblSMTaxCode WITH (NOLOCK)) TC
					ON DT.intTaxCodeId = TC.intTaxCodeId
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
			WHERE
				DT.dblAdjustedTax <> @ZeroDecimal
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				
			UNION ALL 
			--DEBIT Discount
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchIdUsed
				,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0								
				,strDescription				= P.[strDescription]
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= D.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0 END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0 END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			FROM
				(SELECT intInvoiceId, intItemId, intInvoiceDetailId, dblQtyShipped, dblDiscount, dblPrice, intCurrencyExchangeRateTypeId, dblBasePrice FROM tblARInvoiceDetail WITH (NOLOCK)) D
			INNER JOIN			
				(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, intCompanyLocationId, dtmPostDate, dtmDate, strComments 
				 FROM tblARInvoice WITH (NOLOCK)) A 
					ON D.intInvoiceId = A.intInvoiceId
			LEFT OUTER JOIN
				(SELECT intItemId, intLocationId, intDiscountAccountId FROM vyuARGetItemAccount WITH (NOLOCK)) IST
					ON D.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId 
			INNER JOIN
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.intEntityCustomerId = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId, [strDescription] FROM @PostInvoiceData) P
					ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				(
					SELECT
						intCurrencyExchangeRateTypeId 
						,strCurrencyExchangeRateType 
					FROM
						tblSMCurrencyExchangeRateType
				)	SMCERT
					ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
			WHERE
				((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) <> @ZeroDecimal
			
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH

		DECLARE @AVERAGECOST AS INT = 1
				,@FIFO AS INT = 2
				,@LIFO AS INT = 3
				,@LOTCOST AS INT = 4
				,@ACTUALCOST AS INT = 5

		--Update onhand
		BEGIN TRY
			-- Get the items to post  
			DECLARE @ItemsForPost AS ItemCostingTableType  			

			INSERT INTO @ItemsForPost (  
				 [intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[ysnIsStorage]
				,[strActualCostId]
				,[intSourceTransactionId]
				,[strSourceTransactionId]
				,[intInTransitSourceLocationId]
				,[intForexRateTypeId]
				,[dblForexRate]
				,[intStorageScheduleTypeId]
				,[dblUnitRetail]
				,[intCategoryId]
				,[dblAdjustRetailValue]
			) 
			SELECT 
				 [intItemId]
				,[intItemLocationId]
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty]
				,[dblCost]
				,[dblValue]
				,[dblSalesPrice]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[intTransactionId]
				,[intTransactionDetailId]
				,[strTransactionId]
				,[intTransactionTypeId]
				,[intLotId]
				,[intSubLocationId]
				,[intStorageLocationId]
				,[ysnIsStorage]
				,[strActualCostId]
				,[intSourceTransactionId]
				,[strSourceTransactionId]
				,[intInTransitSourceLocationId]
				,[intForexRateTypeId]
				,[dblForexRate]
				,[intStorageScheduleTypeId]
				,[dblUnitRetail]
				,[intCategoryId]
				,[dblAdjustRetailValue]
			FROM 
				[fnARGetItemsForCosting](@PostInvoiceData, @post, 0)
			
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			GOTO Do_Rollback
		END CATCH

		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
		BEGIN
			BEGIN TRY
				-- Call the post routine 
				INSERT INTO @GLEntries (
					 [dtmDate]
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[strRateType]
				)
				EXEC	dbo.uspICPostCosting  
						@ItemsForPost  
						,@batchIdUsed  
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@UserEntityID
				--EXEC	dbo.uspARBatchPostCosting  
				--		@ItemsForPost  
				--		,@batchIdUsed  
				--		,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
				--		,@UserEntityID
				--		,DEFAULT  -- Default is NULL. Used to override the GL description. 
				--		,DEFAULT  -- Options are 'Aggregrate' and'Detailed'. Default is 'Detailed'. 


				DELETE FROM ICIT
				FROM
					tblICInventoryTransaction ICIT WITH (NOLOCK)
				INNER JOIN
					@ItemsForPost SIFP
						ON ICIT.[intTransactionId] = SIFP.[intTransactionId]
						AND ICIT.[strTransactionId] = SIFP.[strTransactionId] 
						AND ICIT.[ysnIsUnposted] <> 1
						AND @recap = 1
						AND @post = 1
					
			END TRY
			BEGIN CATCH
				SELECT @ErrorMerssage = ERROR_MESSAGE()										
				GOTO Do_Rollback
			END CATCH
		END

		BEGIN TRY
			-- Get the items to post  
			DECLARE @InTransitItems AS ItemInTransitCostingTableType 
					,@InTransitItemsForFinalInvoice AS ItemInTransitCostingTableType 
					,@FOB_ORIGIN AS INT = 1
					,@FOB_DESTINATION AS INT = 2			

			INSERT INTO @InTransitItems (
				 [intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,[dblQty] 
				,[dblUOMQty] 
				,[dblCost] 
				,[dblValue] 
				,[dblSalesPrice] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[intTransactionId] 
				,[intTransactionDetailId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intLotId] 
				,[intSourceTransactionId] 
				,[strSourceTransactionId] 
				,[intSourceTransactionDetailId] 
				,[intFobPointId] 
				,[intInTransitSourceLocationId]
				,[intForexRateTypeId]
				,[dblForexRate]
			)
			SELECT
				 [intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId] 
				,[dtmDate] 
				,[dblQty] 
				,[dblUOMQty] 
				,[dblCost] 
				,[dblValue] 
				,[dblSalesPrice] 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[intTransactionId] 
				,[intTransactionDetailId] 
				,[strTransactionId] 
				,[intTransactionTypeId] 
				,[intLotId] 
				,[intSourceTransactionId] 
				,[strSourceTransactionId] 
				,[intSourceTransactionDetailId] 
				,[intFobPointId] 
				,[intInTransitSourceLocationId]
				,[intForexRateTypeId]
				,[dblForexRate]
			FROM 
				dbo.[fnARGetItemsForInTransitCosting](@PostInvoiceData, @post)

			IF EXISTS (SELECT TOP 1 1 FROM @InTransitItems)
			BEGIN 
				-- Call the post routine 
				INSERT INTO @GLEntries (
					[dtmDate] 
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
				)
				EXEC	dbo.uspICPostInTransitCosting  
						@InTransitItems  
						,@batchIdUsed  
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@UserEntityID

				DELETE FROM ICIT
				FROM
					(SELECT [intTransactionId], [strTransactionId], [ysnIsUnposted] FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
				INNER JOIN
					@InTransitItems SIFP
						ON ICIT.[intTransactionId] = SIFP.[intTransactionId]
						AND ICIT.[strTransactionId] = SIFP.[strTransactionId]
						AND ICIT.[ysnIsUnposted] <> 1
						AND @recap  = 1
						AND @post = 1

			END

			IF @HasImpactForProvisional = 1
			BEGIN
				INSERT INTO @InTransitItemsForFinalInvoice (
					 [intItemId] 
					,[intItemLocationId] 
					,[intItemUOMId] 
					,[dtmDate] 
					,[dblQty] 
					,[dblUOMQty] 
					,[dblCost] 
					,[dblValue] 
					,[dblSalesPrice] 
					,[intCurrencyId] 
					,[dblExchangeRate] 
					,[intTransactionId] 
					,[intTransactionDetailId] 
					,[strTransactionId] 
					,[intTransactionTypeId] 
					,[intLotId] 
					,[intSourceTransactionId] 
					,[strSourceTransactionId] 
					,[intSourceTransactionDetailId] 
					,[intFobPointId] 
					,[intInTransitSourceLocationId]
					,[intForexRateTypeId]
					,[dblForexRate]
				)
				SELECT
					 [intItemId] 
					,[intItemLocationId] 
					,[intItemUOMId] 
					,[dtmDate] 
					,[dblQty] 
					,[dblUOMQty] 
					,[dblCost] 
					,[dblValue] 
					,[dblSalesPrice] 
					,[intCurrencyId] 
					,[dblExchangeRate] 
					,[intTransactionId] 
					,[intTransactionDetailId] 
					,[strTransactionId] 
					,[intTransactionTypeId] 
					,[intLotId] 
					,[intSourceTransactionId] 
					,[strSourceTransactionId] 
					,[intSourceTransactionDetailId] 
					,[intFobPointId] 
					,[intInTransitSourceLocationId]
					,[intForexRateTypeId]
					,[dblForexRate]
				FROM 
					dbo.[fnARGetItemsForInTransitCostingForFinalInvoice](@PostInvoiceData, @post)

				IF EXISTS (SELECT TOP 1 1 FROM @InTransitItemsForFinalInvoice)
				BEGIN 
					DELETE FROM @TempGLEntries
					INSERT INTO @TempGLEntries (
						[dtmDate] 
						,[strBatchId]
						,[intAccountId]
						,[dblDebit]
						,[dblCredit]
						,[dblDebitUnit]
						,[dblCreditUnit]
						,[strDescription]
						,[strCode]
						,[strReference]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[dtmDateEntered]
						,[dtmTransactionDate]
						,[strJournalLineDescription]
						,[intJournalLineNo]
						,[ysnIsUnposted]
						,[intUserId]
						,[intEntityId]
						,[strTransactionId]
						,[intTransactionId]
						,[strTransactionType]
						,[strTransactionForm]
						,[strModuleName]
						,[intConcurrencyId]
						,[dblDebitForeign]
						,[dblDebitReport]
						,[dblCreditForeign]
						,[dblCreditReport]
						,[dblReportingRate]
						,[dblForeignRate]
					)
					EXEC	dbo.uspICPostInTransitCosting  
							@InTransitItemsForFinalInvoice  
							,@batchIdUsed  
							,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
							,@UserEntityID

					DELETE FROM ICIT
					FROM
						(SELECT [intTransactionId], [strTransactionId], [ysnIsUnposted] FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
					INNER JOIN
						@InTransitItemsForFinalInvoice SIFP
							ON ICIT.[intTransactionId] = SIFP.[intTransactionId]
							AND ICIT.[strTransactionId] = SIFP.[strTransactionId]
							AND ICIT.[ysnIsUnposted] <> 1
							AND @recap  = 1
							AND @post = 1

					UPDATE
						@TempGLEntries
					SET
						[strDescription] = SUBSTRING('Final Invoice' + ISNULL((' - ' + [strDescription]),''), 1, 255)

					INSERT INTO @GLEntries
					SELECT * FROM @TempGLEntries					

				END
			END
		END TRY 
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			GOTO Do_Rollback
		END CATCH				

		--Update customer storage items
		BEGIN TRY
			-- Get the items to post  
			DECLARE @StorageItemsForPost AS ItemCostingTableType  			

			INSERT INTO @StorageItemsForPost (  
				 [intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty]
				,[dblCost]
				,[dblSalesPrice]
				,[intCurrencyId] 
				,[dblExchangeRate]
				,[intTransactionId] 
				,[intTransactionDetailId]
				,[strTransactionId]  
				,[intTransactionTypeId]  
				,[intLotId] 
				,[intSubLocationId]
				,[intStorageLocationId]
				,[strActualCostId]
			) 
			SELECT 
				 [intItemId] 
				,[intItemLocationId] 
				,[intItemUOMId]
				,[dtmDate]
				,[dblQty]
				,[dblUOMQty]
				,[dblCost]
				,[dblSalesPrice]
				,[intCurrencyId] 
				,[dblExchangeRate]
				,[intTransactionId] 
				,[intTransactionDetailId]
				,[strTransactionId]  
				,[intTransactionTypeId]  
				,[intLotId] 
				,[intSubLocationId]
				,[intStorageLocationId]
				,[strActualCostId]
			FROM 
				[fnARGetItemsForStoragePosting](@PostInvoiceData, @post)
		
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			GOTO Do_Rollback
		END CATCH

		-- Call the post routine 
		IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
		BEGIN 
			BEGIN TRY
				-- Call the post routine 
				INSERT INTO @GLEntries (
					[dtmDate] 
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
				)
				EXEC	dbo.uspICPostStorage  
						@StorageItemsForPost  
						,@batchIdUsed  		
						,@UserEntityID

				DELETE FROM ICIT
				FROM
					tblICInventoryTransaction ICIT WITH(NOLOCK)
				INNER JOIN
					@StorageItemsForPost SIFP
						ON ICIT.[intTransactionId] = SIFP.[intTransactionId]
						AND ICIT.[strTransactionId] = SIFP.[strTransactionId]
						AND ICIT.[ysnIsUnposted] <> 1
						AND @recap  = 1
						AND @post = 1
					
			END TRY
			BEGIN CATCH
				SELECT @ErrorMerssage = ERROR_MESSAGE()										
				GOTO Do_Rollback
			END CATCH
		END

		IF @recap = 0
		BEGIN
			BEGIN TRY
				DECLARE @FinalGLEntries AS RecapTableType
				DELETE FROM @FinalGLEntries
				INSERT INTO @FinalGLEntries
					([dtmDate]
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm]
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[strRateType]
					,[strDocument]
					,[strComments]
					,[strSourceDocumentId]
					,[intSourceLocationId]
					,[intSourceUOMId]
					,[dblSourceUnitDebit]
					,[dblSourceUnitCredit]
					,[intCommodityId]
					,[intSourceEntityId])
				SELECT
					 [dtmDate]						= GLEntries.[dtmDate]
					,[strBatchId]					= GLEntries.[strBatchId]
					,[intAccountId]					= GLEntries.[intAccountId]
					,[dblDebit]						= GLEntries.[dblDebit]
					,[dblCredit]					= GLEntries.[dblCredit]
					,[dblDebitUnit]					= DebitUnit.Value
					,[dblCreditUnit]				= CreditUnit.Value
					,[strDescription]				= GLEntries.[strDescription]
					,[strCode]						= GLEntries.[strCode]
					,[strReference]					= GLEntries.[strReference]
					,[intCurrencyId]				= GLEntries.[intCurrencyId]
					,[dblExchangeRate]				= GLEntries.[dblExchangeRate]
					,[dtmDateEntered]				= @PostDate
					,[dtmTransactionDate]			= GLEntries.[dtmTransactionDate]
					,[strJournalLineDescription]	= GLEntries.[strJournalLineDescription]
					,[intJournalLineNo]				= GLEntries.[intJournalLineNo]
					,[ysnIsUnposted]				= GLEntries.[ysnIsUnposted]
					,[intUserId]					= GLEntries.[intUserId]
					,[intEntityId]					= GLEntries.[intEntityId]
					,[strTransactionId]				= GLEntries.[strTransactionId]
					,[intTransactionId]				= GLEntries.[intTransactionId]
					,[strTransactionType]			= GLEntries.[strTransactionType]
					,[strTransactionForm]			= GLEntries.[strTransactionForm]
					,[strModuleName]				= GLEntries.[strModuleName]
					,[intConcurrencyId]				= GLEntries.[intConcurrencyId]
					,[dblDebitForeign]				= GLEntries.[dblDebitForeign]
					,[dblDebitReport]				= GLEntries.[dblDebitReport]
					,[dblCreditForeign]				= GLEntries.[dblCreditForeign]
					,[dblCreditReport]				= GLEntries.[dblCreditReport]
					,[dblReportingRate]				= GLEntries.[dblReportingRate]
					,[dblForeignRate]				= GLEntries.[dblForeignRate]
					,[strRateType]					= GLEntries.[strRateType]
					,[strDocument]					= GLEntries.[strDocument]
					,[strComments]					= GLEntries.[strComments]
					,[strSourceDocumentId]			= GLEntries.[strSourceDocumentId]
					,[intSourceLocationId]			= GLEntries.[intSourceLocationId]
					,[intSourceUOMId]				= GLEntries.[intSourceUOMId]
					,[dblSourceUnitDebit]			= GLEntries.[dblSourceUnitDebit]
					,[dblSourceUnitCredit]			= GLEntries.[dblSourceUnitCredit]
					,[intCommodityId]				= GLEntries.[intCommodityId]
					,[intSourceEntityId]			= GLEntries.[intSourceEntityId]
				FROM @GLEntries GLEntries
				CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) DebitUnit
				CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) CreditUnit
				ORDER BY
					GLEntries.[strTransactionId]

				IF EXISTS ( SELECT TOP 1 1 FROM @FinalGLEntries)

					DECLARE @InvalidGLEntries AS TABLE
					(strTransactionId	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
					,strText			NVARCHAR(150)  COLLATE Latin1_General_CI_AS NULL
					,intErrorCode		INT
					,strModuleName		NVARCHAR(100)  COLLATE Latin1_General_CI_AS NULL)

					INSERT INTO @InvalidGLEntries
						(strTransactionId
						,strText
						,intErrorCode
						,strModuleName)
					SELECT DISTINCT
						strTransactionId
						,strText
						,intErrorCode
						,strModuleName
					FROM
						[dbo].[fnGetGLEntriesErrors](@GLEntries)

					SET @invalidCount = @invalidCount + ISNULL((SELECT COUNT(strTransactionId) FROM @InvalidGLEntries), 0)

					INSERT INTO 
							tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
						SELECT DISTINCT
							 strError				= IGLE.strText
							,strTransactionType		= GLE.strTransactionType 
							,strTransactionId		= IGLE.strTransactionId
							,strBatchNumber			= GLE.strBatchId
							,intTransactionId		= GLE.intTransactionId 
						FROM
							@InvalidGLEntries IGLE
						LEFT OUTER JOIN
							@GLEntries GLE
								ON IGLE.strTransactionId = GLE.strTransactionId
					

					DELETE FROM @GLEntries
					WHERE
						strTransactionId IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)

					DELETE FROM @PostInvoiceData
					WHERE
						strInvoiceNumber IN (SELECT DISTINCT strTransactionId FROM @InvalidGLEntries)

					EXEC	dbo.uspGLBookEntries
								 @GLEntries		= @FinalGLEntries
								,@ysnPost		= @post
								,@XACT_ABORT_ON = @raiseError
			END TRY
			BEGIN CATCH
				SELECT @ErrorMerssage = ERROR_MESSAGE()										
				GOTO Do_Rollback
			END CATCH
		END		

	END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @post = 0   
	BEGIN
	
		BEGIN TRY
			INSERT INTO @GLEntries(
				 dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,dblDebitForeign
				,dblCreditForeign				
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
			)
			SELECT	
				 dtmDate						= GLD.dtmDate 
				,strBatchId						= @batchIdUsed
				,intAccountId					= GLD.intAccountId
				,dblDebit						= GLD.dblCredit
				,dblCredit						= GLD.dblDebit
				,dblDebitUnit					= GLD.dblCreditUnit
				,dblCreditUnit					= GLD.dblDebitUnit
				,dblDebitForeign				= GLD.dblCreditForeign
				,dblCreditForeign				= GLD.dblDebitForeign				
				,strDescription					= GLD.strDescription
				,strCode						= GLD.strCode
				,strReference					= GLD.strReference
				,intCurrencyId					= GLD.intCurrencyId
				,dblExchangeRate				= GLD.dblExchangeRate
				,dtmDateEntered					= @PostDate
				,dtmTransactionDate				= GLD.dtmTransactionDate
				,strJournalLineDescription		= REPLACE(GLD.strJournalLineDescription, @POSTDESC, 'Unposted ')
				,intJournalLineNo				= GLD.intJournalLineNo 
				,ysnIsUnposted					= 1
				,intUserId						= @userId
				,intEntityId					= @UserEntityID
				,strTransactionId				= GLD.strTransactionId
				,intTransactionId				= GLD.intTransactionId
				,strTransactionType				= GLD.strTransactionType
				,strTransactionForm				= GLD.strTransactionForm
				,strModuleName					= GLD.strModuleName
				,intConcurrencyId				= GLD.intConcurrencyId
			FROM
				(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData) PID
			INNER JOIN
				(SELECT dtmDate, intAccountId, intGLDetailId, intTransactionId, strTransactionId, strDescription, strCode, strReference, intCurrencyId, dblExchangeRate, dtmTransactionDate, 
					strJournalLineDescription, intJournalLineNo, strTransactionType, strTransactionForm, strModuleName, intConcurrencyId, dblCredit, dblDebit, dblCreditUnit, dblDebitUnit, ysnIsUnposted,
					dblCreditForeign, dblDebitForeign
				 FROM dbo.tblGLDetail WITH (NOLOCK)) GLD
					ON PID.intInvoiceId = GLD.intTransactionId
					AND PID.strInvoiceNumber = GLD.strTransactionId							 
			WHERE
				GLD.ysnIsUnposted = 0				
			ORDER BY
				GLD.intGLDetailId


			UPDATE GLD
			SET
				GLD.ysnIsUnposted = 1
			FROM
				tblGLDetail GLD
			INNER JOIN
				(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData) PID
					ON PID.intInvoiceId = GLD.intTransactionId
					AND PID.strInvoiceNumber = GLD.strTransactionId

			IF EXISTS ( SELECT TOP 1 1 FROM @GLEntries)	
				EXEC	dbo.uspGLBookEntries
						@GLEntries		= @GLEntries
						,@ysnPost		= @post
						,@XACT_ABORT_ON = @raiseError
						
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
			
		BEGIN TRY			
			DECLARE @UnPostICInvoiceData TABLE  (
				intInvoiceId int PRIMARY KEY,
				strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
				UNIQUE (intInvoiceId)
			);

			DECLARE @intTransactionId INT
					,@strTransactionId NVARCHAR(80);
			
			INSERT INTO @UnPostICInvoiceData(intInvoiceId, strTransactionId)
			SELECT DISTINCT
				 PID.intInvoiceId
				,PID.strInvoiceNumber
			FROM
				(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData) PID
			INNER JOIN
				(SELECT intInvoiceId, intItemId, intItemUOMId FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
					ON PID.intInvoiceId = ARID.intInvoiceId					
			INNER JOIN
				(SELECT intInvoiceId, intCompanyLocationId, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
					ON ARID.intInvoiceId = ARI.intInvoiceId	AND strTransactionType IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash')				 	
			INNER JOIN
				(SELECT intItemUOMId FROM dbo.tblICItemUOM WITH (NOLOCK) ) ItemUOM 
					ON ItemUOM.intItemUOMId = ARID.intItemUOMId
			LEFT OUTER JOIN
				(SELECT intItemId, intLocationId, strType FROM dbo.vyuICGetItemStock WITH (NOLOCK)) IST
					ON ARID.intItemId = IST.intItemId 
					AND ARI.intCompanyLocationId = IST.intLocationId 

			WHERE 
				(ARID.intItemId IS NOT NULL OR ARID.intItemId <> 0)
				AND ISNULL(IST.strType,'') NOT IN ('Non-Inventory','Service','Other Charge','Software')

			WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostICInvoiceData ORDER BY intInvoiceId)
			BEGIN
				
				DECLARE @intTransactionIdIC INT
						,@strTransactionIdIC NVARCHAR(80)
						,@WStorageCount INT
						,@WOStorageCount INT
					
				SELECT TOP 1 @intTransactionIdIC = intInvoiceId, @strTransactionIdIC = strTransactionId 
				FROM	@UnPostICInvoiceData ORDER BY intInvoiceId

				SELECT @WStorageCount = COUNT(1) FROM tblARInvoiceDetail WITH (NOLOCK) WHERE intInvoiceId = @intTransactionIdIC AND (ISNULL(intItemId, 0) <> 0) AND (ISNULL(intStorageScheduleTypeId,0) <> 0)	
				SELECT @WOStorageCount = COUNT(1) FROM tblARInvoiceDetail WITH (NOLOCK) WHERE intInvoiceId = @intTransactionIdIC AND (ISNULL(intItemId, 0) <> 0) AND (ISNULL(intStorageScheduleTypeId,0) = 0)
				IF @WOStorageCount > 0
				BEGIN
					-- Unpost onhand stocks. 
					EXEC	dbo.uspICUnpostCosting
								@intTransactionIdIC
								,@strTransactionIdIC
								,@batchIdUsed
								,@UserEntityID
								,@recap 
				END

				IF @WStorageCount > 0 
				BEGIN 
					-- Unpost storage stocks. 
					EXEC	dbo.uspICUnpostStorage
							@intTransactionId
							,@strTransactionId
							,@batchIdUsed
							,@UserEntityID
							,@recap
				END					
										
				DELETE FROM @UnPostICInvoiceData 
				WHERE	intInvoiceId = @intTransactionIdIC 
						AND strTransactionId = @strTransactionIdIC 												
			END								 
																
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH										
				
	END 
--------------------------------------------------------------------------------------------  
-- GL ENTRIES END
--------------------------------------------------------------------------------------------	
	
IF @recap = 1		
	BEGIN
		IF @raiseError = 0
			ROLLBACK TRAN @TransactionName		

		DELETE GLDR  
		FROM 
			(SELECT intInvoiceId, strInvoiceNumber FROM @PostInvoiceData) PID  
		INNER JOIN 
			(SELECT intTransactionId, strTransactionId, strCode FROM dbo.tblGLDetailRecap WITH (NOLOCK)) GLDR 
				ON (PID.strInvoiceNumber = GLDR.strTransactionId OR PID.intInvoiceId = GLDR.intTransactionId)  AND GLDR.strCode = @CODE		   
		   
		BEGIN TRY		
		 
			INSERT INTO tblGLPostRecap(
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strJournalLineDescription]
			,[strReference]	
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dblDebitForeign]
			,[dblCreditForeign]			
			,[intCurrencyId]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[dblExchangeRate]
			,[intUserId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strTransactionType]
			,[strAccountId]
			,[strAccountGroup]
			,[strRateType]
		)
		SELECT
			[strTransactionId]
			,A.[intTransactionId]
			,A.[intAccountId]
			--,A.[strDescription]
			, strDescription					= B.strDescription
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,Debit.Value
			,Credit.Value
			,DebitUnit.Value
			,CreditUnit.Value
			,[dblDebitForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.[dblDebitForeign] END
			,[dblCreditForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.[dblCreditForeign]	 END 		
			,A.[intCurrencyId]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,[dblExchangeRate]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE ISNULL(NULLIF(dblBaseInvoiceTotal, 0),1)/ISNULL(NULLIF(dblInvoiceTotal, 0),1) END
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,[strRateType]						= RATETYPE.strCurrencyExchangeRateType
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId			
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit
		OUTER APPLY (
			SELECT SMCERT.strCurrencyExchangeRateType,dblBaseInvoiceTotal,dblInvoiceTotal
			FROM dbo.tblARInvoice I
			OUTER APPLY (
				SELECT TOP 1 intCurrencyExchangeRateTypeId
				FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
				WHERE intInvoiceId = I.intInvoiceId
			) ID
			INNER JOIN (
				SELECT intCurrencyExchangeRateTypeId
					 , strCurrencyExchangeRateType
				FROM dbo.tblSMCurrencyExchangeRateType WITH (NOLOCK)
			) SMCERT ON SMCERT.intCurrencyExchangeRateTypeId = ISNULL(ID.intCurrencyExchangeRateTypeId, @DefaultCurrencyExchangeRateTypeId)
			WHERE I.strInvoiceNumber = A.strTransactionId 
			  AND I.intInvoiceId = A.intTransactionId
		) RATETYPE
				
		--EXEC uspGLPostRecap @GLEntries, @UserEntityID 

		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			IF @raiseError = 0
				BEGIN
					SET @CurrentTranCount = @@TRANCOUNT
					SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
					IF @CurrentTranCount = 0
						BEGIN TRANSACTION
					ELSE
						SAVE TRANSACTION @CurrentSavepoint

					EXEC dbo.uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param		
				IF @CurrentTranCount = 0
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION
						IF (XACT_STATE()) = 1
							COMMIT TRANSACTION
					END		
				ELSE
					BEGIN
						IF (XACT_STATE()) = -1
							ROLLBACK TRANSACTION  @CurrentSavepoint
						--IF (XACT_STATE()) = 1
						--	COMMIT TRANSACTION  @Savepoint
					END
				END			
			IF @raiseError = 1
				RAISERROR(@ErrorMerssage, 11, 1)
			GOTO Post_Exit
		END CATCH
	
	END 	

ELSE 
BEGIN
	DECLARE @tmpBatchId NVARCHAR(100)
	SELECT @tmpBatchId = [strBatchId] 
	FROM @GLEntries A
	INNER JOIN dbo.tblGLAccount B 
		ON A.intAccountId = B.intAccountId
	INNER JOIN dbo.tblGLAccountGroup C
		ON B.intAccountGroupId = C.intAccountGroupId
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit

	UPDATE tblGLPostRecap 
	SET 
		dblCreditForeign = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN 0.00 ELSE dblDebitForeign END
		, dblDebitForeign = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN 0.00 ELSE dblDebitForeign END
		, dblExchangeRate = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN 0.00 ELSE dblExchangeRate END
		, strRateType = CASE WHEN intCurrencyId = @DefaultCurrencyId THEN NULL ELSE strRateType END
	WHERE 			
		tblGLPostRecap.strBatchId = @tmpBatchId
END

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @recap = 0
	BEGIN			 
		BEGIN TRY 
			IF @post = 0
				BEGIN
					--Reverse Blend for Finished Goods
					BEGIN TRY
						WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
							BEGIN
								DECLARE @intInvoiceDetailIdToUnblend		INT
			
								SELECT TOP 1 @intInvoiceDetailIdToUnblend = intInvoiceDetailId FROM @FinishedGoodItems

								EXEC dbo.uspMFReverseAutoBlend
									@intSalesOrderDetailId	= NULL,
									@intInvoiceDetailId		= @intInvoiceDetailIdToUnblend,
									@intUserId				= @userId 

								UPDATE tblARInvoiceDetail SET ysnBlended = 0 WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend
								DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend
							END
					END TRY
					BEGIN CATCH
						SELECT @ErrorMerssage = ERROR_MESSAGE()
						GOTO Do_Rollback
					END CATCH

					UPDATE ARI
					SET
						 ARI.ysnPosted					= 0
						,ARI.ysnPaid					= 0
						,ARI.dblAmountDue				= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
															   THEN 
																	CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) > 0
																		 THEN ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal))
																		 ELSE (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal)
																	END
															   ELSE 
																	CASE WHEN (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) = ISNULL(ARI.dblPayment, @ZeroDecimal))
																			THEN ISNULL(ARI.dblPayment, @ZeroDecimal)
																			ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
																		END
														  END
						,ARI.dblBaseAmountDue			= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
															   THEN 
																	CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) > 0
																		 THEN ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal))
																		 ELSE (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal)
																	END
															   ELSE 
																	CASE WHEN (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) = ISNULL(ARI.dblBasePayment, @ZeroDecimal))
																			THEN ISNULL(ARI.dblBasePayment, @ZeroDecimal)
																			ELSE ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)
																		END
														  END												
						,ARI.dblDiscount				= @ZeroDecimal
						,ARI.dblBaseDiscount			= @ZeroDecimal
						,ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
						,ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
						,ARI.dblInterest				= @ZeroDecimal
						,ARI.dblBaseInterest			= @ZeroDecimal
						,ARI.dblPayment					= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(dblPayment, @ZeroDecimal) END
						,ARI.dblBasePayment				= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(dblBasePayment, @ZeroDecimal) END
						,ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
						,ARI.ysnExcludeFromPayment		= 0
						,ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData ) PID
					INNER JOIN
						(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblBaseAmountDue, dblDiscount, dblBaseDiscount, dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest, dblPayment, dblBasePayment, dtmPostDate, intConcurrencyId, strTransactionType, intSourceId, intOriginalInvoiceId, dblProvisionalAmount, dblBaseProvisionalAmount, dblInvoiceTotal, dblBaseInvoiceTotal, dtmDate, ysnExcludeFromPayment
						 FROM dbo.tblARInvoice WITH (NOLOCK)) ARI ON PID.intInvoiceId = ARI.intInvoiceId 					
					CROSS APPLY (SELECT COUNT(intPrepaidAndCreditId) PPC FROM tblARPrepaidAndCredit WHERE intInvoiceId = PID.intInvoiceId AND ysnApplied = 1) PPC
					--Insert Successfully unposted transactions.
					INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					SELECT 
						@PostSuccessfulMsg
						,PID.strTransactionType
						,PID.strInvoiceNumber
						,@batchIdUsed
						,PID.intInvoiceId
					FROM
						@PostInvoiceData PID					
												
					--Update tblHDTicketHoursWorked ysnBilled					
					UPDATE HDTHW						
					SET
						 HDTHW.ysnBilled = 0
						,HDTHW.dtmBilled = NULL
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData) PID
					INNER JOIN
						(SELECT intInvoiceId, dtmBilled, ysnBilled FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)) HDTHW ON PID.intInvoiceId = HDTHW.intInvoiceId														
					DELETE PD
					FROM tblARPaymentDetail PD
						INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 0
					WHERE PD.intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @PostInvoiceData)
						
					BEGIN TRY
						DECLARE @TankDeliveryForUnSync TABLE (
								intInvoiceId INT,
								UNIQUE (intInvoiceId));
								
						INSERT INTO @TankDeliveryForUnSync					
						SELECT DISTINCT
							ARI.intInvoiceId
						FROM
							(SELECT intInvoiceId FROM @PostInvoiceData ) PID
						INNER JOIN 															
							(SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
								ON PID.intInvoiceId = ARI.intInvoiceId
						INNER JOIN
							(SELECT intInvoiceId, intSiteId  FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
								ON ARI.intInvoiceId = ARID.intInvoiceId		
						INNER JOIN
							(SELECT intSiteID FROM dbo.tblTMSite WITH (NOLOCK)) TMS
								ON ARID.intSiteId = TMS.intSiteID 						
															
						WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForUnSync ORDER BY intInvoiceId)
							BEGIN
							
								DECLARE  @intInvoiceForUnSyncId INT
										,@ResultLogForUnSync NVARCHAR(MAX)
										
								
								SELECT TOP 1 @intInvoiceForUnSyncId = intInvoiceId FROM @TankDeliveryForUnSync ORDER BY intInvoiceId

								EXEC dbo.uspTMUnSyncInvoiceFromDeliveryHistory  @intInvoiceForUnSyncId, @ResultLogForUnSync OUT
												
								DELETE FROM @TankDeliveryForUnSync WHERE intInvoiceId = @intInvoiceForUnSyncId
																												
							END 							
								
						--UPDATE PREPAIDS/CREDIT MEMO FOR CASH REFUND
						DECLARE @CashRefunds AS TABLE (intInvoiceId INT)

						INSERT INTO @CashRefunds
						SELECT intInvoiceId FROM @PostInvoiceData I
						CROSS APPLY (										
							SELECT TOP 1 intPrepaymentId
							FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
							WHERE intInvoiceId = I.intInvoiceId 
								AND ysnApplied = 1
								AND ISNULL(dblAppliedInvoiceDetailAmount, 0) > 0
						) PREPAIDS
						WHERE strTransactionType = 'Cash Refund'

						WHILE EXISTS(SELECT TOP 1 1 FROM @CashRefunds)
							BEGIN
								DECLARE @intInvoiceIdCashRefund INT = NULL

								SELECT TOP 1 @intInvoiceIdCashRefund = intInvoiceId
								FROM @CashRefunds
							
								UPDATE I
								SET dblAmountDue		= dblAmountDue + ISNULL(dblAppliedInvoiceAmount, 0)
								  , dblBaseAmountDue	= dblBaseAmountDue + ISNULL(dblAppliedInvoiceAmount, 0)
								  , dblPayment			= dblPayment - ISNULL(dblAppliedInvoiceAmount, 0)
								  , dblBasePayment		= dblBasePayment - ISNULL(dblAppliedInvoiceAmount, 0)
								  , ysnPaid				= CASE WHEN dblInvoiceTotal = dblPayment - ISNULL(dblAppliedInvoiceAmount, 0) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
								  , ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment - ISNULL(dblAppliedInvoiceAmount, 0) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
								FROM tblARInvoice I
								INNER JOIN (										
									SELECT intPrepaymentId			= intPrepaymentId
										 , dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, 0)
									FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
									WHERE intInvoiceId = @intInvoiceIdCashRefund 
									  AND ysnApplied = 1
									  AND ISNULL(dblAppliedInvoiceDetailAmount, 0) > 0
								) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId
								
								DELETE FROM @CashRefunds WHERE intInvoiceId = @intInvoiceIdCashRefund
							END
																
					END TRY
					BEGIN CATCH
						SELECT @ErrorMerssage = ERROR_MESSAGE()										
						GOTO Do_Rollback
					END CATCH	

				END
			ELSE
				BEGIN

					UPDATE ARI						
					SET
						 ARI.ysnPosted					= 1
						,ARI.ysnPaid					= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.dblAmountDue = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') OR ARI.dblInvoiceTotal = ARI.dblPayment THEN 1 ELSE 0 END)
						,ARI.dblAmountDue				= (CASE WHEN ARI.strTransactionType IN ('Cash')
																THEN @ZeroDecimal
																ELSE (CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
																		   THEN 
																				CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) > 0
																					 THEN ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal))
																					 ELSE (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal)
																				END
																		   ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
																	  END) 
														   END)
						,ARI.dblBaseAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash')
																THEN @ZeroDecimal 
																ELSE (CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
																		   THEN 
																				CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) > 0
																					 THEN ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal))
																					 ELSE (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal)
																				END
																		   ELSE ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)
																	  END) 
														   END)
						,ARI.dblDiscount				= @ZeroDecimal
						,ARI.dblBaseDiscount			= @ZeroDecimal
						,ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
						,ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
						,ARI.dblInterest				= @ZeroDecimal
						,ARI.dblBaseInterest			= @ZeroDecimal
						,ARI.dblPayment					= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END)
						,ARI.dblBasePayment				= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblBasePayment, @ZeroDecimal) END)
						,ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
						,ARI.ysnExcludeFromPayment		= @ExcludeInvoiceFromPayment
						,ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1	
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData ) PID
					INNER JOIN
						(SELECT intInvoiceId, ysnPosted, ysnPaid, dblInvoiceTotal, dblBaseInvoiceTotal, dblAmountDue, dblBaseAmountDue, dblDiscount, dblBaseDiscount, dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest, dblPayment, dblBasePayment, dtmPostDate, intConcurrencyId, intSourceId, intOriginalInvoiceId, dblProvisionalAmount, dblBaseProvisionalAmount, strTransactionType, dtmDate, ysnExcludeFromPayment
						 FROM dbo.tblARInvoice WITH (NOLOCK))  ARI ON PID.intInvoiceId = ARI.intInvoiceId

					UPDATE ARPD
					SET
						 ARPD.dblInvoiceTotal		= ARI.dblInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
						,ARPD.dblBaseInvoiceTotal	= ARI.dblBaseInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
						,ARPD.dblAmountDue			= (ARI.dblInvoiceTotal + ISNULL(ARPD.dblInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblPayment, @ZeroDecimal) + ISNULL(ARPD.dblDiscount, @ZeroDecimal))
						,ARPD.dblBaseAmountDue		= (ARI.dblBaseInvoiceTotal + ISNULL(ARPD.dblBaseInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblBasePayment, @ZeroDecimal) + ISNULL(ARPD.dblBaseDiscount, @ZeroDecimal))
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData ) PID
					INNER JOIN
						(SELECT intInvoiceId, dblInvoiceTotal, dblBaseInvoiceTotal, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
							ON PID.intInvoiceId = ARI.intInvoiceId
					INNER JOIN
						(SELECT intInvoiceId, dblInterest, dblBaseInterest, dblDiscount, dblBaseDiscount, dblAmountDue, dblBaseAmountDue, dblInvoiceTotal, dblBaseInvoiceTotal, dblPayment, dblBasePayment FROM dbo.tblARPaymentDetail WITH (NOLOCK)) ARPD
							ON ARI.intInvoiceId = ARPD.intInvoiceId 

					--Insert Successfully posted transactions.
					INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					SELECT 
						@PostSuccessfulMsg
						,PID.strTransactionType
						,PID.strInvoiceNumber
						,@batchIdUsed
						,PID.intInvoiceId
					FROM
						@PostInvoiceData PID
					
					--Update tblHDTicketHoursWorked ysnBilled					
					UPDATE HDTHW						
					SET
						 HDTHW.ysnBilled = 1
						,HDTHW.dtmBilled = (case when HDTHW.dtmBilled is null then GETDATE() else HDTHW.dtmBilled end)
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData ) PID
					INNER JOIN
						(SELECT intInvoiceId, dtmBilled, ysnBilled FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)) HDTHW
							ON PID.intInvoiceId = HDTHW.intInvoiceId
						
					BEGIN TRY
						DECLARE @TankDeliveryForSync TABLE (
								intInvoiceId INT,
								UNIQUE (intInvoiceId));
								
						INSERT INTO @TankDeliveryForSync					
						SELECT DISTINCT
							I.intInvoiceId
						FROM
							(SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK)) I
						INNER JOIN
							(SELECT intInvoiceId, intSiteId FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) D
								ON I.intInvoiceId = D.intInvoiceId		
						INNER JOIN
							(SELECT intSiteID FROM dbo.tblTMSite WITH (NOLOCK)) TMS
								ON D.intSiteId = TMS.intSiteID 
						INNER JOIN 
							(SELECT intInvoiceId FROM @PostInvoiceData) B
								ON I.intInvoiceId = B.intInvoiceId
								
						WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForSync ORDER BY intInvoiceId)
							BEGIN
							
								DECLARE  @intInvoiceForSyncId INT
										,@ResultLogForSync NVARCHAR(MAX)
										
								
								SELECT TOP 1 @intInvoiceForSyncId = intInvoiceId FROM @TankDeliveryForSync ORDER BY intInvoiceId

								EXEC dbo.uspTMSyncInvoiceToDeliveryHistory @intInvoiceForSyncId, @userId, @ResultLogForSync OUT
												
								DELETE FROM @TankDeliveryForSync WHERE intInvoiceId = @intInvoiceForSyncId
																												
							END 							
						
						--CREATE PAYMENT FOR PREPAIDS/CREDIT MEMO TAB
						DECLARE @InvoicesWithPrepaids AS TABLE (intInvoiceId INT, strTransactionType NVARCHAR(100))
						
						INSERT INTO @InvoicesWithPrepaids
						SELECT intInvoiceId, strTransactionType 
						FROM @PostInvoiceData I
						CROSS APPLY (										
							SELECT TOP 1 intPrepaymentId
							FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
							WHERE intInvoiceId = I.intInvoiceId 
								AND ysnApplied = 1
								AND ISNULL(dblAppliedInvoiceDetailAmount, 0) > 0
						) PREPAIDS

						WHILE EXISTS(SELECT TOP 1 1 FROM @InvoicesWithPrepaids)
							BEGIN
								DECLARE @intInvoiceIdWithPrepaid INT = NULL
								      , @strTransactionTypePrepaid NVARCHAR(100) = NULL

								SELECT TOP 1 @intInvoiceIdWithPrepaid = intInvoiceId
									       , @strTransactionTypePrepaid = strTransactionType
								FROM @InvoicesWithPrepaids
							
								IF @strTransactionTypePrepaid <> 'Cash Refund'
									EXEC dbo.uspARCreateRCVForCreditMemo @intInvoiceId = @intInvoiceIdWithPrepaid, @intUserId = @userId
								ELSE
									BEGIN
										UPDATE I
										SET dblAmountDue		= dblAmountDue - ISNULL(dblAppliedInvoiceAmount, 0)
										  , dblBaseAmountDue	= dblBaseAmountDue - ISNULL(dblAppliedInvoiceAmount, 0)
										  , dblPayment			= dblPayment + ISNULL(dblAppliedInvoiceAmount, 0)
										  , dblBasePayment		= dblBasePayment + ISNULL(dblAppliedInvoiceAmount, 0)
										  , ysnPaid				= CASE WHEN dblInvoiceTotal = dblPayment + ISNULL(dblAppliedInvoiceAmount, 0) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
										  , ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment + ISNULL(dblAppliedInvoiceAmount, 0) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
										FROM tblARInvoice I
										INNER JOIN (										
											SELECT intPrepaymentId			= intPrepaymentId
												 , dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, 0)
											FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
											WHERE intInvoiceId = @intInvoiceIdWithPrepaid 
											  AND ysnApplied = 1
											  AND ISNULL(dblAppliedInvoiceDetailAmount, 0) > 0
										) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId
									END
								
								DELETE FROM @InvoicesWithPrepaids WHERE intInvoiceId = @intInvoiceIdWithPrepaid
							END
																
					END TRY
					BEGIN CATCH
						SELECT @ErrorMerssage = ERROR_MESSAGE()										
						GOTO Do_Rollback
					END CATCH
					
				END
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
			
		BEGIN TRY			
			DECLARE @InvoiceToUpdate TABLE (intInvoiceId INT);
			
			INSERT INTO @InvoiceToUpdate(intInvoiceId)
			SELECT DISTINCT intInvoiceId FROM @PostInvoiceData

			-- Log Transaction History
			DECLARE @InvoicesId AS InvoiceId
			INSERT INTO @InvoicesId(intHeaderId)
			SELECT DISTINCT intInvoiceId FROM @PostInvoiceData
						
			EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @InvoicesId,@post

			--UPDATE tblARCustomer.dblARBalance
			UPDATE CUSTOMER
			SET dblARBalance = dblARBalance + (CASE WHEN @post = 1 THEN ISNULL(dblTotalInvoice, 0) ELSE ISNULL(dblTotalInvoice, 0) * -1 END)
			FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
			INNER JOIN (SELECT intEntityCustomerId
							 , dblTotalInvoice = SUM(CASE WHEN strTransactionType IN ('Invoice', 'Debit Memo') THEN dblInvoiceTotal ELSE dblInvoiceTotal * -1 END)
						FROM dbo.tblARInvoice WITH (NOLOCK)
						WHERE intInvoiceId IN (SELECT intInvoiceId FROM @InvoiceToUpdate)
						GROUP BY intEntityCustomerId
			) INVOICE ON CUSTOMER.intEntityId = INVOICE.intEntityCustomerId

			--UPDATE tblARCustomer.dtmCreditLimitReached
			UPDATE CUSTOMER
			SET dtmCreditLimitReached =  CASE WHEN dtmCreditLimitReached IS NULL THEN CASE WHEN CUSTOMER.dblARBalance >= CUSTOMER.dblCreditLimit THEN INVOICE.dtmPostDate ELSE NULL END ELSE dtmCreditLimitReached END
			FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
			CROSS APPLY (
				SELECT TOP 1 I.dtmPostDate
				FROM dbo.tblARInvoice I
				INNER JOIN @InvoiceToUpdate U ON I.intInvoiceId = U.intInvoiceId
				WHERE I.intEntityCustomerId = CUSTOMER.intEntityId
				ORDER BY I.dtmPostDate DESC
			) INVOICE
			WHERE ISNULL(CUSTOMER.dblCreditLimit, 0) > 0

			--UPDATE BatchIds Used
			UPDATE tblARInvoice 
			SET strBatchId		= CASE WHEN @post = 1 THEN @batchIdUsed ELSE NULL END
			  , dtmBatchDate	= CASE WHEN @post = 1 THEN @PostDate ELSE NULL END
			  , intPostedById	= CASE WHEN @post = 1 THEN @UserEntityID ELSE NULL END
			WHERE intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @InvoiceToUpdate)
				
			WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceToUpdate ORDER BY intInvoiceId)
				BEGIN
				
					DECLARE @intInvoiceIntegractionId INT;
					
					SELECT TOP 1 @intInvoiceIntegractionId = intInvoiceId FROM @InvoiceToUpdate ORDER BY intInvoiceId

					EXEC dbo.uspARPostInvoiceIntegrations @post, @intInvoiceIntegractionId, @userId
								
					DELETE FROM @InvoiceToUpdate WHERE intInvoiceId = @intInvoiceIntegractionId AND intInvoiceId = @intInvoiceIntegractionId 												
				END

			DELETE A
			FROM tblARPrepaidAndCredit A
			INNER JOIN (
				SELECT intInvoiceId 
				FROM @PostInvoiceData
			) B ON A.intInvoiceId = B.intInvoiceId 
			WHERE ysnApplied = 0

																			
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH										
			
	END
	
SET @successfulCount = @totalRecords
SET @invalidCount = @totalInvalid	

IF ISNULL(@raiseError,0) = 0
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

	RETURN 1;

IF @post = 0
	BEGIN
		UPDATE ARI
		SET
			ARI.dblPayment	=(CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') 
									THEN @ZeroDecimal 
									ELSE
										ARI.dblPayment - ISNULL((SELECT SUM(tblARPrepaidAndCredit.dblAppliedInvoiceDetailAmount) FROM tblARPrepaidAndCredit WITH(NOLOCK) WHERE tblARPrepaidAndCredit.intInvoiceId = ARI.intInvoiceId AND tblARPrepaidAndCredit.ysnApplied = 1), @ZeroDecimal)
								END)
		FROM
			(SELECT intInvoiceId FROM @PostInvoiceData) PID
		INNER JOIN
			(SELECT intInvoiceId, dblPayment, dblInvoiceTotal, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
				ON PID.intInvoiceId = ARI.intInvoiceId 

		UPDATE ARI
		SET
			 ARI.ysnPosted				= 0
			,ARI.ysnPaid				= 0
			,ARI.dblAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN @ZeroDecimal ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal) END)
			,ARI.dblDiscount			= @ZeroDecimal
			,ARI.dblDiscountAvailable	= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
			,ARI.dblInterest			= @ZeroDecimal
			,ARI.dblPayment				= ISNULL(dblPayment, @ZeroDecimal)
			,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
			,ARI.ysnExcludeFromPayment	= 0
			,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1
		FROM
			(SELECT intInvoiceId FROM @PostInvoiceData) PID
		INNER JOIN
			(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblDiscount, dblDiscountAvailable, dblInterest, dblPayment, dtmPostDate, ysnExcludeFromPayment, intConcurrencyId,
				dblInvoiceTotal, strTransactionType, dtmDate
			 FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
				ON PID.intInvoiceId = ARI.intInvoiceId 		
	END
ELSE
	BEGIN
		UPDATE ARI
		SET
			ARI.dblPayment	= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') 
									THEN @ZeroDecimal 
									ELSE 
										ARI.dblPayment - ISNULL((SELECT SUM(tblARPrepaidAndCredit.dblAppliedInvoiceDetailAmount) FROM tblARPrepaidAndCredit WHERE tblARPrepaidAndCredit.intInvoiceId = ARI.intInvoiceId AND tblARPrepaidAndCredit.ysnApplied = 1), @ZeroDecimal)
								END)
		FROM
			(SELECT intInvoiceId FROM @PostInvoiceData) PID
		INNER JOIN
			(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblDiscount, dblDiscountAvailable, dblInterest, dblPayment, dtmPostDate,intConcurrencyId,
				dblInvoiceTotal, strTransactionType, dtmDate
			 FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
				ON PID.intInvoiceId = ARI.intInvoiceId 	

		UPDATE ARI						
		SET
			ARI.ysnPosted				= 1
			,ARI.ysnPaid				= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') OR ARI.dblInvoiceTotal = ARI.dblPayment THEN 1 ELSE 0 END)
			,ARI.dblInvoiceTotal		= ARI.dblInvoiceTotal
			,ARI.dblAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN @ZeroDecimal ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal) END)
			,ARI.dblDiscount			= @ZeroDecimal
			,ARI.dblDiscountAvailable	= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
			,ARI.dblInterest			= @ZeroDecimal			
			,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
			,ARI.ysnExcludeFromPayment	= @ExcludeInvoiceFromPayment
			,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1	
		FROM
			(SELECT intInvoiceId FROM @PostInvoiceData) PID
		INNER JOIN
			(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblDiscount, dblDiscountAvailable, dblInterest, dblPayment, dtmPostDate, ysnExcludeFromPayment, intConcurrencyId,
				dblInvoiceTotal, strTransactionType, dtmDate
			 FROM dbo.tblARInvoice WITH (NOLOCK)) ARI

				ON PID.intInvoiceId = ARI.intInvoiceId 	
	END




Do_Rollback:
	IF @raiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint

			EXEC uspARInsertPostResult @batchIdUsed, 'Invoice', @ErrorMerssage, @param								

			IF @CurrentTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1
						ROLLBACK TRANSACTION  @CurrentSavepoint
					--IF (XACT_STATE()) = 1
					--	COMMIT TRANSACTION  @Savepoint
				END	
		END
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)	
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;