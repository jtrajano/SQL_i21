CREATE PROCEDURE [dbo].[uspARPopulateInvoiceDetailForPosting]
     @Param             NVARCHAR(MAX)   = NULL
    ,@BeginDate         DATE            = NULL
    ,@EndDate           DATE            = NULL
    ,@BeginTransaction  NVARCHAR(50)    = NULL
    ,@EndTransaction    NVARCHAR(50)    = NULL
    ,@IntegrationLogId  INT             = NULL
    ,@InvoiceIds        [InvoiceId]     READONLY
    ,@Post              BIT				= 0
    ,@Recap             BIT				= 0
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
    ,@AccrueLicense     BIT             = 0
    ,@TransType         NVARCHAR(25)    = 'all'
    ,@UserId            INT				= 1
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE	@DiscountAccountId          INT
       ,@DeferredRevenueAccountId   INT
       ,@ExcludeInvoiceFromPayment	BIT
       ,@ImpactForProvisional    	BIT
       ,@AllowOtherUserToPost       BIT
       ,@ZeroBit                    BIT
       ,@OneBit                     BIT
       ,@ZeroDecimal                DECIMAL(18,6)
       ,@OneDecimal                 DECIMAL(18,6)
       ,@OneHundredDecimal          DECIMAL(18,6)
       ,@Param2                     NVARCHAR(MAX)
	   ,@Precision					INT = 2

SET @ZeroDecimal = 0.000000
SET @OneDecimal = 1.000000
SET @OneHundredDecimal = 100.000000
SET @OneBit = CAST(1 AS BIT)
SET @ZeroBit = CAST(0 AS BIT)

SELECT TOP 1
     @DiscountAccountId         = [intDiscountAccountId]
    ,@DeferredRevenueAccountId  = [intDeferredRevenueAccountId]
	,@ImpactForProvisional      = ISNULL([ysnImpactForProvisional], @ZeroBit)
    ,@ExcludeInvoiceFromPayment = ISNULL([ysnExcludePaymentInFinalInvoice], @ZeroBit)
FROM dbo.tblARCompanyPreference WITH (NOLOCK)
ORDER BY intCompanyPreferenceId 

SET @Precision = dbo.fnARGetDefaultDecimal()
SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WHERE intEntityUserSecurityId = @UserId)
SET @Param2 = (CASE WHEN UPPER(@Param) = 'ALL' THEN '' ELSE @Param END)
SET @Param = UPPER(RTRIM(LTRIM(ISNULL(@Param,''))))

IF(OBJECT_ID('tempdb..#tblInvoiceIds') IS NOT NULL) DROP TABLE #tblInvoiceIds
CREATE TABLE #tblInvoiceIds (
	  intInvoiceId		INT NOT NULL PRIMARY KEY
	, ysnPost			BIT DEFAULT 1
	, ysnRecap			BIT DEFAULT 0
	, ysnAccrueLicense	BIT DEFAULT 0
	, strBatchId		NVARCHAR(40) COLLATE Latin1_General_CI_AS    NULL	
)

--FILTERED BY ALL
IF @Param = 'ALL'
	BEGIN
		INSERT INTO #tblInvoiceIds WITH (TABLOCK) (
			  intInvoiceId
			, ysnPost
			, ysnRecap
			, ysnAccrueLicense
			, strBatchId
		)
		SELECT intInvoiceId		= ARI.intInvoiceId
			, ysnPost			= @Post
			, ysnRecap			= @Recap
			, ysnAccrueLicense	= @AccrueLicense
			, strBatchId		= @BatchId
		FROM tblARInvoice ARI WITH (NOLOCK)
		WHERE ARI.ysnPosted = 0
		  AND (UPPER(@TransType) = 'ALL' OR ARI.[strTransactionType] = @TransType)
		  AND (@BeginDate IS NULL OR ARI.dtmDate >= @BeginDate)
		  AND (@EndDate IS NULL OR ARI.dtmDate <= @EndDate)
		  AND (@BeginTransaction IS NULL OR ARI.intInvoiceId >= @BeginTransaction)
		  AND (@EndTransaction IS NULL OR ARI.intInvoiceId >= @EndTransaction)
	END
ELSE
	BEGIN 
		IF(OBJECT_ID('tempdb..#TEMPINVOICES') IS NOT NULL) DROP TABLE #TEMPINVOICES 
		CREATE TABLE #TEMPINVOICES (intInvoiceId INT NOT NULL PRIMARY KEY)

		INSERT INTO #TEMPINVOICES
		SELECT DISTINCT intID
		FROM fnGetRowsFromDelimitedValues(@Param)

		--FILTERED BY PARAM
		INSERT INTO #tblInvoiceIds WITH (TABLOCK) (
			  intInvoiceId
			, ysnPost
			, ysnRecap
			, ysnAccrueLicense
			, strBatchId
		)
		SELECT intInvoiceId		= ARI.intInvoiceId
			, ysnPost			= @Post
			, ysnRecap			= @Recap
			, ysnAccrueLicense	= @AccrueLicense
			, strBatchId		= @BatchId
		FROM tblARInvoice ARI WITH (NOLOCK)
		INNER JOIN #TEMPINVOICES DV ON DV.intInvoiceId = ARI.[intInvoiceId]

		UNION

		SELECT intInvoiceId		= LD.intInvoiceId
			, ysnPost			= @Post
			, ysnRecap			= @Recap
			, ysnAccrueLicense	= @AccrueLicense
			, strBatchId		= @BatchId
		FROM tblARInvoiceIntegrationLogDetail LD
		WHERE LD.[intIntegrationLogId] = @IntegrationLogId
          AND LD.[ysnHeader] = 1
		  AND LD.[ysnPosted] <> @Post
          AND LD.[ysnPost] = @Post
		  
		UNION

		SELECT intInvoiceId		= LD.intHeaderId
			, ysnPost			= @Post
			, ysnRecap			= @Recap
			, ysnAccrueLicense	= @AccrueLicense
			, strBatchId		= @BatchId
		FROM @InvoiceIds LD
		WHERE LD.[ysnPost] IS NOT NULL 
          AND LD.[ysnPost] = @Post
	END

--HEADER
INSERT ##ARPostInvoiceHeader WITH (TABLOCK)
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
    ,[ysnFromProvisional]
    ,[dtmDatePosted]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]    
    ,[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]
    ,[ysnRefundProcessed]
    ,[ysnCancelled]
    ,[ysnPaid]
    ,[strPONumber]
    
    ,[intDiscountAccountId]
    ,[strDescription]
    ,[strInterCompanyVendorId]
    ,[strInterCompanyLocationId]
    ,[intInterCompanyId]
    ,[strReceiptNumber]
    ,[ysnInterCompany]
    ,[intInterCompanyVendorId]
	,[strBOLNumber]
)
SELECT 
     [intInvoiceId]                     = ARI.[intInvoiceId]
    ,[strInvoiceNumber]                 = ARI.[strInvoiceNumber]
    ,[strTransactionType]               = ARI.[strTransactionType]
    ,[strType]                          = ARI.[strType]
    ,[dtmDate]                          = ARI.[dtmDate]
    ,[dtmPostDate]                      = ARI.[dtmPostDate]
    ,[dtmShipDate]                      = ISNULL(ARI.[dtmShipDate], ARI.[dtmPostDate])
    ,[intEntityCustomerId]              = ARI.[intEntityCustomerId]
    ,[strCustomerNumber]                = ARC.[strCustomerNumber]
    ,[ysnCustomerActive]                = ARC.[ysnActive]
    ,[dblCustomerCreditLimit]           = ARC.[dblCreditLimit]
    ,[intCompanyLocationId]             = ARI.[intCompanyLocationId]
    ,[strCompanyLocationName]           = SMCL.[strLocationName]
    ,[intAccountId]                     = ARI.[intAccountId]
    ,[intAPAccount]                     = SMCL.[intAPAccount]
    ,[intFreightIncome]                 = SMCL.[intFreightIncome]
    ,[intDeferredRevenueAccountId]      = @DeferredRevenueAccountId
    ,[intUndepositedFundsId]			= SMCL.[intUndepositedFundsId]
    ,[intProfitCenter]                  = SMCL.[intProfitCenter]
    ,[intLocationSalesAccountId]        = SMCL.[intSalesAccount]
    ,[intCurrencyId]                    = ARI.[intCurrencyId]
    ,[dblAverageExchangeRate]           = ARI.[dblCurrencyExchangeRate]
    ,[intTermId]                        = ARI.[intTermId]
    ,[dblInvoiceTotal]                  = ARI.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ARI.[dblBaseInvoiceTotal]
    ,[dblShipping]                      = ARI.[dblShipping]
    ,[dblBaseShipping]                  = ARI.[dblBaseShipping]
    ,[dblTax]                           = ARI.[dblTax]
    ,[dblBaseTax]                       = ARI.[dblBaseTax]
    ,[dblAmountDue]                     = ARI.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARI.[dblBaseAmountDue]
    ,[dblPayment]                       = ARI.[dblPayment]
    ,[dblBasePayment]                   = ARI.[dblBasePayment]
    ,[dblProvisionalAmount]             = ARI.[dblProvisionalAmount]
    ,[dblBaseProvisionalAmount]         = ARI.[dblBaseProvisionalAmount]
    ,[strComments]                      = ARI.[strComments]
    ,[strImportFormat]                  = ARI.[strImportFormat]
    ,[intSourceId]                      = ARI.[intSourceId]
    ,[intOriginalInvoiceId]             = ARI.[intOriginalInvoiceId]
    ,[strInvoiceOriginId]               = ARI.[strInvoiceOriginId]
    ,[intDistributionHeaderId]          = ARI.[intDistributionHeaderId]
    ,[intLoadDistributionHeaderId]      = ARI.[intLoadDistributionHeaderId]
    ,[intLoadId]                        = ARI.[intLoadId]
    ,[intFreightTermId]                 = ARI.[intFreightTermId]
    ,[strActualCostId]                  = ARI.[strActualCostId]
    ,[intPeriodsToAccrue]               = ARI.[intPeriodsToAccrue]
    ,[ysnAccrueLicense]                 = ID.ysnAccrueLicense
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ARI.[ysnImpactInventory]
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[ysnFromProvisional]               = ARI.[ysnFromProvisional]
    ,[dtmDatePosted]                    = @PostDate
    ,[strBatchId]                       = ID.strBatchId
    ,[ysnPost]                          = ID.ysnPost
    ,[ysnRecap]                         = ID.ysnRecap
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]	= @AllowOtherUserToPost    
    ,[ysnProvisionalWithGL]             = (CASE WHEN ARI.[strType] = 'Provisional' THEN @ImpactForProvisional ELSE ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit) END)
    ,[ysnExcludeInvoiceFromPayment]     = @ExcludeInvoiceFromPayment
    ,[ysnRefundProcessed]               = ARI.[ysnRefundProcessed]
    ,[ysnCancelled]                     = ARI.[ysnCancelled]
    ,[ysnPaid]                          = ARI.[ysnPaid]
    ,[strPONumber]                      = ARI.[strPONumber]
    
    ,[intDiscountAccountId]             = ISNULL(SMCL.intSalesDiscounts, @DiscountAccountId)
    ,[strDescription]                   = CASE WHEN ARI.[strType] = 'Provisional' AND @ImpactForProvisional = @OneBit THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + EM.[strName]),'')), 1, 255)
                                               WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + EM.[strName]),'')), 1 , 255)
                                               ELSE ARI.[strTransactionType] + ' for ' + ISNULL(EM.strName, '')
                                          END	
    ,[strInterCompanyVendorId]          = ARC.[strInterCompanyVendorId]
    ,[strInterCompanyLocationId]        = ARC.[strInterCompanyLocationId]
    ,[intInterCompanyId]                = ARC.[intInterCompanyId]
    ,[strReceiptNumber]                 = ARI.[strReceiptNumber]
    ,[ysnInterCompany]                  = ARI.[ysnInterCompany]
    ,[intInterCompanyVendorId]          = ARC.[intInterCompanyVendorId]
	,[strBOLNumber]                     = ARI.strBOLNumber
FROM tblARInvoice ARI
INNER JOIN #tblInvoiceIds ID ON ARI.intInvoiceId = ID.intInvoiceId
INNER JOIN tblARCustomer ARC WITH (NOLOCK) ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
INNER JOIN tblEMEntity EM ON ARC.intEntityId = EM.intEntityId 
INNER JOIN tblSMCompanyLocation SMCL WITH (NOLOCK) ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]

UPDATE ##ARPostInvoiceHeader
SET ysnIsInvoicePositive = CAST(0 AS BIT)  
WHERE strTransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')

UPDATE HEADER
SET ysnForApproval = CAST(1 AS BIT)
  , strDescription = FAT.strApprovalStatus
FROM ##ARPostInvoiceHeader HEADER
INNER JOIN vyuARForApprovalTransction FAT ON HEADER.intInvoiceId = FAT.intTransactionId
WHERE FAT.strScreenName = 'Invoice'

--DETAIL
--INVENTORY
INSERT ##ARPostInvoiceDetail WITH (TABLOCK)
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
    ,[ysnFromProvisional]
    ,[dtmDatePosted]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnForApproval]
    ,[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]
    ,[ysnRefundProcessed]
    ,[ysnIsInvoicePositive]
    ,[ysnCancelled]
    ,[ysnPaid]
    ,[strPONumber]

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
    ,[strDescription]
	,[strBOLNumber]
)
SELECT 
     [intInvoiceId]                     = ARI.[intInvoiceId]
    ,[strInvoiceNumber]                 = ARI.[strInvoiceNumber]
    ,[strTransactionType]               = ARI.[strTransactionType]
    ,[strType]                          = ARI.[strType]
    ,[dtmDate]                          = ARI.[dtmDate]
    ,[dtmPostDate]                      = ARI.[dtmPostDate]
    ,[dtmShipDate]                      = ISNULL(ARI.[dtmShipDate], ARI.[dtmPostDate])
    ,[intEntityCustomerId]              = ARI.[intEntityCustomerId]
    ,[strCustomerNumber]                = ARI.[strCustomerNumber]
    ,[ysnCustomerActive]                = ARI.[ysnCustomerActive]
    ,[dblCustomerCreditLimit]           = ARI.[dblCustomerCreditLimit]
    ,[intCompanyLocationId]             = ARI.[intCompanyLocationId]
    ,[strCompanyLocationName]           = ARI.[strCompanyLocationName]
    ,[intAccountId]                     = ARI.[intAccountId]
    ,[intAPAccount]                     = ARI.[intAPAccount]
    ,[intFreightIncome]                 = ARI.[intFreightIncome]
    ,[intDeferredRevenueAccountId]      = ARI.[intDeferredRevenueAccountId]
    ,[intUndepositedFundsId]			= ARI.[intUndepositedFundsId]
    ,[intProfitCenter]                  = ARI.[intProfitCenter]
    ,[intLocationSalesAccountId]        = ARI.[intLocationSalesAccountId]
    ,[intCurrencyId]                    = ARI.[intCurrencyId]
    ,[dblAverageExchangeRate]           = ARI.[dblAverageExchangeRate]
    ,[intTermId]                        = ARI.[intTermId]
    ,[dblInvoiceTotal]                  = ARI.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ARI.[dblBaseInvoiceTotal]
    ,[dblShipping]                      = ARI.[dblShipping]
    ,[dblBaseShipping]                  = ARI.[dblBaseShipping]
    ,[dblTax]                           = ARI.[dblTax]
    ,[dblBaseTax]                       = ARI.[dblBaseTax]
    ,[dblAmountDue]                     = ARI.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARI.[dblBaseAmountDue]
    ,[dblPayment]                       = ARI.[dblPayment]
    ,[dblBasePayment]                   = ARI.[dblBasePayment]
    ,[dblProvisionalAmount]             = ARI.[dblProvisionalAmount]
    ,[dblBaseProvisionalAmount]         = ARI.[dblBaseProvisionalAmount]
    ,[strComments]                      = ARI.[strComments]
    ,[strImportFormat]                  = ARI.[strImportFormat]
    ,[intSourceId]                      = ARI.[intSourceId]
    ,[intOriginalInvoiceId]             = ARI.[intOriginalInvoiceId]
    ,[strInvoiceOriginId]               = ARI.[strInvoiceOriginId]
    ,[intDistributionHeaderId]          = ARI.[intDistributionHeaderId]
    ,[intLoadDistributionHeaderId]      = ARI.[intLoadDistributionHeaderId]
    ,[intLoadId]                        = ARI.[intLoadId]
    ,[intFreightTermId]                 = ARI.[intFreightTermId]
    ,[strActualCostId]                  = ARI.[strActualCostId]
    ,[intPeriodsToAccrue]               = ARI.[intPeriodsToAccrue]
    ,[ysnAccrueLicense]                 = ARI.[ysnAccrueLicense]
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ARI.[ysnImpactInventory]
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[ysnFromProvisional]               = ARI.[ysnFromProvisional]
    ,[dtmDatePosted]                    = ARI.[dtmDatePosted]
    ,[strBatchId]                       = ARI.[strBatchId]
    ,[ysnPost]                          = ARI.[ysnPost]
    ,[ysnRecap]                         = ARI.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = ARI.[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]	= ARI.[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]          = ARI.[ysnWithinAccountingDate]
    ,[ysnForApproval]                   = ARI.[ysnForApproval]
    ,[ysnProvisionalWithGL]             = ARI.[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]     = ARI.[ysnExcludeInvoiceFromPayment]
    ,[ysnRefundProcessed]               = ARI.[ysnRefundProcessed]
    ,[ysnIsInvoicePositive]             = ARI.[ysnIsInvoicePositive]
    ,[ysnCancelled]                     = ARI.[ysnCancelled]
    ,[ysnPaid]                          = ARI.[ysnPaid]
    ,[strPONumber]                      = ARI.[strPONumber]

    ,[intInvoiceDetailId]               = ARID.[intInvoiceDetailId]
    ,[intItemId]                        = ARID.[intItemId]
    ,[strItemNo]                        = ICI.[strItemNo]
    ,[strItemType]                      = ICI.[strType]
    ,[strItemManufactureType]           = ICI.[strManufactureType]
    ,[strItemDescription]               = ISNULL(ARID.[strItemDescription], ICI.[strDescription])
    ,[intItemUOMId]                     = ARID.[intItemUOMId]
    ,[intItemWeightUOMId]               = ARID.[intItemWeightUOMId]
    ,[intItemAccountId]                 = ARID.[intAccountId]
    ,[intServiceChargeAccountId]        = ARID.[intServiceChargeAccountId]
	,[intSalesAccountId]                = ARID.[intSalesAccountId]
    ,[intCOGSAccountId]                 = ARID.[intCOGSAccountId]
    ,[intInventoryAccountId]            = ARID.[intInventoryAccountId]
    ,[intLicenseAccountId]              = ARID.[intLicenseAccountId]
    ,[intMaintenanceAccountId]          = ARID.[intMaintenanceAccountId]
    ,[intConversionAccountId]           = ARID.[intConversionAccountId]
    ,[dblQtyShipped]                    = ARID.[dblQtyShipped]
    ,[dblUnitQtyShipped]                = ISNULL(dbo.fnARCalculateQtyBetweenUOM(ARID.[intItemUOMId], ICSUOM.[intItemUOMId], ARID.[dblQtyShipped], ICI.[intItemId], ICI.[strType]), @ZeroDecimal)
    ,[dblShipmentNetWt]                 = ARID.[dblShipmentNetWt]
    ,[dblUnitQty]                       = ICIU.[dblUnitQty]
    ,[dblUnitOnHand]                    = ICIS.[dblUnitOnHand]
    ,[intAllowNegativeInventory]        = ICIL.[intAllowNegativeInventory]
    ,[ysnStockTracking]					= @OneBit
    ,[intItemLocationId]                = ICIL.[intItemLocationId]
    ,[dblLastCost]                      = ICIP.[dblLastCost]
    ,[intCategoryId]                    = ICI.[intCategoryId]
    ,[ysnRetailValuation]				= ICC.[ysnRetailValuation]
    ,[dblPrice]                         = ARID.[dblPrice]
    ,[dblBasePrice]                     = ARID.[dblBasePrice]
    ,[dblUnitPrice]                     = ARID.[dblUnitPrice]
    ,[dblBaseUnitPrice]                 = ARID.[dblBaseUnitPrice]
    ,[strPricing]                       = ARID.[strPricing]
    ,[dblDiscount]                      = ARID.[dblDiscount]
    ,[dblDiscountAmount]				= ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), @Precision)), @Precision), @ZeroDecimal)
    ,[dblBaseDiscountAmount]            = ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), @Precision)), @Precision), @ZeroDecimal)
    ,[dblTotal]                         = ARID.[dblTotal]
    ,[dblBaseTotal]                     = ARID.[dblBaseTotal]
    ,[dblLineItemGLAmount]              = ISNULL(ARID.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblPrice), @Precision)), @Precision)
    ,[dblBaseLineItemGLAmount]          = ISNULL(ARID.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblBasePrice), @Precision)), @Precision)
    ,[intCurrencyExchangeRateTypeId]    = ARID.[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]          = ARID.[dblCurrencyExchangeRate]
    ,[strCurrencyExchangeRateType]      = SMCERT.[strCurrencyExchangeRateType]
    ,[intLotId]                         = ARID.[intLotId]
    ,[intOriginalInvoiceDetailId]       = ARID.[intOriginalInvoiceDetailId]
    ,[strMaintenanceType]               = ARID.[strMaintenanceType]
    ,[strFrequency]                     = ARID.[strFrequency]
    ,[dtmMaintenanceDate]               = ARID.[dtmMaintenanceDate]
    ,[dblLicenseAmount]                 = ARID.[dblLicenseAmount]
    ,[dblBaseLicenseAmount]             = ARID.[dblBaseLicenseAmount]
    ,[dblLicenseGLAmount]               = ARID.[dblLicenseAmount]
    ,[dblBaseLicenseGLAmount]           = ARID.[dblBaseLicenseAmount]
    ,[dblMaintenanceAmount]             = ARID.[dblMaintenanceAmount]
    ,[dblBaseMaintenanceAmount]         = ARID.[dblBaseMaintenanceAmount]
    ,[dblMaintenanceGLAmount]           = ARID.[dblMaintenanceAmount]
    ,[dblBaseMaintenanceGLAmount]       = ARID.[dblBaseMaintenanceAmount]    
    ,[ysnLeaseBilling]                  = ARID.[ysnLeaseBilling]
    ,[intSiteId]                        = ARID.[intSiteId]
    ,[intPerformerId]                   = ARID.[intPerformerId]
    ,[intContractHeaderId]              = ARID.[intContractHeaderId]
    ,[intContractDetailId]              = ARID.[intContractDetailId]
    ,[intInventoryShipmentItemId]       = ARID.[intInventoryShipmentItemId]
    ,[intInventoryShipmentChargeId]     = ARID.[intInventoryShipmentChargeId]
    ,[intSalesOrderDetailId]            = ARID.[intSalesOrderDetailId]
    ,[intLoadDetailId]                  = ARID.[intLoadDetailId]
    ,[intShipmentId]                    = ARID.[intShipmentId]
    ,[intTicketId]                      = ARID.[intTicketId]
    ,[intDiscountAccountId]             = ISNULL(SMCL.intSalesDiscounts, @DiscountAccountId)
    ,[intCustomerStorageId]             = ARID.[intCustomerStorageId]
    ,[intStorageScheduleTypeId]         = ARID.[intStorageScheduleTypeId]
    ,[intSubLocationId]                 = ISNULL(ARID.[intCompanyLocationSubLocationId], (CASE WHEN ICI.[ysnAutoBlend] = 1 THEN ICIL.[intSubLocationId] ELSE ISNULL(ARID.[intCompanyLocationSubLocationId], ARID.[intSubLocationId]) END))
    ,[intStorageLocationId]             = ARID.[intStorageLocationId]
    ,[ysnAutoBlend]                     = ICI.[ysnAutoBlend]
    ,[ysnBlended]                       = ARID.[ysnBlended]
 
    ,[strDescription]                   = ISNULL(GL.strDescription, '') + ' Item: ' + ISNULL(ARID.strItemDescription, '') + ', Qty: ' + CAST(CAST(ARID.dblQtyShipped AS NUMERIC(18, 2)) AS nvarchar(100)) + ', Price: ' + CAST(CAST(ARID.dblPrice AS NUMERIC(18, 2)) AS nvarchar(100))
	,[strBOLNumber]						= ARI.strBOLNumber 
FROM ##ARPostInvoiceHeader ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblSMCompanyLocation SMCL ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
INNER JOIN tblICItem ICI WITH(NOLOCK) ON ARID.[intItemId] = ICI.[intItemId]
LEFT OUTER JOIN tblICCategory ICC WITH(NOLOCK) ON ICI.[intCategoryId] = ICC.[intCategoryId]
INNER JOIN tblICItemLocation ICIL WITH(NOLOCK) ON ICI.[intItemId] = ICIL.[intItemId] AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
LEFT OUTER JOIN tblICItemPricing ICIP WITH(NOLOCK) ON ICI.[intItemId] = ICIP.[intItemId] AND ICIL.[intItemLocationId] = ICIP.[intItemLocationId]
LEFT OUTER JOIN tblICItemUOM ICIU WITH(NOLOCK) ON ARID.[intItemUOMId] = ICIU.[intItemUOMId]
LEFT OUTER JOIN (
    SELECT [intItemId]
         , intItemUOMId	= MIN([intItemUOMId])
    FROM tblICItemUOM IUOM WITH(NOLOCK) 
    WHERE [ysnStockUnit] = 1
	GROUP BY IUOM.[intItemId]
) ICSUOM ON ICI.[intItemId] = ICSUOM.[intItemId]
LEFT OUTER JOIN tblICItemStock ICIS WITH(NOLOCK) ON ICIL.[intItemId] = ICIS.[intItemId] AND ICIL.[intItemLocationId] = ICIS.[intItemLocationId]
LEFT OUTER JOIN tblSMCurrencyExchangeRateType SMCERT WITH(NOLOCK) ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN tblGLAccount GL ON ARID.intSalesAccountId = GL.intAccountId
WHERE ICI.strType IN ('Inventory', 'Finished Good', 'Raw Material')

--NON-INVENTORY
INSERT ##ARPostInvoiceDetail WITH (TABLOCK)
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
    ,[ysnFromProvisional]
    ,[dtmDatePosted]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnForApproval]
    ,[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]
    ,[ysnRefundProcessed]
    ,[ysnIsInvoicePositive]
    ,[ysnCancelled]
    ,[ysnPaid]
    ,[strPONumber]

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
    ,[strDescription]
	,[strBOLNumber]
)
SELECT 
     [intInvoiceId]                     = ARI.[intInvoiceId]
    ,[strInvoiceNumber]                 = ARI.[strInvoiceNumber]
    ,[strTransactionType]               = ARI.[strTransactionType]
    ,[strType]                          = ARI.[strType]
    ,[dtmDate]                          = ARI.[dtmDate]
    ,[dtmPostDate]                      = ARI.[dtmPostDate]
    ,[dtmShipDate]                      = ISNULL(ARI.[dtmShipDate], ARI.[dtmPostDate])
    ,[intEntityCustomerId]              = ARI.[intEntityCustomerId]
    ,[strCustomerNumber]                = ARI.[strCustomerNumber]
    ,[ysnCustomerActive]                = ARI.[ysnCustomerActive]
    ,[dblCustomerCreditLimit]           = ARI.[dblCustomerCreditLimit]
    ,[intCompanyLocationId]             = ARI.[intCompanyLocationId]
    ,[strCompanyLocationName]           = ARI.[strCompanyLocationName]
    ,[intAccountId]                     = ARI.[intAccountId]
    ,[intAPAccount]                     = ARI.[intAPAccount]
    ,[intFreightIncome]                 = ARI.[intFreightIncome]
    ,[intDeferredRevenueAccountId]      = ARI.[intDeferredRevenueAccountId]
    ,[intUndepositedFundsId]			= ARI.[intUndepositedFundsId]
    ,[intProfitCenter]                  = ARI.[intProfitCenter]
    ,[intLocationSalesAccountId]        = ARI.[intLocationSalesAccountId]
    ,[intCurrencyId]                    = ARI.[intCurrencyId]
    ,[dblAverageExchangeRate]           = ARI.[dblAverageExchangeRate]
    ,[intTermId]                        = ARI.[intTermId]
    ,[dblInvoiceTotal]                  = ARI.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ARI.[dblBaseInvoiceTotal]
    ,[dblShipping]                      = ARI.[dblShipping]
    ,[dblBaseShipping]                  = ARI.[dblBaseShipping]
    ,[dblTax]                           = ARI.[dblTax]
    ,[dblBaseTax]                       = ARI.[dblBaseTax]
    ,[dblAmountDue]                     = ARI.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARI.[dblBaseAmountDue]
    ,[dblPayment]                       = ARI.[dblPayment]
    ,[dblBasePayment]                   = ARI.[dblBasePayment]
    ,[dblProvisionalAmount]             = ARI.[dblProvisionalAmount]
    ,[dblBaseProvisionalAmount]         = ARI.[dblBaseProvisionalAmount]
    ,[strComments]                      = ARI.[strComments]
    ,[strImportFormat]                  = ARI.[strImportFormat]
    ,[intSourceId]                      = ARI.[intSourceId]
    ,[intOriginalInvoiceId]             = ARI.[intOriginalInvoiceId]
    ,[strInvoiceOriginId]               = ARI.[strInvoiceOriginId]
    ,[intDistributionHeaderId]          = ARI.[intDistributionHeaderId]
    ,[intLoadDistributionHeaderId]      = ARI.[intLoadDistributionHeaderId]
    ,[intLoadId]                        = ARI.[intLoadId]
    ,[intFreightTermId]                 = ARI.[intFreightTermId]
    ,[strActualCostId]                  = ARI.[strActualCostId]
    ,[intPeriodsToAccrue]               = ARI.[intPeriodsToAccrue]
    ,[ysnAccrueLicense]                 = ARI.[ysnAccrueLicense]
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ARI.[ysnImpactInventory]
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[ysnFromProvisional]               = ARI.[ysnFromProvisional]
    ,[dtmDatePosted]                    = ARI.[dtmDatePosted]
    ,[strBatchId]                       = ARI.[strBatchId]
    ,[ysnPost]                          = ARI.[ysnPost]
    ,[ysnRecap]                         = ARI.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = ARI.[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]	= ARI.[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]          = ARI.[ysnWithinAccountingDate]
    ,[ysnForApproval]                   = ARI.[ysnForApproval]
    ,[ysnProvisionalWithGL]             = ARI.[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]     = ARI.[ysnExcludeInvoiceFromPayment]
    ,[ysnRefundProcessed]               = ARI.[ysnRefundProcessed]
    ,[ysnIsInvoicePositive]             = ARI.[ysnIsInvoicePositive]
    ,[ysnCancelled]                     = ARI.[ysnCancelled]
    ,[ysnPaid]                          = ARI.[ysnPaid]
    ,[strPONumber]                      = ARI.[strPONumber]

    ,[intInvoiceDetailId]               = ARID.[intInvoiceDetailId]
    ,[intItemId]                        = ARID.[intItemId]
    ,[strItemNo]                        = ICI.[strItemNo]
    ,[strItemType]                      = ICI.[strType]
    ,[strItemManufactureType]           = ICI.[strManufactureType]
    ,[strItemDescription]               = ISNULL(ARID.[strItemDescription], ICI.[strDescription])
    ,[intItemUOMId]                     = ARID.[intItemUOMId]
    ,[intItemWeightUOMId]               = ARID.[intItemWeightUOMId]
    ,[intItemAccountId]                 = ARID.[intAccountId]
    ,[intServiceChargeAccountId]        = ARID.[intServiceChargeAccountId]
	,[intSalesAccountId]                = ARID.[intSalesAccountId]
    ,[intCOGSAccountId]                 = ARID.[intCOGSAccountId]
    ,[intInventoryAccountId]            = ARID.[intInventoryAccountId]
    ,[intLicenseAccountId]              = ARID.[intLicenseAccountId]
    ,[intMaintenanceAccountId]          = ARID.[intMaintenanceAccountId]
    ,[intConversionAccountId]           = ARID.[intConversionAccountId]
    ,[dblQtyShipped]                    = ARID.[dblQtyShipped]
    ,[dblUnitQtyShipped]                = ARID.[dblQtyShipped]
    ,[dblShipmentNetWt]                 = ARID.[dblShipmentNetWt]
    ,[dblUnitQty]                       = ICIU.[dblUnitQty]
    ,[dblUnitOnHand]                    = @ZeroDecimal
    ,[intAllowNegativeInventory]        = ICIL.[intAllowNegativeInventory]
    ,[ysnStockTracking]					= @ZeroBit
    ,[intItemLocationId]                = ICIL.[intItemLocationId]
    ,[dblLastCost]                      = ICIP.[dblLastCost]
    ,[intCategoryId]                    = ICI.[intCategoryId]
    ,[ysnRetailValuation]				= ICC.[ysnRetailValuation]
    ,[dblPrice]                         = ARID.[dblPrice]
    ,[dblBasePrice]                     = ARID.[dblBasePrice]
    ,[dblUnitPrice]                     = ARID.[dblUnitPrice]
    ,[dblBaseUnitPrice]                 = ARID.[dblBaseUnitPrice]
    ,[strPricing]                       = ARID.[strPricing]
    ,[dblDiscount]                      = ARID.[dblDiscount]
    ,[dblDiscountAmount]				= ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), @Precision)), @Precision), @ZeroDecimal)
    ,[dblBaseDiscountAmount]            = ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), @Precision)), @Precision), @ZeroDecimal)
    ,[dblTotal]                         = ARID.[dblTotal]
    ,[dblBaseTotal]                     = ARID.[dblBaseTotal]
    ,[dblLineItemGLAmount]              = ISNULL(ARID.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblPrice), @Precision)), @Precision)
    ,[dblBaseLineItemGLAmount]          = ISNULL(ARID.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblBasePrice), @Precision)), @Precision)
    ,[intCurrencyExchangeRateTypeId]    = ARID.[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]          = ARID.[dblCurrencyExchangeRate]
    ,[strCurrencyExchangeRateType]      = SMCERT.[strCurrencyExchangeRateType]
    ,[intLotId]                         = ARID.[intLotId]
    ,[intOriginalInvoiceDetailId]       = ARID.[intOriginalInvoiceDetailId]
    ,[strMaintenanceType]               = ARID.[strMaintenanceType]
    ,[strFrequency]                     = ARID.[strFrequency]
    ,[dtmMaintenanceDate]               = ARID.[dtmMaintenanceDate]
    ,[dblLicenseAmount]                 = ARID.[dblLicenseAmount]
    ,[dblBaseLicenseAmount]             = ARID.[dblBaseLicenseAmount]
    ,[dblLicenseGLAmount]               = (CASE WHEN ARID.[strMaintenanceType] = 'License Only'
                                                      THEN ISNULL(ARID.[dblTotal], @ZeroDecimal) + (CASE WHEN (ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), @Precision)), @Precision) END)
                                                      ELSE
                                                            (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
																THEN
																	[dbo].fnRoundBanker(ARID.[dblTotal] * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, @Precision), @Precision)/ @OneHundredDecimal), @Precision) 
																	+
																	(CASE WHEN ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0  
																	      THEN @ZeroDecimal 
																		  ELSE [dbo].fnRoundBanker(
																	                 ([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), @Precision)), @Precision))
																		             *
																					 ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, @Precision), @Precision)/ @OneHundredDecimal)
																			   , @Precision) 
																     END) 
																ELSE
																	[dbo].fnRoundBanker((ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), @Precision)		
                                                            END)
                                                END)
    ,[dblBaseLicenseGLAmount]           = (CASE WHEN ARID.[strMaintenanceType] = 'License Only'
                                                      THEN ISNULL(ARID.[dblBaseTotal], @ZeroDecimal) + (CASE WHEN (ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), @Precision)), @Precision) END)
                                                      ELSE
                                                            (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
																THEN
																	[dbo].fnRoundBanker(ARID.[dblBaseTotal] * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, @Precision), @Precision)/ @OneHundredDecimal), @Precision) 
																	+
																	(CASE WHEN ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0  
																	      THEN @ZeroDecimal 
																		  ELSE [dbo].fnRoundBanker(
																	                 ([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), @Precision)), @Precision))
																		             *
																					 ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, @Precision), @Precision)/ @OneHundredDecimal)
																			   , @Precision) 
																     END) 
																ELSE
																	[dbo].fnRoundBanker((ISNULL(ARID.[dblBaseLicenseAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), @Precision)		
                                                            END)
                                                END)
    ,[dblMaintenanceAmount]             = ARID.[dblMaintenanceAmount]
    ,[dblBaseMaintenanceAmount]         = ARID.[dblBaseMaintenanceAmount]
    ,[dblMaintenanceGLAmount]             = (CASE WHEN ARID.[strMaintenanceType] IN ('Maintenance Only', 'SaaS')
                                                      THEN ISNULL(ARID.[dblTotal], @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.dblPrice), @Precision)), @Precision)
                                                      ELSE
                                                           (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
                                                               THEN
                                                                   [dbo].fnRoundBanker(ARID.[dblTotal] * ([dbo].fnRoundBanker(((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, @Precision)/ @OneHundredDecimal), @Precision) 
																         + 
																         [dbo].fnRoundBanker(([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), @Precision)), @Precision)) * ([dbo].fnRoundBanker(((ISNULL(ARID.dblBaseMaintenanceAmount, @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, @Precision)/ @OneHundredDecimal)
																   , @Precision) 
                                                               ELSE
                                                                   [dbo].fnRoundBanker((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), @Precision)		
                                                           END)
                                          END)
    ,[dblBaseMaintenanceGLAmount]         = (CASE WHEN ARID.[strMaintenanceType] IN ('Maintenance Only', 'SaaS')
                                                      THEN ISNULL(ARID.[dblBaseTotal], @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.dblBasePrice), @Precision)), @Precision)
                                                      ELSE
                                                           (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
                                                               THEN
                                                                   [dbo].fnRoundBanker(ARID.[dblBaseTotal] * ([dbo].fnRoundBanker(((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, @Precision)/ @OneHundredDecimal), @Precision) 
																         + 
																         [dbo].fnRoundBanker(([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), @Precision)), @Precision)) * ([dbo].fnRoundBanker(((ISNULL(ARID.dblBaseMaintenanceAmount, @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, @Precision)/ @OneHundredDecimal)
																   , @Precision) 
                                                               ELSE
                                                                   [dbo].fnRoundBanker((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), @Precision)		
                                                           END)
                                          END)
    ,[ysnLeaseBilling]                  = ARID.[ysnLeaseBilling]
    ,[intSiteId]                        = ARID.[intSiteId]
    ,[intPerformerId]                   = ARID.[intPerformerId]
    ,[intContractHeaderId]              = ARID.[intContractHeaderId]
    ,[intContractDetailId]              = ARID.[intContractDetailId]
    ,[intInventoryShipmentItemId]       = ARID.[intInventoryShipmentItemId]
    ,[intInventoryShipmentChargeId]     = ARID.[intInventoryShipmentChargeId]
    ,[intSalesOrderDetailId]            = ARID.[intSalesOrderDetailId]
    ,[intLoadDetailId]                  = ARID.[intLoadDetailId]
    ,[intShipmentId]                    = ARID.[intShipmentId]
    ,[intTicketId]                      = ARID.[intTicketId]
    ,[intDiscountAccountId]             = ISNULL(SMCL.intSalesDiscounts, @DiscountAccountId)
    ,[intCustomerStorageId]             = ARID.[intCustomerStorageId]
    ,[intStorageScheduleTypeId]         = ARID.[intStorageScheduleTypeId]
    ,[intSubLocationId]                 = ISNULL(ARID.[intCompanyLocationSubLocationId], (CASE WHEN ICI.[ysnAutoBlend] = 1 THEN ICIL.[intSubLocationId] ELSE ISNULL(ARID.[intCompanyLocationSubLocationId], ARID.[intSubLocationId]) END))
    ,[intStorageLocationId]             = ARID.[intStorageLocationId]
    ,[ysnAutoBlend]                     = ICI.[ysnAutoBlend]
    ,[ysnBlended]                       = ARID.[ysnBlended]    
    ,[strDescription]                   = ISNULL(GL.strDescription, '') + ' Item: ' + ISNULL(ARID.strItemDescription, '') + ', Qty: ' + CAST(CAST(ARID.dblQtyShipped AS NUMERIC(18, 2)) AS nvarchar(100)) + ', Price: ' + CAST(CAST(ARID.dblPrice AS NUMERIC(18, 2)) AS nvarchar(100))		
	,[strBOLNumber]						= ARI.strBOLNumber
FROM ##ARPostInvoiceHeader ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblSMCompanyLocation SMCL ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
INNER JOIN tblICItem ICI WITH (NOLOCK) ON ARID.[intItemId] = ICI.[intItemId]
LEFT OUTER JOIN tblICCategory ICC WITH (NOLOCK) ON ICI.[intCategoryId] = ICC.[intCategoryId]
LEFT OUTER JOIN tblICItemLocation ICIL WITH (NOLOCK) ON ICI.[intItemId] = ICIL.[intItemId] AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
LEFT OUTER JOIN tblICItemPricing ICIP WITH (NOLOCK) ON ICI.[intItemId] = ICIP.[intItemId] AND ICIL.[intItemLocationId] = ICIP.[intItemLocationId]
LEFT OUTER JOIN tblICItemUOM ICIU WITH (NOLOCK) ON ARID.[intItemUOMId] = ICIU.[intItemUOMId]
LEFT OUTER JOIN tblSMCurrencyExchangeRateType SMCERT WITH (NOLOCK) ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN tblGLAccount GL ON ARID.intSalesAccountId = GL.intAccountId
WHERE ICI.strType NOT IN ('Inventory', 'Finished Good', 'Raw Material')

--MISC ITEMS
INSERT ##ARPostInvoiceDetail WITH (TABLOCK)
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
    ,[ysnFromProvisional]
    ,[dtmDatePosted]
    ,[strBatchId]
    ,[ysnPost]
    ,[ysnRecap]
    ,[intEntityId]
    ,[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]
    ,[ysnForApproval]
    ,[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]
    ,[ysnRefundProcessed]
    ,[ysnIsInvoicePositive]
    ,[ysnCancelled]
    ,[ysnPaid]
    ,[strPONumber]

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
    ,[dblMaintenanceAmount]
    ,[dblBaseMaintenanceAmount]
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
    ,[strDescription]
	,[strBOLNumber]
)
SELECT 
     [intInvoiceId]                     = ARI.[intInvoiceId]
    ,[strInvoiceNumber]                 = ARI.[strInvoiceNumber]
    ,[strTransactionType]               = ARI.[strTransactionType]
    ,[strType]                          = ARI.[strType]
    ,[dtmDate]                          = ARI.[dtmDate]
    ,[dtmPostDate]                      = ARI.[dtmPostDate]
    ,[dtmShipDate]                      = ISNULL(ARI.[dtmShipDate], ARI.[dtmPostDate])
    ,[intEntityCustomerId]              = ARI.[intEntityCustomerId]
    ,[strCustomerNumber]                = ARI.[strCustomerNumber]
    ,[ysnCustomerActive]                = ARI.[ysnCustomerActive]
    ,[dblCustomerCreditLimit]           = ARI.[dblCustomerCreditLimit]
    ,[intCompanyLocationId]             = ARI.[intCompanyLocationId]
    ,[strCompanyLocationName]           = ARI.[strCompanyLocationName]
    ,[intAccountId]                     = ARI.[intAccountId]
    ,[intAPAccount]                     = ARI.[intAPAccount]
    ,[intFreightIncome]                 = ARI.[intFreightIncome]
    ,[intDeferredRevenueAccountId]      = ARI.[intDeferredRevenueAccountId]
    ,[intUndepositedFundsId]			= ARI.[intUndepositedFundsId]
    ,[intProfitCenter]                  = ARI.[intProfitCenter]
    ,[intLocationSalesAccountId]        = ARI.[intLocationSalesAccountId]
    ,[intCurrencyId]                    = ARI.[intCurrencyId]
    ,[dblAverageExchangeRate]           = ARI.[dblAverageExchangeRate]
    ,[intTermId]                        = ARI.[intTermId]
    ,[dblInvoiceTotal]                  = ARI.[dblInvoiceTotal]
    ,[dblBaseInvoiceTotal]              = ARI.[dblBaseInvoiceTotal]
    ,[dblShipping]                      = ARI.[dblShipping]
    ,[dblBaseShipping]                  = ARI.[dblBaseShipping]
    ,[dblTax]                           = ARI.[dblTax]
    ,[dblBaseTax]                       = ARI.[dblBaseTax]
    ,[dblAmountDue]                     = ARI.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARI.[dblBaseAmountDue]
    ,[dblPayment]                       = ARI.[dblPayment]
    ,[dblBasePayment]                   = ARI.[dblBasePayment]
    ,[dblProvisionalAmount]             = ARI.[dblProvisionalAmount]
    ,[dblBaseProvisionalAmount]         = ARI.[dblBaseProvisionalAmount]
    ,[strComments]                      = ARI.[strComments]
    ,[strImportFormat]                  = ARI.[strImportFormat]
    ,[intSourceId]                      = ARI.[intSourceId]
    ,[intOriginalInvoiceId]             = ARI.[intOriginalInvoiceId]
    ,[strInvoiceOriginId]               = ARI.[strInvoiceOriginId]
    ,[intDistributionHeaderId]          = ARI.[intDistributionHeaderId]
    ,[intLoadDistributionHeaderId]      = ARI.[intLoadDistributionHeaderId]
    ,[intLoadId]                        = ARI.[intLoadId]
    ,[intFreightTermId]                 = ARI.[intFreightTermId]
    ,[strActualCostId]                  = ARI.[strActualCostId]
    ,[intPeriodsToAccrue]               = ARI.[intPeriodsToAccrue]
    ,[ysnAccrueLicense]                 = ARI.[ysnAccrueLicense]
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ARI.[ysnImpactInventory]
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[ysnFromProvisional]               = ARI.[ysnFromProvisional]
    ,[dtmDatePosted]                    = ARI.[dtmDatePosted]
    ,[strBatchId]                       = ARI.[strBatchId]
    ,[ysnPost]                          = ARI.[ysnPost]
    ,[ysnRecap]                         = ARI.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = ARI.[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]	= ARI.[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]          = ARI.[ysnWithinAccountingDate]
    ,[ysnForApproval]                   = ARI.[ysnForApproval]
    ,[ysnProvisionalWithGL]             = ARI.[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]     = ARI.[ysnExcludeInvoiceFromPayment]
    ,[ysnRefundProcessed]               = ARI.[ysnRefundProcessed]
    ,[ysnIsInvoicePositive]             = ARI.[ysnIsInvoicePositive]
    ,[ysnCancelled]                     = ARI.[ysnCancelled]
    ,[ysnPaid]                          = ARI.[ysnPaid]
    ,[strPONumber]                      = ARI.[strPONumber]

    ,[intInvoiceDetailId]               = ARID.[intInvoiceDetailId]
    ,[intItemId]                        = NULL
    ,[strItemNo]                        = ''
    ,[strItemType]                      = ''
    ,[strItemManufactureType]           = ''
    ,[strItemDescription]               = ARID.[strItemDescription]
    ,[intItemUOMId]                     = ARID.[intItemUOMId]
    ,[intItemWeightUOMId]               = ARID.[intItemWeightUOMId]
    ,[intItemAccountId]                 = ARID.[intAccountId]
    ,[intServiceChargeAccountId]        = ARID.[intServiceChargeAccountId]
	,[intSalesAccountId]                = ISNULL(ARID.[intSalesAccountId], ARI.[intLocationSalesAccountId])
    ,[intCOGSAccountId]                 = ARID.[intCOGSAccountId]
    ,[intInventoryAccountId]            = ARID.[intInventoryAccountId]
    ,[intLicenseAccountId]              = ARID.[intLicenseAccountId]
    ,[intMaintenanceAccountId]          = ARID.[intMaintenanceAccountId]
    ,[intConversionAccountId]           = ARID.[intConversionAccountId]
    ,[dblQtyShipped]                    = ARID.[dblQtyShipped]
    ,[dblUnitQtyShipped]                = @ZeroDecimal
    ,[dblShipmentNetWt]                 = @ZeroDecimal
    ,[dblUnitQty]                       = @ZeroDecimal
    ,[dblUnitOnHand]                    = @ZeroDecimal
    ,[intAllowNegativeInventory]        = NULL
    ,[ysnStockTracking]					= @ZeroBit
    ,[intItemLocationId]                = NULL
    ,[dblLastCost]                      = @ZeroDecimal
    ,[intCategoryId]                    = NULL
    ,[ysnRetailValuation]				= @ZeroBit
    ,[dblPrice]                         = ARID.[dblPrice]
    ,[dblBasePrice]                     = ARID.[dblBasePrice]
    ,[dblUnitPrice]                     = ARID.[dblUnitPrice]
    ,[dblBaseUnitPrice]                 = ARID.[dblBaseUnitPrice]
    ,[strPricing]                       = ARID.[strPricing]
    ,[dblDiscount]                      = ARID.[dblDiscount]
    ,[dblDiscountAmount]				= ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), @Precision)), @Precision), @ZeroDecimal)
    ,[dblBaseDiscountAmount]            = ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), @Precision)), @Precision), @ZeroDecimal)
    ,[dblTotal]                         = ARID.[dblTotal]
    ,[dblBaseTotal]                     = ARID.[dblBaseTotal]
    ,[dblLineItemGLAmount]              = ISNULL(ARID.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblPrice), @Precision)), @Precision)
    ,[dblBaseLineItemGLAmount]          = ISNULL(ARID.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblBasePrice), @Precision)), @Precision)
    ,[intCurrencyExchangeRateTypeId]    = ARID.[intCurrencyExchangeRateTypeId]
    ,[dblCurrencyExchangeRate]          = ARID.[dblCurrencyExchangeRate]
    ,[strCurrencyExchangeRateType]      = SMCERT.[strCurrencyExchangeRateType]
    ,[intLotId]                         = ARID.[intLotId]
    ,[intOriginalInvoiceDetailId]       = ARID.[intOriginalInvoiceDetailId]
    ,[strMaintenanceType]               = ARID.[strMaintenanceType]
    ,[strFrequency]                     = ARID.[strFrequency]
    ,[dtmMaintenanceDate]               = ARID.[dtmMaintenanceDate]
    ,[dblLicenseAmount]                 = ARID.[dblLicenseAmount]
    ,[dblBaseLicenseAmount]             = ARID.[dblBaseLicenseAmount]
    ,[dblMaintenanceAmount]             = ARID.[dblMaintenanceAmount]
    ,[dblBaseMaintenanceAmount]         = ARID.[dblBaseMaintenanceAmount]
    ,[ysnLeaseBilling]                  = ARID.[ysnLeaseBilling]
    ,[intSiteId]                        = ARID.[intSiteId]
    ,[intPerformerId]                   = ARID.[intPerformerId]
    ,[intContractHeaderId]              = ARID.[intContractHeaderId]
    ,[intContractDetailId]              = ARID.[intContractDetailId]
    ,[intInventoryShipmentItemId]       = ARID.[intInventoryShipmentItemId]
    ,[intInventoryShipmentChargeId]     = ARID.[intInventoryShipmentChargeId]
    ,[intSalesOrderDetailId]            = ARID.[intSalesOrderDetailId]
    ,[intLoadDetailId]                  = ARID.[intLoadDetailId]
    ,[intShipmentId]                    = ARID.[intShipmentId]
    ,[intTicketId]                      = ARID.[intTicketId]
    ,[intDiscountAccountId]             = ISNULL(SMCL.intSalesDiscounts, @DiscountAccountId)
    ,[intCustomerStorageId]             = ARID.[intCustomerStorageId]
    ,[intStorageScheduleTypeId]         = ARID.[intStorageScheduleTypeId]
    ,[intSubLocationId]                 = ISNULL(ARID.[intCompanyLocationSubLocationId], ARID.[intSubLocationId])
    ,[intStorageLocationId]             = ARID.[intStorageLocationId]
    ,[ysnAutoBlend]                     = @ZeroBit
    ,[ysnBlended]                       = @ZeroBit
    ,[strDescription]                   = ISNULL(GL.strDescription, '') + ' Item: ' + ISNULL(ARID.strItemDescription, '') + ', Qty: ' + CAST(CAST(ARID.dblQtyShipped AS NUMERIC(18, 2)) AS nvarchar(100)) + ', Price: ' + CAST(CAST(ARID.dblPrice AS NUMERIC(18, 2)) AS nvarchar(100))		
	,[strBOLNumber]						= ARI.strBOLNumber
FROM ##ARPostInvoiceHeader ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblSMCompanyLocation SMCL ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN tblSMCurrencyExchangeRateType SMCERT WITH(NOLOCK) ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN tblGLAccount GL ON ARID.intSalesAccountId = GL.intAccountId
WHERE ARID.[intItemId] IS NULL
   OR ARID.[intItemId] = 0

UPDATE ID
SET dblTaxesAddToCost       = IDD.dblTaxesAddToCost
  , dblBaseTaxesAddToCost   = IDD.dblBaseTaxesAddToCost
FROM ##ARPostInvoiceDetail ID
INNER JOIN (
    SELECT dblTaxesAddToCost       = SUM(TAXES.dblTaxesAddToCost)
         , dblBaseTaxesAddToCost   = SUM(TAXES.dblBaseTaxesAddToCost)
         , intInvoiceDetailId      = ID.intInvoiceDetailId
    FROM ##ARPostInvoiceDetail ID
    CROSS APPLY (
        SELECT dblTaxesAddToCost        = ISNULL(dblAdjustedTax, 0)
            , dblBaseTaxesAddToCost     = ISNULL(dblBaseAdjustedTax, 0)
        FROM tblARInvoiceDetailTax IDT
        INNER JOIN tblSMTaxCode TC ON IDT.intTaxCodeId = TC.intTaxCodeId
        WHERE TC.ysnAddToCost = 1
        AND IDT.intInvoiceDetailId = ID.intInvoiceDetailId    
    ) TAXES
    GROUP BY ID.intInvoiceDetailId
) IDD ON ID.intInvoiceDetailId = IDD.intInvoiceDetailId

RETURN 1