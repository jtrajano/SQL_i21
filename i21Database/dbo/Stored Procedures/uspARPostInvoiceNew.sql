CREATE PROCEDURE [dbo].[uspARPostInvoiceNew] 
     @BatchId			AS NVARCHAR(40)		= NULL
	,@Post				AS BIT				= 0
	,@Recap				AS BIT				= 0
	,@UserId			AS INT				= NULL
	,@InvoiceIds		AS InvoiceId		READONLY
	,@IntegrationLogId	AS INT
	,@BeginDate			AS DATE				= NULL
	,@EndDate			AS DATE				= NULL
	,@BeginTransaction	AS NVARCHAR(50)		= NULL
	,@EndTransaction	AS NVARCHAR(50)		= NULL
	,@Exclude			AS NVARCHAR(MAX)	= NULL
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@Success			AS BIT				= 0 OUTPUT
	,@TransType			AS NVARCHAR(25)		= 'all'
	,@RaiseError		AS BIT				= 0
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF 

IF @RaiseError = 1
	SET XACT_ABORT ON
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'InvoiceRecap' + CAST(NEWID() AS NVARCHAR(100));

DECLARE  @totalRecords		INT = 0
		,@totalInvalid		INT = 0
		,@InitTranCount		INT
		,@CurrentTranCount	INT
		,@Savepoint			NVARCHAR(32)
		,@CurrentSavepoint	NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

DECLARE @UserEntityID				INT
		,@DiscountAccountId			INT
		,@DeferredRevenueAccountId	INT
		,@AllowOtherUserToPost		BIT

SET @UserEntityID = ISNULL((SELECT [intEntityId] FROM dbo.tblSMUserSecurity WITH (NOLOCK) WHERE [intEntityId] = @UserId),@UserId)
SET @DiscountAccountId = (SELECT TOP 1 [intDiscountAccountId] FROM dbo.tblARCompanyPreference WITH (NOLOCK) WHERE ISNULL([intDiscountAccountId],0) <> 0)
SET @DeferredRevenueAccountId = (SELECT TOP 1 [intDeferredRevenueAccountId] FROM dbo.tblARCompanyPreference  WITH (NOLOCK)WHERE ISNULL([intDeferredRevenueAccountId],0) <> 0)
SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WITH (NOLOCK) WHERE intEntityUserSecurityId = @UserEntityID)

DECLARE @ErrorMerssage NVARCHAR(MAX)
DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000	
DECLARE @PostInvoiceData AS [InvoicePostingTable]

IF @RaiseError = 0
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

IF(@BatchId IS NULL)
	EXEC dbo.uspSMGetStartingNumber 3, @BatchId OUT

SET @BatchIdUsed = @BatchId

DECLARE @InvalidInvoiceData AS TABLE(
	 [intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)

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
	,[ysnAccrueLicense]				= II.[ysnAccrueLicense]
	,[intSplitId]					= ARI.[intSplitId]
	,[dblSplitPercent]				= ARI.[dblSplitPercent]			
	,[ysnSplitted]					= ARI.[ysnSplitted]
	,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
	,[intEntityId]					= ARI.[intEntityId]
	,[ysnPost]						= @Post
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
	,[strBatchId]					= @BatchIdUsed
	,[strPostingMessage]			= ''
	,[intUserId]					= @UserEntityID
	,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost		
FROM
	tblARInvoice ARI WITH (NOLOCK) 
INNER JOIN @InvoiceIds II 
	ON ARI.[intInvoiceId] = II.[intHeaderId] 

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '



SET @Success = 1

DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Cost of Goods'
DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5
SELECT @INVENTORY_SHIPMENT_TYPE = [intTransactionTypeId] FROM dbo.tblICInventoryTransactionType WITH (NOLOCK) WHERE [strName] = @SCREEN_NAME

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33
SELECT	@INVENTORY_INVOICE_TYPE = intTransactionTypeId 
FROM	tblICInventoryTransactionType WITH (NOLOCK)
WHERE	strName = @SCREEN_NAME

-- Ensure @Post and @Recap is not NULL  
SET @Post = ISNULL(@Post, 0)
SET @Recap = ISNULL(@Recap, 0)
 
-- Get Transaction to Post
IF (@TransType IS NULL OR RTRIM(LTRIM(@TransType)) = '')
	SET @TransType = 'all'

IF @IntegrationLogId IS NOT NULL AND NOT EXISTS(SELECT TOP 1 NULL FROM @InvoiceIds)
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
			,[ysnAccrueLicense]				= ARIILD.[ysnAccrueLicense]
			,[intSplitId]					= ARI.[intSplitId]
			,[dblSplitPercent]				= ARI.[dblSplitPercent]			
			,[ysnSplitted]					= ARI.[ysnSplitted]
			,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
			,[intEntityId]					= ARI.[intEntityId]
			,[ysnPost]						= @Post
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
			,[strBatchId]					= @BatchIdUsed
			,[strPostingMessage]			= ''
			,[intUserId]					= @UserEntityID
			,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost		
        FROM
            dbo.tblARInvoice ARI WITH (NOLOCK) 
        INNER JOIN
            tblARInvoiceIntegrationLogDetail ARIILD
                ON ARI.[intInvoiceId] = ARIILD.[intInvoiceId]
                AND ARIILD.[ysnPost] IS NOT NULL 
                AND ARIILD.[ysnPost] = @Post
                AND ARIILD.[ysnHeader] = 1
                AND ARIILD.[intIntegrationLogId] = @IntegrationLogId
        WHERE
            NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
            AND (ARI.[strTransactionType] = @TransType OR ISNULL(@TransType,'all') = 'all')
	END


IF @IntegrationLogId IS NOT NULL AND EXISTS(SELECT TOP 1 NULL FROM @InvoiceIds)
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
			,[ysnAccrueLicense]				= ARIILD.[ysnAccrueLicense]
			,[intSplitId]					= ARI.[intSplitId]
			,[dblSplitPercent]				= ARI.[dblSplitPercent]			
			,[ysnSplitted]					= ARI.[ysnSplitted]
			,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
			,[intEntityId]					= ARI.[intEntityId]
			,[ysnPost]						= @Post
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
			,[strBatchId]					= @BatchIdUsed
			,[strPostingMessage]			= ''
			,[intUserId]					= @UserEntityID
			,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost		
        FROM
            dbo.tblARInvoice ARI WITH (NOLOCK) 
        INNER JOIN
            tblARInvoiceIntegrationLogDetail ARIILD
                ON ARI.[intInvoiceId] = ARIILD.[intInvoiceId]
                AND ARIILD.[ysnPost] IS NOT NULL 
                AND ARIILD.[ysnPost] = @Post
                AND ARIILD.[ysnHeader] = 1
                AND ARIILD.[intIntegrationLogId] = @IntegrationLogId
		INNER JOIN
			@InvoiceIds II
				ON ARIILD.[intInvoiceId] = II.[intHeaderId]
        WHERE
            NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
            AND (ARI.[strTransactionType] = @TransType OR ISNULL(@TransType,'all') = 'all')
	END


IF(@BeginDate IS NOT NULL)
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
			,[ysnAccrueLicense]				= 0
			,[intSplitId]					= ARI.[intSplitId]
			,[dblSplitPercent]				= ARI.[dblSplitPercent]			
			,[ysnSplitted]					= ARI.[ysnSplitted]
			,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
			,[intEntityId]					= ARI.[intEntityId]
			,[ysnPost]						= @Post
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
			,[strBatchId]					= @BatchIdUsed
			,[strPostingMessage]			= ''
			,[intUserId]					= @UserEntityID
			,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost		
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		WHERE DATEADD(dd, DATEDIFF(dd, 0, ARI.[dtmDate]), 0) BETWEEN @BeginDate AND @EndDate
		AND (ARI.[strTransactionType] = @TransType OR @TransType = 'all')
	END

IF(@BeginTransaction IS NOT NULL)
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
			,[ysnAccrueLicense]				= 0
			,[intSplitId]					= ARI.[intSplitId]
			,[dblSplitPercent]				= ARI.[dblSplitPercent]			
			,[ysnSplitted]					= ARI.[ysnSplitted]
			,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
			,[intEntityId]					= ARI.[intEntityId]
			,[ysnPost]						= @Post
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
			,[strBatchId]					= @BatchIdUsed
			,[strPostingMessage]			= ''
			,[intUserId]					= @UserEntityID
			,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost		
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		WHERE intInvoiceId BETWEEN @BeginTransaction AND @EndTransaction
		AND (strTransactionType = @TransType OR @TransType = 'all')
	END

--Removed excluded Invoices to post/unpost
IF(@Exclude IS NOT NULL)
	BEGIN
		DECLARE @InvoicesExclude TABLE  (
			intInvoiceId INT
		);

		INSERT INTO @InvoicesExclude
		SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@Exclude)


		DELETE FROM A
		FROM @PostInvoiceData A
		WHERE EXISTS(SELECT NULL FROM @InvoicesExclude B WHERE A.[intInvoiceId] = B.[intInvoiceId])
	END
	


--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
--BEGIN TRAN @TransactionName
if @Recap = 1 AND @RaiseError = 0
	SAVE TRAN @TransactionName



DECLARE @TempInvoiceIds TABLE(
	id  	INT
)
INSERT INTO @TempInvoiceIds(id)
SELECT distinct intInvoiceId FROM @PostInvoiceData

WHILE EXISTS(SELECT TOP 1 NULL FROM @TempInvoiceIds ORDER BY id)
BEGIN				
	DECLARE @InvoiceId1 INT
				
	SELECT TOP 1 @InvoiceId1 = id FROM @TempInvoiceIds ORDER BY id

	-- EXEC [dbo].[uspICPostStockReservation]
	-- 	@intTransactionId		= @InvoiceId1
	-- 	,@intTransactionTypeId	= @INVENTORY_SHIPMENT_TYPE
	-- 	,@ysnPosted				= @Post
	EXEC dbo.[uspARUpdateReservedStock] @InvoiceId1, 0, @UserId, 1, @Post
		
	DELETE FROM @TempInvoiceIds WHERE id = @InvoiceId1
END		

INSERT INTO @InvalidInvoiceData(
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[intInvoiceDetailId]
	,[intItemId]
	,[strBatchId]
	,[strPostingError])
SELECT
	 [intInvoiceId]			= IID.[intInvoiceId]
	,[strInvoiceNumber]		= IID.[strInvoiceNumber]
	,[strTransactionType]	= IID.[strTransactionType]
	,[intInvoiceDetailId]	= IID.[intInvoiceDetailId]
	,[intItemId]			= IID.[intItemId]
	,[strBatchId]			= IID.[strBatchId]
	,[strPostingError]		= IID.[strPostingError]
FROM 
	[dbo].[fnARGetInvalidInvoicesForPosting](@PostInvoiceData, @Post, @Recap) AS IID
		
SELECT @totalInvalid = COUNT(*) FROM @InvalidInvoiceData

IF(@totalInvalid > 0)
	BEGIN
		--	@InvalidInvoiceData
					
		UPDATE ILD
		SET
			 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
			,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
			,ILD.[strPostingMessage]		= PID.[strPostingError]
			,ILD.[strBatchId]				= PID.[strBatchId]
			,ILD.[strPostedTransactionId] = PID.[strInvoiceNumber] 
		FROM
			tblARInvoiceIntegrationLogDetail ILD
		INNER JOIN
			@InvalidInvoiceData PID
				ON ILD.[intInvoiceId] = PID.[intInvoiceId]
		WHERE
			ILD.[intIntegrationLogId] = @IntegrationLogId
			AND ILD.[ysnPost] IS NOT NULL

		--DELETE Invalid Transaction From temp table
		DELETE @PostInvoiceData
			FROM @PostInvoiceData A
				INNER JOIN @InvalidInvoiceData B
					ON A.intInvoiceId = B.[intInvoiceId]
				
		IF @RaiseError = 1
			BEGIN
				SELECT TOP 1 @ErrorMerssage = [strPostingError] FROM @InvalidInvoiceData
				RAISERROR(@ErrorMerssage, 11, 1)							
				GOTO Post_Exit
			END					
	END

SELECT @totalRecords = COUNT(*) FROM @PostInvoiceData
			
IF(@totalInvalid >= 1 AND @totalRecords <= 0)
	BEGIN
		IF @RaiseError = 0
		BEGIN
			IF @InitTranCount = 0
				BEGIN
					IF (XACT_STATE()) = -1 OR  @Recap = 1
						ROLLBACK TRANSACTION
					IF (XACT_STATE()) = 1
						COMMIT TRANSACTION
				END		
			ELSE
				BEGIN
					IF (XACT_STATE()) = -1 OR  @Recap = 1
						ROLLBACK TRANSACTION  @Savepoint

					UPDATE ILD
					SET
						 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
						,ILD.[strPostingMessage]		= PID.[strPostingError]
						,ILD.[strBatchId]				= PID.[strBatchId]
						,ILD.[strPostedTransactionId] = PID.[strInvoiceNumber] 
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@InvalidInvoiceData PID
							ON ILD.[intInvoiceId] = PID.[intInvoiceId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL
				END	
		END
			
		IF @RaiseError = 1
			BEGIN
				SELECT TOP 1 @ErrorMerssage = [strPostingError] FROM @InvalidInvoiceData
				RAISERROR(@ErrorMerssage, 11, 1)							
				GOTO Post_Exit
			END				
		GOTO Post_Exit	
	END


--Process Split Invoice
IF @Post = 1 AND @Recap = 0
BEGIN
	DECLARE @SplitInvoiceData TABLE([intInvoiceId] INT, [strInvoiceNumber] NVARCHAR(50))

	INSERT INTO @SplitInvoiceData
	SELECT 
		[intInvoiceId]
		,[strInvoiceNumber]
	FROM
		dbo.tblARInvoice ARI WITH (NOLOCK)
	WHERE
		ARI.[ysnSplitted] = 0 
		AND ISNULL(ARI.[intSplitId], 0) > 0
		AND EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])

	WHILE EXISTS(SELECT NULL FROM @SplitInvoiceData)
		BEGIN
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('ARProcessSplitInvoice' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)
			SET @ErrorMerssage	  = NULL
			
			IF @CurrentTranCount = 0
				BEGIN
					BEGIN TRANSACTION @CurrentSavepoint
				END
			ELSE
				BEGIN
					SAVE TRANSACTION @CurrentSavepoint
				END

			DECLARE	@intSplitInvoiceId INT
			DECLARE	@strSplitInvoiceNumber NVARCHAR(50)

			BEGIN TRY
				DECLARE @invoicesToAdd NVARCHAR(MAX) = NULL

				SELECT TOP 1 @intSplitInvoiceId = intInvoiceId, @strSplitInvoiceNumber = [strInvoiceNumber] FROM @SplitInvoiceData ORDER BY intInvoiceId

				EXEC dbo.uspARProcessSplitInvoice @intSplitInvoiceId, @UserId, @invoicesToAdd OUT

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
							,[ysnAccrueLicense]				= 0
							,[intSplitId]					= ARI.[intSplitId]
							,[dblSplitPercent]				= ARI.[dblSplitPercent]			
							,[ysnSplitted]					= ARI.[ysnSplitted]
							,[ysnImpactInventory]			= ARI.[ysnImpactInventory]
							,[intEntityId]					= ARI.[intEntityId]
							,[ysnPost]						= @Post
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
							,[strBatchId]					= @BatchIdUsed
							,[strPostingMessage]			= ''
							,[intUserId]					= @UserEntityID
							,[ysnAllowOtherUserToPost]		= @AllowOtherUserToPost		
						FROM dbo.tblARInvoice ARI WITH (NOLOCK)
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
			END TRY
			BEGIN CATCH
				SELECT @ErrorMerssage = ERROR_MESSAGE()
				IF @RaiseError = 0
					BEGIN
						IF @CurrentTranCount = 0
							BEGIN
								IF (XACT_STATE()) <> 0
									ROLLBACK TRANSACTION
							END
						ELSE
							BEGIN
								IF (XACT_STATE()) <> 0
									ROLLBACK TRANSACTION @CurrentSavepoint
							END

						UPDATE ILD
						SET
							 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
							,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
							,ILD.[strPostingMessage]		= @ErrorMerssage
							,ILD.[strBatchId]				= @BatchId
							,ILD.[strPostedTransactionId]	= @strSplitInvoiceNumber
						FROM
							tblARInvoiceIntegrationLogDetail ILD
						WHERE
							ILD.[intIntegrationLogId] = @IntegrationLogId
							AND ILD.[ysnPost] IS NOT NULL
							AND ILD.[intInvoiceId] = @intSplitInvoiceId

						DELETE FROM @SplitInvoiceData WHERE intInvoiceId = @intSplitInvoiceId
						DELETE FROM @PostInvoiceData WHERE [intInvoiceId] = @intSplitInvoiceId
						SET @CurrentTranCount = NULL
						SET @CurrentSavepoint = NULL
						SET @ErrorMerssage	  = NULL

					END
										
				IF @RaiseError = 1
					RAISERROR(@ErrorMerssage, 11, 1)
			END CATCH
		END
END

--Process Finished Good Items
DECLARE @FinishedGoodItems TABLE(intInvoiceDetailId		INT
								, intItemId				INT
								, dblQuantity			NUMERIC(18,6)
								, intItemUOMId			INT
								, intLocationId			INT
								, intSublocationId		INT
								, intStorageLocationId	INT
								,[intInvoiceId]			INT
								,[strInvoiceNumber]		NVARCHAR(50))

		
INSERT INTO @FinishedGoodItems
SELECT ID.intInvoiceDetailId
		, ID.intItemId
		, ID.dblQtyShipped
		, ID.intItemUOMId
		, I.intCompanyLocationId
		, ICL.intSubLocationId
		, ID.intStorageLocationId
		, I.intInvoiceId
		, I.strInvoiceNumber
FROM tblARInvoice I
	INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
	INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
	INNER JOIN tblICItemLocation ICL ON ID.intItemId = ICL.intItemId AND I.intCompanyLocationId = ICL.intLocationId
	LEFT OUTER JOIN tblICItemStock ICIS ON ICI.intItemId = ICIS.intItemId AND ICL.intItemLocationId = ICIS.intItemLocationId 
WHERE I.intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
AND ID.ysnBlended <> @Post
AND ICI.ysnAutoBlend = 1
AND I.strTransactionType NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment')
AND 
	(
	@Post = 0
	OR
		(
			@Post = 1
		AND 
			ISNULL(ICIS.dblUnitOnHand,0.000000) = @ZeroDecimal
		AND 
			ICL.intAllowNegativeInventory = 3
		)
	)

DECLARE @intFGInvoiceId		INT
DECLARE @strFGInvoiceNumber	NVARCHAR(50)
DECLARE @intInvoiceDetailId		INT
		, @intItemId			INT
		, @dblQuantity			NUMERIC(18,6)
		, @dblMaxQuantity		NUMERIC(18,6) = 0
		, @intItemUOMId			INT
		, @intLocationId		INT
		, @intSublocationId		INT
		, @intStorageLocationId	INT

WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
BEGIN
	SET @CurrentTranCount = @@TRANCOUNT
	SET @CurrentSavepoint = SUBSTRING(('ARAutoBlend' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)
	SET @ErrorMerssage	  = NULL
			
	IF @CurrentTranCount = 0
		BEGIN
			BEGIN TRANSACTION @CurrentSavepoint
		END
	ELSE
		BEGIN
			SAVE TRANSACTION @CurrentSavepoint
		END
							
	SELECT TOP 1 
		  @intInvoiceDetailId	= intInvoiceDetailId
		, @intItemId			= intItemId
		, @dblQuantity			= dblQuantity				
		, @intItemUOMId			= intItemUOMId
		, @intLocationId		= intLocationId
		, @intSublocationId		= intSublocationId
		, @intStorageLocationId	= intStorageLocationId
		, @intFGInvoiceId		= intInvoiceId
		, @strFGInvoiceNumber	= strInvoiceNumber
	FROM @FinishedGoodItems 
				  
	BEGIN TRY
	IF @Post = 1
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
				@intUserId				= @UserId,
				@dblMaxQtyToProduce		= @dblMaxQuantity OUT		

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
						@intUserId				= @UserId,
						@dblMaxQtyToProduce		= @dblMaxQuantity OUT
				END

				UPDATE tblARInvoiceDetail SET ysnBlended = @Post WHERE intInvoiceDetailId = @intInvoiceDetailId

				DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailId
		END				
	END TRY
	BEGIN CATCH
		SELECT @ErrorMerssage = ERROR_MESSAGE()
		IF @RaiseError = 0
			BEGIN
				IF @CurrentTranCount = 0
					BEGIN
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION
					END
				ELSE
					BEGIN
						IF (XACT_STATE()) <> 0
							ROLLBACK TRANSACTION @CurrentSavepoint
					END

				UPDATE ILD
				SET
					 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
					,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
					,ILD.[strPostingMessage]		= @ErrorMerssage
					,ILD.[strBatchId]				= @BatchId
					,ILD.[strPostedTransactionId]	= @strFGInvoiceNumber
				FROM
					tblARInvoiceIntegrationLogDetail ILD
				WHERE
					ILD.[intIntegrationLogId] = @IntegrationLogId
					AND ILD.[ysnPost] IS NOT NULL
					AND ILD.[intInvoiceId] = @intFGInvoiceId

				DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailId
				DELETE FROM @PostInvoiceData WHERE [intInvoiceId] = @intFGInvoiceId
				SET @CurrentTranCount = NULL
				SET @CurrentSavepoint = NULL
				SET @ErrorMerssage	  = NULL

			END
										
		IF @RaiseError = 1
			RAISERROR(@ErrorMerssage, 11, 1)
	END CATCH
END

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------

IF @Post = 1  
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
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('ARGenerateEntriesForAccrualNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)
			SET @ErrorMerssage	  = NULL
			
			IF @CurrentTranCount = 0
				BEGIN
					BEGIN TRANSACTION @CurrentSavepoint
				END
			ELSE
				BEGIN
					SAVE TRANSACTION @CurrentSavepoint
				END
		 
			DECLARE @Accruals AS InvoiceId
			INSERT INTO @Accruals([intHeaderId], [ysnAccrueLicense])
			SELECT IP.intInvoiceId, IP.ysnAccrueLicense  
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
			EXEC	dbo.[uspARGenerateEntriesForAccrualNew]  
						 @InvoiceIds				= @Accruals
						,@DeferredRevenueAccountId	= @DeferredRevenueAccountId
						,@BatchId					= @BatchId
						,@Code						= @CODE
						,@UserId					= @UserId
						,@UserEntityId				= @UserEntityID
						,@ScreenName				= @SCREEN_NAME
						,@ModuleName				= @MODULE_NAME

		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			IF @RaiseError = 0
				BEGIN
					IF @CurrentTranCount = 0
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION
						END
					ELSE
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION @CurrentSavepoint
						END

					UPDATE ILD
					SET
						 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
						,ILD.[strPostingMessage]		= @ErrorMerssage
						,ILD.[strBatchId]				= @BatchId
						,ILD.[strPostedTransactionId]	= PID.[strInvoiceNumber]
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@Accruals A
							ON ILD.[intInvoiceId] = A.[intHeaderId]
					INNER JOIN 
						@PostInvoiceData PID
							ON PID.[intInvoiceId] = A.[intHeaderId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL


					DELETE PID FROM @PostInvoiceData PID INNER JOIN @Accruals A ON PID.[intInvoiceId] = A.[intHeaderId]
					SET @CurrentTranCount = NULL
					SET @CurrentSavepoint = NULL
					SET @ErrorMerssage	  = NULL

				END
										
			IF @RaiseError = 1
				RAISERROR(@ErrorMerssage, 11, 1)
		END CATCH	

		DECLARE @AVERAGECOST AS INT = 1
				,@FIFO AS INT = 2
				,@LIFO AS INT = 3
				,@LOTCOST AS INT = 4
				,@ACTUALCOST AS INT = 5

		BEGIN TRY
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = 'ARPostCosting'
			SET @ErrorMerssage	  = NULL
			
			IF @CurrentTranCount = 0
				BEGIN
					BEGIN TRANSACTION @CurrentSavepoint
				END
			ELSE
				BEGIN
					SAVE TRANSACTION @CurrentSavepoint
				END

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
				[fnARGetItemsForCosting](@PostInvoiceData, @Post, 0)	
				
			IF EXISTS (SELECT TOP 1 1 FROM @ItemsForPost)
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
				EXEC	dbo.uspARBatchPostCosting  
						@ItemsForPost  
						,@BatchId  
						,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
						,@UserEntityID
						,DEFAULT  -- Default is NULL. Used to override the GL description. 
						,DEFAULT  -- Options are 'Aggregrate' and'Detailed'. Default is 'Detailed'.

				DELETE FROM ICIT
				FROM
					tblICInventoryTransaction ICIT WITH (NOLOCK)
				INNER JOIN
					@ItemsForPost SIFP
						ON ICIT.[intTransactionId] = SIFP.[intTransactionId]
						AND ICIT.[strTransactionId] = SIFP.[strTransactionId] 
						AND ICIT.[ysnIsUnposted] <> 1
						AND @Recap = 1
						AND @Post = 1		
			END				
			
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			IF @RaiseError = 0
				BEGIN
					IF @CurrentTranCount = 0
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION
						END
					ELSE
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION @CurrentSavepoint
						END

					UPDATE ILD
					SET
						 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
						,ILD.[strPostingMessage]		= @ErrorMerssage
						,ILD.[strBatchId]				= @BatchId
						,ILD.[strPostedTransactionId]	= IFP.[strTransactionId] 
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@ItemsForPost IFP
							ON ILD.[intInvoiceId] = IFP.[intTransactionId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL


					DELETE PID FROM @PostInvoiceData PID INNER JOIN @ItemsForPost IFP ON PID.[intInvoiceId] = IFP.[intTransactionId] 
					SET @CurrentTranCount = NULL
					SET @CurrentSavepoint = NULL
					SET @ErrorMerssage	  = NULL

				END
										
			IF @RaiseError = 1
				RAISERROR(@ErrorMerssage, 11, 1)
		END CATCH

		BEGIN TRY
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = 'ARPostInTransitCosting'
			SET @ErrorMerssage	  = NULL
			
			IF @CurrentTranCount = 0
				BEGIN
					BEGIN TRANSACTION @CurrentSavepoint
				END
			ELSE
				BEGIN
					SAVE TRANSACTION @CurrentSavepoint
				END

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
				[fnARGetItemsForInTransitCosting](@PostInvoiceData, @Post)

			IF EXISTS (SELECT TOP 1 1 FROM @InTransitItems)
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
				)
				EXEC	dbo.uspICPostInTransitCosting  
						@InTransitItems  
						,@BatchId  
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
						AND @Recap  = 1
						AND @Post = 1

			END
		END TRY 
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			IF @RaiseError = 0
				BEGIN
					IF @CurrentTranCount = 0
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION
						END
					ELSE
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION @CurrentSavepoint
						END

					UPDATE ILD
					SET
						 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
						,ILD.[strPostingMessage]		= @ErrorMerssage
						,ILD.[strBatchId]				= @BatchId
						,ILD.[strPostedTransactionId]	= ITI.[strTransactionId] 
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@InTransitItems ITI
							ON ILD.[intInvoiceId] = ITI.[intTransactionId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL


					DELETE PID FROM @PostInvoiceData PID INNER JOIN @InTransitItems ITI ON PID.[intInvoiceId] = ITI.[intTransactionId] 
					SET @CurrentTranCount = NULL
					SET @CurrentSavepoint = NULL
					SET @ErrorMerssage	  = NULL

				END
										
			IF @RaiseError = 1
				RAISERROR(@ErrorMerssage, 11, 1)
					
		END CATCH			

		BEGIN TRY
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = 'ARPostStorage'
			SET @ErrorMerssage	  = NULL
			
			IF @CurrentTranCount = 0
				BEGIN
					BEGIN TRANSACTION @CurrentSavepoint
				END
			ELSE
				BEGIN
					SAVE TRANSACTION @CurrentSavepoint
				END
  
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
				[fnARGetItemsForStoragePosting](@PostInvoiceData, @Post)

			IF EXISTS (SELECT TOP 1 1 FROM @StorageItemsForPost) 
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
					)
					EXEC	dbo.uspICPostStorage  
							@StorageItemsForPost  
							,@BatchId  		
							,@UserEntityID

					DELETE FROM ICIT
					FROM
						tblICInventoryTransaction ICIT WITH(NOLOCK)
					INNER JOIN
						@StorageItemsForPost SIFP
							ON ICIT.[intTransactionId] = SIFP.[intTransactionId]
							AND ICIT.[strTransactionId] = SIFP.[strTransactionId]
							AND ICIT.[ysnIsUnposted] <> 1
							AND @Recap  = 1
							AND @Post = 1
					
			END
		
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			IF @RaiseError = 0
				BEGIN
					IF @CurrentTranCount = 0
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION
						END
					ELSE
						BEGIN
							IF (XACT_STATE()) <> 0
								ROLLBACK TRANSACTION @CurrentSavepoint
						END

					UPDATE ILD
					SET
						 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
						,ILD.[strPostingMessage]		= @ErrorMerssage
						,ILD.[strBatchId]				= @BatchId
						,ILD.[strPostedTransactionId]	= SIFP.[strTransactionId] 
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@StorageItemsForPost SIFP
							ON ILD.[intInvoiceId] = SIFP.[intTransactionId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL


					DELETE PID FROM @PostInvoiceData PID INNER JOIN @StorageItemsForPost SIFP ON PID.[intInvoiceId] = SIFP.[intTransactionId] 
					SET @CurrentTranCount = NULL
					SET @CurrentSavepoint = NULL
					SET @ErrorMerssage	  = NULL

				END
										
			IF @RaiseError = 1
				RAISERROR(@ErrorMerssage, 11, 1)
					
		END CATCH

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
			--DEBIT Total
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @BatchId
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
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @UserId
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
				(SELECT intEntityId, strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C
					ON A.[intEntityCustomerId] = C.intEntityId
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
					(SELECT [intInvoiceId], strTransactionType FROM tblARInvoice WITH (NOLOCK)) ARI1
						ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId] AND ARI1.strTransactionType = 'Credit Memo'				
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
				,strBatchID					= @BatchId
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
				,intUserId					= @UserId
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
				(SELECT [intInvoiceId], [strInvoiceNumber], intAccountId, strTransactionType FROM tblARInvoice WITH (NOLOCK)) ARI1
					ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId] AND ARI1.strTransactionType = 'Credit Memo'				 
			LEFT JOIN 
				(SELECT intEntityId, strCustomerNumber FROM tblARCustomer WITH (NOLOCK)) C ON A.[intEntityCustomerId] = C.[intEntityId]
			INNER JOIN 
				(SELECT intInvoiceId FROM @PostInvoiceData ) P ON A.intInvoiceId = P.intInvoiceId
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1			

			UNION ALL

			--Debit Payment
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @BatchId
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
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @UserId
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
					(SELECT [intInvoiceId], strTransactionType FROM tblARInvoice WITH (NOLOCK)) ARI1 ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId] AND ARI1.strTransactionType = 'Credit Memo'
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
				,strBatchID					= @BatchId
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
				,intUserId					= @UserId
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
				(SELECT [intInvoiceId], [strInvoiceNumber], intAccountId FROM tblARInvoice WITH (NOLOCK)) ARI1 ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId] AND strTransactionType <> 'Credit Memo'		
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
				,strBatchID					= @BatchId
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
				,intUserId					= @UserId
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
				,strBatchID					= @BatchId
				,intAccountId				= B.intLicenseAccountId 
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
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
				,intUserId					= @UserId
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
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																													
																										 END)
											  ELSE 0  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
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
				(SELECT intInvoiceId, ysnAccrueLicense FROM @PostInvoiceData)	P ON A.intInvoiceId = P.intInvoiceId 
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
				AND (ISNULL(A.intPeriodsToAccrue,0) <= 1 OR ( ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(P.ysnAccrueLicense,0) = 0))

			--DEBIT Software -- License
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @BatchId
				,intAccountId				= @DeferredRevenueAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblBaseLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  ELSE 0  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblBaseTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblBaseTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblBaseMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblBaseTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
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
				,intUserId					= @UserId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
				,[dblDebitForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  ELSE 0  END
				,[dblDebitReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  ELSE 0  END
				,[dblCreditForeign]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
																														ELSE
																															[dbo].fnRoundBanker((ISNULL(B.dblLicenseAmount, @ZeroDecimal) * B.dblQtyShipped), dbo.fnARGetDefaultDecimal())		
																													END)
																										 END)
											  END
				,[dblCreditReport]			= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 
																									ELSE (CASE WHEN B.strMaintenanceType = 'License Only'
																												THEN
																													ISNULL(B.dblTotal, @ZeroDecimal) + (CASE WHEN (ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0) THEN 0 ELSE [dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
																												ELSE
																													(CASE WHEN ISNULL(B.dblDiscount, @ZeroDecimal) > @ZeroDecimal 
																														THEN
																															[dbo].fnRoundBanker(B.dblTotal * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) + + (CASE WHEN ISNULL(A.intPeriodsToAccrue,0) > 1 AND P.ysnAccrueLicense = 0  THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(([dbo].fnRoundBanker(((B.dblDiscount/100.00) * [dbo].fnRoundBanker((B.dblQtyShipped * B.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(100.000000 - [dbo].fnRoundBanker(((ISNULL(B.dblMaintenanceAmount, @ZeroDecimal) * B.dblQtyShipped) / B.dblTotal) * 100.00000, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ 100.000000), dbo.fnARGetDefaultDecimal()) END) 
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
				(SELECT intInvoiceId, ysnAccrueLicense FROM @PostInvoiceData) P ON A.intInvoiceId = P.intInvoiceId
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
				AND (ISNULL(A.intPeriodsToAccrue,0) > 1 AND ISNULL(P.ysnAccrueLicense,0) = 0)

			--CREDIT Software -- Maintenance
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @BatchId
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
				,intUserId					= @UserId
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
				,strBatchID					= @BatchId
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
				,intUserId					= @UserId
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
				,strBatchID					= @BatchId
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
				,intUserId					= @UserId
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
				,strBatchID					= @BatchId
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
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @UserId
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
				,strBatchID					= @BatchId
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
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= DT.intInvoiceDetailTaxId
				,ysnIsUnposted				= 0
				,intUserId					= @UserId
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
				,strBatchID					= @BatchId
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
				,strJournalLineDescription	= @POSTDESC + A.strTransactionType 
				,intJournalLineNo			= D.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @UserId
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
			
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH

		IF @Recap = 0
		BEGIN
			BEGIN TRY
				UPDATE @GLEntries SET [dtmDateEntered] = @PostDate 
				EXEC dbo.uspGLBookEntries
					 @GLEntries		= @GLEntries
					,@ysnPost		= @Post
					,@XACT_ABORT_ON = @RaiseError

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
IF @Post = 0   
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
				,strBatchId						= @BatchId
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
				,intUserId						= @UserId
				,intEntityId					= @UserEntityID
				,strTransactionId				= GLD.strTransactionId
				,intTransactionId				= GLD.intTransactionId
				,strTransactionType				= GLD.strTransactionType
				,strTransactionForm				= GLD.strTransactionForm
				,strModuleName					= GLD.strModuleName
				,intConcurrencyId				= GLD.intConcurrencyId
			FROM
				(SELECT intInvoiceId, [strInvoiceNumber] FROM @PostInvoiceData) PID
			INNER JOIN
				(SELECT dtmDate, intAccountId, intGLDetailId, intTransactionId, strTransactionId, strDescription, strCode, strReference, intCurrencyId, dblExchangeRate, dtmTransactionDate, 
					strJournalLineDescription, intJournalLineNo, strTransactionType, strTransactionForm, strModuleName, intConcurrencyId, dblCredit, dblDebit, dblCreditUnit, dblDebitUnit, ysnIsUnposted,
					dblCreditForeign, dblDebitForeign
				 FROM dbo.tblGLDetail WITH (NOLOCK)) GLD
					ON PID.intInvoiceId = GLD.intTransactionId
					AND PID.[strInvoiceNumber] = GLD.strTransactionId							 
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
				,PID.[strInvoiceNumber]
			FROM
				@PostInvoiceData PID				
			INNER JOIN
				(SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK) ) ARI
					ON PID.intInvoiceId = ARI.intInvoiceId

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
				,PID.[strInvoiceNumber]
			FROM
				(SELECT intInvoiceId, [strInvoiceNumber] FROM @PostInvoiceData) PID
			INNER JOIN
				(SELECT intInvoiceId, intItemId, intItemUOMId FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
					ON PID.intInvoiceId = ARID.intInvoiceId					
			INNER JOIN
				(SELECT intInvoiceId, intCompanyLocationId, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
					ON ARID.intInvoiceId = ARI.intInvoiceId	AND strTransactionType IN ('Invoice', 'Credit Memo', 'Cash', 'Cash Refund')				 	
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
								,@BatchId
								,@UserEntityID
								,@Recap 
				END

				IF @WStorageCount > 0 
				BEGIN 
					-- Unpost storage stocks. 
					EXEC	dbo.uspICUnpostStorage
							@intTransactionId
							,@strTransactionId
							,@BatchId
							,@UserEntityID
							,@Recap
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
		
IF @Recap = 1		
	BEGIN
		IF @RaiseError = 0
			ROLLBACK TRAN @TransactionName		

		DELETE GLDR  
		FROM 
			(SELECT intInvoiceId, [strInvoiceNumber] FROM @PostInvoiceData) PID  
		INNER JOIN 
			(SELECT intTransactionId, strTransactionId, strCode FROM dbo.tblGLDetailRecap WITH (NOLOCK)) GLDR 
				ON (PID.[strInvoiceNumber] = GLDR.strTransactionId OR PID.intInvoiceId = GLDR.intTransactionId)  AND GLDR.strCode = @CODE		   
		   
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
			,A.[strDescription]
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[dtmTransactionDate]
			,Debit.Value
			,Credit.Value
			,DebitUnit.Value
			,CreditUnit.Value
			,A.[dblDebitForeign]
			,A.[dblCreditForeign]			
			,A.[intCurrencyId]
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,A.[dblExchangeRate]
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,A.strRateType
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) CreditUnit
				
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

		UPDATE tblGLPostRecap SET strDescription = ABC.strDescription
		FROM 
			tblGLPostRecap
		INNER JOIN
		(
			SELECT GLA.intAccountId, GLA.strDescription 
			FROM 
				(SELECT intAccountId, strDescription, strBatchId FROM tblGLPostRecap) GLPR
				INNER JOIN 
				(SELECT intAccountId, strDescription FROM tblGLAccount) GLA ON GLPR.intAccountId = GLPR.intAccountId
				WHERE
					(ISNULL(GLPR.strDescription, '') = '' OR (GLPR.strDescription = 'Thank you for your business!'))
					AND GLPR.strBatchId = @tmpBatchId
		) ABC ON tblGLPostRecap.intAccountId = ABC.intAccountId
		WHERE 
			((ISNULL(tblGLPostRecap.strDescription, '') = '') OR  (tblGLPostRecap.strDescription = 'Thank you for your business!'))
			AND tblGLPostRecap.strBatchId = @tmpBatchId

		--EXEC uspGLPostRecap @GLEntries, @UserEntityID 

		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			IF @RaiseError = 0
				BEGIN
			
				SET @CurrentTranCount = @@TRANCOUNT
				SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
				IF @CurrentTranCount = 0
					BEGIN TRANSACTION
				ELSE
					SAVE TRANSACTION @CurrentSavepoint	
					
					UPDATE ILD
					SET
						 ILD.[ysnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN 0 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 0 END
						,ILD.[strPostingMessage]	= @ErrorMerssage
						,ILD.[strBatchId]			= @BatchId
						,ILD.[strPostedTransactionId] = PID.[strInvoiceNumber] 
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@PostInvoiceData PID
							ON ILD.[intInvoiceId] = PID.[intInvoiceId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL 
					
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
						END	

				END			
			IF @RaiseError = 1
				RAISERROR(@ErrorMerssage, 11, 1)
			GOTO Post_Exit
		END CATCH
	
	END 	

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @Recap = 0
	BEGIN			 
		BEGIN TRY 
			IF @Post = 0
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
					
					UPDATE ILD
					SET
						 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
						,ILD.[strPostingMessage]		= @UnpostSuccessfulMsg
						,ILD.[strBatchId]				= @BatchId
						,ILD.[strPostedTransactionId]	= PID.[strInvoiceNumber] 
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@PostInvoiceData PID
							ON ILD.[intInvoiceId] = PID.[intInvoiceId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL
												
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

							
					UPDATE ILD
					SET
						 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
						,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
						,ILD.[strPostingMessage]		= @PostSuccessfulMsg
						,ILD.[strBatchId]				= @BatchId
						,ILD.[strPostedTransactionId]	= PID.[strInvoiceNumber] 
					FROM
						tblARInvoiceIntegrationLogDetail ILD
					INNER JOIN
						@PostInvoiceData PID
							ON ILD.[intInvoiceId] = PID.[intInvoiceId]
					WHERE
						ILD.[intIntegrationLogId] = @IntegrationLogId
						AND ILD.[ysnPost] IS NOT NULL
					
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

								EXEC dbo.uspTMSyncInvoiceToDeliveryHistory @intInvoiceForSyncId, @UserId, @ResultLogForSync OUT
												
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
			DECLARE @InvoiceToUpdate AS InvoiceId;
			
			INSERT INTO @InvoiceToUpdate(		 [intHeaderId]
				,[ysnUpdateAvailableDiscountOnly]
				,[intDetailId]
				,[ysnForDelete]
				,[ysnFromPosting]
				,[ysnPost]
				,[ysnAccrueLicense]
				,[strTransactionType]
				,[strSourceTransaction]
				,[ysnProcessed])
			SELECT DISTINCT
				 [intHeaderId]						= PID.[intInvoiceId]
				,[ysnUpdateAvailableDiscountOnly]	= ARIILD.[ysnUpdateAvailableDiscount]
				,[intDetailId]						= NULL
				,[ysnForDelete]						= 0
				,[ysnFromPosting]					= 1
				,[ysnPost]							= @Post
				,[ysnAccrueLicense]					= ARIILD.[ysnAccrueLicense]
				,[strTransactionType]				= ARIILD.[strTransactionType]
				,[strSourceTransaction]				= ARIILD.[strSourceTransaction]
				,[ysnProcessed]						= 0
			FROM 
				@PostInvoiceData PID
			INNER JOIN
				(SELECT [intInvoiceId], [ysnHeader], [ysnSuccess], [intId], [intIntegrationLogId], [strTransactionType], [ysnPost], [ysnAccrueLicense], [strSourceTransaction], [ysnUpdateAvailableDiscount] FROM tblARInvoiceIntegrationLogDetail WITH (NOLOCK)) ARIILD
					ON PID.[intInvoiceId] = ARIILD.[intInvoiceId]
				
			EXEC [uspARPostInvoicesIntegrationsNew] @InvoiceIds = @InvoiceToUpdate, @UserId = @UserId 

			--UPDATE tblARCustomer.dblARBalance
			UPDATE CUSTOMER
			SET dblARBalance = dblARBalance + (CASE WHEN @Post = 1 THEN ISNULL(dblTotalInvoice, 0) ELSE ISNULL(dblTotalInvoice, 0) * -1 END)
			FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
			INNER JOIN (SELECT intEntityCustomerId
							 , dblTotalInvoice = SUM(CASE WHEN strTransactionType IN ('Invoice', 'Debit Memo') THEN dblInvoiceTotal ELSE dblInvoiceTotal * -1 END)
						FROM dbo.tblARInvoice WITH (NOLOCK)
						WHERE intInvoiceId IN (SELECT [intHeaderId] FROM @InvoiceToUpdate)
						GROUP BY intEntityCustomerId
			) INVOICE ON CUSTOMER.intEntityId = INVOICE.intEntityCustomerId

			--UPDATE BatchIds Used
			UPDATE tblARInvoice 
			SET 
				 [strBatchId]		= CASE WHEN @Post = 1 THEN @BatchId ELSE NULL END
				,[dtmBatchDate]		= CASE WHEN @Post = 1 THEN @PostDate ELSE NULL END
				,[intPostedById]	= CASE WHEN @Post = 1 THEN @UserEntityID ELSE NULL END
			WHERE intInvoiceId IN (SELECT [intHeaderId] FROM @InvoiceToUpdate)

		DELETE dbo.tblARPrepaidAndCredit  
		FROM 
			(SELECT intInvoiceId, ysnApplied FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)) A 
		INNER JOIN (SELECT intInvoiceId FROM @PostInvoiceData ) B  
		   ON A.intInvoiceId = B.intInvoiceId AND (ISNULL(ysnApplied,0) = 0 OR @Post = 0)
																
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH										
			
	END
	
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
		END	
END

RETURN 1;

IF @Post = 0
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
	IF @RaiseError = 0
		BEGIN
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
						
			UPDATE ILD
			SET
				 ILD.[ysnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
				,ILD.[ysnUnPosted]			= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
				,ILD.[strPostingMessage]	= @ErrorMerssage
				,ILD.[strBatchId]			= @BatchId
				,ILD.[strPostedTransactionId] = PID.[strInvoiceNumber] 
			FROM
				tblARInvoiceIntegrationLogDetail ILD
			INNER JOIN
				@PostInvoiceData PID
					ON ILD.[intInvoiceId] = PID.[intInvoiceId]
			WHERE
				ILD.[intIntegrationLogId] = @IntegrationLogId
				AND ILD.[ysnPost] IS NOT NULL
				
		END
	IF @RaiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)	
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @Success = 0	
	RETURN 0;
