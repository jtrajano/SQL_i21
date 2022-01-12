CREATE PROCEDURE [dbo].[uspARInitializeTempTableForPosting]
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF(OBJECT_ID('tempdb..##ARPostInvoiceHeader') IS NOT NULL)
BEGIN
    DROP TABLE ##ARPostInvoiceHeader
END
CREATE TABLE ##ARPostInvoiceHeader (
     [intInvoiceId]                         INT             NOT NULL PRIMARY KEY
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
    ,[strBatchId]                           NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
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
    ,[ysnFromReturn]                        BIT             NULL

    ,[intInvoiceDetailId]                   INT             NULL
    ,[intItemId]                            INT             NULL
    ,[strItemNo]                            NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemType]                          NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemManufactureType]				NVARCHAR(50)    COLLATE Latin1_General_CI_AS 	NULL
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
    ,[strDescription]                       NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[strInterCompanyVendorId]				NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[strInterCompanyLocationId]			NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[intInterCompanyId]					INT				NULL
	,[strReceiptNumber]						NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[ysnInterCompany]                      BIT             NULL
	,[intInterCompanyVendorId]				INT				NULL
	,[strBOLNumber]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS    NULL
)

IF(OBJECT_ID('tempdb..##ARPostInvoiceDetail') IS NOT NULL)
BEGIN
    DROP TABLE ##ARPostInvoiceDetail
END
CREATE TABLE ##ARPostInvoiceDetail (
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
    ,[strBatchId]                           NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
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
    ,[ysnFromReturn]                        BIT             NULL

    ,[intInvoiceDetailId]                   INT             NOT NULL PRIMARY KEY
    ,[intItemId]                            INT             NULL
    ,[strItemNo]                            NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemType]                          NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[strItemManufactureType]				NVARCHAR(50)    COLLATE Latin1_General_CI_AS 	NULL
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
    ,[strDescription]                       NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[strInterCompanyVendorId]				NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[strInterCompanyLocationId]			NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[intInterCompanyId]					INT				NULL
	,[strReceiptNumber]						NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[ysnInterCompany]                      BIT             NULL
	,[intInterCompanyVendorId]				INT				NULL
	,[strBOLNumber]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS    NULL
)

IF(OBJECT_ID('tempdb..##ARInvoiceItemAccount') IS NOT NULL)
BEGIN
    DROP TABLE ##ARInvoiceItemAccount
END
CREATE TABLE ##ARInvoiceItemAccount (
	 [intItemId]                         INT                                             NOT NULL
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
	,PRIMARY KEY CLUSTERED ([intItemId], [intLocationId])
)

IF(OBJECT_ID('tempdb..##ARInvalidInvoiceData') IS NOT NULL)
BEGIN
    DROP TABLE ##ARInvalidInvoiceData
END
CREATE TABLE ##ARInvalidInvoiceData (
      [intInvoiceId]			INT				NOT NULL
	, [strInvoiceNumber]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [intInvoiceDetailId]		INT				NULL
	, [intItemId]				INT				NULL
	, [strBatchId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	, [strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)

IF(OBJECT_ID('tempdb..##ARItemsForCosting') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForCosting
END
CREATE TABLE ##ARItemsForCosting (
	  [intItemId]						INT NOT NULL
	, [intItemLocationId]				INT NULL
	, [intItemUOMId]					INT NOT NULL
	, [dtmDate]							DATETIME NOT NULL
    , [dblQty]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblUOMQty]						NUMERIC(38, 20) NOT NULL DEFAULT 1
    , [dblCost]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblValue]						NUMERIC(38, 20) NOT NULL DEFAULT 0 
	, [dblSalesPrice]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [intCurrencyId]					INT NULL
	, [dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1 NOT NULL
    , [intTransactionId]				INT NOT NULL
	, [intTransactionDetailId]			INT NULL
	, [strTransactionId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	, [intTransactionTypeId]			INT NOT NULL
	, [intLotId]						INT NULL
	, [intSubLocationId]				INT NULL
	, [intStorageLocationId]			INT NULL
	, [ysnIsStorage]					BIT NULL
	, [strActualCostId]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [intSourceTransactionId]			INT NULL
	, [strSourceTransactionId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	, [intInTransitSourceLocationId]	INT NULL
	, [intForexRateTypeId]				INT NULL
	, [dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1
	, [intStorageScheduleTypeId]		INT NULL
    , [dblUnitRetail]					NUMERIC(38, 20) NULL
	, [intCategoryId]					INT NULL 
	, [dblAdjustCostValue]				NUMERIC(38, 20) NULL
	, [dblAdjustRetailValue]			NUMERIC(38, 20) NULL
	, [strType]                         NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , [ysnAutoBlend]                    BIT NULL
    , [ysnGLOnly]						BIT NULL
	, [strBOLNumber]					NVARCHAR(100) NULL 
    , [strSourceType]                   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , [strSourceNumber]                 NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , [intTicketId]                     INT NULL
    , [intSourceEntityId]				INT NULL
)

IF(OBJECT_ID('tempdb..##ARItemsForInTransitCosting') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForInTransitCosting
END
CREATE TABLE ##ARItemsForInTransitCosting (
	  [intItemId]						INT NOT NULL
	, [intItemLocationId]				INT NULL
	, [intItemUOMId]					INT NOT NULL
	, [dtmDate]							DATETIME NOT NULL
    , [dblQty]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblUOMQty]						NUMERIC(38, 20) NOT NULL DEFAULT 1
    , [dblCost]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblValue]						NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblSalesPrice]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [intCurrencyId]					INT NULL
	, [dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1 NOT NULL
    , [intTransactionId]				INT NOT NULL
	, [intTransactionDetailId]			INT NULL
	, [strTransactionId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	, [intTransactionTypeId]			INT NOT NULL
	, [intLotId]						INT NULL
    , [intSourceTransactionId]			INT NULL
	, [strSourceTransactionId]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [intSourceTransactionDetailId]	INT NULL
	, [intFobPointId]					TINYINT NULL
	, [intInTransitSourceLocationId]	INT NULL
	, [intForexRateTypeId]				INT NULL
	, [dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1
	, [intLinkedItem]					INT NULL
	, [intLinkedItemId]					INT NULL
	, [strBOLNumber]					NVARCHAR(100) NULL 
    , [intTicketId]                     INT NULL
)

IF(OBJECT_ID('tempdb..##ARItemsForStorageCosting') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForStorageCosting
END
CREATE TABLE ##ARItemsForStorageCosting (
	  [intItemId]						INT NOT NULL
	, [intItemLocationId]				INT NULL
	, [intItemUOMId]					INT NOT NULL
	, [dtmDate]							DATETIME NOT NULL
    , [dblQty]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblUOMQty]						NUMERIC(38, 20) NOT NULL DEFAULT 1
    , [dblCost]							NUMERIC(38, 20) NOT NULL DEFAULT 0
	, [dblValue]						NUMERIC(38, 20) NOT NULL DEFAULT 0 
	, [dblSalesPrice]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [intCurrencyId]					INT NULL
	, [dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1 NOT NULL
    , [intTransactionId]				INT NOT NULL
	, [intTransactionDetailId]			INT NULL
	, [strTransactionId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	, [intTransactionTypeId]			INT NOT NULL
	, [intLotId]						INT NULL
	, [intSubLocationId]				INT NULL
	, [intStorageLocationId]			INT NULL
	, [ysnIsStorage]					BIT NULL
	, [strActualCostId]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [intSourceTransactionId]			INT NULL
	, [strSourceTransactionId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	, [intInTransitSourceLocationId]	INT NULL
	, [intForexRateTypeId]				INT NULL
	, [dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1
	, [intStorageScheduleTypeId]		INT NULL
    , [dblUnitRetail]					NUMERIC(38, 20) NULL
	, [intCategoryId]					INT NULL 
	, [dblAdjustCostValue]				NUMERIC(38, 20) NULL
	, [dblAdjustRetailValue]			NUMERIC(38, 20) NULL
	, [strBOLNumber]					NVARCHAR(100) NULL 
    , [intTicketId]                     INT NULL
)

IF(OBJECT_ID('tempdb..##ARItemsForContracts') IS NOT NULL)
BEGIN
    DROP TABLE ##ARItemsForContracts
END
CREATE TABLE ##ARItemsForContracts (
	  [intInvoiceId]					INT NOT NULL
	, [intInvoiceDetailId]				INT NOT NULL
	, [intOriginalInvoiceId]			INT NULL
	, [intOriginalInvoiceDetailId]		INT NULL
	, [intItemId]						INT NULL
	, [intContractDetailId]				INT NULL
	, [intContractHeaderId]				INT NULL
	, [intEntityId]						INT NULL
	, [intUserId]						INT NULL
	, [dtmDate]							DATETIME NULL
	, [dblQuantity]						NUMERIC(18, 6) NOT NULL DEFAULT 0
    , [dblBalanceQty]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [dblSheduledQty]					NUMERIC(18, 6) NOT NULL DEFAULT 0
    , [dblRemainingQty]					NUMERIC(18, 6) NOT NULL DEFAULT 0
	, [strType]							NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strTransactionType]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strInvoiceNumber]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strItemNo]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [strBatchId]						NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, [ysnFromReturn]					BIT NULL
)

IF(OBJECT_ID('tempdb..##ARInvoiceGLEntries') IS NOT NULL)
BEGIN
    DROP TABLE ##ARInvoiceGLEntries
END
CREATE TABLE ##ARInvoiceGLEntries (
	  [dtmDate]							DATETIME         NOT NULL
	, [strBatchId]						NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL
	, [intAccountId]					INT              NULL
	, [dblDebit]						NUMERIC (18, 6)  NULL
	, [dblCredit]						NUMERIC (18, 6)  NULL
	, [dblDebitUnit]					NUMERIC (18, 6)  NULL
	, [dblCreditUnit]					NUMERIC (18, 6)  NULL
	, [strDescription]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [strCode]							NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL 
	, [strReference]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [intCurrencyId]					INT              NULL
	, [dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1 NOT NULL
	, [dtmDateEntered]					DATETIME         NOT NULL
	, [dtmTransactionDate]				DATETIME         NULL
	, [strJournalLineDescription]		NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL
	, [intJournalLineNo]				INT              NULL
	, [ysnIsUnposted]					BIT              NOT NULL
	, [intUserId]						INT              NULL
	, [intEntityId]						INT              NULL
	, [strTransactionId]				NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
	, [intTransactionId]				INT              NULL
	, [strTransactionType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strTransactionForm]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strModuleName]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [intConcurrencyId]				INT              DEFAULT 1 NOT NULL
	, [dblDebitForeign]					NUMERIC (18, 9) NULL
	, [dblDebitReport]					NUMERIC (18, 9) NULL
	, [dblCreditForeign]				NUMERIC (18, 9) NULL
	, [dblCreditReport]					NUMERIC (18, 9) NULL
	, [dblReportingRate]				NUMERIC (18, 9) NULL
	, [dblForeignRate]					NUMERIC (18, 9) NULL
	, [intCurrencyExchangeRateTypeId]	INT NULL
	, [strRateType]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [strDocument]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strComments]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strSourceDocumentId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [intSourceLocationId]				INT NULL
	, [intSourceUOMId]					INT NULL
	, [dblSourceUnitDebit]				NUMERIC (18, 6)  NULL
	, [dblSourceUnitCredit]				NUMERIC (18, 6)  NULL
	, [intCommodityId]					INT NULL
	, [intSourceEntityId]				INT NULL
	, [ysnRebuild]						BIT NULL
)
GO
