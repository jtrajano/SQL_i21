CREATE PROCEDURE [dbo].[uspARPostInvoiceRecap]
     @Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@BatchId           NVARCHAR(40)
    ,@PostDate          DATETIME                
    ,@UserId            INT
	,@BatchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@raiseError		AS BIT				= 0
	,@IntegrationLogId	AS INT				= NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

--SET @InitTranCount = @@TRANCOUNT
--SET @Savepoint = SUBSTRING(('uspARPostInvoiceRecap' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000

DECLARE @ZeroBit BIT
SET @ZeroBit = CAST(0 AS BIT)
DECLARE @OneBit BIT
SET @OneBit = CAST(1 AS BIT)

DECLARE @ErrorMerssage NVARCHAR(MAX)

--DECLARE  @totalRecords INT = 0
--		,@totalInvalid INT = 0
DECLARE @DelimitedIds VARCHAR(MAX)

--IF ISNULL(@raiseError,0) = 0	
--BEGIN
--	IF @InitTranCount = 0
--		BEGIN TRANSACTION 
--	ELSE
--		SAVE TRANSACTION @Savepoint
--END

DECLARE @TransactionName AS VARCHAR(500) = 'Invoice Transaction' + CAST(NEWID() AS NVARCHAR(100));
IF @@TRANCOUNT = 0
	BEGIN TRANSACTION @TransactionName
ELSE	 
	SAVE TRAN @TransactionName

BEGIN TRY

    DECLARE @StartingNumberId INT
    SET @StartingNumberId = 3
    IF(LEN(RTRIM(LTRIM(ISNULL(@BatchId,'')))) = 0)
    BEGIN
        EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @BatchId OUT
    END

	SET @BatchIdUsed = @BatchId

	IF @Post = @OneBit
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
			@PostDate        = @PostDate
		   ,@UserId          = @UserId

	IF @Post = @OneBit
    EXEC [dbo].[uspARPrePostInvoiceIntegration]

	IF @Post = @OneBit
    EXEC dbo.[uspARUpdateTransactionAccountOnPost]  

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = @ZeroBit
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
            
			SET @DelimitedIds = ''
			SELECT
				@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
			FROM
				#ARPostInvoiceHeader
			WHERE
				[ysnRecap] = @OneBit
									
			EXEC dbo.uspARInsertPostResult @BatchId, 'Invoice', @ErrorMerssage, @DelimitedIds

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
	IF @raiseError = @OneBit
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

BEGIN TRY
    IF(OBJECT_ID('tempdb..#ARInvoiceGLEntries') IS NOT NULL)
    BEGIN
        DROP TABLE #ARInvoiceGLEntries
    END

	CREATE TABLE #ARInvoiceGLEntries
	([dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId]          INT              DEFAULT 1 NOT NULL,
	[dblDebitForeign]			NUMERIC (18, 9) NULL,
	[dblDebitReport]			NUMERIC (18, 9) NULL,
	[dblCreditForeign]			NUMERIC (18, 9) NULL,
	[dblCreditReport]			NUMERIC (18, 9) NULL,
	[dblReportingRate]			NUMERIC (18, 9) NULL,
	[dblForeignRate]			NUMERIC (18, 9) NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[strRateType]			    NVARCHAR(50)	COLLATE Latin1_General_CI_AS,
	[strDocument]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strComments]               NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL,
	[strSourceDocumentId] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intSourceLocationId]		INT NULL,
	[intSourceUOMId]			INT NULL,
	[dblSourceUnitDebit]		NUMERIC (18, 6)  NULL,
	[dblSourceUnitCredit]		NUMERIC (18, 6)  NULL,
	[intCommodityId]			INT NULL,
	intSourceEntityId INT NULL,
	ysnRebuild BIT NULL)
	
	IF @Post = @OneBit
	EXEC dbo.uspARGenerateEntriesForAccrual  

    EXEC [dbo].[uspARGenerateGLEntries]
         @Post     = @Post
	    ,@Recap    = @Recap
        ,@PostDate = @PostDate
        ,@BatchId  = @BatchId
        ,@UserId   = @UserId

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = @ZeroBit
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

			SET @DelimitedIds = ''
			SELECT
				@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
			FROM
				#ARPostInvoiceHeader
			WHERE
				[ysnRecap] = @OneBit
									
			EXEC dbo.uspARInsertPostResult @BatchId, 'Invoice', @ErrorMerssage, @DelimitedIds
									
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
	IF @raiseError = @OneBit
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

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
    #ARPostInvoiceHeader

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
    #ARInvoiceGLEntries

DECLARE @DefaultCurrencyId                  INT
        ,@DefaultCurrencyExchangeRateTypeId INT

SET @DefaultCurrencyId = (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
SET @DefaultCurrencyExchangeRateTypeId = (SELECT TOP 1 intAccountsReceivableRateTypeId FROM tblSMMultiCurrency)

ROLLBACK TRAN @TransactionName		

BEGIN TRY	

    DELETE FROM tblGLPostRecap WHERE [strBatchId] = @BatchId

	--DELETE GLPR  
	--FROM
	--	tblGLPostRecap GLPR
	--INNER JOIN
	--	@Invoice I
	--		ON GLPR.[intTransactionId] = I.[intInvoiceId]
	--		AND GLPR.[strTransactionId] = I.[strInvoiceNumber]		   	
		 
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

	IF @IntegrationLogId IS NOT NULL
    UPDATE ILD
    SET
        ILD.[ysnPosted]                 = CASE WHEN ILD.[ysnPost] = @OneBit THEN 0 ELSE ILD.[ysnPosted] END
        ,ILD.[ysnUnPosted]              = CASE WHEN ILD.[ysnPost] = @OneBit THEN ILD.[ysnUnPosted] ELSE 0 END
        ,ILD.[strPostingMessage]        = CASE WHEN ILD.[ysnPost] = 1 THEN 'Recap - Transaction successfully posted.' ELSE 'Recap - Transaction successfully unposted.' END
        ,ILD.[strBatchId]               = PID.[strBatchId]
        ,ILD.[strPostedTransactionId]   = PID.[strInvoiceNumber] 
    FROM
        tblARInvoiceIntegrationLogDetail ILD
    INNER JOIN
        @Invoice PID
            ON ILD.[intInvoiceId] = PID.[intInvoiceId]
    WHERE
        ILD.[intIntegrationLogId] = @IntegrationLogId
        AND ILD.[ysnPost] IS NOT NULL
        AND ILD.[ysnRecap] = @OneBit

    UPDATE ARIL
    SET
         [strBatchIdForNewPost] = NIP.[strBatchId]
        ,[intPostedNewCount] = ISNULL(NIP.[intRecordTotal], 0)
        ,[strBatchIdForNewPostRecap] = NIPR.[strBatchId]
        ,[intRecapNewCount] = ISNULL(NIPR.[intRecordTotal], 0)
        ,[strBatchIdForExistingPost] = EIP.[strBatchId]
        ,[intPostedExistingCount] = ISNULL(EIP.[intRecordTotal], 0)
        ,[strBatchIdForExistingRecap] = EIPR.[strBatchId]
        ,[intRecapPostExistingCount] = ISNULL(EIPR.[intRecordTotal], 0)
        ,[strBatchIdForExistingUnPost] = EIU.[strBatchId]
        ,[intUnPostedExistingCount] = ISNULL(EIU.[intRecordTotal], 0)
        ,[strBatchIdForExistingUnPostRecap] = EIUR.[strBatchId]
        ,[intRecapUnPostedExistingCount] = ISNULL(EIUR.[intRecordTotal], 0)
    FROM
        tblARInvoiceIntegrationLog ARIL
    LEFT JOIN
        (
        SELECT
             [intIntegrationLogId]	= [intIntegrationLogId]
            ,[intRecordTotal]       = COUNT([intIntegrationLogDetailId])
            ,[strBatchId]           = MIN(strBatchId)
        FROM
            tblARInvoiceIntegrationLogDetail
        WHERE
            [intIntegrationLogId] = @IntegrationLogId
            AND [ysnHeader] = 1
            AND [ysnInsert] = 1
            AND [ysnRecap] = 0
            AND [ysnPost] = 1
            AND [ysnPosted] = 1
        GROUP BY
            [intIntegrationLogId]
        ) NIP
            ON ARIL.[intIntegrationLogId] = NIP.[intIntegrationLogId]
    LEFT JOIN
        (
        SELECT
             [intIntegrationLogId]	= [intIntegrationLogId]
            ,[intRecordTotal]       = COUNT([intIntegrationLogDetailId])
            ,[strBatchId]           = MIN(strBatchId)
        FROM
            tblARInvoiceIntegrationLogDetail
        WHERE
            [intIntegrationLogId] = @IntegrationLogId
            AND [ysnHeader] = 1
            AND [ysnInsert] = 1
            AND [ysnRecap] = 1
            AND [ysnPost] = 1
        GROUP BY
            [intIntegrationLogId]
        ) NIPR
            ON ARIL.[intIntegrationLogId] = NIPR.[intIntegrationLogId]
    LEFT JOIN
        (
        SELECT
             [intIntegrationLogId]	= [intIntegrationLogId]
            ,[intRecordTotal]       = COUNT([intIntegrationLogDetailId])
            ,[strBatchId]           = MIN(strBatchId)
        FROM
            tblARInvoiceIntegrationLogDetail
        WHERE
            [intIntegrationLogId] = @IntegrationLogId
            AND [ysnHeader] = 1
            AND [ysnInsert] = 0
            AND [ysnRecap] = 0
            AND [ysnPost] = 1
            AND [ysnPosted] = 1
        GROUP BY
            [intIntegrationLogId]
        ) EIP
            ON ARIL.[intIntegrationLogId] = EIP.[intIntegrationLogId]
    LEFT JOIN
        (
        SELECT
             [intIntegrationLogId]	= [intIntegrationLogId]
            ,[intRecordTotal]       = COUNT([intIntegrationLogDetailId])
            ,[strBatchId]           = MIN(strBatchId)
        FROM
            tblARInvoiceIntegrationLogDetail
        WHERE
            [intIntegrationLogId] = @IntegrationLogId
            AND [ysnHeader] = 1
            AND [ysnInsert] = 0
            AND [ysnRecap] = 1
            AND [ysnPost] = 1
        GROUP BY
            [intIntegrationLogId]
        ) EIPR
            ON ARIL.[intIntegrationLogId] = EIPR.[intIntegrationLogId]
    LEFT JOIN
        (
        SELECT
             [intIntegrationLogId]	= [intIntegrationLogId]
            ,[intRecordTotal]       = COUNT([intIntegrationLogDetailId])
            ,[strBatchId]           = MIN(strBatchId)
        FROM
            tblARInvoiceIntegrationLogDetail
        WHERE
            [intIntegrationLogId] = @IntegrationLogId
            AND [ysnHeader] = 1
            AND [ysnInsert] = 0
            AND [ysnRecap] = 0
            AND [ysnPost] = 0
            AND [ysnUnPosted] = 1
        GROUP BY
            [intIntegrationLogId]
        ) EIU
            ON ARIL.[intIntegrationLogId] = EIU.[intIntegrationLogId]
    LEFT JOIN
        (
        SELECT
             [intIntegrationLogId]	= [intIntegrationLogId]
            ,[intRecordTotal]       = COUNT([intIntegrationLogDetailId])
            ,[strBatchId]           = MIN(strBatchId)
        FROM
            tblARInvoiceIntegrationLogDetail
        WHERE
            [intIntegrationLogId] = @IntegrationLogId
            AND [ysnHeader] = 1
            AND [ysnInsert] = 0
            AND [ysnRecap] = 1
            AND [ysnPost] = 0
        GROUP BY
            [intIntegrationLogId]
        ) EIUR
            ON ARIL.[intIntegrationLogId] = EIUR.[intIntegrationLogId]
    WHERE
        ARIL.[intIntegrationLogId] = @IntegrationLogId

END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()
	IF @raiseError = @ZeroBit
		BEGIN
			SET @CurrentTranCount = @@TRANCOUNT
			SET @CurrentSavepoint = SUBSTRING(('uspARPostInvoiceNew' + CONVERT(VARCHAR, @CurrentTranCount)), 1, 32)										
			
			IF @CurrentTranCount = @ZeroBit
				BEGIN TRANSACTION
			ELSE
				SAVE TRANSACTION @CurrentSavepoint

	SET @DelimitedIds = ''
	SELECT
		@DelimitedIds = COALESCE(@DelimitedIds + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250))
	FROM
		#ARPostInvoiceHeader
	WHERE
		[ysnRecap] = @OneBit

			EXEC dbo.uspARInsertPostResult @BatchId, 'Invoice', @ErrorMerssage, @DelimitedIds		
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
	IF @raiseError = @OneBit
		RAISERROR(@ErrorMerssage, 11, 1)
	GOTO Post_Exit
END CATCH

	RETURN 1;

Post_Exit:
	RETURN 0;
