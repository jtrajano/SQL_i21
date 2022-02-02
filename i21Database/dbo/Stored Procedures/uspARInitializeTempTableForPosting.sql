CREATE PROCEDURE [dbo].[uspARInitializeTempTableForPosting]
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET ANSI_WARNINGS OFF

IF(OBJECT_ID('tempdb..##ARPostInvoiceHeader') IS NOT NULL) DROP TABLE ##ARPostInvoiceHeader
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
    ,[ysnCustomerActive]                    BIT             NULL DEFAULT 0
    ,[dblCustomerCreditLimit]               NUMERIC(18,6)   NULL DEFAULT 0
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
    ,[dblAverageExchangeRate]               NUMERIC(18,6)   NULL DEFAULT 0
    ,[intTermId]                            INT             NULL
    ,[dblInvoiceTotal]                      NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseInvoiceTotal]                  NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblShipping]                          NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseShipping]                      NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblTax]                               NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseTax]                           NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblAmountDue]                         NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseAmountDue]                     NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblPayment]                           NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBasePayment]                       NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblProvisionalAmount]                 NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseProvisionalAmount]             NUMERIC(18,6)   NULL DEFAULT 0
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
    ,[intPeriodsToAccrue]                   INT             NULL DEFAULT 1
    ,[ysnAccrueLicense]                     BIT             NULL DEFAULT 0
    ,[intSplitId]                           INT             NULL
    ,[dblSplitPercent]                      NUMERIC(18,6)   NULL DEFAULT 0	
    ,[ysnSplitted]                          BIT             NULL DEFAULT 0
    ,[ysnPosted]                            BIT             NULL DEFAULT 0	
    ,[ysnRecurring]                         BIT             NULL DEFAULT 0	
    ,[ysnImpactInventory]                   BIT             NULL DEFAULT 1	
	,[ysnImportedAsPosted]                  BIT             NULL DEFAULT 0	
	,[ysnImportedFromOrigin]                BIT             NULL DEFAULT 0
    ,[dtmDatePosted]                        DATETIME        NULL
    ,[strBatchId]                           NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnPost]                              BIT             NULL DEFAULT 0
    ,[ysnRecap]                             BIT             NULL DEFAULT 0
    ,[intEntityId]                          INT             NOT NULL
    ,[intUserId]                            INT             NOT NULL
    ,[ysnUserAllowedToPostOtherTrans]       BIT             NULL DEFAULT 0
    ,[ysnWithinAccountingDate]              BIT             NULL DEFAULT 0
    ,[ysnForApproval]                       BIT             NULL DEFAULT 0
    ,[ysnFromProvisional]                   BIT             NULL DEFAULT 0
    ,[ysnProvisionalWithGL]                 BIT             NULL DEFAULT 0
    ,[ysnExcludeInvoiceFromPayment]         BIT             NULL DEFAULT 0
    ,[ysnRefundProcessed]                   BIT             NULL DEFAULT 0
    ,[ysnIsInvoicePositive]                 BIT             NULL DEFAULT 1
    ,[ysnFromReturn]                        BIT             NULL DEFAULT 0
    ,[ysnCancelled]                         BIT             NULL DEFAULT 0
    ,[ysnPaid]                              BIT             NULL DEFAULT 0
    ,[strPONumber]                          NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL

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
    ,[dblQtyShipped]                        NUMERIC(38,20)  NULL DEFAULT 0	
    ,[dblUnitQtyShipped]                    NUMERIC(38,20)  NULL DEFAULT 0
    ,[dblShipmentNetWt]                     NUMERIC(38,20)  NULL DEFAULT 0	
    ,[dblUnitQty]                           NUMERIC(38,20)  NULL DEFAULT 0
    ,[dblUnitOnHand]                        NUMERIC(38,20)  NULL DEFAULT 0
    ,[intAllowNegativeInventory]            INT             NULL
    ,[ysnStockTracking]                     BIT             NULL DEFAULT 0
    ,[intItemLocationId]                    INT             NULL
    ,[dblLastCost]                          NUMERIC(38,20)  NULL DEFAULT 0
    ,[intCategoryId]                        INT             NULL
    ,[ysnRetailValuation]                   BIT             NULL DEFAULT 0
    ,[dblPrice]                             NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBasePrice]                         NUMERIC(18,6)   NULL DEFAULT 0
	,[dblUnitPrice]                         NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseUnitPrice]                     NUMERIC(18,6)   NULL DEFAULT 0
    ,[strPricing]                           NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[dblDiscount]                          NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblDiscountAmount]                    NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseDiscountAmount]                NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblTotal]                             NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseTotal]                         NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblLineItemGLAmount]                  NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseLineItemGLAmount]              NUMERIC(18,6)   NULL DEFAULT 0
    ,[intCurrencyExchangeRateTypeId]        INT             NULL
    ,[dblCurrencyExchangeRate]              NUMERIC(18,6)   NULL DEFAULT 1
    ,[strCurrencyExchangeRateType]          NVARCHAR(20)    COLLATE Latin1_General_CI_AS    NULL
    ,[intLotId]                             INT             NULL
    ,[intOriginalInvoiceDetailId]           INT             NULL
    ,[strMaintenanceType]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strFrequency]                         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[dtmMaintenanceDate]                   DATETIME        NULL
    ,[dblLicenseAmount]                     NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseLicenseAmount]                 NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblLicenseGLAmount]                   NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseLicenseGLAmount]               NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblMaintenanceAmount]                 NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseMaintenanceAmount]             NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblMaintenanceGLAmount]               NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseMaintenanceGLAmount]           NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblTaxesAddToCost]					NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseTaxesAddToCost]				NUMERIC(18,6)   NULL DEFAULT 0
    ,[ysnTankRequired]                      BIT             NULL DEFAULT 0
    ,[ysnLeaseBilling]                      BIT             NULL DEFAULT 0
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
    ,[ysnAutoBlend]                         BIT             NULL DEFAULT 0
    ,[ysnBlended]                           BIT             NULL DEFAULT 0  
    ,[dblQuantity]                          NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblMaxQuantity]                       NUMERIC(18,6)   NULL DEFAULT 0	
    ,[strOptionType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strSourceType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strPostingMessage]                    NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
    ,[strDescription]                       NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
	,[strBOLNumber]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS    NULL
)

IF(OBJECT_ID('tempdb..##ARPostInvoiceDetail') IS NOT NULL) DROP TABLE ##ARPostInvoiceDetail
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
    ,[ysnCustomerActive]                    BIT             NULL DEFAULT 0
    ,[dblCustomerCreditLimit]               NUMERIC(18,6)   NULL DEFAULT 0
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
    ,[dblAverageExchangeRate]               NUMERIC(18,6)   NULL DEFAULT 0
    ,[intTermId]                            INT             NULL
    ,[dblInvoiceTotal]                      NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseInvoiceTotal]                  NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblShipping]                          NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseShipping]                      NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblTax]                               NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseTax]                           NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblAmountDue]                         NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseAmountDue]                     NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblPayment]                           NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBasePayment]                       NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblProvisionalAmount]                 NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseProvisionalAmount]             NUMERIC(18,6)   NULL DEFAULT 0
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
    ,[intPeriodsToAccrue]                   INT             NULL DEFAULT 1
    ,[ysnAccrueLicense]                     BIT             NULL DEFAULT 0
    ,[intSplitId]                           INT             NULL
    ,[dblSplitPercent]                      NUMERIC(18,6)   NULL DEFAULT 0	
    ,[ysnSplitted]                          BIT             NULL DEFAULT 0
    ,[ysnPosted]                            BIT             NULL DEFAULT 0	
    ,[ysnRecurring]                         BIT             NULL DEFAULT 0	
    ,[ysnImpactInventory]                   BIT             NULL DEFAULT 1	
	,[ysnImportedAsPosted]                  BIT             NULL DEFAULT 0	
	,[ysnImportedFromOrigin]                BIT             NULL DEFAULT 0	
    ,[dtmDatePosted]                        DATETIME        NULL
    ,[strBatchId]                           NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
    ,[ysnPost]                              BIT             NULL DEFAULT 0
    ,[ysnRecap]                             BIT             NULL DEFAULT 0
    ,[intEntityId]                          INT             NOT NULL
    ,[intUserId]                            INT             NOT NULL
    ,[ysnUserAllowedToPostOtherTrans]       BIT             NULL DEFAULT 0
    ,[ysnWithinAccountingDate]              BIT             NULL DEFAULT 0
    ,[ysnForApproval]                       BIT             NULL DEFAULT 0
    ,[ysnFromProvisional]                   BIT             NULL DEFAULT 0
    ,[ysnProvisionalWithGL]                 BIT             NULL DEFAULT 0
    ,[ysnExcludeInvoiceFromPayment]         BIT             NULL DEFAULT 0
    ,[ysnRefundProcessed]                   BIT             NULL DEFAULT 0
    ,[ysnIsInvoicePositive]                 BIT             NULL DEFAULT 1
    ,[ysnFromReturn]                        BIT             NULL DEFAULT 0
    ,[ysnCancelled]                         BIT             NULL DEFAULT 0
    ,[ysnPaid]                              BIT             NULL DEFAULT 0
    ,[strPONumber]                          NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL

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
    ,[dblQtyShipped]                        NUMERIC(38,20)  NULL DEFAULT 0	
    ,[dblUnitQtyShipped]                    NUMERIC(38,20)  NULL DEFAULT 0
    ,[dblShipmentNetWt]                     NUMERIC(38,20)  NULL DEFAULT 0	
    ,[dblUnitQty]                           NUMERIC(38,20)  NULL DEFAULT 0
    ,[dblUnitOnHand]                        NUMERIC(38,20)  NULL DEFAULT 0
    ,[intAllowNegativeInventory]            INT             NULL
    ,[ysnStockTracking]                     BIT             NULL DEFAULT 0
    ,[intItemLocationId]                    INT             NULL
    ,[dblLastCost]                          NUMERIC(38,20)  NULL DEFAULT 0
    ,[intCategoryId]                        INT             NULL
    ,[ysnRetailValuation]                   BIT             NULL DEFAULT 0
    ,[dblPrice]                             NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBasePrice]                         NUMERIC(18,6)   NULL DEFAULT 0
	,[dblUnitPrice]                         NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseUnitPrice]                     NUMERIC(18,6)   NULL DEFAULT 0
    ,[strPricing]                           NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
    ,[dblDiscount]                          NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblDiscountAmount]                    NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseDiscountAmount]                NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblTotal]                             NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseTotal]                         NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblLineItemGLAmount]                  NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseLineItemGLAmount]              NUMERIC(18,6)   NULL DEFAULT 0
    ,[intCurrencyExchangeRateTypeId]        INT             NULL
    ,[dblCurrencyExchangeRate]              NUMERIC(18,6)   NULL DEFAULT 1
    ,[strCurrencyExchangeRateType]          NVARCHAR(20)    COLLATE Latin1_General_CI_AS    NULL
    ,[intLotId]                             INT             NULL
    ,[intOriginalInvoiceDetailId]           INT             NULL
    ,[strMaintenanceType]                   NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[strFrequency]                         NVARCHAR(25)    COLLATE Latin1_General_CI_AS    NULL
    ,[dtmMaintenanceDate]                   DATETIME        NULL
    ,[dblLicenseAmount]                     NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseLicenseAmount]                 NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblLicenseGLAmount]                   NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseLicenseGLAmount]               NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblMaintenanceAmount]                 NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseMaintenanceAmount]             NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblMaintenanceGLAmount]               NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseMaintenanceGLAmount]           NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblTaxesAddToCost]					NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblBaseTaxesAddToCost]				NUMERIC(18,6)   NULL DEFAULT 0
    ,[ysnTankRequired]                      BIT             NULL DEFAULT 0
    ,[ysnLeaseBilling]                      BIT             NULL DEFAULT 0
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
    ,[ysnAutoBlend]                         BIT             NULL DEFAULT 0
    ,[ysnBlended]                           BIT             NULL DEFAULT 0  
    ,[dblQuantity]                          NUMERIC(18,6)   NULL DEFAULT 0
    ,[dblMaxQuantity]                       NUMERIC(18,6)   NULL DEFAULT 0	
    ,[strOptionType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strSourceType]                        NVARCHAR(30)    COLLATE Latin1_General_CI_AS    NULL
    ,[strPostingMessage]                    NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS    NULL
    ,[strDescription]                       NVARCHAR(250)   COLLATE Latin1_General_CI_AS    NULL
	,[strBOLNumber]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS    NULL
)

IF(OBJECT_ID('tempdb..##ARInvoiceItemAccount') IS NOT NULL) DROP TABLE ##ARInvoiceItemAccount
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

IF(OBJECT_ID('tempdb..##ARInvalidInvoiceData') IS NOT NULL) DROP TABLE ##ARInvalidInvoiceData
CREATE TABLE ##ARInvalidInvoiceData (
      [intInvoiceId]			INT				NOT NULL
	, [strInvoiceNumber]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [strTransactionType]		NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL
	, [intInvoiceDetailId]		INT				NULL
	, [intItemId]				INT				NULL
	, [strBatchId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL
	, [strPostingError]			NVARCHAR(MAX)	COLLATE Latin1_General_CI_AS	NULL
)

IF(OBJECT_ID('tempdb..##ARItemsForCosting') IS NOT NULL) DROP TABLE ##ARItemsForCosting
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
	, [ysnIsStorage]					BIT NULL DEFAULT 0
	, [strActualCostId]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [intSourceTransactionId]			INT NULL
	, [strSourceTransactionId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	, [intInTransitSourceLocationId]	INT NULL
	, [intForexRateTypeId]				INT NULL
	, [dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1
	, [intStorageScheduleTypeId]		INT NULL
    , [dblUnitRetail]					NUMERIC(38, 20) NULL DEFAULT 0
	, [intCategoryId]					INT NULL 
	, [dblAdjustCostValue]				NUMERIC(38, 20) NULL DEFAULT 0
	, [dblAdjustRetailValue]			NUMERIC(38, 20) NULL DEFAULT 0
	, [strType]                         NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , [ysnAutoBlend]                    BIT NULL DEFAULT 0
    , [ysnGLOnly]						BIT NULL DEFAULT 0
	, [strBOLNumber]					NVARCHAR(100) NULL 
    , [strSourceType]                   NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , [strSourceNumber]                 NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    , [intSourceEntityId]				INT NULL
)

IF(OBJECT_ID('tempdb..##ARItemsForInTransitCosting') IS NOT NULL) DROP TABLE ##ARItemsForInTransitCosting
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
    , [intSourceEntityId]				INT NULL
)

IF(OBJECT_ID('tempdb..##ARItemsForStorageCosting') IS NOT NULL) DROP TABLE ##ARItemsForStorageCosting
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
	, [ysnIsStorage]					BIT NULL DEFAULT 0
	, [strActualCostId]					NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
    , [intSourceTransactionId]			INT NULL
	, [strSourceTransactionId]			NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	, [intInTransitSourceLocationId]	INT NULL
	, [intForexRateTypeId]				INT NULL
	, [dblForexRate]					NUMERIC(38, 20) NULL DEFAULT 1
	, [intStorageScheduleTypeId]		INT NULL
    , [dblUnitRetail]					NUMERIC(38, 20) NULL DEFAULT 0
	, [intCategoryId]					INT NULL 
	, [dblAdjustCostValue]				NUMERIC(38, 20) NULL DEFAULT 0
	, [dblAdjustRetailValue]			NUMERIC(38, 20) NULL DEFAULT 0
	, [strBOLNumber]					NVARCHAR(100) NULL 
)

IF(OBJECT_ID('tempdb..##ARItemsForContracts') IS NOT NULL) DROP TABLE ##ARItemsForContracts
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
	, [ysnFromReturn]					BIT NULL DEFAULT 0
)

IF(OBJECT_ID('tempdb..##ARInvoiceGLEntries') IS NOT NULL) DROP TABLE ##ARInvoiceGLEntries
CREATE TABLE ##ARInvoiceGLEntries (
	  [dtmDate]							DATETIME         NOT NULL
	, [strBatchId]						NVARCHAR (50)    COLLATE Latin1_General_CI_AS NULL
	, [intAccountId]					INT              NULL
	, [dblDebit]						NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblCredit]						NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblDebitUnit]					NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblCreditUnit]					NUMERIC (18, 6)  NULL DEFAULT 0
	, [strDescription]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [strCode]							NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL 
	, [strReference]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL
	, [intCurrencyId]					INT              NULL
	, [dblExchangeRate]					NUMERIC (38, 20) DEFAULT 1 NOT NULL
	, [dtmDateEntered]					DATETIME         NOT NULL
	, [dtmTransactionDate]				DATETIME         NULL
	, [strJournalLineDescription]		NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL
	, [intJournalLineNo]				INT              NULL
	, [ysnIsUnposted]					BIT              NOT NULL DEFAULT 0
	, [intUserId]						INT              NULL
	, [intEntityId]						INT              NULL
	, [strTransactionId]				NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL
	, [intTransactionId]				INT              NULL
	, [strTransactionType]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strTransactionForm]				NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [strModuleName]					NVARCHAR (255)   COLLATE Latin1_General_CI_AS NOT NULL
	, [intConcurrencyId]				INT              DEFAULT 1 NOT NULL
	, [dblDebitForeign]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblDebitReport]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblCreditForeign]				NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblCreditReport]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblReportingRate]				NUMERIC (18, 9)  NULL DEFAULT 0
	, [dblForeignRate]					NUMERIC (18, 9)  NULL DEFAULT 0
	, [intCurrencyExchangeRateTypeId]	INT NULL
	, [strRateType]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [strDocument]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strComments]						NVARCHAR(255)   COLLATE Latin1_General_CI_AS NULL
	, [strSourceDocumentId]				NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	, [intSourceLocationId]				INT NULL
	, [intSourceUOMId]					INT NULL
	, [dblSourceUnitDebit]				NUMERIC (18, 6)  NULL DEFAULT 0
	, [dblSourceUnitCredit]				NUMERIC (18, 6)  NULL DEFAULT 0
	, [intCommodityId]					INT NULL
	, [intSourceEntityId]				INT NULL
	, [ysnRebuild]						BIT				 NULL DEFAULT 0
)
GO