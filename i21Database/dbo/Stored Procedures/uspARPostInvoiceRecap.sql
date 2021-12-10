CREATE PROCEDURE [dbo].[uspARPostInvoiceRecap]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@BatchId           NVARCHAR(40)
    ,@PostDate          DATETIME                
    ,@UserId            INT
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

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

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '


DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000

DECLARE @ErrorMerssage NVARCHAR(MAX)
DECLARE @DelimitedIds VARCHAR(MAX)


BEGIN TRY

    DECLARE @StartingNumberId INT
    SET @StartingNumberId = 3
    IF(LEN(RTRIM(LTRIM(ISNULL(@BatchId,'')))) = 0)
    BEGIN
        EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @BatchId OUT
    END

	SET @BatchIdUsed = @BatchId

	EXEC [dbo].[uspARPostItemResevation]

	IF @Post = 1
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
			@PostDate        = @PostDate
		   ,@UserId          = @UserId

	IF @Post = 1
    EXEC [dbo].[uspARPrePostInvoiceIntegration]

	IF @Post = 1
    EXEC dbo.[uspARUpdateTransactionAccountOnPost]  
    	
	--IF @Post = 1
	--EXEC dbo.uspARGenerateEntriesForAccrual  

    EXEC [dbo].[uspARGenerateGLEntries]
         @Post     = @Post
	    ,@Recap    = @Recap
        ,@PostDate = @PostDate
        ,@BatchId  = @BatchId
        ,@UserId   = @UserId

DECLARE @Invoice [InvoicePostingTable]
INSERT @Invoice
    ([intInvoiceId]
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
    ,[ysnIsInvoicePositive]

    ,[intInvoiceDetailId]
    ,[intItemId]
    ,[strItemNo]
    ,[strItemType]
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
    ,[strDescription])
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
    ,[ysnIsInvoicePositive]

    ,[intInvoiceDetailId]
    ,[intItemId]
    ,[strItemNo]
    ,[strItemType]
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

DECLARE @GLEntries RecapTableType
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
	,[strRateType]
	,[strDocument]
	,[strComments]
	,[strSourceDocumentId]
	,[intSourceLocationId]
	,[intSourceUOMId]
	,[dblSourceUnitDebit]
	,[dblSourceUnitCredit]
	,[intCommodityId]
	,[intSourceEntityId]
	,[ysnRebuild])
SELECT
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
	,[strDocument]
	,[strComments]
	,[strSourceDocumentId]
	,[intSourceLocationId]
	,[intSourceUOMId]
	,[dblSourceUnitDebit]
	,[dblSourceUnitCredit]
	,[intCommodityId]
	,[intSourceEntityId]
	,[ysnRebuild]
FROM
    ##ARInvoiceGLEntries

END TRY
BEGIN CATCH
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
	ROLLBACK TRANSACTION
ELSE
	ROLLBACK TRANSACTION @Savepoint


DECLARE @DefaultCurrencyId                  INT
        ,@DefaultCurrencyExchangeRateTypeId INT

SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 intAccountsReceivableRateTypeId FROM tblSMMultiCurrency)


BEGIN TRY	

    DELETE FROM tblGLPostRecap WHERE [strBatchId] = @BatchId
	
		 
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
		,[dblDebitForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN @ZeroDecimal ELSE A.[dblDebitForeign] END
		,[dblCreditForeign]					= CASE WHEN A.[intCurrencyId] = @DefaultCurrencyId THEN @ZeroDecimal ELSE A.[dblCreditForeign]	 END 		
		,A.[intCurrencyId]
		,A.[dtmDate]
		,A.[ysnIsUnposted]
		,A.[intConcurrencyId]	
		,[dblExchangeRate]					= ISNULL(RATETYPE.dblCurrencyExchangeRate, @OneDecimal)
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
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, @ZeroDecimal) - ISNULL(A.dblCredit, @ZeroDecimal)) Credit
	CROSS APPLY dbo.fnGetDebitUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) DebitUnit
	CROSS APPLY dbo.fnGetCreditUnit(ISNULL(A.dblDebitUnit, @ZeroDecimal) - ISNULL(A.dblCreditUnit, @ZeroDecimal)) CreditUnit
	OUTER APPLY (
		SELECT SMCERT.strCurrencyExchangeRateType,dblBaseInvoiceTotal,dblInvoiceTotal,dblCurrencyExchangeRate
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
				

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()
	RAISERROR(@ErrorMerssage, 11, 1)
END CATCH

RETURN 1;

Post_Exit:
	RETURN 0;
