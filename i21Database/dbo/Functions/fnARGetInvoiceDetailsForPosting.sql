CREATE FUNCTION [dbo].[fnARGetInvoiceDetailsForPosting]
(
     @InvoiceIds	    [InvoiceId]     READONLY
    ,@PostDate          DATETIME        = NULL
    ,@BatchId           NVARCHAR(40)    = NULL
    ,@UserId            BIT             = NULL
    ,@IntegrationLogId  INT             = NULL
)
RETURNS @returntable TABLE
(
     [intInvoiceId]                         INT             NOT NULL
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
    ,[dblQtyShipped]                        NUMERIC(18,6)   NULL	
    ,[dblUnitQtyShipped]                    NUMERIC(18,6)   NULL
    ,[dblShipmentNetWt]                     NUMERIC(18,6)   NULL	
    ,[dblUnitQty]                           NUMERIC(38,20)  NULL
    ,[dblUnitOnHand]                        NUMERIC(18,6)   NULL
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
    ,[strDescription]                       NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
)
AS
BEGIN

DECLARE	@DiscountAccountId          INT
       ,@DeferredRevenueAccountId   INT
       ,@ExcludeInvoiceFromPayment	BIT
       ,@AllowOtherUserToPost       BIT
       ,@ZeroBit                    BIT
       ,@OneBit                     BIT
       ,@ZeroDecimal                DECIMAL(18,6)
       ,@OneDecimal                 DECIMAL(18,6)
       ,@OneHundredDecimal          DECIMAL(18,6)

SET @ZeroDecimal = 0.000000
SET @OneDecimal = 1.000000
SET @OneHundredDecimal = 100.000000
SET @OneBit = CAST(1 AS BIT)
SET @ZeroBit = CAST(0 AS BIT)

SELECT TOP 1
     @DiscountAccountId         = [intDiscountAccountId]
    ,@DeferredRevenueAccountId  = [intDeferredRevenueAccountId]
    ,@ExcludeInvoiceFromPayment = ISNULL([ysnExcludePaymentInFinalInvoice],0)
FROM dbo.tblARCompanyPreference WITH (NOLOCK)

SET @AllowOtherUserToPost = (SELECT TOP 1 ysnAllowUserSelfPost FROM tblSMUserPreference WHERE intEntityUserSecurityId = @UserId)


DECLARE @IntegrationHeader AS [dbo].[InvoicePostingTable]
IF @IntegrationLogId IS NOT NULL AND EXISTS(SELECT TOP 1 NULL FROM tblARInvoiceIntegrationLogDetail WHERE [intIntegrationLogId] = @IntegrationLogId)
BEGIN
    INSERT @IntegrationHeader
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
        ,[dblProvisionalAmount]				= ISNULL(ARI.[dblProvisionalAmount], @ZeroDecimal)
        ,[dblBaseProvisionalAmount]			= ISNULL(ARI.[dblBaseProvisionalAmount], @ZeroDecimal)
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
        ,[ysnImpactInventory]               = ARI.[ysnImpactInventory]
    	,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	    ,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
        ,[dtmDatePosted]                    = @PostDate
        ,[strBatchId]                       = CASE WHEN LEN(RTRIM(LTRIM(ISNULL(ARILD.[strBatchId],'')))) > 0 THEN ARILD.[strBatchId] ELSE @BatchId END
        ,[ysnPost]                          = ARILD.[ysnPost]
        ,[ysnRecap]                         = ARILD.[ysnRecap]
        ,[intEntityId]                      = ARI.[intEntityId]
        ,[intUserId]                        = @UserId
        ,[ysnUserAllowedToPostOtherTrans]	= ISNULL(@AllowOtherUserToPost, @ZeroBit)
        ,[ysnWithinAccountingDate]          = ISNULL(dbo.isOpenAccountingDate(ISNULL(ARI.[dtmPostDate], ARI.[dtmDate])), @ZeroBit)
        ,[ysnForApproval]                   = (CASE WHEN FAT.[intTransactionId] IS NOT NULL THEN @OneBit ELSE @ZeroBit END)
        ,[ysnFromProvisional]               = ISNULL(ARI.[ysnFromProvisional], @ZeroBit)
        ,[ysnProvisionalWithGL]             = ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit)
        ,[ysnExcludeInvoiceFromPayment]     = ISNULL(@ExcludeInvoiceFromPayment, @ZeroBit)
        ,[ysnIsInvoicePositive]             = (CASE WHEN [dbo].[fnARGetInvoiceAmountMultiplier](ARI.[strTransactionType]) = 1 THEN @OneBit ELSE @ZeroBit END)

        ,[intInvoiceDetailId]               = NULL
        ,[intItemId]                        = NULL
        ,[strItemNo]                        = NULL
        ,[strItemType]                      = NULL
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
        ,[intDiscountAccountId]             = @DiscountAccountId
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
        ,[strDescription]                   = CASE WHEN ARI.[strType] = 'Provisional' AND ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit) = @OneBit THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1, 255)
                                                   WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1 , 255)
                                                   ELSE ARI.[strComments]
                                              END		
    
    FROM
        tblARInvoice ARI
    INNER JOIN
        (
    	SELECT [intInvoiceId], [ysnPost], [ysnRecap], [ysnAccrueLicense], [strBatchId] FROM tblARInvoiceIntegrationLogDetail 
    	--WHERE [ysnPost] IS NOT NULL AND [ysnPost] = @Post AND [ysnHeader] = 1 AND [intIntegrationLogId] = @IntegrationLogId
    	WHERE [ysnPost] IS NOT NULL AND [ysnHeader] = 1 AND [intIntegrationLogId] = @IntegrationLogId
    	) ARILD
            ON ARI.[intInvoiceId] = ARILD.[intInvoiceId]
    INNER JOIN
        (
        SELECT [intEntityId], [strCustomerNumber], [ysnActive], [dblCreditLimit] FROM tblARCustomer WITH(NoLock)
        ) ARC
            ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
    LEFT OUTER JOIN
        (
        SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId], [intAPAccount], [intFreightIncome], [intProfitCenter], [intSalesAccount] FROM tblSMCompanyLocation  WITH(NoLock)
        ) SMCL
            ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
	LEFT OUTER JOIN
        (
        SELECT [intTransactionId] FROM vyuARForApprovalTransction  WITH (NOLOCK) WHERE [strScreenName] = 'Invoice'
        ) FAT
            ON ARI.[intInvoiceId] = FAT.[intTransactionId]
    OPTION(recompile)


END


DECLARE @Header AS [dbo].[InvoicePostingTable]

INSERT INTO @Header
SELECT * FROM @IntegrationHeader

INSERT @Header
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
    ,[dblProvisionalAmount]				= ISNULL(ARI.[dblProvisionalAmount], @ZeroDecimal)
    ,[dblBaseProvisionalAmount]			= ISNULL(ARI.[dblBaseProvisionalAmount], @ZeroDecimal)
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
    ,[ysnAccrueLicense]                 = ISNULL(II.[ysnAccrueLicense], @ZeroBit)
    ,[intSplitId]                       = ARI.[intSplitId]
    ,[dblSplitPercent]                  = ARI.[dblSplitPercent]
    ,[ysnSplitted]                      = ARI.[ysnSplitted]
    ,[ysnPosted]                        = ARI.[ysnPosted]
    ,[ysnRecurring]                     = ARI.[ysnRecurring]
    ,[ysnImpactInventory]               = ARI.[ysnImpactInventory]
    ,[ysnImportedAsPosted]              = ARI.[ysnImportedAsPosted]
	,[ysnImportedFromOrigin]            = ARI.[ysnImportedFromOrigin]
    ,[dtmDatePosted]                    = @PostDate
    ,[strBatchId]                       = ISNULL(II.[strBatchId], @BatchId)
    ,[ysnPost]                          = ISNULL(II.[ysnPost], @ZeroBit)
    ,[ysnRecap]                         = ISNULL(II.[ysnRecap], @ZeroBit)
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = @UserId
    ,[ysnUserAllowedToPostOtherTrans]	= ISNULL(@AllowOtherUserToPost, @ZeroBit)
    ,[ysnWithinAccountingDate]          = ISNULL(dbo.isOpenAccountingDate(ISNULL(ARI.[dtmPostDate], ARI.[dtmDate])), @ZeroBit)
    ,[ysnForApproval]                   = (CASE WHEN FAT.[intTransactionId] IS NOT NULL THEN @OneBit ELSE @ZeroBit END)
    ,[ysnFromProvisional]               = ISNULL(ARI.[ysnFromProvisional], @ZeroBit)
    ,[ysnProvisionalWithGL]             = ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit)
    ,[ysnExcludeInvoiceFromPayment]     = ISNULL(@ExcludeInvoiceFromPayment, @ZeroBit)
    ,[ysnIsInvoicePositive]             = (CASE WHEN [dbo].[fnARGetInvoiceAmountMultiplier](ARI.[strTransactionType]) = 1 THEN @OneBit ELSE @ZeroBit END)

    ,[intInvoiceDetailId]               = NULL
    ,[intItemId]                        = NULL
    ,[strItemNo]                        = NULL
    ,[strItemType]                      = NULL
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
    ,[intDiscountAccountId]             = @DiscountAccountId
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
    ,[strDescription]                   = CASE WHEN ARI.[strType] = 'Provisional' AND ISNULL(ARI.[ysnProvisionalWithGL], @ZeroBit) = @OneBit THEN SUBSTRING(('Provisional Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1, 255)
                                                WHEN ARI.[intOriginalInvoiceId] IS NOT NULL AND ARI.[intSourceId] IS NOT NULL AND ARI.[intOriginalInvoiceId] <> 0 AND ARI.[intSourceId] = 2 THEN SUBSTRING(('Final Invoice' + ISNULL((' - ' + ARI.[strComments]),'')), 1 , 255)
                                                ELSE ARI.[strComments]
                                            END		
    
FROM
    tblARInvoice ARI
INNER JOIN
    @InvoiceIds II
        ON ARI.[intInvoiceId] = II.[intHeaderId]
INNER JOIN
    (
    SELECT [intEntityId], [strCustomerNumber], [ysnActive], [dblCreditLimit] FROM tblARCustomer WITH(NoLock)
    ) ARC
        ON ARI.[intEntityCustomerId] = ARC.[intEntityId]
LEFT OUTER JOIN
    (
    SELECT [intCompanyLocationId], [strLocationName], [intUndepositedFundsId], [intAPAccount], [intFreightIncome], [intProfitCenter], [intSalesAccount] FROM tblSMCompanyLocation  WITH(NoLock)
    ) SMCL
        ON ARI.[intCompanyLocationId] = SMCL.[intCompanyLocationId]
LEFT OUTER JOIN
    (
    SELECT [intTransactionId] FROM vyuARForApprovalTransction  WITH (NOLOCK) WHERE [strScreenName] = 'Invoice'
    ) FAT
        ON ARI.[intInvoiceId] = FAT.[intTransactionId]
	WHERE
		NOT EXISTS(SELECT NULL FROM @IntegrationHeader IH WHERE IH.[intInvoiceId] = ARI.[intInvoiceId])
OPTION(recompile)


DECLARE @Detail AS [dbo].[InvoicePostingTable]
INSERT @Detail
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
    ,[dblProvisionalAmount]				= ARI.[dblProvisionalAmount]
    ,[dblBaseProvisionalAmount]			= ARI.[dblBaseProvisionalAmount]
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
    ,[dtmDatePosted]                    = ARI.[dtmDatePosted]
    ,[strBatchId]                       = ARI.[strBatchId]
    ,[ysnPost]                          = ARI.[ysnPost]
    ,[ysnRecap]                         = ARI.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = ARI.[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]	= ARI.[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]          = ARI.[ysnWithinAccountingDate]
    ,[ysnForApproval]                   = ARI.[ysnForApproval]
    ,[ysnFromProvisional]               = ARI.[ysnFromProvisional]
    ,[ysnProvisionalWithGL]             = ARI.[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]     = ARI.[ysnExcludeInvoiceFromPayment]
    ,[ysnIsInvoicePositive]             = ARI.[ysnIsInvoicePositive]

    ,[intInvoiceDetailId]               = ARID.[intInvoiceDetailId]
    ,[intItemId]                        = ARID.[intItemId]
    ,[strItemNo]                        = ICI.[strItemNo]
    ,[strItemType]                      = ICI.[strType]
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
    ,[intDiscountAccountId]             = @DiscountAccountId
    ,[intCustomerStorageId]             = ARID.[intCustomerStorageId]
    ,[intStorageScheduleTypeId]         = ARID.[intStorageScheduleTypeId]
    ,[intSubLocationId]                 = ISNULL(ARID.[intCompanyLocationSubLocationId], (CASE WHEN ICI.[ysnAutoBlend] = 1 THEN ICIL.[intSubLocationId] ELSE ARID.[intCompanyLocationSubLocationId] END))
    ,[intStorageLocationId]             = ARID.[intStorageLocationId]
    ,[ysnAutoBlend]                     = ICI.[ysnAutoBlend]
    ,[ysnBlended]                       = ARID.[ysnBlended]
    ,[dblQuantity]                      = NULL
    ,[dblMaxQuantity]                   = NULL
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = NULL		
    
FROM
    tblARInvoiceDetail ARID
INNER JOIN
    @Header ARI
        ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
    (
    SELECT [intItemId], [strItemNo], [strType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NoLock)
    ) ICI
        ON ARID.[intItemId] = ICI.[intItemId]
LEFT OUTER JOIN
    (
    SELECT [intCategoryId], [ysnRetailValuation] FROM tblICCategory WITH(NoLock)
    ) ICC
        ON ICI.[intCategoryId] = ICC.[intCategoryId]
INNER JOIN
    (
    SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NoLock)
    ) ICIL
        ON ICI.[intItemId] = ICIL.[intItemId]
        AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intItemLocationId], [dblLastCost] FROM tblICItemPricing  WITH(NoLock)
    ) ICIP
        ON ICI.[intItemId] = ICIP.[intItemId]
        AND ICIL.[intItemLocationId] = ICIP.[intItemLocationId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH(NoLock)
    ) ICIU
        ON ARID.[intItemUOMId] = ICIU.[intItemUOMId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intItemUOMId] FROM tblICItemUOM WITH(NoLock) WHERE [ysnStockUnit] = 1
    ) ICSUOM
        ON ICI.[intItemId] = ICSUOM.[intItemId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intItemLocationId], [dblUnitOnHand] FROM tblICItemStock WITH(NoLock)
    ) ICIS
        ON ICIL.[intItemId] = ICIS.[intItemId]
        AND ICIL.[intItemLocationId] = ICIS.[intItemLocationId]
LEFT OUTER JOIN
    (
    SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType WITH(NoLock)
    ) SMCERT
        ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
WHERE
    [dbo].[fnARIsStockTrackingItem](ICI.[strType], ICI.[intItemId]) = 1
OPTION(recompile)

INSERT @Detail
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
    ,[dblProvisionalAmount]				= ARI.[dblProvisionalAmount]
    ,[dblBaseProvisionalAmount]			= ARI.[dblBaseProvisionalAmount]
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
    ,[dtmDatePosted]                    = ARI.[dtmDatePosted]
    ,[strBatchId]                       = ARI.[strBatchId]
    ,[ysnPost]                          = ARI.[ysnPost]
    ,[ysnRecap]                         = ARI.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = ARI.[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]	= ARI.[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]          = ARI.[ysnWithinAccountingDate]
    ,[ysnForApproval]                   = ARI.[ysnForApproval]
    ,[ysnFromProvisional]               = ARI.[ysnFromProvisional]
    ,[ysnProvisionalWithGL]             = ARI.[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]     = ARI.[ysnExcludeInvoiceFromPayment]
    ,[ysnIsInvoicePositive]             = ARI.[ysnIsInvoicePositive]

    ,[intInvoiceDetailId]               = ARID.[intInvoiceDetailId]
    ,[intItemId]                        = ARID.[intItemId]
    ,[strItemNo]                        = ICI.[strItemNo]
    ,[strItemType]                      = ICI.[strType]
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
    ,[intDiscountAccountId]             = @DiscountAccountId
    ,[intCustomerStorageId]             = ARID.[intCustomerStorageId]
    ,[intStorageScheduleTypeId]         = ARID.[intStorageScheduleTypeId]
    ,[intSubLocationId]                 = ISNULL(ARID.[intCompanyLocationSubLocationId], (CASE WHEN ICI.[ysnAutoBlend] = 1 THEN ICIL.[intSubLocationId] ELSE ARID.[intCompanyLocationSubLocationId] END))
    ,[intStorageLocationId]             = ARID.[intStorageLocationId]
    ,[ysnAutoBlend]                     = ICI.[ysnAutoBlend]
    ,[ysnBlended]                       = ARID.[ysnBlended]
    ,[dblQuantity]                      = NULL
    ,[dblMaxQuantity]                   = NULL
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = NULL		
    
FROM
    tblARInvoiceDetail ARID
INNER JOIN
    @Header ARI
        ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
INNER JOIN
    (
    SELECT [intItemId], [strItemNo], [strType], [strDescription], [ysnAutoBlend], [intCategoryId] FROM tblICItem WITH(NoLock)
    ) ICI
        ON ARID.[intItemId] = ICI.[intItemId]
LEFT OUTER JOIN
    (
    SELECT [intCategoryId], [ysnRetailValuation] FROM tblICCategory WITH(NoLock)
    ) ICC
        ON ICI.[intCategoryId] = ICC.[intCategoryId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intLocationId], [intItemLocationId], [intAllowNegativeInventory], [intSubLocationId] FROM tblICItemLocation WITH(NoLock)
    ) ICIL
        ON ICI.[intItemId] = ICIL.[intItemId]
        AND ARI.[intCompanyLocationId] = ICIL.[intLocationId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intItemLocationId], [dblLastCost] FROM tblICItemPricing  WITH(NoLock)
    ) ICIP
        ON ICI.[intItemId] = ICIP.[intItemId]
        AND ICIL.[intItemLocationId] = ICIP.[intItemLocationId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intItemUOMId], [dblUnitQty] FROM tblICItemUOM WITH(NoLock)
    ) ICIU
        ON ARID.[intItemUOMId] = ICIU.[intItemUOMId]
LEFT OUTER JOIN
    (
    SELECT [intItemId], [intItemUOMId] FROM tblICItemUOM WITH(NoLock) WHERE [ysnStockUnit] = 1
    ) ICSUOM
        ON ICI.[intItemId] = ICSUOM.[intItemId]
LEFT OUTER JOIN
    (
    SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType WITH(NoLock)
    ) SMCERT
        ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
WHERE
    [dbo].[fnARIsStockTrackingItem](ICI.[strType], ICI.[intItemId]) = 0
OPTION(recompile)

INSERT @Detail
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
    ,[dblProvisionalAmount]				= ARI.[dblProvisionalAmount]
    ,[dblBaseProvisionalAmount]			= ARI.[dblBaseProvisionalAmount]
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
    ,[dtmDatePosted]                    = ARI.[dtmDatePosted]
    ,[strBatchId]                       = ARI.[strBatchId]
    ,[ysnPost]                          = ARI.[ysnPost]
    ,[ysnRecap]                         = ARI.[ysnRecap]
    ,[intEntityId]                      = ARI.[intEntityId]
    ,[intUserId]                        = ARI.[intUserId]
    ,[ysnUserAllowedToPostOtherTrans]	= ARI.[ysnUserAllowedToPostOtherTrans]
    ,[ysnWithinAccountingDate]          = ARI.[ysnWithinAccountingDate]
    ,[ysnForApproval]                   = ARI.[ysnForApproval]
    ,[ysnFromProvisional]               = ARI.[ysnFromProvisional]
    ,[ysnProvisionalWithGL]             = ARI.[ysnProvisionalWithGL]
    ,[ysnExcludeInvoiceFromPayment]     = ARI.[ysnExcludeInvoiceFromPayment]
    ,[ysnIsInvoicePositive]             = ARI.[ysnIsInvoicePositive]

    ,[intInvoiceDetailId]               = ARID.[intInvoiceDetailId]
    ,[intItemId]                        = NULL
    ,[strItemNo]                        = ''
    ,[strItemType]                      = ''
    ,[strItemDescription]               = ARID.[strItemDescription]
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
    ,[intDiscountAccountId]             = @DiscountAccountId
    ,[intCustomerStorageId]             = ARID.[intCustomerStorageId]
    ,[intStorageScheduleTypeId]         = ARID.[intStorageScheduleTypeId]
    ,[intSubLocationId]                 = ARID.[intCompanyLocationSubLocationId]
    ,[intStorageLocationId]             = ARID.[intStorageLocationId]
    ,[ysnAutoBlend]                     = @ZeroBit
    ,[ysnBlended]                       = @ZeroBit
    ,[dblQuantity]                      = NULL
    ,[dblMaxQuantity]                   = NULL
    ,[strOptionType]                    = NULL
    ,[strSourceType]                    = NULL
    ,[strPostingMessage]                = NULL
    ,[strDescription]                   = NULL		
    
FROM
    tblARInvoiceDetail ARID
INNER JOIN
    @Header ARI
        ON ARID.[intInvoiceId] = ARI.[intInvoiceId]
LEFT OUTER JOIN
    (
    SELECT [intCurrencyExchangeRateTypeId], [strCurrencyExchangeRateType] FROM tblSMCurrencyExchangeRateType WITH(NoLock)
    ) SMCERT
        ON ARID.[intCurrencyExchangeRateTypeId] = SMCERT.[intCurrencyExchangeRateTypeId]
WHERE
    ARID.[intItemId] IS NULL
    OR ARID.[intItemId] = 0
OPTION(recompile)

INSERT INTO @returntable
SELECT * FROM @Header
UNION
SELECT * FROM @Detail

RETURN

END