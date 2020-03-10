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

SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WHERE intEntityUserSecurityId = @UserId)
SET @Param2 = (CASE WHEN UPPER(@Param) = 'ALL' THEN '' ELSE @Param END)

--Header
INSERT #ARPostInvoiceHeader
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
    ,[dblTax]                           = ISNULL(ARI.[dblTax], @ZeroDecimal)
    ,[dblBaseTax]                       = ISNULL(ARI.[dblBaseTax], @ZeroDecimal)
    ,[dblAmountDue]                     = ARI.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARI.[dblBaseAmountDue]
    ,[dblPayment]                       = ISNULL(ARI.[dblPayment], @ZeroDecimal)
    ,[dblBasePayment]                   = ISNULL(ARI.[dblBasePayment], @ZeroDecimal)
    ,[dblProvisionalAmount]             = ISNULL(ARI.[dblProvisionalAmount], @ZeroDecimal)
    ,[dblBaseProvisionalAmount]         = ISNULL(ARI.[dblBaseProvisionalAmount], @ZeroDecimal)
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
    ,[intPeriodsToAccrue]               = ISNULL(ARI.[intPeriodsToAccrue], 1)
    ,[ysnAccrueLicense]                 = ISNULL(@AccrueLicense, @ZeroBit)
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ISNULL(ARI.[ysnImpactInventory], CAST(1 AS BIT))
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[ysnFromProvisional]               = ISNULL(ARI.[ysnFromProvisional], @ZeroBit)
    ,[dtmDatePosted]                    = @PostDate
    ,[strBatchId]                       = @BatchId
    ,[ysnPost]                          = @Post
    ,[ysnRecap]                         = @Recap
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]	= ISNULL(@AllowOtherUserToPost, @ZeroBit)
    ,[ysnWithinAccountingDate]          = @ZeroBit --ISNULL(dbo.isOpenAccountingDate(ISNULL(ARI.[dtmPostDate], ARI.[dtmDate])), @ZeroBit)
    ,[ysnForApproval]                   = (CASE WHEN FAT.[intTransactionId] IS NOT NULL THEN @OneBit ELSE @ZeroBit END)
    ,[ysnProvisionalWithGL]             = (CASE WHEN ARI.[strType] = 'Provisional' THEN @ImpactForProvisional ELSE ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit) END)
    ,[ysnExcludeInvoiceFromPayment]     = ISNULL(@ExcludeInvoiceFromPayment, @ZeroBit)
    ,[ysnRefundProcessed]               = ISNULL(ARI.[ysnRefundProcessed], @ZeroBit)
    ,[ysnIsInvoicePositive]             = (CASE WHEN [dbo].[fnARGetInvoiceAmountMultiplier](ARI.[strTransactionType]) = @OneDecimal THEN @OneBit ELSE @ZeroBit END)

    ,[intInvoiceDetailId]               = NULL
    ,[intItemId]                        = NULL
    ,[strItemNo]                        = NULL
    ,[strItemType]                      = NULL
    ,[strItemManufactureType]           = NULL
    ,[strItemDescription]               = NULL
    ,[intItemUOMId]                     = NULL
    ,[intItemWeightUOMId]               = NULL
    ,[intItemAccountId]                 = NULL
    ,[intServiceChargeAccountId]        = NULL
    ,[intSalesAccountId]                = NULL
    ,[intCOGSAccountId]                 = NULL
    ,[intInventoryAccountId]            = NULL
    ,[intLicenseAccountId]              = NULL
    ,[intMaintenanceAccountId]          = NULL
    ,[intConversionAccountId]           = NULL
    ,[dblQtyShipped]                    = @ZeroDecimal
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
    ,[dblPrice]                         = @ZeroDecimal
    ,[dblBasePrice]                     = @ZeroDecimal
    ,[dblUnitPrice]                     = @ZeroDecimal
    ,[dblBaseUnitPrice]                 = @ZeroDecimal
    ,[strPricing]                       = NULL
    ,[dblDiscount]                      = @ZeroDecimal
    ,[dblDiscountAmount]				= @ZeroDecimal
    ,[dblBaseDiscountAmount]            = @ZeroDecimal
    ,[dblTotal]                         = @ZeroDecimal
    ,[dblBaseTotal]                     = @ZeroDecimal
    ,[dblLineItemGLAmount]              = @ZeroDecimal
    ,[dblBaseLineItemGLAmount]          = @ZeroDecimal
    ,[intCurrencyExchangeRateTypeId]    = NULL
    ,[dblCurrencyExchangeRate]          = @OneDecimal
    ,[strCurrencyExchangeRateType]      = NULL
    ,[intLotId]                         = NULL
    ,[intOriginalInvoiceDetailId]       = NULL
    ,[strMaintenanceType]               = NULL
    ,[strFrequency]                     = NULL
    ,[dtmMaintenanceDate]               = @ZeroDecimal
    ,[dblLicenseAmount]                 = @ZeroDecimal
    ,[dblBaseLicenseAmount]             = @ZeroDecimal
    ,[dblLicenseGLAmount]               = @ZeroDecimal
    ,[dblBaseLicenseGLAmount]           = @ZeroDecimal
    ,[dblMaintenanceAmount]             = @ZeroDecimal
    ,[dblBaseMaintenanceAmount]         = @ZeroDecimal
    ,[dblMaintenanceGLAmount]           = @ZeroDecimal
    ,[dblBaseMaintenanceGLAmount]       = @ZeroDecimal
    ,[ysnTankRequired]                  = @ZeroBit
    ,[ysnLeaseBilling]                  = @ZeroBit
    ,[intSiteId]                        = NULL
    ,[intPerformerId]                   = NULL
    ,[intContractHeaderId]              = NULL
    ,[intContractDetailId]              = NULL
    ,[intInventoryShipmentItemId]       = NULL
    ,[intInventoryShipmentChargeId]     = NULL
    ,[intSalesOrderDetailId]            = NULL
    ,[intLoadDetailId]                  = NULL
    ,[intShipmentId]                    = NULL
    ,[intTicketId]                      = NULL
    ,[intDiscountAccountId]             = ISNULL(SMCL.intSalesDiscounts, @DiscountAccountId)
    ,[intCustomerStorageId]             = NULL
    ,[intStorageScheduleTypeId]         = NULL
    ,[intSubLocationId]                 = NULL
    ,[intStorageLocationId]             = NULL
    ,[ysnAutoBlend]                     = @ZeroBit
    ,[ysnBlended]                       = @ZeroBit
    ,[dblQuantity]                      = @ZeroDecimal
    ,[dblMaxQuantity]                   = @ZeroDecimal
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = CASE WHEN ARI.[strType] = 'Provisional' AND @ImpactForProvisional = @OneBit THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARC.[strName]),'')), 1, 255)
                                                WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARC.[strName]),'')), 1 , 255)
                                                ELSE ARI.[strTransactionType] + ' for ' + ISNULL(ARC.strName, '')
                                            END		
    
FROM tblARInvoice ARI
INNER JOIN (
    SELECT C.[intEntityId], EM.strName, [strCustomerNumber], C.[ysnActive], [dblCreditLimit] FROM tblARCustomer C WITH(NoLock)
    INNER JOIN tblEMEntity EM ON C.intEntityId = EM.intEntityId
) ARC ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
LEFT OUTER JOIN (
    SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId], [intAPAccount], [intFreightIncome], [intProfitCenter], [intSalesAccount], [intSalesDiscounts] FROM tblSMCompanyLocation  WITH(NoLock)
) SMCL ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN (
    SELECT [intTransactionId] FROM vyuARForApprovalTransction  WITH (NOLOCK) WHERE [strScreenName] = 'Invoice'
) FAT ON ARI.[intInvoiceId] = FAT.[intTransactionId]
WHERE
	NOT EXISTS(SELECT NULL FROM #ARPostInvoiceHeader IH WHERE IH.[intInvoiceId] = ARI.[intInvoiceId])
    AND (
            (
				RTRIM(LTRIM(ISNULL(@Param,''))) <> ''
				AND
				(
					(UPPER(@Param) = 'ALL' AND ARI.[ysnPosted] = 0 AND (ARI.[strTransactionType] = @TransType OR @TransType = 'all'))
					OR
					(UPPER(@Param) <> 'ALL' AND EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@Param2) DV WHERE DV.[intID] = ARI.[intInvoiceId]))
				)
            )
			OR
            (
				@BeginDate IS NOT NULL
				AND (ARI.[strTransactionType] = @TransType OR @TransType = 'all')					
				AND CAST(ARI.[dtmDate] AS DATE) BETWEEN CAST(@BeginDate AS DATE) AND CAST(@EndDate AS DATE)
            )
			OR
            (
				@BeginTransaction IS NOT NULL
				AND (ARI.[strTransactionType] = @TransType OR @TransType = 'all')
				AND ARI.[intInvoiceId] BETWEEN @BeginTransaction AND @EndTransaction
            )
        )

INSERT #ARPostInvoiceHeader
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
    ,[dblTax]                           = ISNULL(ARI.[dblTax], @ZeroDecimal)
    ,[dblBaseTax]                       = ISNULL(ARI.[dblBaseTax], @ZeroDecimal)
    ,[dblAmountDue]                     = ARI.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARI.[dblBaseAmountDue]
    ,[dblPayment]                       = ISNULL(ARI.[dblPayment], @ZeroDecimal)
    ,[dblBasePayment]                   = ISNULL(ARI.[dblBasePayment], @ZeroDecimal)
    ,[dblProvisionalAmount]             = ISNULL(ARI.[dblProvisionalAmount], @ZeroDecimal)
    ,[dblBaseProvisionalAmount]         = ISNULL(ARI.[dblBaseProvisionalAmount], @ZeroDecimal)
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
    ,[intPeriodsToAccrue]               = ISNULL(ARI.[intPeriodsToAccrue], 1)
    ,[ysnAccrueLicense]                 = ISNULL([ysnAccrueLicense], @ZeroBit)
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ISNULL(ARI.[ysnImpactInventory], CAST(1 AS BIT))
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[ysnFromProvisional]               = ISNULL(ARI.[ysnFromProvisional], @ZeroBit)
    ,[dtmDatePosted]                    = @PostDate
    ,[strBatchId]                       = CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARILD.[strBatchId],'')))) > 0 THEN ARILD.[strBatchId] ELSE @BatchId END
    ,[ysnPost]                          = ARILD.[ysnPost]
    ,[ysnRecap]                         = ARILD.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]	= ISNULL(@AllowOtherUserToPost, @ZeroBit)
    ,[ysnWithinAccountingDate]          = @ZeroBit --ISNULL(dbo.isOpenAccountingDate(ISNULL(ARI.[dtmPostDate], ARI.[dtmDate])), @ZeroBit)
    ,[ysnForApproval]                   = (CASE WHEN FAT.[intTransactionId] IS NOT NULL THEN @OneBit ELSE @ZeroBit END)
    ,[ysnProvisionalWithGL]             = (CASE WHEN ARI.[strType] = 'Provisional' THEN @ImpactForProvisional ELSE ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit) END)
    ,[ysnExcludeInvoiceFromPayment]     = ISNULL(@ExcludeInvoiceFromPayment, @ZeroBit)
    ,[ysnRefundProcessed]               = ISNULL(ARI.[ysnRefundProcessed], @ZeroBit)
    ,[ysnIsInvoicePositive]             = (CASE WHEN [dbo].[fnARGetInvoiceAmountMultiplier](ARI.[strTransactionType]) = 1 THEN @OneBit ELSE @ZeroBit END)

    ,[intInvoiceDetailId]               = NULL
    ,[intItemId]                        = NULL
    ,[strItemNo]                        = NULL
    ,[strItemType]                      = NULL
    ,[strItemManufactureType]           = NULL
    ,[strItemDescription]               = NULL
    ,[intItemUOMId]                     = NULL
    ,[intItemWeightUOMId]               = NULL
    ,[intItemAccountId]                 = NULL
    ,[intServiceChargeAccountId]        = NULL
    ,[intSalesAccountId]                = NULL
    ,[intCOGSAccountId]                 = NULL
    ,[intInventoryAccountId]            = NULL
    ,[intLicenseAccountId]              = NULL
    ,[intMaintenanceAccountId]          = NULL
    ,[intConversionAccountId]           = NULL
    ,[dblQtyShipped]                    = @ZeroDecimal
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
    ,[dblPrice]                         = @ZeroDecimal
    ,[dblBasePrice]                     = @ZeroDecimal
    ,[dblUnitPrice]                     = @ZeroDecimal
    ,[dblBaseUnitPrice]                 = @ZeroDecimal
    ,[strPricing]                       = NULL
    ,[dblDiscount]                      = @ZeroDecimal
    ,[dblDiscountAmount]				= @ZeroDecimal
    ,[dblBaseDiscountAmount]            = @ZeroDecimal
    ,[dblTotal]                         = @ZeroDecimal
    ,[dblBaseTotal]                     = @ZeroDecimal
    ,[dblLineItemGLAmount]              = @ZeroDecimal
    ,[dblBaseLineItemGLAmount]          = @ZeroDecimal
    ,[intCurrencyExchangeRateTypeId]    = NULL
    ,[dblCurrencyExchangeRate]          = @OneDecimal
    ,[strCurrencyExchangeRateType]      = NULL
    ,[intLotId]                         = NULL
    ,[intOriginalInvoiceDetailId]       = NULL
    ,[strMaintenanceType]               = NULL
    ,[strFrequency]                     = NULL
    ,[dtmMaintenanceDate]               = @ZeroDecimal
    ,[dblLicenseAmount]                 = @ZeroDecimal
    ,[dblBaseLicenseAmount]             = @ZeroDecimal
    ,[dblLicenseGLAmount]               = @ZeroDecimal
    ,[dblBaseLicenseGLAmount]           = @ZeroDecimal
    ,[dblMaintenanceAmount]             = @ZeroDecimal
    ,[dblBaseMaintenanceAmount]         = @ZeroDecimal
    ,[dblMaintenanceGLAmount]           = @ZeroDecimal
    ,[dblBaseMaintenanceGLAmount]       = @ZeroDecimal
    ,[ysnTankRequired]                  = @ZeroBit
    ,[ysnLeaseBilling]                  = @ZeroBit
    ,[intSiteId]                        = NULL
    ,[intPerformerId]                   = NULL
    ,[intContractHeaderId]              = NULL
    ,[intContractDetailId]              = NULL
    ,[intInventoryShipmentItemId]       = NULL
    ,[intInventoryShipmentChargeId]     = NULL
    ,[intSalesOrderDetailId]            = NULL
    ,[intLoadDetailId]                  = NULL
    ,[intShipmentId]                    = NULL
    ,[intTicketId]                      = NULL
    ,[intDiscountAccountId]             = ISNULL(SMCL.intSalesDiscounts, @DiscountAccountId)
    ,[intCustomerStorageId]             = NULL
    ,[intStorageScheduleTypeId]         = NULL
    ,[intSubLocationId]                 = NULL
    ,[intStorageLocationId]             = NULL
    ,[ysnAutoBlend]                     = @ZeroBit
    ,[ysnBlended]                       = @ZeroBit
    ,[dblQuantity]                      = @ZeroDecimal
    ,[dblMaxQuantity]                   = @ZeroDecimal
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = CASE WHEN ARI.[strType] = 'Provisional' AND @ImpactForProvisional = @OneBit THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARC.[strName]),'')), 1, 255)
                                                WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARC.[strName]),'')), 1 , 255)
                                                ELSE ARI.[strTransactionType] + ' for ' + ISNULL(ARC.strName, '')
                                            END		
    
FROM
    (
    SELECT LD.[intInvoiceId], LD.[ysnPost], LD.[ysnRecap], LD.[ysnAccrueLicense], LD.[strBatchId] FROM tblARInvoiceIntegrationLogDetail LD
    WHERE 
        LD.[intIntegrationLogId] = @IntegrationLogId
        AND NOT EXISTS(SELECT NULL FROM #ARPostInvoiceHeader IH WHERE LD.[intInvoiceId] = IH.[intInvoiceId])
        AND LD.[ysnHeader] = 1
		AND ISNULL(LD.[ysnPosted],0) <> @Post
        AND LD.[ysnPost] = @Post
    ) ARILD
INNER JOIN
    tblARInvoice ARI
        ON ARILD.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
    (
    SELECT C.[intEntityId], EM.strName, [strCustomerNumber], C.[ysnActive], [dblCreditLimit] FROM tblARCustomer C WITH (NOLOCK)
    INNER JOIN tblEMEntity EM ON C.intEntityId = EM.intEntityId
    ) ARC
        ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
LEFT OUTER JOIN
    (
    SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId], [intAPAccount], [intFreightIncome], [intProfitCenter], [intSalesAccount], [intSalesDiscounts] FROM tblSMCompanyLocation  WITH(NoLock)
    ) SMCL
        ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
    (
    SELECT [intTransactionId] FROM vyuARForApprovalTransction  WITH (NOLOCK) WHERE [strScreenName] = 'Invoice'
    ) FAT
        ON ARI.[intInvoiceId] = FAT.[intTransactionId]

INSERT #ARPostInvoiceHeader
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
    ,[dblTax]                           = ISNULL(ARI.[dblTax], @ZeroDecimal)
    ,[dblBaseTax]                       = ISNULL(ARI.[dblBaseTax], @ZeroDecimal)
    ,[dblAmountDue]                     = ARI.[dblAmountDue]
    ,[dblBaseAmountDue]                 = ARI.[dblBaseAmountDue]
    ,[dblPayment]                       = ISNULL(ARI.[dblPayment], @ZeroDecimal)
    ,[dblBasePayment]                   = ISNULL(ARI.[dblBasePayment], @ZeroDecimal)
    ,[dblProvisionalAmount]             = ISNULL(ARI.[dblProvisionalAmount], @ZeroDecimal)
    ,[dblBaseProvisionalAmount]         = ISNULL(ARI.[dblBaseProvisionalAmount], @ZeroDecimal)
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
    ,[intPeriodsToAccrue]               = ISNULL(ARI.[intPeriodsToAccrue], 1)
    ,[ysnAccrueLicense]                 = ISNULL([ysnAccrueLicense], @ZeroBit)
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ISNULL(ARI.[ysnImpactInventory], CAST(1 AS BIT))
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[ysnFromProvisional]               = ISNULL(ARI.[ysnFromProvisional], @ZeroBit)
    ,[dtmDatePosted]                    = @PostDate
    ,[strBatchId]                       = CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARILD.[strBatchId],'')))) > 0 THEN ARILD.[strBatchId] ELSE @BatchId END
    ,[ysnPost]                          = ARILD.[ysnPost]
    ,[ysnRecap]                         = ARILD.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]	= ISNULL(@AllowOtherUserToPost, @ZeroBit)
    ,[ysnWithinAccountingDate]          = @ZeroBit --ISNULL(dbo.isOpenAccountingDate(ISNULL(ARI.[dtmPostDate], ARI.[dtmDate])), @ZeroBit)
    ,[ysnForApproval]                   = (CASE WHEN FAT.[intTransactionId] IS NOT NULL THEN @OneBit ELSE @ZeroBit END)
    ,[ysnProvisionalWithGL]             = (CASE WHEN ARI.[strType] = 'Provisional' THEN @ImpactForProvisional ELSE ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit) END)
    ,[ysnExcludeInvoiceFromPayment]     = ISNULL(@ExcludeInvoiceFromPayment, @ZeroBit)
    ,[ysnRefundProcessed]               = ISNULL(ARI.[ysnRefundProcessed], @ZeroBit)
    ,[ysnIsInvoicePositive]             = (CASE WHEN [dbo].[fnARGetInvoiceAmountMultiplier](ARI.[strTransactionType]) = 1 THEN @OneBit ELSE @ZeroBit END)

    ,[intInvoiceDetailId]               = NULL
    ,[intItemId]                        = NULL
    ,[strItemNo]                        = NULL
    ,[strItemType]                      = NULL
    ,[strItemManufactureType]           = NULL
    ,[strItemDescription]               = NULL
    ,[intItemUOMId]                     = NULL
    ,[intItemWeightUOMId]               = NULL
    ,[intItemAccountId]                 = NULL
    ,[intServiceChargeAccountId]        = NULL
    ,[intSalesAccountId]                = NULL
    ,[intCOGSAccountId]                 = NULL
    ,[intInventoryAccountId]            = NULL
    ,[intLicenseAccountId]              = NULL
    ,[intMaintenanceAccountId]          = NULL
    ,[intConversionAccountId]           = NULL
    ,[dblQtyShipped]                    = @ZeroDecimal
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
    ,[dblPrice]                         = @ZeroDecimal
    ,[dblBasePrice]                     = @ZeroDecimal
    ,[dblUnitPrice]                     = @ZeroDecimal
    ,[dblBaseUnitPrice]                 = @ZeroDecimal
    ,[strPricing]                       = NULL
    ,[dblDiscount]                      = @ZeroDecimal
    ,[dblDiscountAmount]				= @ZeroDecimal
    ,[dblBaseDiscountAmount]            = @ZeroDecimal
    ,[dblTotal]                         = @ZeroDecimal
    ,[dblBaseTotal]                     = @ZeroDecimal
    ,[dblLineItemGLAmount]              = @ZeroDecimal
    ,[dblBaseLineItemGLAmount]          = @ZeroDecimal
    ,[intCurrencyExchangeRateTypeId]    = NULL
    ,[dblCurrencyExchangeRate]          = @OneDecimal
    ,[strCurrencyExchangeRateType]      = NULL
    ,[intLotId]                         = NULL
    ,[intOriginalInvoiceDetailId]       = NULL
    ,[strMaintenanceType]               = NULL
    ,[strFrequency]                     = NULL
    ,[dtmMaintenanceDate]               = @ZeroDecimal
    ,[dblLicenseAmount]                 = @ZeroDecimal
    ,[dblBaseLicenseAmount]             = @ZeroDecimal
    ,[dblLicenseGLAmount]               = @ZeroDecimal
    ,[dblBaseLicenseGLAmount]           = @ZeroDecimal
    ,[dblMaintenanceAmount]             = @ZeroDecimal
    ,[dblBaseMaintenanceAmount]         = @ZeroDecimal
    ,[dblMaintenanceGLAmount]           = @ZeroDecimal
    ,[dblBaseMaintenanceGLAmount]       = @ZeroDecimal
    ,[ysnTankRequired]                  = @ZeroBit
    ,[ysnLeaseBilling]                  = @ZeroBit
    ,[intSiteId]                        = NULL
    ,[intPerformerId]                   = NULL
    ,[intContractHeaderId]              = NULL
    ,[intContractDetailId]              = NULL
    ,[intInventoryShipmentItemId]       = NULL
    ,[intInventoryShipmentChargeId]     = NULL
    ,[intSalesOrderDetailId]            = NULL
    ,[intLoadDetailId]                  = NULL
    ,[intShipmentId]                    = NULL
    ,[intTicketId]                      = NULL
    ,[intDiscountAccountId]             = ISNULL(SMCL.intSalesDiscounts, @DiscountAccountId)
    ,[intCustomerStorageId]             = NULL
    ,[intStorageScheduleTypeId]         = NULL
    ,[intSubLocationId]                 = NULL
    ,[intStorageLocationId]             = NULL
    ,[ysnAutoBlend]                     = @ZeroBit
    ,[ysnBlended]                       = @ZeroBit
    ,[dblQuantity]                      = @ZeroDecimal
    ,[dblMaxQuantity]                   = @ZeroDecimal
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = CASE WHEN ARI.[strType] = 'Provisional' AND @ImpactForProvisional = @OneBit THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARC.[strName]),'')), 1, 255)
                                                WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARC.[strName]),'')), 1 , 255)
                                                ELSE ARI.[strTransactionType] + ' for ' + ISNULL(ARC.strName , '')
                                            END		
    
FROM
    (
    SELECT LD.[intHeaderId] AS 'intInvoiceId', LD.[ysnPost], LD.[ysnRecap], LD.[ysnAccrueLicense], LD.[strBatchId] FROM @InvoiceIds LD
    WHERE 
        NOT EXISTS(SELECT NULL FROM #ARPostInvoiceHeader IH WHERE LD.[intHeaderId] = IH.[intInvoiceId])
		AND LD.[ysnPost] IS NOT NULL 
        AND LD.[ysnPost] = @Post
    ) ARILD
INNER JOIN
    tblARInvoice ARI
        ON ARILD.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
    (
    SELECT C.[intEntityId], EM.strName, [strCustomerNumber], C.[ysnActive], [dblCreditLimit] FROM tblARCustomer C WITH (NOLOCK)
    INNER JOIN tblEMEntity EM ON C.intEntityId = EM.intEntityId
    ) ARC
        ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
LEFT OUTER JOIN
    (
    SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId], [intAPAccount], [intFreightIncome], [intProfitCenter], [intSalesAccount], [intSalesDiscounts] FROM tblSMCompanyLocation  WITH(NoLock)
    ) SMCL
        ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
    (
    SELECT [intTransactionId] FROM vyuARForApprovalTransction  WITH (NOLOCK) WHERE [strScreenName] = 'Invoice'
    ) FAT
        ON ARI.[intInvoiceId] = FAT.[intTransactionId]

--Detail
INSERT #ARPostInvoiceDetail
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
    ,[ysnImpactInventory]               = ISNULL(ARI.[ysnImpactInventory], CAST(1 AS BIT))
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
    --,[dblUnitQtyShipped]                = ISNULL(ARID.[dblQtyShipped], @ZeroDecimal)
    ,[dblShipmentNetWt]                 = ARID.[dblShipmentNetWt]
    ,[dblUnitQty]                       = ICIU.[dblUnitQty]
    ,[dblUnitOnHand]                    = ISNULL(ICIS.[dblUnitOnHand], @ZeroDecimal)
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
    ,[dblDiscountAmount]				= ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal)
    ,[dblBaseDiscountAmount]            = ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal)
    ,[dblTotal]                         = ARID.[dblTotal]
    ,[dblBaseTotal]                     = ARID.[dblBaseTotal]
    ,[dblLineItemGLAmount]              = ISNULL(ARID.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
    ,[dblBaseLineItemGLAmount]          = ISNULL(ARID.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
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
    ,[ysnTankRequired]                  = NULL --ARID.[ysnTankRequired]
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
    ,[ysnAutoBlend]                     = ISNULL(ICI.[ysnAutoBlend], @ZeroBit)
    ,[ysnBlended]                       = ISNULL(ARID.[ysnBlended], @ZeroBit)
    ,[dblQuantity]                      = NULL
    ,[dblMaxQuantity]                   = NULL
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = ISNULL(GL.strDescription, '') + ' Item: ' + ISNULL(ARID.strItemDescription, '') + ', Qty: ' + CAST(CAST(ARID.dblQtyShipped AS NUMERIC(18, 2)) AS nvarchar(100)) + ', Price: ' + CAST(CAST(ARID.dblPrice AS NUMERIC(18, 2)) AS nvarchar(100))
    
FROM #ARPostInvoiceHeader ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblSMCompanyLocation SMCL ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
INNER JOIN (
    SELECT [intItemId], [strItemNo], [strType], [strManufactureType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NOLOCK)
) ICI ON ARID.[intItemId] = ICI.[intItemId]
LEFT OUTER JOIN (
    SELECT [intCategoryId], [ysnRetailValuation] FROM tblICCategory WITH(NOLOCK)
) ICC ON ICI.[intCategoryId] = ICC.[intCategoryId]
INNER JOIN (
    SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NOLOCK)
) ICIL ON ICI.[intItemId] = ICIL.[intItemId]
      AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
LEFT OUTER JOIN (
    SELECT [intItemId], [intItemLocationId], [dblLastCost] FROM tblICItemPricing  WITH(NOLOCK)
) ICIP ON ICI.[intItemId] = ICIP.[intItemId]
      AND ICIL.[intItemLocationId] = ICIP.[intItemLocationId]
LEFT OUTER JOIN (
    SELECT [intItemId], [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH(NOLOCK)
) ICIU ON ARID.[intItemUOMId] = ICIU.[intItemUOMId]
OUTER APPLY (
    SELECT TOP 1 [intItemId]
               , [intItemUOMId] 
    FROM tblICItemUOM IUOM WITH(NOLOCK) 
    WHERE [ysnStockUnit] = 1
      AND ICI.[intItemId] = IUOM.[intItemId]
) ICSUOM 
LEFT OUTER JOIN (
    SELECT [intItemId], [intItemLocationId], [dblUnitOnHand] FROM tblICItemStock WITH(NOLOCK)
) ICIS ON ICIL.[intItemId] = ICIS.[intItemId]
      AND ICIL.[intItemLocationId] = ICIS.[intItemLocationId]
LEFT OUTER JOIN (
    SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType WITH(NOLOCK)
) SMCERT ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN tblGLAccount GL ON ARID.intSalesAccountId = GL.intAccountId
WHERE [dbo].[fnARIsStockTrackingItem](ICI.[strType], ICI.[intItemId]) = 1

INSERT #ARPostInvoiceDetail
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
    ,[dblUnitQtyShipped]                = ISNULL(ARID.[dblQtyShipped], @ZeroDecimal) --ISNULL(dbo.fnARCalculateQtyBetweenUOM(ARID.[intItemUOMId], ICSUOM.[intItemUOMId], ARID.[dblQtyShipped], ICI.[intItemId], ICI.[strType]), @ZeroDecimal)
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
    ,[dblDiscountAmount]				= ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal)
    ,[dblBaseDiscountAmount]            = ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal)
    ,[dblTotal]                         = ARID.[dblTotal]
    ,[dblBaseTotal]                     = ARID.[dblBaseTotal]
    ,[dblLineItemGLAmount]              = ISNULL(ARID.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
    ,[dblBaseLineItemGLAmount]          = ISNULL(ARID.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
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
                                                      THEN ISNULL(ARID.[dblTotal], @ZeroDecimal) + (CASE WHEN (ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
                                                      ELSE
                                                            (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
																THEN
																	[dbo].fnRoundBanker(ARID.[dblTotal] * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
																	+
																	(CASE WHEN ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0  
																	      THEN @ZeroDecimal 
																		  ELSE [dbo].fnRoundBanker(
																	                 ([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()))
																		             *
																					 ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal)
																			   , dbo.fnARGetDefaultDecimal()) 
																     END) 
																ELSE
																	[dbo].fnRoundBanker((ISNULL(ARID.[dblLicenseAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), dbo.fnARGetDefaultDecimal())		
                                                            END)
                                                END)
    ,[dblBaseLicenseGLAmount]           = (CASE WHEN ARID.[strMaintenanceType] = 'License Only'
                                                      THEN ISNULL(ARID.[dblBaseTotal], @ZeroDecimal) + (CASE WHEN (ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0) THEN @ZeroDecimal ELSE [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()) END)
                                                      ELSE
                                                            (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
																THEN
																	[dbo].fnRoundBanker(ARID.[dblBaseTotal] * ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
																	+
																	(CASE WHEN ARI.[intPeriodsToAccrue] > 1 AND ARI.[ysnAccrueLicense] = 0  
																	      THEN @ZeroDecimal 
																		  ELSE [dbo].fnRoundBanker(
																	                 ([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()))
																		             *
																					 ([dbo].fnRoundBanker(@OneHundredDecimal - [dbo].fnRoundBanker(((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal()), dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal)
																			   , dbo.fnARGetDefaultDecimal()) 
																     END) 
																ELSE
																	[dbo].fnRoundBanker((ISNULL(ARID.[dblBaseLicenseAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), dbo.fnARGetDefaultDecimal())		
                                                            END)
                                                END)
    ,[dblMaintenanceAmount]             = ARID.[dblMaintenanceAmount]
    ,[dblBaseMaintenanceAmount]         = ARID.[dblBaseMaintenanceAmount]
    ,[dblMaintenanceGLAmount]             = (CASE WHEN ARID.[strMaintenanceType] IN ('Maintenance Only', 'SaaS')
                                                      THEN ISNULL(ARID.[dblTotal], @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
                                                      ELSE
                                                           (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
                                                               THEN
                                                                   [dbo].fnRoundBanker(ARID.[dblTotal] * ([dbo].fnRoundBanker(((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
																         + 
																         [dbo].fnRoundBanker(([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(ARID.dblBaseMaintenanceAmount, @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal)
																   , dbo.fnARGetDefaultDecimal()) 
                                                               ELSE
                                                                   [dbo].fnRoundBanker((ISNULL(ARID.[dblMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), dbo.fnARGetDefaultDecimal())		
                                                           END)
                                          END)
    ,[dblBaseMaintenanceGLAmount]         = (CASE WHEN ARID.[strMaintenanceType] IN ('Maintenance Only', 'SaaS')
                                                      THEN ISNULL(ARID.[dblBaseTotal], @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
                                                      ELSE
                                                           (CASE WHEN ISNULL(ARID.[dblDiscount], @ZeroDecimal) > @ZeroDecimal 
                                                               THEN
                                                                   [dbo].fnRoundBanker(ARID.[dblBaseTotal] * ([dbo].fnRoundBanker(((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal), dbo.fnARGetDefaultDecimal()) 
																         + 
																         [dbo].fnRoundBanker(([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())) * ([dbo].fnRoundBanker(((ISNULL(ARID.dblBaseMaintenanceAmount, @ZeroDecimal) * ARID.[dblQtyShipped]) / ARID.[dblBaseTotal]) * @OneHundredDecimal, dbo.fnARGetDefaultDecimal())/ @OneHundredDecimal)
																   , dbo.fnARGetDefaultDecimal()) 
                                                               ELSE
                                                                   [dbo].fnRoundBanker((ISNULL(ARID.[dblBaseMaintenanceAmount], @ZeroDecimal) * ARID.[dblQtyShipped]), dbo.fnARGetDefaultDecimal())		
                                                           END)
                                          END)
    ,[ysnTankRequired]                  = NULL --ARID.[ysnTankRequired]
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
    ,[ysnAutoBlend]                     = ISNULL(ICI.[ysnAutoBlend], @ZeroBit)
    ,[ysnBlended]                       = ISNULL(ARID.[ysnBlended], @ZeroBit)
    ,[dblQuantity]                      = NULL
    ,[dblMaxQuantity]                   = NULL
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = ISNULL(GL.strDescription, '') + ' Item: ' + ISNULL(ARID.strItemDescription, '') + ', Qty: ' + CAST(CAST(ARID.dblQtyShipped AS NUMERIC(18, 2)) AS nvarchar(100)) + ', Price: ' + CAST(CAST(ARID.dblPrice AS NUMERIC(18, 2)) AS nvarchar(100))		
FROM #ARPostInvoiceHeader ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblSMCompanyLocation SMCL ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
INNER JOIN (
    SELECT [intItemId], [strItemNo], [strType], [strManufactureType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NoLock)
) ICI ON ARID.[intItemId] = ICI.[intItemId]
LEFT OUTER JOIN (
    SELECT [intCategoryId], [ysnRetailValuation] FROM tblICCategory WITH(NoLock)
) ICC ON ICI.[intCategoryId] = ICC.[intCategoryId]
LEFT OUTER JOIN (
    SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NoLock)
) ICIL ON ICI.[intItemId] = ICIL.[intItemId]
      AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
LEFT OUTER JOIN (
    SELECT [intItemId], [intItemLocationId], [dblLastCost] FROM tblICItemPricing  WITH(NoLock)
) ICIP ON ICI.[intItemId] = ICIP.[intItemId]
      AND ICIL.[intItemLocationId] = ICIP.[intItemLocationId]
LEFT OUTER JOIN (
    SELECT [intItemId], [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH(NoLock)
) ICIU ON ARID.[intItemUOMId] = ICIU.[intItemUOMId]
LEFT OUTER JOIN (
    SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType WITH(NoLock)
) SMCERT ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN tblGLAccount GL ON ARID.intSalesAccountId = GL.intAccountId
WHERE [dbo].[fnARIsStockTrackingItem](ICI.[strType], ICI.[intItemId]) = 0

INSERT #ARPostInvoiceDetail
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
    ,[dblDiscountAmount]				= ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblPrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal)
    ,[dblBaseDiscountAmount]            = ISNULL([dbo].fnRoundBanker(((ARID.[dblDiscount]/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.[dblQtyShipped] * ARID.[dblBasePrice]), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal()), @ZeroDecimal)
    ,[dblTotal]                         = ARID.[dblTotal]
    ,[dblBaseTotal]                     = ARID.[dblBaseTotal]
    ,[dblLineItemGLAmount]              = ISNULL(ARID.dblTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblPrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
    ,[dblBaseLineItemGLAmount]          = ISNULL(ARID.dblBaseTotal, @ZeroDecimal) + [dbo].fnRoundBanker(((ARID.dblDiscount/@OneHundredDecimal) * [dbo].fnRoundBanker((ARID.dblQtyShipped * ARID.dblBasePrice), dbo.fnARGetDefaultDecimal())), dbo.fnARGetDefaultDecimal())
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
    ,[ysnTankRequired]                  = @ZeroBit
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
    ,[dblQuantity]                      = NULL
    ,[dblMaxQuantity]                   = NULL
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = ISNULL(GL.strDescription, '') + ' Item: ' + ISNULL(ARID.strItemDescription, '') + ', Qty: ' + CAST(CAST(ARID.dblQtyShipped AS NUMERIC(18, 2)) AS nvarchar(100)) + ', Price: ' + CAST(CAST(ARID.dblPrice AS NUMERIC(18, 2)) AS nvarchar(100))		
FROM #ARPostInvoiceHeader ARI
INNER JOIN tblARInvoiceDetail ARID ON ARI.[intInvoiceId] = ARID.[intInvoiceId]
INNER JOIN tblSMCompanyLocation SMCL ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN (
    SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType WITH(NoLock)
) SMCERT ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
LEFT OUTER JOIN tblGLAccount GL ON ARID.intSalesAccountId = GL.intAccountId
WHERE ARID.[intItemId] IS NULL
   OR ARID.[intItemId] = 0

UPDATE ID
SET dblTaxesAddToCost       = IDD.dblTaxesAddToCost
  , dblBaseTaxesAddToCost   = IDD.dblBaseTaxesAddToCost
FROM #ARPostInvoiceDetail ID
INNER JOIN (
    SELECT dblTaxesAddToCost       = SUM(TAXES.dblTaxesAddToCost)
         , dblBaseTaxesAddToCost   = SUM(TAXES.dblBaseTaxesAddToCost)
         , intInvoiceDetailId      = ID.intInvoiceDetailId
    FROM #ARPostInvoiceDetail ID
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
