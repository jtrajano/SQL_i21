CREATE PROCEDURE [dbo].[uspARProcessSplitOnInvoicePost]
     @PostDate DATETIME
    ,@UserId  INT
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON  

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF @InitTranCount = 0
	BEGIN TRANSACTION
ELSE
	SAVE TRANSACTION @Savepoint

BEGIN TRY

DECLARE @ForInsertion NVARCHAR(MAX)
DECLARE @ForDeletion NVARCHAR(MAX)

DECLARE @SplitInvoiceData [InvoicePostingTable]
INSERT INTO @SplitInvoiceData
SELECT
	 [intInvoiceId]
	,[strInvoiceNumber]
	,[strTransactionType]
	,[strType]
	,[dtmDate]
	,[dtmPostDate]
	,[dtmShipDate]
	,[intEntityCustomerId]
	,[strCustomerNumber]
	,[ysnCustomerActive]
	,[dblCustomerCreditLimit]
	,[intCompanyLocationId]
	,[strCompanyLocationName]
	,[intAccountId]
	,[intAPAccount]
	,[intFreightIncome]
	,[intDeferredRevenueAccountId]
	,[intUndepositedFundsId]
	,[intProfitCenter]
	,[intLocationSalesAccountId]
	,[intCurrencyId]
	,[dblAverageExchangeRate]
	,[intTermId]
	,[dblInvoiceTotal]
	,[dblBaseInvoiceTotal]
	,[dblShipping]
	,[dblBaseShipping]
	,[dblTax]
	,[dblBaseTax]
	,[dblAmountDue]
	,[dblBaseAmountDue]
	,[dblPayment]
	,[dblBasePayment]
	,[dblProvisionalAmount]
	,[dblBaseProvisionalAmount]
	,[strComments]
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
	,[ysnPosted]
	,[ysnRecurring]
	,[ysnImpactInventory]
	,[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]
	,[dtmDatePosted]
	,[strBatchId]
	,[ysnPost]
	,[ysnRecap]
	,[intEntityId]
	,[intUserId]
	,[ysnUserAllowedToPostOtherTrans]
	,[ysnWithinAccountingDate]
	,[ysnForApproval]
	,[ysnFromProvisional]
	,[ysnProvisionalWithGL]
	,[ysnExcludeInvoiceFromPayment]
	,[ysnRefundProcessed]
	,[ysnIsInvoicePositive]
	,[ysnFromReturn]

	,[intInvoiceDetailId]
	,[intItemId]
	,[strItemNo]
	,[strItemType]
	,[strItemManufactureType]
	,[strItemDescription]
	,[intItemUOMId]
	,[intItemWeightUOMId]
	,[intItemAccountId]
	,[intServiceChargeAccountId]
	,[intSalesAccountId]
	,[intCOGSAccountId]
	,[intInventoryAccountId]
	,[intLicenseAccountId]
	,[intMaintenanceAccountId]
	,[intConversionAccountId]
	,[dblQtyShipped]
	,[dblUnitQtyShipped]
	,[dblShipmentNetWt]
	,[dblUnitQty]
	,[dblUnitOnHand]
	,[intAllowNegativeInventory]
	,[ysnStockTracking]
	,[intItemLocationId]
	,[dblLastCost]
	,[intCategoryId]
	,[ysnRetailValuation]
	,[dblPrice]
	,[dblBasePrice]
	,[dblUnitPrice]
	,[dblBaseUnitPrice]
	,[strPricing]
	,[dblDiscount]
	,[dblDiscountAmount]
	,[dblBaseDiscountAmount]
	,[dblTotal]
	,[dblBaseTotal]
	,[dblLineItemGLAmount]
	,[dblBaseLineItemGLAmount]
	,[intCurrencyExchangeRateTypeId]
	,[dblCurrencyExchangeRate]
	,[strCurrencyExchangeRateType]
	,[intLotId]
	,[intOriginalInvoiceDetailId]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblLicenseAmount]
	,[dblBaseLicenseAmount]
	,[dblLicenseGLAmount]
	,[dblBaseLicenseGLAmount]
	,[dblMaintenanceAmount]
	,[dblBaseMaintenanceAmount]
	,[dblMaintenanceGLAmount]
	,[dblBaseMaintenanceGLAmount]
	,[dblTaxesAddToCost]
	,[dblBaseTaxesAddToCost]
	,[ysnTankRequired]
	,[ysnLeaseBilling]
	,[intSiteId]
	,[intPerformerId]
	,[intContractHeaderId]
	,[intContractDetailId]
	,[intInventoryShipmentItemId]
	,[intInventoryShipmentChargeId]
	,[intSalesOrderDetailId]
	,[intLoadDetailId]
	,[intShipmentId]
	,[intTicketId]
	,[intDiscountAccountId]
	,[intCustomerStorageId]
	,[intStorageScheduleTypeId]
	,[intSubLocationId]
	,[intStorageLocationId]
	,[ysnAutoBlend]
	,[ysnBlended]
	,[dblQuantity]
	,[dblMaxQuantity]
	,[strOptionType]
	,[strSourceType]
	,[strPostingMessage]
	,[strDescription]
FROM
    ##ARPostInvoiceHeader
WHERE
	[ysnSplitted] = 0
    AND ISNULL([intSplitId], 0) > 0
    AND [strTransactionType] IN ('Invoice', 'Cash', 'Debit Memo')

WHILE EXISTS(SELECT NULL FROM @SplitInvoiceData)
BEGIN
    DECLARE  @invoicesToAdd     NVARCHAR(MAX) = NULL
            ,@intSplitInvoiceId INT
            ,@Post              BIT
            ,@Recap             BIT
            ,@BatchId           NVARCHAR(40)
            ,@AccrueLicense     BIT

    SELECT TOP 1 
         @intSplitInvoiceId	= [intInvoiceId]
        ,@Post              = [ysnPost]
        ,@Recap             = [ysnRecap]
        ,@BatchId           = [strBatchId]          
        ,@AccrueLicense     = [ysnAccrueLicense]
    FROM
        @SplitInvoiceData
    ORDER BY
        [intInvoiceId]

    EXEC dbo.uspARProcessSplitInvoice @intSplitInvoiceId, @UserId, @invoicesToAdd OUT

    SELECT @ForDeletion = ISNULL(@ForDeletion, '') + ISNULL(CONVERT(NVARCHAR(20), @intSplitInvoiceId), '') + ','
	SELECT @ForInsertion = ISNULL(@ForInsertion, '') + ISNULL(CONVERT(NVARCHAR(20), @invoicesToAdd), '') + ','

	DECLARE @TempInvoiceIds AS [InvoiceId]
	DELETE FROM @TempInvoiceIds

	INSERT INTO @TempInvoiceIds
		([intHeaderId]
		,[ysnPost]
		,[ysnRecap]
		,[strBatchId]
		,[ysnAccrueLicense])
	SELECT
		[intHeaderId]   = ARI.[intInvoiceId]
		,[ysnPost]          = @Post
		,[ysnRecap]         = @Recap
		,[strBatchId]       = @BatchId
		,[ysnAccrueLicense]	= @AccrueLicense
	FROM
	tblARInvoice ARI
	WHERE
		ARI.intInvoiceId <> @intSplitInvoiceId
		AND EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@ForInsertion) DV WHERE DV.[intID] = ARI.[intInvoiceId])

	WHILE EXISTS(SELECT NULL FROM @TempInvoiceIds)
	BEGIN
		DECLARE @TempInvoiceId INT
		SELECT TOP 1 @TempInvoiceId = [intHeaderId] FROM @TempInvoiceIds
		EXEC dbo.[uspSOUpdateOrderShipmentStatus] @TempInvoiceId, 'Invoice', 1
		DELETE FROM @TempInvoiceIds WHERE [intHeaderId] = @TempInvoiceId
	END

	DELETE FROM @SplitInvoiceData WHERE intInvoiceId = @intSplitInvoiceId
END

IF (ISNULL(@ForDeletion, '') <> '')
	BEGIN
        DELETE FROM ##ARPostInvoiceHeader
        WHERE 
            [intInvoiceId] IN (SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@ForDeletion))
        DELETE FROM ##ARPostInvoiceDetail
        WHERE 
            [intInvoiceId] IN (SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@ForDeletion))
	END

IF (ISNULL(@ForInsertion, '') <> '')
	BEGIN
		DECLARE @InvoiceIds AS [InvoiceId]
        DELETE FROM @InvoiceIds

        INSERT INTO @InvoiceIds
            ([intHeaderId]
            ,[ysnPost]
            ,[ysnRecap]
            ,[strBatchId]
            ,[ysnAccrueLicense])
        SELECT
             [intHeaderId]   = ARI.[intInvoiceId]
            ,[ysnPost]          = @Post
            ,[ysnRecap]         = @Recap
            ,[strBatchId]       = @BatchId
            ,[ysnAccrueLicense]	= @AccrueLicense
        FROM
            tblARInvoice ARI
        WHERE
            EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@ForInsertion) DV WHERE DV.[intID] = ARI.[intInvoiceId])
            AND NOT EXISTS(SELECT NULL FROM ##ARPostInvoiceHeader PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])

		EXEC [dbo].[uspARPopulateInvoiceDetailForPosting]
			 @Param             = NULL
			,@BeginDate         = NULL
			,@EndDate           = NULL
			,@BeginTransaction  = NULL
			,@EndTransaction    = NULL
			,@IntegrationLogId  = NULL
			,@InvoiceIds        = @InvoiceIds
			,@Post              = @Post
			,@Recap             = @Recap
			,@PostDate          = @PostDate
			,@BatchId           = @BatchId
			,@AccrueLicense     = 0
			,@TransType         = NULL
			,@UserId            = @UserId	
	END

END TRY
BEGIN CATCH
    DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
    IF @InitTranCount = 0
        IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
	ELSE
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION @Savepoint
												
	RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH


IF @InitTranCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION
		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION
		RETURN 1;
	END	


Post_Exit:
	RETURN 0;