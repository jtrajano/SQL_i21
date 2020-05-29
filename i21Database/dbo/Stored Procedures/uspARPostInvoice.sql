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

 WITH RECOMPILE
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   

DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'
DECLARE @POSTDESC NVARCHAR(10) = 'Posted '

DECLARE @PostDate AS DATETIME
SET @PostDate = GETDATE()

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000
DECLARE @OneHundredDecimal DECIMAL(18,6)
SET @OneHundredDecimal = 100.000000

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

DECLARE  @totalRecords INT = 0
		,@totalInvalid INT = 0
 
SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@raiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

DECLARE @ErrorMerssage NVARCHAR(MAX)

SET @recapId = '1'
SET @success = 1

-- Ensure @post and @recap is not NULL  
SET @post = ISNULL(@post, 0)
SET @recap = ISNULL(@recap, 0)
SET @accrueLicense = ISNULL(@accrueLicense, 0)

DECLARE @StartingNumberId INT
SET @StartingNumberId = 3
IF(LEN(RTRIM(LTRIM(ISNULL(@batchId,'')))) = 0) AND @recap = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber @StartingNumberId, @batchId OUT
END
SET @batchIdUsed = @batchId
 
-- Get Transaction to Post
IF (@transType IS NULL OR RTRIM(LTRIM(@transType)) = '')
	SET @transType = 'all'

DECLARE @InvoiceIds AS [InvoiceId]
IF(OBJECT_ID('tempdb..#ARPostInvoiceHeader') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostInvoiceHeader
END

CREATE TABLE #ARPostInvoiceHeader
    ([intInvoiceId]                         INT             NOT NULL PRIMARY KEY
    ,[strInvoiceNumber]                     NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL UNIQUE NONCLUSTERED
    ,[strTransactionType]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strType]                              NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[dtmDate]                              DATETIME        NOT NULL
    ,[dtmPostDate]                          DATETIME        NULL
    ,[dtmShipDate]                          DATETIME        NULL
    ,[intEntityCustomerId]                  INT             NULL
    ,[strCustomerNumber]                    NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnCustomerActive]                    BIT             NULL
    ,[dblCustomerCreditLimit]               NUMERIC(18,6)   NULL
    ,[intCompanyLocationId]                 INT             NULL
    ,[strCompanyLocationName]               NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[intAccountId]                         INT             NULL
    ,[intAPAccount]                         INT             NULL
    ,[intFreightIncome]                     INT             NULL
    ,[intDeferredRevenueAccountId]          INT             NULL
    ,[intUndepositedFundsId]                INT             NULL
    ,[intProfitCenter]                      INT             NULL
    ,[intLocationSalesAccountId]            INT             NULL
    ,[intCurrencyId]                        INT             NULL
    ,[dblAverageExchangeRate]               NUMERIC(18,6)   NULL
    ,[intTermId]                            INT             NULL
    ,[dblInvoiceTotal]                      NUMERIC(18,6)   NULL
    ,[dblBaseInvoiceTotal]                  NUMERIC(18,6)   NULL
    ,[dblShipping]                          NUMERIC(18,6)   NULL
    ,[dblBaseShipping]                      NUMERIC(18,6)   NULL
    ,[dblTax]                               NUMERIC(18,6)   NULL
    ,[dblBaseTax]                           NUMERIC(18,6)   NULL
    ,[dblAmountDue]                         NUMERIC(18,6)   NULL
    ,[dblBaseAmountDue]                     NUMERIC(18,6)   NULL
    ,[dblPayment]                           NUMERIC(18,6)   NULL
    ,[dblBasePayment]                       NUMERIC(18,6)   NULL
    ,[dblProvisionalAmount]                 NUMERIC(18,6)   NULL
    ,[dblBaseProvisionalAmount]             NUMERIC(18,6)   NULL
    ,[strComments]                          NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
    ,[strImportFormat]                      NVARCHAR(50)    NULL
    ,[intSourceId]                          INT             NULL
    ,[intOriginalInvoiceId]                 INT             NULL
    ,[strInvoiceOriginId]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[intDistributionHeaderId]              INT             NULL
    ,[intLoadDistributionHeaderId]          INT             NULL
    ,[intLoadId]                            INT             NULL
    ,[intFreightTermId]                     INT             NULL
    ,[strActualCostId]                      NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL	
    ,[intPeriodsToAccrue]                   INT             NULL
    ,[ysnAccrueLicense]                     BIT             NULL
    ,[intSplitId]                           INT             NULL
    ,[dblSplitPercent]                      NUMERIC(18,6)   NULL	
    ,[ysnSplitted]                          BIT             NULL
    ,[ysnPosted]                            BIT             NULL	
    ,[ysnRecurring]                         BIT             NULL	
    ,[ysnImpactInventory]                   BIT             NULL	
	,[ysnImportedAsPosted]                  BIT             NULL	
	,[ysnImportedFromOrigin]                BIT             NULL
    ,[dtmDatePosted]                        DATETIME        NULL
    ,[strBatchId]                           NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnPost]                              BIT             NULL
    ,[ysnRecap]                             BIT             NULL
    ,[intEntityId]                          INT             NOT NULL
    ,[intUserId]                            INT             NOT NULL
    ,[ysnUserAllowedToPostOtherTrans]       BIT             NULL
    ,[ysnWithinAccountingDate]              BIT             NULL
    ,[ysnForApproval]                       BIT             NULL
    ,[ysnFromProvisional]                   BIT             NULL
    ,[ysnProvisionalWithGL]                 BIT             NULL
    ,[ysnExcludeInvoiceFromPayment]         BIT             NULL
    ,[ysnRefundProcessed]                   BIT             NULL
    ,[ysnIsInvoicePositive]                 BIT             NULL

    ,[intInvoiceDetailId]                   INT             NULL
    ,[intItemId]                            INT             NULL
    ,[strItemNo]                            NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemType]                          NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemDescription]                   NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[intItemUOMId]                         INT             NULL
    ,[intItemWeightUOMId]                   INT             NULL
    ,[intItemAccountId]                     INT             NULL
    ,[intServiceChargeAccountId]            INT             NULL
    ,[intSalesAccountId]                    INT             NULL
    ,[intCOGSAccountId]                     INT             NULL
    ,[intInventoryAccountId]                INT             NULL
    ,[intLicenseAccountId]                  INT             NULL
    ,[intMaintenanceAccountId]              INT             NULL
    ,[intConversionAccountId]               INT             NULL
    ,[dblQtyShipped]                        NUMERIC(38,20)  NULL	
    ,[dblUnitQtyShipped]                    NUMERIC(38,20)  NULL
    ,[dblShipmentNetWt]                     NUMERIC(38,20)  NULL	
    ,[dblUnitQty]                           NUMERIC(38,20)  NULL
    ,[dblUnitOnHand]                        NUMERIC(38,20)  NULL
    ,[intAllowNegativeInventory]            INT             NULL
    ,[ysnStockTracking]                     BIT             NULL
    ,[intItemLocationId]                    INT             NULL
    ,[dblLastCost]                          NUMERIC(38,20)  NULL
    ,[intCategoryId]                        INT             NULL
    ,[ysnRetailValuation]                   BIT             NULL
    ,[dblPrice]                             NUMERIC(18,6)   NULL
    ,[dblBasePrice]                         NUMERIC(18,6)   NULL
	,[dblUnitPrice]                         NUMERIC(18,6)   NULL
    ,[dblBaseUnitPrice]                     NUMERIC(18,6)   NULL
    ,[strPricing]                           NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[dblDiscount]                          NUMERIC(18,6)   NULL
    ,[dblDiscountAmount]                    NUMERIC(18,6)   NULL
    ,[dblBaseDiscountAmount]                NUMERIC(18,6)   NULL
    ,[dblTotal]                             NUMERIC(18,6)   NULL
    ,[dblBaseTotal]                         NUMERIC(18,6)   NULL
    ,[dblLineItemGLAmount]                  NUMERIC(18,6)   NULL
    ,[dblBaseLineItemGLAmount]              NUMERIC(18,6)   NULL
    ,[intCurrencyExchangeRateTypeId]        INT             NULL
    ,[dblCurrencyExchangeRate]              NUMERIC(18,6)   NULL
    ,[strCurrencyExchangeRateType]          NVARCHAR(20)    COLLATE Latin1_General_CI_AS    NULL
    ,[intLotId]                             INT             NULL
    ,[intOriginalInvoiceDetailId]           INT             NULL
    ,[strMaintenanceType]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strFrequency]                         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[dtmMaintenanceDate]                   DATETIME        NULL
    ,[dblLicenseAmount]                     NUMERIC(18,6)   NULL
    ,[dblBaseLicenseAmount]                 NUMERIC(18,6)   NULL
    ,[dblLicenseGLAmount]                   NUMERIC(18,6)   NULL
    ,[dblBaseLicenseGLAmount]               NUMERIC(18,6)   NULL
    ,[dblMaintenanceAmount]                 NUMERIC(18,6)   NULL
    ,[dblBaseMaintenanceAmount]             NUMERIC(18,6)   NULL
    ,[dblMaintenanceGLAmount]               NUMERIC(18,6)   NULL
    ,[dblBaseMaintenanceGLAmount]           NUMERIC(18,6)   NULL
	,[dblTaxesAddToCost]					NUMERIC(18,6)   NULL
	,[dblBaseTaxesAddToCost]				NUMERIC(18,6)   NULL
    ,[ysnTankRequired]                      BIT             NULL
    ,[ysnLeaseBilling]                      BIT             NULL
    ,[intSiteId]                            INT             NULL
    ,[intPerformerId]                       INT             NULL
    ,[intContractHeaderId]                  INT             NULL
    ,[intContractDetailId]                  INT             NULL
    ,[intInventoryShipmentItemId]           INT             NULL
    ,[intInventoryShipmentChargeId]         INT             NULL
    ,[intSalesOrderDetailId]                INT             NULL
    ,[intLoadDetailId]                      INT             NULL
    ,[intShipmentId]                        INT             NULL
    ,[intTicketId]                          INT             NULL
    ,[intDiscountAccountId]                 INT             NULL	
    ,[intCustomerStorageId]                 INT             NULL
    ,[intStorageScheduleTypeId]             INT             NULL
    ,[intSubLocationId]                     INT             NULL
    ,[intStorageLocationId]                 INT             NULL
    ,[ysnAutoBlend]                         BIT             NULL
    ,[ysnBlended]                           BIT             NULL    
    ,[dblQuantity]                          NUMERIC(18,6)   NULL
    ,[dblMaxQuantity]                       NUMERIC(18,6)   NULL	
    ,[strOptionType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strSourceType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strPostingMessage]                    NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
    ,[strDescription]                       NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL)

IF(OBJECT_ID('tempdb..#ARPostInvoiceDetail') IS NOT NULL)
BEGIN
    DROP TABLE #ARPostInvoiceDetail
END

CREATE TABLE #ARPostInvoiceDetail
    ([intInvoiceId]                         INT             NOT NULL
    ,[strInvoiceNumber]                     NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strTransactionType]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strType]                              NVARCHAR(100)   COLLATE Latin1_General_CI_AS    NULL
    ,[dtmDate]                              DATETIME        NOT NULL
    ,[dtmPostDate]                          DATETIME        NULL
    ,[dtmShipDate]                          DATETIME        NULL
    ,[intEntityCustomerId]                  INT             NULL
    ,[strCustomerNumber]                    NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnCustomerActive]                    BIT             NULL
    ,[dblCustomerCreditLimit]               NUMERIC(18,6)   NULL
    ,[intCompanyLocationId]                 INT             NULL
    ,[strCompanyLocationName]               NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[intAccountId]                         INT             NULL
    ,[intAPAccount]                         INT             NULL
    ,[intFreightIncome]                     INT             NULL
    ,[intDeferredRevenueAccountId]          INT             NULL
    ,[intUndepositedFundsId]                INT             NULL
    ,[intProfitCenter]                      INT             NULL
    ,[intLocationSalesAccountId]            INT             NULL
    ,[intCurrencyId]                        INT             NULL
    ,[dblAverageExchangeRate]               NUMERIC(18,6)   NULL
    ,[intTermId]                            INT             NULL
    ,[dblInvoiceTotal]                      NUMERIC(18,6)   NULL
    ,[dblBaseInvoiceTotal]                  NUMERIC(18,6)   NULL
    ,[dblShipping]                          NUMERIC(18,6)   NULL
    ,[dblBaseShipping]                      NUMERIC(18,6)   NULL
    ,[dblTax]                               NUMERIC(18,6)   NULL
    ,[dblBaseTax]                           NUMERIC(18,6)   NULL
    ,[dblAmountDue]                         NUMERIC(18,6)   NULL
    ,[dblBaseAmountDue]                     NUMERIC(18,6)   NULL
    ,[dblPayment]                           NUMERIC(18,6)   NULL
    ,[dblBasePayment]                       NUMERIC(18,6)   NULL
    ,[dblProvisionalAmount]                 NUMERIC(18,6)   NULL
    ,[dblBaseProvisionalAmount]             NUMERIC(18,6)   NULL
    ,[strComments]                          NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
    ,[strImportFormat]                      NVARCHAR(50)    NULL
    ,[intSourceId]                          INT             NULL
    ,[intOriginalInvoiceId]                 INT             NULL
    ,[strInvoiceOriginId]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[intDistributionHeaderId]              INT             NULL
    ,[intLoadDistributionHeaderId]          INT             NULL
    ,[intLoadId]                            INT             NULL
    ,[intFreightTermId]                     INT             NULL
    ,[strActualCostId]                      NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL	
    ,[intPeriodsToAccrue]                   INT             NULL
    ,[ysnAccrueLicense]                     BIT             NULL
    ,[intSplitId]                           INT             NULL
    ,[dblSplitPercent]                      NUMERIC(18,6)   NULL	
    ,[ysnSplitted]                          BIT             NULL
    ,[ysnPosted]                            BIT             NULL	
    ,[ysnRecurring]                         BIT             NULL	
    ,[ysnImpactInventory]                   BIT             NULL	
	,[ysnImportedAsPosted]                  BIT             NULL	
	,[ysnImportedFromOrigin]                BIT             NULL
    ,[dtmDatePosted]                        DATETIME        NULL
    ,[strBatchId]                           NVARCHAR(40)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnPost]                              BIT             NULL
    ,[ysnRecap]                             BIT             NULL
    ,[intEntityId]                          INT             NOT NULL
    ,[intUserId]                            INT             NOT NULL
    ,[ysnUserAllowedToPostOtherTrans]       BIT             NULL
    ,[ysnWithinAccountingDate]              BIT             NULL
    ,[ysnForApproval]                       BIT             NULL
    ,[ysnFromProvisional]                   BIT             NULL
    ,[ysnProvisionalWithGL]                 BIT             NULL
    ,[ysnExcludeInvoiceFromPayment]         BIT             NULL
    ,[ysnRefundProcessed]                   BIT             NULL
    ,[ysnIsInvoicePositive]                 BIT             NULL

    ,[intInvoiceDetailId]                   INT             NOT NULL PRIMARY KEY
    ,[intItemId]                            INT             NULL
    ,[strItemNo]                            NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemType]                          NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemDescription]                   NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[intItemUOMId]                         INT             NULL
    ,[intItemWeightUOMId]                   INT             NULL
    ,[intItemAccountId]                     INT             NULL
    ,[intServiceChargeAccountId]            INT             NULL
    ,[intSalesAccountId]                    INT             NULL
    ,[intCOGSAccountId]                     INT             NULL
    ,[intInventoryAccountId]                INT             NULL
    ,[intLicenseAccountId]                  INT             NULL
    ,[intMaintenanceAccountId]              INT             NULL
    ,[intConversionAccountId]               INT             NULL
    ,[dblQtyShipped]                        NUMERIC(38,20)  NULL	
    ,[dblUnitQtyShipped]                    NUMERIC(38,20)  NULL
    ,[dblShipmentNetWt]                     NUMERIC(38,20)  NULL	
    ,[dblUnitQty]                           NUMERIC(38,20)  NULL
    ,[dblUnitOnHand]                        NUMERIC(38,20)  NULL
    ,[intAllowNegativeInventory]            INT             NULL
    ,[ysnStockTracking]                     BIT             NULL
    ,[intItemLocationId]                    INT             NULL
    ,[dblLastCost]                          NUMERIC(38,20)  NULL
    ,[intCategoryId]                        INT             NULL
    ,[ysnRetailValuation]                   BIT             NULL
    ,[dblPrice]                             NUMERIC(18,6)   NULL
    ,[dblBasePrice]                         NUMERIC(18,6)   NULL
	,[dblUnitPrice]                         NUMERIC(18,6)   NULL
    ,[dblBaseUnitPrice]                     NUMERIC(18,6)   NULL
    ,[strPricing]                           NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[dblDiscount]                          NUMERIC(18,6)   NULL
    ,[dblDiscountAmount]                    NUMERIC(18,6)   NULL
    ,[dblBaseDiscountAmount]                NUMERIC(18,6)   NULL
    ,[dblTotal]                             NUMERIC(18,6)   NULL
    ,[dblBaseTotal]                         NUMERIC(18,6)   NULL
    ,[dblLineItemGLAmount]                  NUMERIC(18,6)   NULL
    ,[dblBaseLineItemGLAmount]              NUMERIC(18,6)   NULL
    ,[intCurrencyExchangeRateTypeId]        INT             NULL
    ,[dblCurrencyExchangeRate]              NUMERIC(18,6)   NULL
    ,[strCurrencyExchangeRateType]          NVARCHAR(20)    COLLATE Latin1_General_CI_AS    NULL
    ,[intLotId]                             INT             NULL
    ,[intOriginalInvoiceDetailId]           INT             NULL
    ,[strMaintenanceType]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strFrequency]                         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[dtmMaintenanceDate]                   DATETIME        NULL
    ,[dblLicenseAmount]                     NUMERIC(18,6)   NULL
    ,[dblBaseLicenseAmount]                 NUMERIC(18,6)   NULL
    ,[dblLicenseGLAmount]                   NUMERIC(18,6)   NULL
    ,[dblBaseLicenseGLAmount]               NUMERIC(18,6)   NULL
    ,[dblMaintenanceAmount]                 NUMERIC(18,6)   NULL
    ,[dblBaseMaintenanceAmount]             NUMERIC(18,6)   NULL
    ,[dblMaintenanceGLAmount]               NUMERIC(18,6)   NULL
    ,[dblBaseMaintenanceGLAmount]           NUMERIC(18,6)   NULL
	,[dblTaxesAddToCost]					NUMERIC(18,6)   NULL
	,[dblBaseTaxesAddToCost]				NUMERIC(18,6)   NULL
    ,[ysnTankRequired]                      BIT             NULL
    ,[ysnLeaseBilling]                      BIT             NULL
    ,[intSiteId]                            INT             NULL
    ,[intPerformerId]                       INT             NULL
    ,[intContractHeaderId]                  INT             NULL
    ,[intContractDetailId]                  INT             NULL
    ,[intInventoryShipmentItemId]           INT             NULL
    ,[intInventoryShipmentChargeId]         INT             NULL
    ,[intSalesOrderDetailId]                INT             NULL
    ,[intLoadDetailId]                      INT             NULL
    ,[intShipmentId]                        INT             NULL
    ,[intTicketId]                          INT             NULL
    ,[intDiscountAccountId]                 INT             NULL	
    ,[intCustomerStorageId]                 INT             NULL
    ,[intStorageScheduleTypeId]             INT             NULL
    ,[intSubLocationId]                     INT             NULL
    ,[intStorageLocationId]                 INT             NULL
    ,[ysnAutoBlend]                         BIT             NULL
    ,[ysnBlended]                           BIT             NULL    
    ,[dblQuantity]                          NUMERIC(18,6)   NULL
    ,[dblMaxQuantity]                       NUMERIC(18,6)   NULL	
    ,[strOptionType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strSourceType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strPostingMessage]                    NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
    ,[strDescription]                       NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL)
--DECLARE @PostProvisionalData AS [InvoicePostingTable]

EXEC [dbo].[uspARPopulateInvoiceDetailForPosting]
     @Param             = @param
    ,@BeginDate         = @beginDate
    ,@EndDate           = @endDate
    ,@BeginTransaction  = @beginTransaction
    ,@EndTransaction    = @endTransaction
    ,@IntegrationLogId  = NULL
    ,@InvoiceIds        = @InvoiceIds
    ,@Post              = @post
    ,@Recap             = @recap
    ,@PostDate          = @PostDate
    ,@BatchId           = @batchIdUsed
    ,@AccrueLicense     = @accrueLicense
    ,@TransType         = @transType
    ,@UserId            = @userId


IF @post = 1 AND @recap = 0
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
         @PostDate    = @PostDate
        ,@UserId      = @userId

--Removed excluded Invoices to post/unpost
IF(@exclude IS NOT NULL)
	BEGIN
		DECLARE @InvoicesExclude TABLE  (
			intInvoiceId INT
		);

		INSERT INTO @InvoicesExclude
		SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@exclude)


		DELETE FROM A
		FROM #ARPostInvoiceHeader A
		WHERE EXISTS(SELECT NULL FROM @InvoicesExclude B WHERE A.[intInvoiceId] = B.[intInvoiceId])

		DELETE FROM A
		FROM #ARPostInvoiceDetail A
		WHERE EXISTS(SELECT NULL FROM @InvoicesExclude B WHERE A.[intInvoiceId] = B.[intInvoiceId])
	END

--------------------------------------------------------------------------------------------  
-- Validations  
----------------------------------------------------------------------------------------------
--DECLARE @ItemAccounts AS [InvoiceItemAccount]
IF(OBJECT_ID('tempdb..#ARInvoiceItemAccount') IS NOT NULL)
BEGIN
    DROP TABLE #ARInvoiceItemAccount
END

CREATE TABLE #ARInvoiceItemAccount
	([intItemId]                         INT                                             NOT NULL
    ,[strItemNo]                         NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[strType]                           NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NOT NULL
    ,[intLocationId]                     INT                                             NOT NULL 
    ,[intCOGSAccountId]                  INT                                             NULL
    ,[intSalesAccountId]                 INT                                             NULL
    ,[intInventoryAccountId]             INT                                             NULL
    ,[intInventoryInTransitAccountId]    INT                                             NULL
    ,[intGeneralAccountId]               INT                                             NULL
    ,[intOtherChargeIncomeAccountId]     INT                                             NULL
    ,[intAccountId]                      INT                                             NULL
    ,[intDiscountAccountId]              INT                                             NULL
    ,[intMaintenanceSalesAccountId]      INT                                             NULL
	,PRIMARY KEY CLUSTERED ([intItemId], [intLocationId]))

EXEC [dbo].[uspARPopulateInvoiceAccountForPosting]
     @Post     = @post

IF(OBJECT_ID('tempdb..#ARInvalidInvoiceData') IS NOT NULL)
BEGIN
    DROP TABLE #ARInvalidInvoiceData
END

CREATE TABLE #ARInvalidInvoiceData
    ([intInvoiceId]				INT				NOT NULL
	,[strInvoiceNumber]			NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	,[intInvoiceDetailId]		INT				NULL
	,[intItemId]				INT				NULL
	,[strBatchId]				NVARCHAR(40)	COLLATE Latin1_General_CI_AS	NULL
	,[strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL)

IF(OBJECT_ID('tempdb..#ARItemsForCosting') IS NOT NULL)
BEGIN
    DROP TABLE #ARItemsForCosting
END
CREATE TABLE #ARItemsForCosting
	([intItemId] INT NOT NULL
	,[intItemLocationId] INT NULL
	,[intItemUOMId] INT NOT NULL
	,[dtmDate] DATETIME NOT NULL
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 1
    ,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblValue] NUMERIC(38, 20) NOT NULL DEFAULT 0 
	,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
	,[intCurrencyId] INT NULL
	,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL
    ,[intTransactionId] INT NOT NULL
	,[intTransactionDetailId] INT NOT NULL
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[intTransactionTypeId] INT NOT NULL
	,[intLotId] INT NULL
	,[intSubLocationId] INT NULL
	,[intStorageLocationId] INT NULL
	,[ysnIsStorage] BIT NULL
	,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    ,[intSourceTransactionId] INT NULL
	,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,[intInTransitSourceLocationId] INT NULL
	,[intForexRateTypeId] INT NULL
	,[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1
	,[intStorageScheduleTypeId] INT NULL
    ,[dblUnitRetail] NUMERIC(38, 20) NULL
	,[intCategoryId] INT NULL 
	,[dblAdjustCostValue] NUMERIC(38, 20) NULL
	,[dblAdjustRetailValue] NUMERIC(38, 20) NULL
	,[ysnForValidation] BIT NULL)

IF(OBJECT_ID('tempdb..#ARItemsForInTransitCosting') IS NOT NULL)
BEGIN
    DROP TABLE #ARItemsForInTransitCosting
END
CREATE TABLE #ARItemsForInTransitCosting
	([intItemId] INT NOT NULL
	,[intItemLocationId] INT NULL
	,[intItemUOMId] INT NOT NULL
	,[dtmDate] DATETIME NOT NULL
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 1
    ,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblValue] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
	,[intCurrencyId] INT NULL
	,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL
    ,[intTransactionId] INT NOT NULL
	,[intTransactionDetailId] INT NOT NULL
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[intTransactionTypeId] INT NOT NULL
	,[intLotId] INT NULL
    ,[intSourceTransactionId] INT NULL
	,[strSourceTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    ,[intSourceTransactionDetailId] INT NULL
	,[intFobPointId] TINYINT NULL
	,[intInTransitSourceLocationId] INT NULL
	,[intForexRateTypeId] INT NULL
	,[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1
	,[intLinkedItem] INT NULL
	,[intLinkedItemId] INT NULL
	)

IF(OBJECT_ID('tempdb..#ARItemsForStorageCosting') IS NOT NULL)
BEGIN
    DROP TABLE #ARItemsForStorageCosting
END
CREATE TABLE #ARItemsForStorageCosting
	([intItemId] INT NOT NULL
	,[intItemLocationId] INT NULL
	,[intItemUOMId] INT NOT NULL
	,[dtmDate] DATETIME NOT NULL
    ,[dblQty] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblUOMQty] NUMERIC(38, 20) NOT NULL DEFAULT 1
    ,[dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0
	,[dblValue] NUMERIC(38, 20) NOT NULL DEFAULT 0 
	,[dblSalesPrice] NUMERIC(18, 6) NOT NULL DEFAULT 0
	,[intCurrencyId] INT NULL
	,[dblExchangeRate] NUMERIC (38, 20) DEFAULT 1 NOT NULL
    ,[intTransactionId] INT NOT NULL
	,[intTransactionDetailId] INT NOT NULL
	,[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[intTransactionTypeId] INT NOT NULL
	,[intLotId] INT NULL
	,[intSubLocationId] INT NULL
	,[intStorageLocationId] INT NULL
	,[ysnIsStorage] BIT NULL
	,[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    ,[intSourceTransactionId] INT NULL
	,[strSourceTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,[intInTransitSourceLocationId] INT NULL
	,[intForexRateTypeId] INT NULL
	,[dblForexRate] NUMERIC(38, 20) NULL DEFAULT 1
	,[intStorageScheduleTypeId] INT NULL
    ,[dblUnitRetail] NUMERIC(38, 20) NULL
	,[intCategoryId] INT NULL 
	,[dblAdjustCostValue] NUMERIC(38, 20) NULL
	,[dblAdjustRetailValue] NUMERIC(38, 20) NULL)

DELETE PQ
FROM tblARPostingQueue PQ
INNER JOIN #ARPostInvoiceHeader II ON II.strInvoiceNumber = PQ.strTransactionNumber AND II.intInvoiceId = PQ.intTransactionId
WHERE DATEDIFF(SECOND, dtmPostingdate, GETDATE()) > 20 OR @post = 0

EXEC [dbo].[uspARPopulateInvalidPostInvoiceData]
         @Post     = @post
        ,@Recap    = @recap
        ,@PostDate = @PostDate
        ,@BatchId  = @batchIdUsed
		
SELECT @totalInvalid = COUNT(DISTINCT [intInvoiceId]) FROM #ARInvalidInvoiceData

IF(@totalInvalid > 0)
	BEGIN
		IF @raiseError = 1 AND @recap = 1
			SELECT TOP 1 @ErrorMerssage = strPostingError FROM #ARInvalidInvoiceData

		--Insert Invalid Post transaction result
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT [strPostingError]
			 , [strTransactionType]
			 , [strInvoiceNumber]
			 , [strBatchId]
			 , [intInvoiceId]
		FROM #ARInvalidInvoiceData

		SET @invalidCount = @totalInvalid

		--DELETE Invalid Transaction From temp table
		DELETE A
		FROM #ARPostInvoiceHeader A
		INNER JOIN #ARInvalidInvoiceData B ON A.intInvoiceId = B.intInvoiceId

		DELETE A
		FROM #ARPostInvoiceDetail A
		INNER JOIN #ARInvalidInvoiceData B ON A.intInvoiceId = B.intInvoiceId

		DELETE A
		FROM #ARItemsForCosting A
		INNER JOIN #ARInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]

		DELETE A
		FROM #ARItemsForInTransitCosting A
		INNER JOIN #ARInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]

		DELETE A
		FROM #ARItemsForStorageCosting A
		INNER JOIN #ARInvalidInvoiceData B ON A.[intTransactionId] = B.[intInvoiceId]		

        DELETE FROM #ARInvalidInvoiceData
	END

SELECT @totalRecords = COUNT([intInvoiceId]) FROM #ARPostInvoiceHeader

--INSERT INVOICES TO POSTING QUEUE
IF (@totalRecords > 0) AND @recap = 0 AND @post = 1
	BEGIN
		INSERT INTO tblARPostingQueue (
			  intTransactionId
			, strTransactionNumber
			, strBatchId
			, dtmPostingdate
			, intEntityId
			, strTransactionType
		)
		SELECT DISTINCT 
			  intTransactionId		= intInvoiceId
			, strTransactionNumber	= strInvoiceNumber
			, strBatchId			= strBatchId
			, dtmPostingdate		= GETDATE()
			, intEntityId			= intEntityId
			, strTransactionType	= 'Invoice'
		FROM #ARPostInvoiceHeader 
	END
			
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

			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT [strPostingError]
				 , [strTransactionType]
				 , [strInvoiceNumber]
				 , [strBatchId]
				 , [intInvoiceId]
			FROM #ARInvalidInvoiceData
		END

		IF @raiseError = 1
			BEGIN
				IF ISNULL(@ErrorMerssage, '') = ''
					SELECT TOP 1 @ErrorMerssage = [strMessage] FROM tblARPostResult WHERE [strBatchNumber] = @batchIdUsed

				RAISERROR(@ErrorMerssage, 11, 1)							
			END				
		GOTO Post_Exit	
	END

BEGIN TRY

	IF @recap = 0
		EXEC [dbo].[uspARPostItemResevation]

	IF @recap = 1
    BEGIN
        EXEC [dbo].[uspARPostInvoiceRecap]
                @Post            = @post
		       ,@Recap           = @recap
		       ,@BatchId         = @batchId
		       ,@PostDate        = @PostDate
		       ,@UserId          = @userId
		       ,@BatchIdUsed     = @batchIdUsed OUT
        GOTO Do_Commit
    END


	IF @post = 1 AND @recap = 1
    EXEC [dbo].[uspARProcessSplitOnInvoicePost]
			@PostDate        = @PostDate
		   ,@UserId          = @userId

	IF @post = 1
    EXEC [dbo].[uspARPrePostInvoiceIntegration]

	IF @post = 1
    EXEC dbo.[uspARUpdateTransactionAccountOnPost]  	

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
BEGIN TRY
	IF(OBJECT_ID('tempdb..#ARInvalidInventories') IS NOT NULL)
    BEGIN
        DROP TABLE #ARInvalidInventories
    END

	CREATE TABLE #ARInvalidInventories (
		 [strMessage]			NVARCHAR (MAX)   COLLATE Latin1_General_CI_AS NULL
		,[strTransactionType]	NVARCHAR (200)   COLLATE Latin1_General_CI_AS NULL
		,[strTransactionId]		NVARCHAR (200)   COLLATE Latin1_General_CI_AS NULL
		,[strBatchNumber]		NVARCHAR (200)   COLLATE Latin1_General_CI_AS NULL
		,[intTransactionId]		INT              NULL
	)

    IF(OBJECT_ID('tempdb..#ARInvoiceGLEntries') IS NOT NULL)
    BEGIN
        DROP TABLE #ARInvoiceGLEntries
    END

	CREATE TABLE #ARInvoiceGLEntries
	([dtmDate]                  DATETIME         NOT NULL,
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
	
    DECLARE @GLEntries RecapTableType
	IF @post = 1
	EXEC dbo.[uspARGenerateEntriesForAccrual] 

    EXEC [dbo].[uspARGenerateGLEntries]
         @Post     		= @post
	    ,@Recap    		= @recap
        ,@PostDate 		= @PostDate
        ,@BatchId  		= @batchIdUsed
        ,@UserId   		= @userId
		,@raiseError	= @raiseError
	
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


    DECLARE @InvalidGLEntries AS TABLE
        ([strTransactionId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
        ,[strText]          NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL
        ,[intErrorCode]     INT
        ,[strModuleName]    NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL)

    INSERT INTO @InvalidGLEntries
        ([strTransactionId]
        ,[strText]
        ,[intErrorCode]
        ,[strModuleName])
    SELECT DISTINCT
         [strTransactionId]
        ,[strText]
        ,[intErrorCode]
        ,[strModuleName]
    FROM
        [dbo].[fnGetGLEntriesErrors](@GLEntries, @post)

	INSERT INTO @InvalidGLEntries (
		  [strTransactionId]
        , [strText]
        , [intErrorCode]
        , [strModuleName]
	)
	SELECT DISTINCT
		 [strTransactionId]
		,[strMessage]
		,100
		,'Accounts Receivable'
	FROM #ARInvalidInventories

    DECLARE @invalidGLCount INT
	SET @invalidGLCount = ISNULL((SELECT COUNT(DISTINCT[strTransactionId]) FROM @InvalidGLEntries), 0)
    SET @invalidCount = @invalidCount + @invalidGLCount
	SET @totalRecords = @totalRecords - @invalidGLCount

    INSERT INTO tblARPostResult
		([strMessage]
        ,[strTransactionType]
        ,[strTransactionId]
        ,[strBatchNumber]
        ,[intTransactionId])
    SELECT DISTINCT
         [strError]             = IGLE.[strText]
        ,[strTransactionType]   = GLE.[strTransactionType] 
        ,[strTransactionId]     = IGLE.[strTransactionId]
        ,[strBatchNumber]       = GLE.[strBatchId]
        ,[intTransactionId]     = GLE.[intTransactionId] 
    FROM @InvalidGLEntries IGLE
    LEFT OUTER JOIN @GLEntries GLE ON IGLE.[strTransactionId] = GLE.[strTransactionId]	
	WHERE IGLE.strTransactionId IS NOT NULL

	UNION ALL

	SELECT DISTINCT
         [strError]             = strMessage
        ,[strTransactionType]   = strTransactionType
        ,[strTransactionId]     = strTransactionId
        ,[strBatchNumber]       = strBatchNumber
        ,[intTransactionId]     = intTransactionId
    FROM #ARInvalidInventories

	IF @raiseError = 1 AND ISNULL(@invalidGLCount, 0) > 0
	BEGIN
		SELECT TOP 1 @ErrorMerssage = [strText] FROM @InvalidGLEntries
		RAISERROR(@ErrorMerssage, 11, 1)
	END

    DELETE FROM #ARInvoiceGLEntries
    WHERE [strTransactionId] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM #ARPostInvoiceHeader
    WHERE [strInvoiceNumber] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    DELETE FROM #ARPostInvoiceDetail
    WHERE [strInvoiceNumber] IN (SELECT DISTINCT [strTransactionId] FROM @InvalidGLEntries)

    EXEC [dbo].[uspARBookInvoiceGLEntries]
            @Post    = @post
           ,@BatchId = @batchIdUsed
		   ,@UserId  = @userId

    EXEC [dbo].[uspARPostInvoiceIntegrations]
            @Post    = @post
           ,@BatchId = @batchIdUsed
		   ,@UserId  = @userId

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

SET @successfulCount = @totalRecords
SET @invalidCount = @totalInvalid	

Do_Commit:
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