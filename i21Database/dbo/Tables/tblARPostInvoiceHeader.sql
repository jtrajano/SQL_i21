CREATE TABLE tblARPostInvoiceHeader (
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
    ,[strInterCompanyVendorId]				NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[strInterCompanyLocationId]			NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[intInterCompanyId]					INT				NULL
	,[strReceiptNumber]						NVARCHAR(15)    COLLATE Latin1_General_CI_AS    NULL
	,[ysnInterCompany]                      BIT             NULL
	,[intInterCompanyVendorId]				INT				NULL
	,[strBOLNumber]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS    NULL
    ,[ysnAllowIntraEntries]                 BIT             NULL DEFAULT 0
    ,[ysnSkipIntraEntriesValiation]         BIT             NULL DEFAULT 0
    ,[strSessionId]			                NVARCHAR(50)    COLLATE Latin1_General_CI_AS    NULL
);
GO
CREATE INDEX [idx_tblARPostInvoiceHeader_intInvoiceId] ON [dbo].[tblARPostInvoiceHeader] (intInvoiceId)
GO
CREATE INDEX [idx_tblARPostInvoiceHeader_strSessionId] ON [dbo].[tblARPostInvoiceHeader] (strSessionId)
GO