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
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   

DECLARE @totalRecords INT = 0
DECLARE @totalInvalid INT = 0
 
DECLARE @PostInvoiceData AS [InvoicePostingTable]
DECLARE @PostProvisionalData AS [InvoicePostingTable]

DECLARE @InvalidInvoiceData AS TABLE(
	 [intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'

DECLARE @UserEntityID				INT
		,@DiscountAccountId			INT
		,@DeferredRevenueAccountId	INT
		,@AllowOtherUserToPost		BIT
		,@DefaultCurrencyId			INT
		,@HasImpactForProvisional   BIT
		,@InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

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

SELECT TOP 1 @DiscountAccountId = intDiscountAccountId 
		   , @DeferredRevenueAccountId = intDeferredRevenueAccountId
		   , @HasImpactForProvisional = ysnImpactForProvisional
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

IF(@batchId IS NULL)
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
				,[intOriginalInvoiceId]
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
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
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
				,[intOriginalInvoiceId]
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
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
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
				,[intOriginalInvoiceId]
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
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
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
				,[intOriginalInvoiceId]
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
				,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
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

--Get Provisional Invoices
IF ISNULL(@HasImpactForProvisional, 0) = 1
	BEGIN
		INSERT INTO @PostProvisionalData(
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
			,[intOriginalInvoiceId]
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
			,[ysnAllowOtherUserToPost])
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
			,[intOriginalInvoiceId]			= ARI.[intOriginalInvoiceId]
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
		FROM dbo.tblARInvoice ARI WITH (NOLOCK) 
		WHERE strType = 'Provisional'
		  AND ysnPosted = 1
		  AND intInvoiceId IN (SELECT intOriginalInvoiceId FROM @PostInvoiceData WHERE ISNULL(intOriginalInvoiceId, 0) <> 0)
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

IF @post = 1 --delete this part once TM-2455 is done		-start
	BEGIN											
		BEGIN TRY
			DECLARE @TankDelivery TABLE (
					intInvoiceId INT,
					UNIQUE (intInvoiceId));
							
			INSERT INTO @TankDelivery					
			SELECT DISTINCT
				I.intInvoiceId
			FROM
				(SELECT intInvoiceId FROM tblARInvoice WITH (NOLOCK)) I
			INNER JOIN
				(SELECT intInvoiceId, intSiteId FROM tblARInvoiceDetail WITH (NOLOCK)) D
					ON I.intInvoiceId = D.intInvoiceId		
			INNER JOIN
				(SELECT intSiteID FROM tblTMSite WITH (NOLOCK)) TMS
					ON D.intSiteId = TMS.intSiteID 
			INNER JOIN 
				@PostInvoiceData B
					ON I.intInvoiceId = B.intInvoiceId
							
			WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDelivery ORDER BY intInvoiceId)
				BEGIN
						
					DECLARE  @intInvoiceId INT
							,@ResultLog NVARCHAR(MAX)
									
					SET @ResultLog = 'OK'
							
					SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @TankDelivery ORDER BY intInvoiceId

					EXEC dbo.uspTMValidateInvoiceForSync @intInvoiceId, @ResultLog OUT
											
					DELETE FROM @TankDelivery WHERE intInvoiceId = @intInvoiceId
							
					IF NOT(@ResultLog = 'OK' OR RTRIM(LTRIM(@ResultLog)) = '')
						BEGIN
							INSERT INTO @InvalidInvoiceData([strPostingError], [strTransactionType], [strInvoiceNumber], [strBatchId], [intInvoiceId])
							SELECT
								@ResultLog,
								A.strTransactionType,
								A.strInvoiceNumber,
								@batchId,
								A.intInvoiceId
							FROM 
								(SELECT intInvoiceId, strInvoiceNumber, strTransactionType FROM tblARInvoice WITH (NOLOCK)) A 
							INNER JOIN 
								@PostInvoiceData B
									ON A.intInvoiceId = B.intInvoiceId
							WHERE
								A.intInvoiceId = @intInvoiceId									
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
								
					EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param
					
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
	END --delete this part once TM-2455 is done		-end
		
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
						FROM 
							dbo.tblARInvoice ARI WITH (NOLOCK)
						WHERE ARI.[ysnPosted] = 0 
							AND intInvoiceId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@invoicesToAdd))

						EXEC dbo.uspARReComputeInvoiceAmounts @intSplitInvoiceId

						DECLARE @AddedInvoices AS [dbo].[Id]
						INSERT INTO @AddedInvoices([intId])
						SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@invoicesToAdd)
						DECLARE @AddedInvoiceId INT

						WHILE EXISTS(SELECT NULL FROM @AddedInvoices)
							BEGIN
								SELECT @AddedInvoiceId = [intId] FROM @AddedInvoices

								EXEC dbo.uspARReComputeInvoiceAmounts @AddedInvoiceId

								DELETE FROM @AddedInvoices WHERE [intId] = @AddedInvoiceId
							END
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
									
			EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param

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

--BEGIN TRY
--	--IF @recap = 0
--		BEGIN
--			DECLARE @GrainItems TABLE(
--									 intEntityCustomerId		INT
--									,intInvoiceId				INT	
--									,intInvoiceDetailId			INT
--									,intItemId					INT
--									,dblQuantity				NUMERIC(18,6)
--									,intItemUOMId				INT
--									,intLocationId				INT
--									,intStorageScheduleTypeId	INT
--									,intCustomerStorageId		INT)

--			INSERT INTO @GrainItems
--			SELECT
--				 I.intEntityCustomerId 
--				,I.intInvoiceId 
--				,ID.intInvoiceDetailId
--				,ID.intItemId
--				,dbo.fnCalculateStockUnitQty(ID.dblQtyShipped, ICIU.dblUnitQty)
--				,ID.intItemUOMId
--				,I.intCompanyLocationId
--				,ID.intStorageScheduleTypeId
--				,ID.intCustomerStorageId 
--			FROM 
--				(SELECT intInvoiceId, intEntityCustomerId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) I
--			INNER JOIN 
--				(SELECT intInvoiceId, intInvoiceDetailId, intItemId, dblQtyShipped, intItemUOMId, intStorageScheduleTypeId, intCustomerStorageId FROM tblARInvoiceDetail WITH (NOLOCK)) ID ON I.intInvoiceId = ID.intInvoiceId
--			INNER JOIN
--				(SELECT intItemId, intItemUOMId, dblUnitQty FROM tblICItemUOM WITH (NOLOCK)) ICIU  ON ID.intItemId = ICIU.intItemId AND ID.intItemUOMId = ICIU.intItemUOMId				 		
--			WHERE I.intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
--				AND ID.intStorageScheduleTypeId IS NOT NULL
--				AND ID.dblQtyShipped <> @ZeroDecimal

	

--			WHILE EXISTS (SELECT NULL FROM @GrainItems)
--				BEGIN
				
--					DECLARE
--						 @EntityCustomerId		INT
--						,@InvoiceId				INT 
--						,@InvoiceDetailId		INT
--						,@ItemId				INT
--						,@Quantity				NUMERIC(18,6)
--						,@ItemUOMId				INT
--						,@LocationId			INT
--						,@StorageScheduleTypeId	INT
--						,@CustomerStorageId		INT
			
--					SELECT TOP 1 
--						  @InvoiceDetailId			= GI.intInvoiceDetailId
--						, @InvoiceId				= GI.intInvoiceId
--						, @EntityCustomerId			= GI.intEntityCustomerId 
--						, @ItemId					= GI.intItemId
--						, @Quantity					= GI.dblQuantity				
--						, @ItemUOMId				= GI.intItemUOMId
--						, @LocationId				= GI.intLocationId
--						, @StorageScheduleTypeId	= GI.intStorageScheduleTypeId
--						, @CustomerStorageId		= GI.intCustomerStorageId 
--					FROM @GrainItems GI

				  
--					BEGIN TRY
--					IF @post = 1
--						BEGIN
							
--							DECLARE @GrainStorageCharge TABLE  (
--								intCustomerStorageId INT,
--								strStorageTicketNumber NVARCHAR(100),
--								dblOpeningBalance NUMERIC(18,6),
--								intUnitMeasureId INT,
--								strUnitMeasure NVARCHAR(100),
--								strItemType NVARCHAR(100),
--								intItemId INT,
--								strItem NVARCHAR(100),
--								dblCharge NUMERIC(18,6)
--							);
						 
--							INSERT INTO @GrainStorageCharge
--							(
--								intCustomerStorageId, 
--								strStorageTicketNumber,
--								dblOpeningBalance,
--								intUnitMeasureId,
--								strUnitMeasure, 
--								strItemType,
--								intItemId,
--								strItem,
--								dblCharge 
--							)
--							EXEC uspGRUpdateGrainOpenBalanceByFIFO 
--								@strOptionType		= 'Update'
--								,@strSourceType		= 'Invoice'
--								,@intEntityId		= @EntityCustomerId
--								,@intItemId			= @ItemId
--								,@intStorageTypeId	= @StorageScheduleTypeId
--								,@dblUnitsConsumed	= @Quantity
--								,@IntSourceKey		= @InvoiceId
--								,@intUserId			= @UserEntityID								
						
--							DECLARE @intStorageItemId INT
--									, @strStorageItemDescription NVARCHAR(100)
--									, @intStorageUOM INT
--									, @intItemUOM INT
--									, @strItemDescription NVARCHAR(100)
--									, @dblStorageCharge NUMERIC (18,6)
--									, @intCustomerStorageId INT
							
--							SELECT TOP 1 
--								@intStorageItemId = intItemId
--								, @strStorageItemDescription = strItem
--								, @intStorageUOM = intUnitMeasureId
--								, @dblStorageCharge = dblCharge
--								, @intCustomerStorageId = intCustomerStorageId
--							FROM
--								@GrainStorageCharge	
--							WHERE 
--								strItemType = 'Storage Charge'

--							SELECT 
--								@strItemDescription = strDescription 
--							FROM 
--								tblICItem
--							WHERE 
--								intItemId = @intStorageItemId

--							SELECT 
--								@intItemUOM = intItemUOMId 
--							FROM 
--								tblICItemUOM
--							WHERE 
--								intUnitMeasureId = @intStorageUOM 			

--							DECLARE  @NewId INT
--									,@NewDetailId INT
--									,@AddDetailError NVARCHAR(MAX)
					 
--							EXEC [dbo].[uspARAddItemToInvoice]
--									 @InvoiceId						= @InvoiceId	
--									,@ItemId						= @intStorageItemId
--									,@ItemPrepayTypeId				= NULL
--									,@ItemPrepayRate				= NULL
--									,@ItemIsInventory				= NULL
--									,@NewInvoiceDetailId			= @NewDetailId		OUTPUT 
--									,@ErrorMessage					= @AddDetailError	OUTPUT
--									,@RaiseError					= @raiseError
--									,@ItemDocumentNumber			= NULL
--									,@ItemDescription				= @strItemDescription
--									,@OrderUOMId					= NULL
--									,@ItemQtyOrdered				= NULL
--									,@ItemUOMId						= @intItemUOM
--									,@ItemQtyShipped				= 1
--									,@ItemDiscount					= NULL
--									,@ItemTermDiscount				= NULL
--									,@ItemTermDiscountBy			= NULL
--									,@ItemPrice						= @dblStorageCharge
--									,@RefreshPrice					= 0
--									,@ItemMaintenanceType			= NULL
--									,@ItemFrequency					= NULL
--									,@ItemMaintenanceDate			= NULL
--									,@ItemMaintenanceAmount			= NULL
--									,@ItemLicenseAmount				= NULL
--									,@ItemTaxGroupId				= NULL
--									,@ItemStorageLocationId			= NULL 
--									,@ItemCompanyLocationSubLocationId	= NULL 
--									,@RecomputeTax					= NULL
--									,@ItemSCInvoiceId				= NULL
--									,@ItemSCInvoiceNumber			= NULL
--									,@ItemInventoryShipmentItemId	= NULL
--									,@ItemInventoryShipmentChargeId	= NULL
--									,@ItemShipmentNumber			= NULL
--									,@ItemRecipeItemId				= NULL
--									,@ItemRecipeId					= NULL
--									,@ItemSublocationId				= NULL
--									,@ItemCostTypeId				= NULL
--									,@ItemMarginById				= NULL
--									,@ItemCommentTypeId				= NULL
--									,@ItemMargin					= NULL
--									,@ItemRecipeQty					= NULL		
--									,@ItemSalesOrderDetailId		= NULL
--									,@ItemSalesOrderNumber			= NULL
--									,@ItemContractHeaderId			= NULL
--									,@ItemContractDetailId			= NULL
--									,@ItemShipmentId				= NULL
--									,@ItemShipmentPurchaseSalesContractId	= NULL
--									,@ItemWeightUOMId				= NULL
--									,@ItemWeight					= NULL
--									,@ItemShipmentGrossWt			= NULL
--									,@ItemShipmentTareWt			= NULL
--									,@ItemShipmentNetWt				= NULL
--									,@ItemTicketId					= NULL
--									,@ItemTicketHoursWorkedId		= NULL
--									,@ItemCustomerStorageId			= @intCustomerStorageId
--									,@ItemSiteDetailId				= NULL
--									,@ItemLoadDetailId				= NULL
--									,@ItemLotId						= NULL
--									,@ItemOriginalInvoiceDetailId	= NULL
--									,@ItemSiteId					= NULL
--									,@ItemBillingBy					= NULL
--									,@ItemPercentFull				= NULL
--									,@ItemNewMeterReading			= NULL
--									,@ItemPreviousMeterReading		= NULL
--									,@ItemConversionFactor			= NULL
--									,@ItemPerformerId				= NULL
--									,@ItemLeaseBilling				= NULL
--									,@ItemVirtualMeterReading		= NULL
--									,@ItemConversionAccountId		= NULL
--									,@ItemSalesAccountId			= NULL
--									,@ItemSubCurrencyId				= NULL
--									,@ItemSubCurrencyRate			= NULL
--									,@ItemStorageScheduleTypeId		= @StorageScheduleTypeId
--									,@ItemDestinationGradeId		= NULL
--									,@ItemDestinationWeightId		= NULL	
									
									
--							UPDATE tblARInvoiceDetail 
--							SET 
--								intCustomerStorageId = @intCustomerStorageId 
--							WHERE 
--								intInvoiceDetailId IN (@NewDetailId)
																																			
--							END
--					ELSE
--						BEGIN
--							EXEC dbo.uspGRReverseTicketOpenBalance 
--									@strSourceType	= 'Invoice',
--									@IntSourceKey	= @InvoiceId,
--									@intUserId		= @UserEntityID

--							DELETE FROM tblARInvoiceDetail 
--							WHERE 
--								intInvoiceId = @InvoiceId AND intCustomerStorageId IS NOT NULL

--							UPDATE tblARInvoiceDetail 
--							SET 
--								intCustomerStorageId = NULL 
--							WHERE 
--								intInvoiceDetailId = @InvoiceDetailId	
								
--							EXEC [dbo].[uspARReComputeInvoiceAmounts] @InvoiceId									
												
--						END						
--					END TRY
--					BEGIN CATCH
--						SELECT @ErrorMerssage = ERROR_MESSAGE()
--						IF @raiseError = 0
--							BEGIN
--								IF (XACT_STATE()) = -1
--									ROLLBACK TRANSACTION							
--								BEGIN TRANSACTION						
--								EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param
--								COMMIT TRANSACTION
--							END						
--						IF @raiseError = 1
--							RAISERROR(@ErrorMerssage, 11, 1)
		
--						GOTO Post_Exit
--					END CATCH					

--					DELETE FROM @GrainItems WHERE intInvoiceDetailId = @InvoiceDetailId
--				END	
--		END	
--END TRY
--BEGIN CATCH
--	SELECT @ErrorMerssage = ERROR_MESSAGE()
--	IF @raiseError = 0
--		BEGIN
--			IF (XACT_STATE()) = -1
--				ROLLBACK TRANSACTION							
--			BEGIN TRANSACTION						
--			EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param
--			COMMIT TRANSACTION
--		END						
--	IF @raiseError = 1
--		RAISERROR(@ErrorMerssage, 11, 1)
		
--	GOTO Post_Exit
--END CATCH

--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
-- Create a unique transaction name for recap. 
DECLARE @TransactionName AS VARCHAR(500) = 'Invoice Transaction' + CAST(NEWID() AS NVARCHAR(100));
if @recap = 1 AND @raiseError = 0
	SAVE TRAN @TransactionName

--Process Finished Good Items
BEGIN TRY
	--IF @recap = 0
		--BEGIN
			DECLARE @FinishedGoodItems TABLE(intInvoiceDetailId		INT
										   , intItemId				INT
										   , dblQuantity			NUMERIC(18,6)
										   , intItemUOMId			INT
										   , intLocationId			INT
										   , intSublocationId		INT
										   , intStorageLocationId	INT
										   , dtmPostDate			DATETIME)

		
			INSERT INTO @FinishedGoodItems
			SELECT ID.intInvoiceDetailId
				 , ID.intItemId
				 , ID.dblQtyShipped
				 , ID.intItemUOMId
				 , I.intCompanyLocationId
				 , ICL.intSubLocationId
				 , ID.intStorageLocationId
				 ,I.dtmPostDate
			FROM tblARInvoice I
				INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
				INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
				INNER JOIN tblICItemLocation ICL ON ID.intItemId = ICL.intItemId AND I.intCompanyLocationId = ICL.intLocationId
			WHERE I.intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
			AND ID.ysnBlended <> @post
			AND ICI.ysnAutoBlend = 1
			AND ISNULL(ICI.strType,'') = 'Finished Good'

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
						  , @dtmPostDate			DATETIME
			
					SELECT TOP 1 
						  @intInvoiceDetailId	= intInvoiceDetailId
						, @intItemId			= intItemId
						, @dblQuantity			= dblQuantity				
						, @intItemUOMId			= intItemUOMId
						, @intLocationId		= intLocationId
						, @intSublocationId		= intSublocationId
						, @intStorageLocationId	= intStorageLocationId
						, @dtmPostDate			= dtmPostDate 
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
								@dtmDate				= @dtmPostDate

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
										@dtmDate				= @dtmPostDate
								END
						END
					--ELSE
					--	BEGIN
					--		EXEC dbo.uspMFReverseAutoBlend
					--			@intSalesOrderDetailId	= NULL,
					--			@intInvoiceDetailId		= @intInvoiceDetailId,
					--			@intUserId				= @userId 
					--	END						
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
									
								EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param

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

					IF @post = 1
						UPDATE tblARInvoiceDetail SET ysnBlended = 1 WHERE intInvoiceDetailId = @intInvoiceDetailId

					DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailId
				END	
		--END	
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
															
			EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param

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
						,@BatchId					= @batchId
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
			IF ISNULL(@HasImpactForProvisional, 0) = 1
				BEGIN
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
					SELECT dtmDate						= CAST(ISNULL(P.dtmPostDate, P.dtmDate) AS DATE)
						 , strBatchID					= @batchId
						 , intAccountId					= GL.intAccountId
						 , dblDebit						= GL.dblCredit
						 , dblCredit					= GL.dblDebit
						 , dblDebitUnit					= GL.dblCreditUnit
						 , dblCreditUnit				= GL.dblDebitUnit
						 , strDescription				= 'Provisional Invoice - ' + ISNULL(GL.strDescription, '')
						 , strCode						= @CODE
						 , strReference					= GL.strReference
						 , intCurrencyId				= GL.intCurrencyId 
						 , dblExchangeRate				= GL.dblExchangeRate
						 , dtmDateEntered				= @PostDate
						 , dtmTransactionDate			= P.dtmDate
						 , strJournalLineDescription	= 'Provisional Invoice - ' + PROV.strInvoiceNumber
						 , intJournalLineNo				= PROV.intInvoiceId
						 , ysnIsUnposted				= 0
						 , intUserId					= @userId
						 , intEntityId					= @UserEntityID	
						 , strTransactionId				= P.strInvoiceNumber
						 , intTransactionId				= P.intInvoiceId
						 , strTransactionType			= PROV.strTransactionType
						 , strTransactionForm			= @SCREEN_NAME
						 , strModuleName				= @MODULE_NAME
						 , intConcurrencyId				= 1
						 , [dblDebitForeign]			= GL.dblCreditForeign
						 , [dblDebitReport]				= GL.dblCreditReport
						 , [dblCreditForeign]			= GL.dblDebitForeign
						 , [dblCreditReport]			= GL.dblDebitReport
						 , [dblReportingRate]			= GL.dblReportingRate
						 , [dblForeignRate]				= GL.dblForeignRate
						 , [strRateType]				= NULL
					FROM (
						SELECT intOriginalInvoiceId
							 , intInvoiceId
							 , dtmPostDate
							 , dtmDate
							 , strInvoiceNumber
						FROM @PostInvoiceData
						WHERE ISNULL(intOriginalInvoiceId, 0) <> 0
					) P
					INNER JOIN (						
						SELECT intInvoiceId
							 , strInvoiceNumber
							 , strTransactionType
						FROM @PostProvisionalData
					) PROV ON P.intOriginalInvoiceId = PROV.intInvoiceId
					INNER JOIN (
						SELECT intAccountId
							 , intGLDetailId
							 , intTransactionId
							 , strTransactionId
							 , dblCredit
							 , dblDebit
							 , dblCreditUnit
							 , dblDebitUnit
							 , strReference
							 , strDescription
							 , intCurrencyId
							 , dblExchangeRate
							 , dblCreditForeign
							 , dblCreditReport
							 , dblDebitForeign
							 , dblDebitReport
							 , dblReportingRate
							 , dblForeignRate
						FROM tblGLDetail WITH (NOLOCK)
						WHERE ysnIsUnposted = 0
					) GL ON PROV.intInvoiceId = GL.intTransactionId
						AND PROV.strInvoiceNumber = GL.strTransactionId
					ORDER BY GL.intGLDetailId
				END
						
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
				,strBatchID					= @batchId
				,intAccountId				= A.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseInvoiceTotal - ISNULL(CM.[dblBaseAppliedCMAmount], @ZeroDecimal) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblBaseInvoiceTotal - ISNULL(CM.[dblBaseAppliedCMAmount], @ZeroDecimal) END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
																								(
																									SELECT
																										SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal)))
																									FROM
																										(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
																										 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
																									INNER JOIN
																										(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
																											ON ARID.intInvoiceId = ARI.intInvoiceId	
																									LEFT OUTER JOIN
																										(SELECT intItemId FROM tblICItem WITH (NOLOCK)) I
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
																									SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, @ZeroDecimal)))
																								FROM
																									(SELECT intInvoiceId, intItemId, intItemUOMId, dblQtyShipped 
																									 FROM tblARInvoiceDetail WITH (NOLOCK)) ARID 
																								INNER JOIN
																									(SELECT intInvoiceId, intCompanyLocationId FROM tblARInvoice WITH (NOLOCK)) ARI
																										ON ARID.intInvoiceId = ARI.intInvoiceId	
																								LEFT OUTER JOIN
																									(SELECT intItemId FROM tblICItem WITH (NOLOCK)) I
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
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 0
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
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
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) ELSE 0 END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblInvoiceTotal - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) ELSE 0 END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblInvoiceTotal - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblInvoiceTotal - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''
			FROM
				(SELECT intInvoiceId, strInvoiceNumber, intEntityCustomerId, strTransactionType, intCurrencyId, dtmDate, dtmPostDate, strComments, dblInvoiceTotal, intAccountId, intPeriodsToAccrue, dblBaseInvoiceTotal
				 FROM tblARInvoice WITH (NOLOCK)) A
			LEFT JOIN 
				(SELECT [intEntityId], [strCustomerNumber] FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId FROM @PostInvoiceData )	P ON A.intInvoiceId = P.intInvoiceId	
			LEFT OUTER JOIN
				(
				--Credit Memo Prepaids
				SELECT
					 [dblAppliedCMAmount]		= SUM(ISNULL(ARPAC.[dblAppliedInvoiceDetailAmount],@ZeroDecimal))
					,[dblBaseAppliedCMAmount]	= SUM(ISNULL(ARPAC.[dblBaseAppliedInvoiceDetailAmount],@ZeroDecimal))
					,[intInvoiceId]				= A.[intInvoiceId] 
				FROM
					(SELECT [intInvoiceId], [intPrepaymentId], [dblAppliedInvoiceDetailAmount], [dblBaseAppliedInvoiceDetailAmount] FROM tblARPrepaidAndCredit WITH (NOLOCK)
					 WHERE ISNULL([ysnApplied],0) = 1 AND [dblAppliedInvoiceDetailAmount] <> @ZeroDecimal) ARPAC
				INNER JOIN
					(SELECT [intInvoiceId] FROM tblARInvoice WITH (NOLOCK)) A
						ON ARPAC.[intInvoiceId] = A.[intInvoiceId] 						
				INNER JOIN
					(SELECT [intInvoiceId], strTransactionType FROM tblARInvoice WITH (NOLOCK) WHERE strTransactionType IN ('Credit Memo', 'Credit Note')) ARI1
						ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId]	
				GROUP BY
					A.[intInvoiceId]
				) CM
					ON A.[intInvoiceId] = CM.[intInvoiceId]
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (
						A.dblInvoiceTotal <> @ZeroDecimal
						OR
						EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN (SELECT intItemId, strType FROM tblICItem) ICI ON ARID.intItemId = ICI.intItemId AND ICI.strType <> 'Comment' WHERE ARID.intInvoiceId  = A.[intInvoiceId])
					)


			UNION ALL
			--DEBIT Prepaids
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= ARI1.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  ARPAC.[dblBaseAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
				,dblDebitUnit				= @ZeroDecimal 
				,dblCreditUnit				= @ZeroDecimal
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Applied Prepaid - ' + ARI1.[strInvoiceNumber] 
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
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''	 
			FROM
				(SELECT [intInvoiceId], [intPrepaidAndCreditId], [intPrepaymentId], [ysnApplied], [dblAppliedInvoiceDetailAmount], [dblBaseAppliedInvoiceDetailAmount]
				 FROM tblARPrepaidAndCredit WITH (NOLOCK)) ARPAC
			INNER JOIN
				(SELECT [intInvoiceId], strInvoiceNumber, dtmDate, dtmPostDate, strTransactionType, intCurrencyId, [intEntityCustomerId], strComments, intPeriodsToAccrue
				 FROM tblARInvoice WITH (NOLOCK)) A
					ON ARPAC.[intInvoiceId] = A.[intInvoiceId] AND ISNULL(ARPAC.[ysnApplied],0) = 1 AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
			INNER JOIN
				(SELECT [intInvoiceId], [strInvoiceNumber], intAccountId, strTransactionType FROM tblARInvoice WITH (NOLOCK) WHERE strTransactionType IN ('Credit Memo', 'Credit Note')) ARI1
					ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId]				 
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
				,strBatchID					= @batchId
				,intAccountId				= SMCL.intUndepositedFundsId 
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblBasePayment - ISNULL(CM.[dblBaseAppliedCMAmount], @ZeroDecimal) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblBasePayment - ISNULL(CM.[dblBaseAppliedCMAmount], @ZeroDecimal) END
				,dblDebitUnit				= @ZeroDecimal
				,dblCreditUnit				= @ZeroDecimal					
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 0
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
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
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblPayment - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) ELSE 0 END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblPayment - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) ELSE 0 END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblPayment - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblPayment - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal) END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''	  			
			FROM
				(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], intCompanyLocationId, dtmPostDate, dtmDate, strTransactionType, dblPayment, strComments, intCurrencyId, intPeriodsToAccrue, dblBasePayment
				 FROM tblARInvoice WITH (NOLOCK)) A
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
			INNER JOIN
				(SELECT intCompanyLocationId, intUndepositedFundsId FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
					ON A.intCompanyLocationId = SMCL.intCompanyLocationId
			LEFT OUTER JOIN
				(
				--Credit Memo Prepaids
				SELECT
					 [dblAppliedCMAmount]		= SUM(ISNULL(ARPAC.[dblAppliedInvoiceDetailAmount],@ZeroDecimal))
					,[dblBaseAppliedCMAmount]	= SUM(ISNULL(ARPAC.[dblBaseAppliedInvoiceDetailAmount],@ZeroDecimal))
					,[intInvoiceId]				= A.[intInvoiceId] 
				FROM
					(SELECT [intInvoiceId], [intPrepaymentId], [dblAppliedInvoiceDetailAmount], [dblBaseAppliedInvoiceDetailAmount], [ysnApplied] FROM tblARPrepaidAndCredit WITH (NOLOCK)) ARPAC
				INNER JOIN
					(SELECT [intInvoiceId] FROM tblARInvoice WITH (NOLOCK)) A ON ARPAC.[intInvoiceId] = A.[intInvoiceId] AND ISNULL(ARPAC.[ysnApplied],0) = 1 AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal						  
				INNER JOIN
					(SELECT [intInvoiceId], strTransactionType FROM tblARInvoice WITH (NOLOCK) WHERE strTransactionType IN ('Credit Memo', 'Credit Note')) ARI1 
						ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId]
				GROUP BY
					A.[intInvoiceId]
				) CM
					ON A.[intInvoiceId] = CM.[intInvoiceId] 
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (A.dblPayment - ISNULL(CM.[dblAppliedCMAmount], @ZeroDecimal)) <> @ZeroDecimal
			
			UNION ALL
			--Credit Prepaids
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= ARI1.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE ARPAC.[dblBaseAppliedInvoiceDetailAmount] END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  ARPAC.[dblBaseAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,dblDebitUnit				= @ZeroDecimal 
				,dblCreditForeign			= @ZeroDecimal
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Applied Prepaid - ' + ARI1.[strInvoiceNumber] 
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
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,[dblReportingRate]			= 0
				,[dblForeignRate]			= 0
				,[strRateType]				= ''
			FROM
				(SELECT [intInvoiceId], [intPrepaidAndCreditId], [intPrepaymentId], dblAppliedInvoiceDetailAmount, [ysnApplied], [dblBaseAppliedInvoiceDetailAmount]
				 FROM tblARPrepaidAndCredit WITH (NOLOCK)) ARPAC
			INNER JOIN
				(SELECT [intInvoiceId], strInvoiceNumber, dtmPostDate, dtmDate, [intEntityCustomerId], strTransactionType, intCurrencyId, strComments, intPeriodsToAccrue
				 FROM tblARInvoice WITH (NOLOCK) ) A ON ARPAC.[intInvoiceId] = A.[intInvoiceId] AND  ISNULL(ARPAC.[ysnApplied],0) = 1 AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal				 
			INNER JOIN
				(SELECT [intInvoiceId], [strInvoiceNumber], intAccountId FROM tblARInvoice WITH (NOLOCK)  WHERE strTransactionType NOT IN ('Credit Memo', 'Credit Note')) ARI1 
					ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId] 
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
					
			--CREDIT MISC
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= B.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN 0 ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0  END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN 0 ELSE ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')) THEN ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) ELSE 0 END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
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
				(SELECT intInvoiceId FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId 	
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
				--B.dblTotal <> @ZeroDecimal AND 
				((B.intItemId IS NULL OR B.intItemId = 0)
					OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))))
				AND (A.strTransactionType <> 'Debit Memo' OR (A.strTransactionType = 'Debit Memo' AND A.strType IN ('CF Tran', 'CF Invoice', 'Card Fueling Transaction')))
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND (B.dblTotal <> 0 OR B.dblQtyShipped <> 0)

			--CREDIT Software -- License
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
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
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) ELSE 0 END							
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
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
				(SELECT intInvoiceId FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId 
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
				AND A.strTransactionType <> 'Debit Memo'
				AND (ISNULL(A.intPeriodsToAccrue,0) <= 1 OR ( ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(@accrueLicense,0) = 0))

			--DEBIT Software -- License
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
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
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) ELSE 0 END				
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
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
				(SELECT intInvoiceId FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
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
				AND A.strTransactionType <> 'Debit Memo'
				AND (ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(@accrueLicense,0) = 0)

			--CREDIT Software -- Maintenance
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
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
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, @ZeroDecimal)) ELSE 0 END							
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
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
				(SELECT intInvoiceId FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId
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
				AND A.strTransactionType <> 'Debit Memo'
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT SALES
			UNION ALL 
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) ELSE 0 END							
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
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
				(SELECT intInvoiceId FROM @PostInvoiceData)	P
					ON A.intInvoiceId = P.intInvoiceId
			INNER JOIN
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
				(B.intItemId IS NOT NULL OR B.intItemId <> 0)
				AND ISNULL(I.strType,'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Comment')
				AND A.strTransactionType <> 'Debit Memo'
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
				,strBatchID					= @batchId
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) ELSE 0 END							
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
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
				(SELECT intInvoiceId FROM @PostInvoiceData)	P
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
				,strBatchID					= @batchId
				,intAccountId				= L.intFreightIncome
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblBaseShipping END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblBaseShipping ELSE 0  END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0							
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
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
				(SELECT intInvoiceId, strInvoiceNumber, [intEntityCustomerId], intCompanyLocationId, dtmPostDate, dtmDate, dblShipping, strTransactionType, strComments, intCurrencyId, dblBaseShipping
				 FROM tblARInvoice WITH (NOLOCK)) A 
			LEFT JOIN 
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.[intEntityId]	
			INNER JOIN
				(SELECT intCompanyLocationId, intFreightIncome FROM tblSMCompanyLocation WITH (NOLOCK)) L
					ON A.intCompanyLocationId = L.intCompanyLocationId	
			INNER JOIN 
				(SELECT intInvoiceId FROM @PostInvoiceData)	P
					ON A.intInvoiceId = P.intInvoiceId	
			WHERE
				A.dblShipping <> @ZeroDecimal		
				
		UNION ALL 
			--CREDIT Tax
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
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
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
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
				(SELECT intInvoiceId, dtmPostDate, dtmDate, intEntityCustomerId, strComments, strTransactionType, intCurrencyId, strInvoiceNumber, intPeriodsToAccrue, intCompanyLocationId
				 FROM tblARInvoice WITH (NOLOCK)) A 
					ON D.intInvoiceId = A.intInvoiceId
			INNER JOIN
				(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.intEntityCustomerId = C.[intEntityId]
			INNER JOIN
				tblSMCompanyLocation SMCL
					ON A.intCompanyLocationId = SMCL.intCompanyLocationId 
			INNER JOIN 
				(SELECT intInvoiceId FROM @PostInvoiceData )	P
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
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE [dbo].fnRoundBanker(((D.dblDiscount/100.00) * [dbo].fnRoundBanker((D.dblQtyShipped * D.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0								
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
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
				(SELECT intInvoiceId FROM @PostInvoiceData) P
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
			
			--UNION ALL 
			----DEBIT COGS - Inbound Shipment
			--SELECT			
			--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
			--	,strBatchID					= @batchId
			--	,intAccountId				= IST.intCOGSAccountId
			--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) ELSE 0 END
			--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) END
			--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] ELSE 0 END
			--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] END								
			--	,strDescription				= A.strComments
			--	,strCode					= @CODE
			--	,strReference				= C.strCustomerNumber
			--	,intCurrencyId				= A.intCurrencyId 
			--	,dblExchangeRate			= D.dblCurrencyExchangeRate
			--	,dtmDateEntered				= @PostDate
			--	,dtmTransactionDate			= A.dtmDate
			--	,strJournalLineDescription	= D.strItemDescription
			--	,intJournalLineNo			= D.intInvoiceDetailId
			--	,ysnIsUnposted				= 0
			--	,intUserId					= @userId
			--	,intEntityId				= @UserEntityID				
			--	,strTransactionId			= A.strInvoiceNumber
			--	,intTransactionId			= A.intInvoiceId
			--	,strTransactionType			= A.strTransactionType
			--	,strTransactionForm			= @SCREEN_NAME
			--	,strModuleName				= @MODULE_NAME
			--	,intConcurrencyId			= 1
			--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) ELSE 0 END
			--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) ELSE 0 END
			--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) END
			--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) END
			--	,[dblReportingRate]			= D.dblCurrencyExchangeRate
			--	,[dblForeignRate]			= D.dblCurrencyExchangeRate
			--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			--FROM
			--	(SELECT intInvoiceId, intInvoiceDetailId, intItemId, dblQtyShipped, intItemUOMId, strItemDescription, intLoadDetailId, dblTotal,
			--			intCurrencyExchangeRateTypeId, dblPrice, dblCurrencyExchangeRate, dblBasePrice
			--	 FROM tblARInvoiceDetail WITH (NOLOCK)) D
			--INNER JOIN			
			--	(SELECT intInvoiceId, dtmDate, dtmPostDate, intEntityCustomerId, intCurrencyId, strComments, strTransactionType, strInvoiceNumber, intCompanyLocationId, intPeriodsToAccrue
			--		FROM tblARInvoice WITH (NOLOCK)) A 
			--		ON D.intInvoiceId = A.intInvoiceId AND ISNULL(intPeriodsToAccrue,0) <= 1				 
			--INNER JOIN
			--	(SELECT intItemUOMId FROM tblICItemUOM) ItemUOM 
			--		ON ItemUOM.intItemUOMId = D.intItemUOMId
			--LEFT OUTER JOIN
			--	(SELECT intItemId, intLocationId, intCOGSAccountId, strType FROM vyuARGetItemAccount WITH (NOLOCK)) IST
			--		ON D.intItemId = IST.intItemId 
			--		AND A.intCompanyLocationId = IST.intLocationId 
			--INNER JOIN
			--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
			--		ON A.intEntityCustomerId = C.[intEntityId]					
			--INNER JOIN 
			--	(SELECT intInvoiceId FROM @PostInvoiceData)	P
			--		ON A.intInvoiceId = P.intInvoiceId				
			--INNER JOIN
			--	(SELECT intLoadId, intLoadDetailId FROM tblLGLoadDetail WITH (NOLOCK)) ISD
			--		ON 	D.intLoadDetailId = ISD.intLoadDetailId
			--INNER JOIN
			--	(SELECT intLoadId, strLoadNumber FROM tblLGLoad WITH (NOLOCK)) ISH
			--		ON ISD.intLoadId = ISH.intLoadId
			--INNER JOIN (SELECT [intItemId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [strTransactionId], [ysnIsUnposted] FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
			--		ON ICIT.[intTransactionId] = ISH.[intLoadId] 
			--		AND ICIT.[intTransactionDetailId] = ISD.[intLoadDetailId] 
			--		AND ICIT.[strTransactionId] = ISH.strLoadNumber 
			--		AND ICIT.[ysnIsUnposted] = 0	  
			--LEFT OUTER JOIN
			--	(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
			--		ON D.intItemId = ICIS.intItemId 
			--		AND A.intCompanyLocationId = ICIS.intLocationId
			--LEFT OUTER JOIN
			--	(
			--		SELECT
			--			intCurrencyExchangeRateTypeId 
			--			,strCurrencyExchangeRateType 
			--		FROM
			--			tblSMCurrencyExchangeRateType
			--	)	SMCERT
			--		ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId	
			--WHERE
			--	D.dblTotal <> @ZeroDecimal
			--	AND D.intLoadDetailId IS NOT NULL AND D.intLoadDetailId <> 0				
			--	AND D.intItemId IS NOT NULL AND D.intItemId <> 0
			--	AND ISNULL(IST.strType,'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
			--	AND A.strTransactionType <> 'Debit Memo'
				
			--UNION ALL 
			----CREDIT Inventory In-Transit - Inbound Shipment
			--SELECT			
			--	 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
			--	,strBatchID					= @batchId
			--	,intAccountId				= IST.intInventoryInTransitAccountId
			--	,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) END
			--	,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) ELSE 0 END
			--	,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] END
			--	,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] ELSE 0 END								
			--	,strDescription				= A.strComments
			--	,strCode					= @CODE
			--	,strReference				= C.strCustomerNumber
			--	,intCurrencyId				= A.intCurrencyId 
			--	,dblExchangeRate			= 1
			--	,dtmDateEntered				= @PostDate
			--	,dtmTransactionDate			= A.dtmDate
			--	,strJournalLineDescription	= D.strItemDescription
			--	,intJournalLineNo			= D.intInvoiceDetailId
			--	,ysnIsUnposted				= 0
			--	,intUserId					= @userId
			--	,intEntityId				= @UserEntityID				
			--	,strTransactionId			= A.strInvoiceNumber
			--	,intTransactionId			= A.intInvoiceId
			--	,strTransactionType			= A.strTransactionType
			--	,strTransactionForm			= @SCREEN_NAME
			--	,strModuleName				= @MODULE_NAME
			--	,intConcurrencyId			= 1
			--	,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) END
			--	,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) END
			--	,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) ELSE 0 END
			--	,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICIT.[dblQty]) * ICIT.[dblUOMQty] * ICIT.[dblCost]) ELSE 0 END
			--	,[dblReportingRate]			= D.dblCurrencyExchangeRate
			--	,[dblForeignRate]			= D.dblCurrencyExchangeRate
			--	,[strRateType]				= SMCERT.strCurrencyExchangeRateType 
			--FROM
			--	(SELECT intInvoiceId, intInvoiceDetailId, intItemId, strItemDescription, dblQtyShipped,  intItemUOMId, intLoadDetailId, dblTotal,
			--			intCurrencyExchangeRateTypeId, dblPrice, dblCurrencyExchangeRate
			--	 FROM tblARInvoiceDetail WITH (NOLOCK)) D
			--INNER JOIN			
			--	(SELECT intInvoiceId, strInvoiceNumber, strTransactionType, strComments, intCurrencyId, dtmDate, dtmPostDate, intCompanyLocationId, intEntityCustomerId, intPeriodsToAccrue
			--	 FROM tblARInvoice WITH (NOLOCK)) A 
			--		ON D.intInvoiceId = A.intInvoiceId AND ISNULL(intPeriodsToAccrue,0) <= 1			  
			--INNER JOIN
			--	(SELECT intItemUOMId FROM tblICItemUOM) ItemUOM 
			--		ON ItemUOM.intItemUOMId = D.intItemUOMId
			--LEFT OUTER JOIN
			--	(SELECT intItemId, intLocationId, intInventoryInTransitAccountId, strType FROM vyuARGetItemAccount WITH (NOLOCK)) IST
			--		ON D.intItemId = IST.intItemId 
			--		AND A.intCompanyLocationId = IST.intLocationId 
			--INNER JOIN
			--	(SELECT [intEntityId], strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
			--		ON A.intEntityCustomerId = C.[intEntityId]					
			--INNER JOIN 
			--	(SELECT intInvoiceId FROM @PostInvoiceData)	P
			--		ON A.intInvoiceId = P.intInvoiceId				
			--INNER JOIN
			--	(SELECT intLoadId, intLoadDetailId FROM tblLGLoadDetail WITH (NOLOCK)) ISD
			--		ON 	D.intLoadDetailId = ISD.intLoadDetailId
			--INNER JOIN
			--	(SELECT intLoadId, strLoadNumber FROM tblLGLoad WITH (NOLOCK)) ISH
			--		ON ISD.intLoadId = ISH.intLoadId
			--INNER JOIN (SELECT [intItemId], [intTransactionId], [dblQty], [intTransactionDetailId], [dblUOMQty], [dblCost], [strTransactionId], [ysnIsUnposted] FROM tblICInventoryTransaction WITH (NOLOCK)) ICIT
			--		ON ICIT.[intTransactionId] = ISH.[intLoadId] 
			--		AND ICIT.[intTransactionDetailId] = ISD.[intLoadDetailId] 
			--		AND ICIT.[strTransactionId] = ISH.strLoadNumber 
			--		AND ICIT.[ysnIsUnposted] = 0		
			--LEFT OUTER JOIN
			--	(SELECT intItemId, intLocationId, intStockUOMId FROM vyuICGetItemStock WITH (NOLOCK)) ICIS
			--		ON D.intItemId = ICIS.intItemId 
			--		AND A.intCompanyLocationId = ICIS.intLocationId
			--LEFT OUTER JOIN
			--	(
			--		SELECT
			--			intCurrencyExchangeRateTypeId 
			--			,strCurrencyExchangeRateType 
			--		FROM
			--			tblSMCurrencyExchangeRateType
			--	)	SMCERT
			--		ON D.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
			--WHERE
			--	D.dblTotal <> @ZeroDecimal
			--	AND D.intLoadDetailId IS NOT NULL AND D.intLoadDetailId <> 0				
			--	AND D.intItemId IS NOT NULL AND D.intItemId <> 0
			--	AND ISNULL(IST.strType,'') NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
			--	AND A.strTransactionType <> 'Debit Memo'
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
				,[intForexRateTypeId]
				,[dblForexRate]
			FROM 
				[fnARGetItemsForCosting](@PostInvoiceData, @post)
			
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
						,@batchId  
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@UserEntityID

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
				[fnARGetItemsForInTransitCosting](@PostInvoiceData, @post)

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
						,@batchId  
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
						,@batchId  		
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
				UPDATE @GLEntries SET [dtmDateEntered] = @PostDate 
				EXEC dbo.uspGLBookEntries @GLEntries, @post
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
				 GLD.dtmDate 
				,@batchId
				,GLD.intAccountId
				,dblDebit						= GLD.dblCredit
				,dblCredit						= GLD.dblDebit
				,dblDebitUnit					= GLD.dblCreditUnit
				,dblCreditUnit					= GLD.dblDebitUnit
				,dblDebitForeign				= GLD.dblCreditForeign
				,dblCreditForeign				= GLD.dblDebitForeign				
				,GLD.strDescription
				,GLD.strCode
				,GLD.strReference
				,GLD.intCurrencyId
				,GLD.dblExchangeRate
				,dtmDateEntered					= GETDATE()
				,GLD.dtmTransactionDate
				,GLD.strJournalLineDescription
				,GLD.intJournalLineNo 
				,ysnIsUnposted					= 1
				,intUserId						= @userId
				,intEntityId					= @UserEntityID
				,GLD.strTransactionId
				,GLD.intTransactionId
				,GLD.strTransactionType
				,GLD.strTransactionForm
				,GLD.strModuleName
				,GLD.intConcurrencyId
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
						
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
		
		BEGIN TRY			
			DECLARE @UnPostInvoiceData TABLE  (
				intInvoiceId int PRIMARY KEY,
				strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
				UNIQUE (intInvoiceId)
			);
			
			INSERT INTO @UnPostInvoiceData(intInvoiceId, strTransactionId)
			SELECT DISTINCT
				 PID.intInvoiceId
				,PID.strInvoiceNumber
			FROM
				@PostInvoiceData PID				
			INNER JOIN
				(SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) ) ARI
					ON PID.intInvoiceId = ARI.intInvoiceId

			IF ISNULL(@HasImpactForProvisional, 0) = 1
				BEGIN
					INSERT INTO @UnPostInvoiceData(intInvoiceId, strTransactionId)
					SELECT DISTINCT
						 PID.intInvoiceId
						,PID.strInvoiceNumber
					FROM
						@PostProvisionalData PID				
					INNER JOIN
						(SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) ) ARI
							ON PID.intInvoiceId = ARI.intInvoiceId
				END

			WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostInvoiceData ORDER BY intInvoiceId)
				BEGIN
				
					DECLARE @intTransactionId INT
							,@strTransactionId NVARCHAR(80);
					
					SELECT TOP 1 @intTransactionId = intInvoiceId, @strTransactionId = strTransactionId FROM @UnPostInvoiceData ORDER BY intInvoiceId					

					EXEC	dbo.uspGLInsertReverseGLEntry
								@strTransactionId	= @strTransactionId
								,@intEntityId		= @UserEntityID
								,@dtmDateReverse	= NULL
										
					DELETE FROM @UnPostInvoiceData WHERE intInvoiceId = @intTransactionId AND strTransactionId = @strTransactionId 
												
				END							 
																
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
					ON ARID.intInvoiceId = ARI.intInvoiceId	AND strTransactionType IN ('Invoice', 'Credit Memo', 'Credit Note', 'Cash', 'Cash Refund')				 	
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
								,@batchId
								,@UserEntityID
								,@recap 
				END

				IF @WStorageCount > 0 
				BEGIN 
					-- Unpost storage stocks. 
					EXEC	dbo.uspICUnpostStorage
							@intTransactionId
							,@strTransactionId
							,@batchId
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
			,[dblExchangeRate]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN 0.00 ELSE A.[dblExchangeRate] END
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,[strRateType]						= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN NULL ELSE A.[strRateType] END
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit
				
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

					EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param		
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

					UPDATE ARI
					SET
						ARI.dblPayment	= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash', 'Cash Refund' ) 
												THEN @ZeroDecimal 
												ELSE 
													ARI.dblPayment - ISNULL((SELECT SUM(tblARPrepaidAndCredit.dblAppliedInvoiceDetailAmount) FROM tblARPrepaidAndCredit WITH (NOLOCK) WHERE tblARPrepaidAndCredit.intInvoiceId = ARI.intInvoiceId AND tblARPrepaidAndCredit.ysnApplied = 1), @ZeroDecimal)
											END)
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData) PID
					INNER JOIN
						(SELECT intInvoiceId, strTransactionType, dblPayment, dblInvoiceTotal FROM dbo.tblARInvoice WITH (NOLOCK)) ARI ON PID.intInvoiceId = ARI.intInvoiceId 


					UPDATE ARI
					SET
						 ARI.ysnPosted				= 0
						,ARI.ysnPaid				= 0
						,ARI.dblAmountDue			= ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
						,ARI.dblDiscount			= @ZeroDecimal
						,ARI.dblDiscountAvailable	= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
						,ARI.dblInterest			= @ZeroDecimal
						,ARI.dblPayment				= ISNULL(dblPayment, @ZeroDecimal)
						,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
						,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData ) PID
					INNER JOIN
						(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblDiscount, dblDiscountAvailable, dblInterest, dblPayment, dtmPostDate, intConcurrencyId,
							dblInvoiceTotal, dtmDate 
						 FROM dbo.tblARInvoice WITH (NOLOCK)) ARI ON PID.intInvoiceId = ARI.intInvoiceId 					

					--Insert Successfully unposted transactions.
					INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					SELECT 
						@PostSuccessfulMsg
						,PID.strTransactionType
						,PID.strInvoiceNumber
						,@batchId
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
						 ARI.ysnPosted				= 1
						,ARI.ysnPaid				= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash', 'Cash Refund' ) OR ARI.dblInvoiceTotal = ARI.dblPayment THEN 1 ELSE 0 END)
						,ARI.dblInvoiceTotal		= ARI.dblInvoiceTotal
						,ARI.dblAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN @ZeroDecimal ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal) END)
						,ARI.dblDiscount			= @ZeroDecimal
						,ARI.dblDiscountAvailable	= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
						,ARI.dblInterest			= @ZeroDecimal
						,ARI.dblPayment				= (CASE WHEN ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END)
						,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
						,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1	
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData ) PID
					INNER JOIN
						(SELECT intInvoiceId, ysnPosted, ysnPaid, dblInvoiceTotal, dblAmountDue, dblDiscount, dblDiscountAvailable, dblInterest, dblPayment, dtmPostDate, intConcurrencyId, 
						 strTransactionType, dtmDate 
						 FROM dbo.tblARInvoice WITH (NOLOCK))  ARI ON PID.intInvoiceId = ARI.intInvoiceId

					UPDATE ARPD
					SET
						ARPD.dblInvoiceTotal = ARI.dblInvoiceTotal 
						,ARPD.dblAmountDue = (ARI.dblInvoiceTotal + ISNULL(ARPD.dblInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblPayment, @ZeroDecimal) + ISNULL(ARPD.dblDiscount, @ZeroDecimal))
					FROM
						(SELECT intInvoiceId FROM @PostInvoiceData ) PID
					INNER JOIN
						(SELECT intInvoiceId, dblInvoiceTotal FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
							ON PID.intInvoiceId = ARI.intInvoiceId
					INNER JOIN
						(SELECT intInvoiceId, dblInterest, dblDiscount, dblAmountDue, dblInvoiceTotal, dblPayment FROM dbo.tblARPaymentDetail WITH (NOLOCK)) ARPD
							ON ARI.intInvoiceId = ARPD.intInvoiceId 

					--Insert Successfully posted transactions.
					INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					SELECT 
						@PostSuccessfulMsg
						,PID.strTransactionType
						,PID.strInvoiceNumber
						,@batchId
						,PID.intInvoiceId
					FROM
						@PostInvoiceData PID
					
					--Update tblHDTicketHoursWorked ysnBilled					
					UPDATE HDTHW						
					SET
						 HDTHW.ysnBilled = 1
						,HDTHW.dtmBilled = GETDATE()
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
			ARI.dblPayment	= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash', 'Cash Refund' ) 
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
			,ARI.dblAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN @ZeroDecimal ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal) END)
			,ARI.dblDiscount			= @ZeroDecimal
			,ARI.dblDiscountAvailable	= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
			,ARI.dblInterest			= @ZeroDecimal
			,ARI.dblPayment				= ISNULL(dblPayment, @ZeroDecimal)
			,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
			,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1
		FROM
			(SELECT intInvoiceId FROM @PostInvoiceData) PID
		INNER JOIN
			(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblDiscount, dblDiscountAvailable, dblInterest, dblPayment, dtmPostDate,intConcurrencyId,
				dblInvoiceTotal, strTransactionType, dtmDate
			 FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
				ON PID.intInvoiceId = ARI.intInvoiceId 		
	END
ELSE
	BEGIN
		UPDATE ARI
		SET
			ARI.dblPayment	= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash', 'Cash Refund' ) 
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
			,ARI.ysnPaid				= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash', 'Cash Refund' ) OR ARI.dblInvoiceTotal = ARI.dblPayment THEN 1 ELSE 0 END)
			,ARI.dblInvoiceTotal		= ARI.dblInvoiceTotal
			,ARI.dblAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN @ZeroDecimal ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal) END)
			,ARI.dblDiscount			= @ZeroDecimal
			,ARI.dblDiscountAvailable	= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
			,ARI.dblInterest			= @ZeroDecimal			
			,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
			,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1	
		FROM
			(SELECT intInvoiceId FROM @PostInvoiceData) PID
		INNER JOIN
			(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblDiscount, dblDiscountAvailable, dblInterest, dblPayment, dtmPostDate,intConcurrencyId,
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

			EXEC uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param								

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