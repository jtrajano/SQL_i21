CREATE PROCEDURE [dbo].[uspARProcessRefund]
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

DECLARE @totalRecords INT = 0
        ,@totalInvalid INT = 0 
        ,@PostInvoiceData AS [InvoicePostingTable]
DECLARE @InvalidInvoiceData AS TABLE( -- Invalid Entries for CPP or CM header
            [intInvoiceId]				INT				NOT NULL
            ,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
            ,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
            ,[intInvoiceDetailId]		INT				NULL
            ,[intItemId]				INT				NULL
            ,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
            ,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
        )
DECLARE @InvalidInvoiceDataHeaderCashRefund AS TABLE( -- Invalid Entries for Generated Cash refund
            [intInvoiceId]				INT				NOT NULL
            ,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
            ,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
            ,[intInvoiceDetailId]		INT				NULL
            ,[intItemId]				INT				NULL
            ,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
            ,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
        )
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted'
        ,@MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
        ,@SCREEN_NAME NVARCHAR(25) = 'Invoice'
        ,@CODE NVARCHAR(25) = 'AR'
        ,@POSTDESC NVARCHAR(10) = 'Refund Processed '
        ,@UserEntityID				INT
        ,@DiscountAccountId			INT
        ,@DeferredRevenueAccountId	INT
        ,@AllowOtherUserToPost		BIT
        ,@DefaultCurrencyId			INT
        ,@HasImpactForProvisional   BIT
        ,@InitTranCount				INT
        ,@CurrentTranCount			INT
        ,@Savepoint					NVARCHAR(32)
        ,@CurrentSavepoint			NVARCHAR(32)
        ,@DefaultCurrencyExchangeRateTypeId INT
		
        ,@ErrorMessage NVARCHAR(MAX)
        ,@ZeroDecimal DECIMAL(18,6)

SET @ZeroDecimal = 0.000000	
SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARProcessRefund' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@raiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

/* SET BATCH ID*/
IF(LEN(RTRIM(LTRIM(ISNULL(@batchId,'')))) = 0)
	EXEC dbo.uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId
/* END SET BATCH ID*/


-- GET TRANSACTION TO POST

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
			FROM
				dbo.tblARInvoice ARI WITH (NOLOCK) 
			WHERE
				ARI.[intInvoiceId] BETWEEN @beginTransaction AND @endTransaction
				AND (ARI.[strTransactionType] = @transType OR @transType = 'all')
				AND NOT EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])
	END

-- VALIDATION

    INSERT INTO @InvalidInvoiceData([intInvoiceId],[strInvoiceNumber],[strTransactionType],[intInvoiceDetailId],[intItemId],[strBatchId],[strPostingError])
    SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= I.strTransactionType + ': ' + I.strInvoiceNumber + ' transaction is not yet posted.'
    FROM @PostInvoiceData I
    INNER JOIN 
        (SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice WITH (NOLOCK)) ARI
            ON I.[intInvoiceId] = ARI.[intInvoiceId]
    WHERE  
        ARI.[ysnPosted] = 0

	INSERT INTO @InvalidInvoiceData([intInvoiceId],[strInvoiceNumber],[strTransactionType],[intInvoiceDetailId],[intItemId],[strBatchId],[strPostingError])
SELECT
			[intInvoiceId]			= I.[intInvoiceId]
		,[strInvoiceNumber]		= I.[strInvoiceNumber]		
		,[strTransactionType]	= I.[strTransactionType]
		,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
		,[intItemId]			= I.[intItemId] 
		,[strBatchId]			= I.[strBatchId]
		,[strPostingError]		= 'Refund for ' + I.strTransactionType + ': ' + I.strInvoiceNumber + ' already processed.'
FROM @PostInvoiceData I
INNER JOIN 
    (SELECT [intInvoiceId], [ysnPosted], [ysnRefundProcessed] FROM tblARInvoice WITH (NOLOCK)) ARI
        ON I.[intInvoiceId] = ARI.[intInvoiceId] 
WHERE  
    ARI.[ysnRefundProcessed] = 1

    INSERT INTO @InvalidInvoiceData([intInvoiceId],[strInvoiceNumber],[strTransactionType],[intInvoiceDetailId],[intItemId],[strBatchId],[strPostingError])
    SELECT   [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= 'Only Customer Prepayment and Credit Memo transactions are allowed.'
    FROM @PostInvoiceData I
    INNER JOIN 
        (SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice WITH (NOLOCK)) ARI
            ON I.[intInvoiceId] = ARI.[intInvoiceId]
    WHERE  
        I.strTransactionType NOT IN('Customer Prepayment', 'Credit Memo')

    INSERT INTO @InvalidInvoiceData([intInvoiceId],[strInvoiceNumber],[strTransactionType],[intInvoiceDetailId],[intItemId],[strBatchId],[strPostingError])
    SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= I.[strInvoiceNumber] + ' is not yet Paid.'
    FROM @PostInvoiceData I
    INNER JOIN 
        (SELECT [intInvoiceId], intPaymentId, [ysnPosted] FROM tblARInvoice WITH (NOLOCK)) ARI
            ON I.[intInvoiceId] = ARI.[intInvoiceId]
    INNER JOIN tblARPayment P
        ON P.intPaymentId   = ARI.intPaymentId
    WHERE  
        I.strTransactionType = 'Customer Prepayment' AND P.ysnPosted = 0

    INSERT INTO @InvalidInvoiceData([intInvoiceId],[strInvoiceNumber],[strTransactionType],[intInvoiceDetailId],[intItemId],[strBatchId],[strPostingError])
    SELECT
			 [intInvoiceId]			= I.[intInvoiceId]
			,[strInvoiceNumber]		= I.[strInvoiceNumber]		
			,[strTransactionType]	= I.[strTransactionType]
			,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
			,[intItemId]			= I.[intItemId] 
			,[strBatchId]			= I.[strBatchId]
			,[strPostingError]		= I.[strInvoiceNumber] + ' is not yet Paid.'
    FROM @PostInvoiceData I
    INNER JOIN 
        (SELECT [intInvoiceId], [ysnPosted] FROM tblARInvoice WITH (NOLOCK)) ARI
            ON I.[intInvoiceId] = ARI.[intInvoiceId]
	INNER JOIN tblARPaymentDetail PD
		ON PD.intInvoiceId = ARI.intInvoiceId
	INNER JOIN tblARPayment P
		ON P.intPaymentId = PD.intPaymentId
	WHERE I.strTransactionType = 'Credit Memo' and P.ysnPosted = 0

    /* Get Invalid Data */
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
				SELECT TOP 1 @ErrorMessage = [strPostingError] FROM @InvalidInvoiceData
				RAISERROR(@ErrorMessage, 11, 1)							
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
                    SELECT TOP 1 @ErrorMessage = [strPostingError] FROM @InvalidInvoiceData
                    RAISERROR(@ErrorMessage, 11, 1)							
                    GOTO Post_Exit
                END				
            GOTO Post_Exit	
        END
/* END Invoice Validation for Process Refund */
--BEGIN Refund Process
			
	DECLARE @EntityId						INT
			,@InvoiceDate					DATETIME		
			,@EntityCustomerId				INT
			,@CompanyLocationId				INT,
			@intNewInvoiceId					INT,
			@_ERR							VARCHAR(MAX),
			@raiseERR						INT,
			@ItemDescription				NVARCHAR(MAX)
	SELECT TOP 1 @EntityId = intEntityId,@EntityCustomerId = intEntityCustomerId, @CompanyLocationId = intCompanyLocationId,@InvoiceDate = dtmDate, @ItemDescription = 'Cash Refund for :' + strInvoiceNumber FROM @PostInvoiceData

	EXEC [dbo].[uspARCreateCustomerInvoice]
							@EntityCustomerId          = @EntityCustomerId
						,@InvoiceDate              = @InvoiceDate
						,@CompanyLocationId        = @CompanyLocationId
						,@EntityId                 = @EntityId
						,@NewInvoiceId             = @intNewInvoiceId OUTPUT
						,@ErrorMessage             = @_ERR OUTPUT
						,@ItemQtyShipped           = 1
						,@TransactionType	       = 'Cash Refund'
						,@Type					   = 'Standard'
						,@RaiseError			   = 0
						,@ItemCommentTypeId		   = 1
						,@ItemDescription		   = @ItemDescription
	IF LEN(ISNULL(@_ERR,'')) > 0
	BEGIN
		GOTO InvalidDataPost
	END

	DECLARE @invoiceId AS INT, @intUserId as INT
	SELECT @invoiceId = intInvoiceId, @intUserId = intUserId FROM @PostInvoiceData

	EXEC dbo.uspARUpdatePrepaidForInvoice @InvoiceId = @intNewInvoiceId, @UserId = @intUserId

	IF EXISTS(SELECT COUNT(1) FROM tblARPrepaidAndCredit WHERE intPrepaymentId = @invoiceId)
	BEGIN		
		UPDATE PPC
		SET dblAppliedInvoiceDetailAmount = I2.dblInvoiceTotal,
			dblBaseAppliedInvoiceDetailAmount = I2.dblBaseInvoiceTotal,
			ysnApplied = 1
		FROM tblARInvoice I
		INNER JOIN tblARPrepaidAndCredit PPC
			ON I.intInvoiceId = PPC.intInvoiceId
		INNER JOIN tblARInvoice I2
			ON PPC.intPrepaymentId = I2.intInvoiceId
		INNER JOIN tblARInvoiceDetail ID
			ON ID.intInvoiceId = I.intInvoiceId
		WHERE I.intInvoiceId = @intNewInvoiceId and I2.intInvoiceId = @invoiceId

		UPDATE ID
		SET dblPrice = PPC.dblAppliedInvoiceDetailAmount,
			dblTotal = PPC.dblAppliedInvoiceDetailAmount
		FROM tblARInvoiceDetail ID
		INNER JOIN tblARPrepaidAndCredit PPC
			ON PPC.intInvoiceId = ID.intInvoiceId
		INNER JOIN tblARInvoice I2
			ON I2.intInvoiceId = PPC.intPrepaymentId
		WHERE ID.intInvoiceId = @intNewInvoiceId and PPC.intPrepaymentId = @invoiceId


		UPDATE I
		SET dblAmountDue = I2.dblAmountDue,
			dblBaseAmountDue = I2.dblBaseAmountDue,
			dblInvoiceSubtotal = I2.dblInvoiceTotal,
			dblBaseInvoiceSubtotal = I2.dblBaseInvoiceTotal,
			dblBaseInvoiceTotal = I2.dblBaseInvoiceTotal,
			dblInvoiceTotal = I2.dblInvoiceTotal,
			intAccountId = I2.intAccountId
		FROM tblARInvoice I
		INNER JOIN tblARPrepaidAndCredit PPC
			ON PPC.intInvoiceId = I.intInvoiceId
		INNER JOIN tblARInvoice I2 
			ON I2.intInvoiceId = PPC.intPrepaymentId
		WHERE I.intInvoiceId = @intNewInvoiceId and intPrepaymentId = @invoiceId
		
		DECLARE @strNewInvoiceId AS NVARCHAR(MAX) = CAST(@intNewInvoiceId AS NVARCHAR(MAX))
		EXEC uspARPostInvoice @post=1,@recap=0,@param=@strNewInvoiceId,@userId=@userId

		/* CREATE VOUCHER */
		BEGIN TRY
		--DECLARE @APClearingAccountId AS INT
		--SELECT TOP 1 @APClearingAccountId = ISNULL(intAPClearingAccountId,intARAccountId) FROM tblARCompanyPreference
		DECLARE @VoucherDetailNonInventory AS VoucherDetailNonInventory
		DECLARE @voucherPODetails AS VoucherPODetail
        DELETE FROM @VoucherDetailNonInventory
		DECLARE @intEntityVendorId as INT
		DECLARE @intShiptoId AS INT
		DECLARE @strInvoiceNumber as NVARCHAR(MAX)
		SELECT @intEntityVendorId = intEntityCustomerId,@intShiptoId = intCompanyLocationId,@strInvoiceNumber = strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId

        INSERT INTO @VoucherDetailNonInventory
            ([intAccountId]
            ,[intItemId]
            ,[strMiscDescription]
            ,[dblQtyReceived]
            ,[dblDiscount]
            ,[dblCost]
            ,[intTaxGroupId]
			,[intInvoiceId])
		SELECT
             [intAccountId]         = NULL
            ,[intItemId]            = NULL
            ,[strMiscDescription]   = 'Cash Refund'
            ,[dblQtyReceived]       = 1.000000
            ,[dblDiscount]          = @ZeroDecimal
            ,[dblCost]              = dblInvoiceTotal
            ,[intTaxGroupId]        = NULL
			,[intInvoiceId]         = intInvoiceId
		FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId
		/*END CREATE VOUCHER */
		/* POST VOUCHER */
		DECLARE @BillId as INT
		DECLARE @DateNow AS DATETIME = GETDATE()
        EXEC [dbo].[uspAPCreateBillData]
             @userId                = @userId
            ,@vendorId              = @intEntityVendorId
			,@voucherPODetails		= @voucherPODetails
            ,@type                  = 1
            ,@voucherNonInvDetails  = @VoucherDetailNonInventory
            ,@voucherDate           = @DateNow
			,@shipTo				= @intShiptoId
			,@vendorOrderNumber		= @strInvoiceNumber
			,@billId                = @BillId OUTPUT
		
		IF(ISNULL(@BillId,0) > 0)
		BEGIN
			DECLARE @strBillno as NVARCHAR(MAX)
			SET @strBillno = CAST(@BillId as NVARCHAR(MAX))
			EXEC [dbo].[uspAPPostBill]@post=1,@recap=0,@param=@strBillno,@userId=@userId

			UPDATE tblARInvoice
			SET ysnRefundProcessed = 1
			WHERE intInvoiceId in(SELECT intInvoiceId FROM @PostInvoiceData)

			SET @_ERR =  'Refund successfully processed!';
			IF LEN(ISNULL(@_ERR,'')) > 0
				BEGIN
					SELECT @_ERR
					GOTO InvalidDataPost
				END

		END
		/*END POST VOUCHER*/


		END TRY
		BEGIN CATCH
			SELECT @_ERR = ERROR_MESSAGE()
				IF LEN(ISNULL(@_ERR,'')) > 0
				BEGIN
					SELECT @_ERR
					GOTO InvalidDataPost
				END
		END CATCH
		
	END


/* END Refund Process */

InvalidDataPost:
INSERT INTO @InvalidInvoiceData([intInvoiceId],[strInvoiceNumber],[strTransactionType],[intInvoiceDetailId],[intItemId],[strBatchId],[strPostingError])
			SELECT
				 [intInvoiceId]			= I.[intInvoiceId]
				,[strInvoiceNumber]		= I.[strInvoiceNumber]		
				,[strTransactionType]	= I.[strTransactionType]
				,[intInvoiceDetailId]	= I.[intInvoiceDetailId] 
				,[intItemId]			= I.[intItemId] 
				,[strBatchId]			= I.[strBatchId]
				,[strPostingError]		= @_ERR
			FROM @PostInvoiceData I

			/* Get Invalid Data */
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
					SELECT TOP 1 @ErrorMessage = [strPostingError] FROM @InvalidInvoiceData
					RAISERROR(@ErrorMessage, 11, 1)							
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
						SELECT TOP 1 @ErrorMessage = [strPostingError] FROM @InvalidInvoiceData
						RAISERROR(@ErrorMessage, 11, 1)							
						GOTO Post_Exit
					END				
				GOTO Post_Exit	
			END

Do_Rollback:
	IF @raiseError = 0
		BEGIN
			IF LEN(ISNULL(@_ERR,'')) > 0
				BEGIN
					SET @ErrorMessage = ERROR_MESSAGE()
				END
			IF @InitTranCount = 0
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION
			ELSE
				IF (XACT_STATE()) <> 0
					ROLLBACK TRANSACTION @Savepoint
												
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARProcessRefund' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = 0
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint
			EXEC uspARInsertPostResult @batchIdUsed, 'Invoice',@ErrorMessage , @param								

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
		RAISERROR(@ErrorMessage, 11, 1)	
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;


	SELECT * FROM tblARPostResult Order BY intId DESC