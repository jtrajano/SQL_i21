﻿CREATE TABLE [dbo].[tblARInvoiceDetail] (
    [intInvoiceDetailId]					INT             IDENTITY (1, 1)					NOT NULL,
    [intInvoiceId]							INT												NOT NULL,
	[strDocumentNumber]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
    [intItemId]								INT												NULL,
	[intPrepayTypeId]						INT				CONSTRAINT [DF_tblARInvoiceDetail_intPrepayTypeId] DEFAULT ((0)) NULL,
	[dblPrepayRate]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblPrepayRate] DEFAULT ((0)) NULL,
    [strItemDescription]					NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dblQtyOrdered]							NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblQtyOrdered] DEFAULT ((0)) NULL,
	[intOrderUOMId]							INT												NULL,    
    [dblQtyShipped]							NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblQtyShipped] DEFAULT ((0)) NULL,
	[intItemUOMId]							INT												NULL,
	[dblItemWeight]							NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblItemWeight] DEFAULT ((0)) NULL,
	[intItemWeightUOMId]					INT												NULL, 
	[dblStandardWeight]						NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblStandardWeight] DEFAULT ((0)) NULL,
	[dblDiscount]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblDiscount] DEFAULT ((0)) NULL,
	[dblItemTermDiscount]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblItemTermDiscount] DEFAULT ((0)) NULL,	
	[strItemTermDiscountBy]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[dblItemTermDiscountAmount]				NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblItemTermDiscountAmount] DEFAULT ((0)) NULL,
	[dblBaseItemTermDiscountAmount]			NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseItemTermDiscountAmount] DEFAULT ((0)) NULL,
	[dblItemTermDiscountExemption]			NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblItemTermDiscountExemption] DEFAULT ((0)) NULL,
	[dblBaseItemTermDiscountExemption]		NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseItemTermDiscountExemption] DEFAULT ((0)) NULL,
	[dblTermDiscountRate]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblTermDiscountRate] DEFAULT ((0)) NULL,
	[ysnTermDiscountExempt]					BIT				CONSTRAINT [DF_tblARInvoiceDetail_ysnTermDiscountExempt] DEFAULT ((0)) NULL,
    [dblPrice]								NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblPrice] DEFAULT ((0)) NULL,
	[dblBasePrice]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBasePrice] DEFAULT ((0)) NULL,
	[dblUnitPrice]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblUnitPrice] DEFAULT ((0)) NULL,	
	[dblBaseUnitPrice]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseUnitPrice] DEFAULT ((0)) NULL,
	[ysnAllowRePrice]						BIT				CONSTRAINT [DF_tblARInvoiceDetail_ysnAllowRePrice] DEFAULT ((0)) NULL,
	[dblOriginalGrossPrice]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblOriginalGrossPrice] DEFAULT ((0)) NULL,
	[dblBaseOriginalGrossPrice]				NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseOriginalGrossPrice] DEFAULT ((0)) NULL,
	[dblComputedGrossPrice]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblComputedGrossPrice] DEFAULT ((0)) NULL,
	[dblBaseComputedGrossPrice]				NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseComputedGrossPrice] DEFAULT ((0)) NULL,
	[intPriceUOMId]							INT												NULL,	
	[dblUnitQuantity]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblUnitQuantity] DEFAULT ((0)) NULL,
	[strPricing]							NVARCHAR(250)	COLLATE Latin1_General_CI_AS	NULL,
	[dblTotalTax]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblTotalTax] DEFAULT ((0)) NULL,
	[dblBaseTotalTax]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseTotalTax] DEFAULT ((0)) NULL,
    [dblTotal]								NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblTotal] DEFAULT ((0)) NULL,
	[dblBaseTotal]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseTotal] DEFAULT ((0)) NULL,
	[intCurrencyExchangeRateTypeId]			INT												NULL,
	[intCurrencyExchangeRateId]				INT												NULL,
	[dblCurrencyExchangeRate]				NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblCurrencyExchangeRate] DEFAULT ((1)) NULL,
	[intSubCurrencyId]						INT												NULL,
	[dblSubCurrencyRate]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblSubCurrencyRate] DEFAULT ((1)) NULL,
	[ysnRestricted]							BIT				CONSTRAINT [DF_tblARInvoiceDetail_ysnRestricted] DEFAULT ((0)) NULL,
	[ysnBlended]							BIT				CONSTRAINT [DF_tblARInvoiceDetail_ysnBlended] DEFAULT ((0)) NULL,
	[ysnReturned]							BIT				CONSTRAINT [DF_tblARInvoiceDetail_ysnReturned] DEFAULT ((0)) NULL,
	[intAccountId]							INT												NULL,
	[intCOGSAccountId]						INT												NULL,
	[intSalesAccountId]						INT												NULL,
	[intInventoryAccountId]					INT												NULL,
	[intServiceChargeAccountId]				INT												NULL,
	[intLicenseAccountId]					INT												NULL,
	[intMaintenanceAccountId]				INT												NULL,
	[strMaintenanceType]					NVARCHAR(25)    COLLATE Latin1_General_CI_AS	NULL,
    [strFrequency]							NVARCHAR(25)    COLLATE Latin1_General_CI_AS	NULL,
    [dtmMaintenanceDate]					DATETIME										NULL, 
    [dblMaintenanceAmount]					NUMERIC(18, 6)									NULL, 
	[dblBaseMaintenanceAmount]				NUMERIC(18, 6)									NULL, 
    [dblLicenseAmount]						NUMERIC(18, 6)									NULL,      	
	[dblBaseLicenseAmount]					NUMERIC(18, 6)									NULL,      	
	[intTaxGroupId]							INT												NULL,
	[intStorageLocationId]					INT												NULL,
	[intCompanyLocationSubLocationId]		INT												NULL,
	[intSCInvoiceId]						INT												NULL,
	[intSCBudgetId]							INT												NULL,
	[strSCInvoiceNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strSCBudgetDescription]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
	[intInventoryShipmentItemId]			INT												NULL,
	[intInventoryShipmentChargeId]			INT												NULL,
	[intRecipeItemId]						INT												NULL,
	[strShipmentNumber]						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[strSubFormula] 						NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,
	[intSalesOrderDetailId]					INT												NULL,
	[strSalesOrderNumber]					NVARCHAR(25)	COLLATE Latin1_General_CI_AS	NULL,
	[strVFDDocumentNumber]					NVARCHAR(100)	COLLATE Latin1_General_CI_AS	NULL,
	[strBOLNumberDetail]					NVARCHAR(50)	COLLATE Latin1_General_CI_AS	NULL,    
	[intContractHeaderId]					INT												NULL,
	[intContractDetailId]					INT												NULL, 
	[intItemContractHeaderId]				INT												NULL,
	[intItemContractDetailId]				INT												NULL, 
	[intItemCategoryId]						INT												NULL,
	[intCategoryId]							INT												NULL,
	[dblContractBalance]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblContractBalance] DEFAULT ((0)) NULL,
	[dblContractAvailable]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblContractAvailable] DEFAULT ((0)) NULL,
	[intShipmentId]							INT												NULL,
	[intShipmentPurchaseSalesContractId]	INT												NULL,	
	[dblShipmentGrossWt]					NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblShipmentGrossWt] DEFAULT ((0)) NULL,
	[dblShipmentTareWt]						NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblShipmentTareWt] DEFAULT ((0)) NULL,
	[dblShipmentNetWt]						NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblShipmentNetWt] DEFAULT ((0)) NULL,
	[intTicketId]							INT												NULL, 
	[intTicketHoursWorkedId]				INT												NULL,
	[intCustomerStorageId]					INT												NULL,
	[intSiteDetailId]						INT												NULL,
	[intLoadDetailId]						INT												NULL,
	[intLoadDistributionDetailId]			INT												NULL,
	[intLotId]								INT												NULL,
	[intOriginalInvoiceDetailId]			INT												NULL,
	[intConversionAccountId]				INT												NULL,
	[intEntitySalespersonId]				INT												NULL,
	[intSiteId]								INT												NULL,
	[strBillingBy]							NVARCHAR(100)   COLLATE Latin1_General_CI_AS	NULL,
	[dblPercentFull]						NUMERIC(18, 6)									NULL,
	[dblNewMeterReading]					NUMERIC(18, 6)									NULL,
	[dblPreviousMeterReading]				NUMERIC(18, 6)									NULL,
	[dblConversionFactor]					NUMERIC(18, 8)									NULL,
	[intPerformerId]						INT												NULL,
	[ysnLeaseBilling]						BIT												NULL,	
	[ysnVirtualMeterReading]				BIT												NULL,	
	[dblOriginalItemWeight]					NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblOriginalItemWeight] DEFAULT ((0)) NULL,
	[intCompanyId]							INT												NULL,
    [intConcurrencyId]						INT				CONSTRAINT [DF_tblARInvoiceDetail_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	[intRecipeId]							INT												NULL,
	[intSubLocationId]						INT												NULL,
	[intCostTypeId]							INT												NULL,
	[intMarginById]							INT												NULL,
	[intCommentTypeId]						INT												NULL,
	[dblMargin]								NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblMargin] DEFAULT ((0)) NULL,
	[dblRecipeQuantity]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblRecipeQuantity] DEFAULT ((0)) NULL,
	[intStorageScheduleTypeId]				INT												NULL,
	[intDestinationGradeId]					INT												NULL,
	[intDestinationWeightId]				INT												NULL,
	[intSpecialPriceId]						INT												NULL,
	[strRebateSubmitted]					NVARCHAR(1)		COLLATE Latin1_General_CI_AS CONSTRAINT [DF_tblARInvoiceDetail_strRebateSubmitted] DEFAULT (N'N') NOT NULL,
	[dblRebateAmount]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblRebateAmount] DEFAULT ((0)) NULL,
	[dblBaseRebateAmount]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseRebateAmount] DEFAULT ((0)) NULL,
	[strBuybackSubmitted]					NVARCHAR(1)		COLLATE Latin1_General_CI_AS CONSTRAINT [DF_tblARInvoiceDetail_strBuybackSubmitted] DEFAULT (N'N') NOT NULL,
	[dblBuybackAmount]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBuybackAmount] DEFAULT ((0)) NULL,
	[dblBaseBuybackAmount]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseBuybackAmount] DEFAULT ((0)) NULL,
	[strAddonDetailKey]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS 	NULL,
	[ysnAddonParent]						BIT												NULL,
	[ysnItemContract]						BIT												NULL,
	[dblAddOnQuantity]						NUMERIC(38, 20)	CONSTRAINT [DF_tblARInvoiceDetail_dblAddOnQuantity] DEFAULT ((0)) NULL,
	[dblPriceAdjustment]					NUMERIC(18,6)									NULL,
	[strBinNumber]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS 	NULL,
	[strGroupNumber]						NVARCHAR(100)	COLLATE Latin1_General_CI_AS 	NULL,
	[strFeedDiet]							NVARCHAR(100)	COLLATE Latin1_General_CI_AS 	NULL,
	[intPriceFixationDetailId]				INT												NULL,
	[dblRounding]							NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblRounding] DEFAULT ((0)) NULL,
	[dblBaseRounding]						NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblBaseRounding] DEFAULT ((0)) NULL,
	[dblQualityPremium]						NUMERIC(18, 6)  CONSTRAINT [DF_tblARInvoiceDetail_dblQualityPremium] DEFAULT ((0)) NULL,
	[dblOptionalityPremium]					NUMERIC(18, 6)  CONSTRAINT [DF_tblARInvoiceDetail_dblOptionalityPremium] DEFAULT ((0)) NULL,
	[ysnOverrideForexRate]					BIT												NULL,
	[strReasonablenessComment]				NVARCHAR(MAX)   COLLATE Latin1_General_CI_AS	NULL,
	[dblServiceChargeAmountDue]				NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblServiceChargeAmountDue] DEFAULT ((0)) NULL,
	[dblServiceChargeAPR]					NUMERIC(18, 6)	CONSTRAINT [DF_tblARInvoiceDetail_dblServiceChargeAPR] DEFAULT ((0)) NULL,
	[ysnOverrideTaxGroup]					BIT												NULL,
    CONSTRAINT [PK_tblARInvoiceDetail_intInvoiceDetailId] PRIMARY KEY CLUSTERED ([intInvoiceDetailId] ASC),
    CONSTRAINT [FK_tblARInvoiceDetail_tblARInvoice] FOREIGN KEY ([intInvoiceId]) REFERENCES [dbo].[tblARInvoice] ([intInvoiceId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intAccountId] FOREIGN KEY ([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intConversionAccountId] FOREIGN KEY ([intConversionAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intLicenseAccountId] FOREIGN KEY ([intLicenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
    CONSTRAINT [FK_tblARInvoiceDetail_tblGLAccount_intMaintenanceAccountId] FOREIGN KEY ([intMaintenanceAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICInventoryShipmentItem_intInventoryShipmentItemId] FOREIGN KEY ([intInventoryShipmentItemId]) REFERENCES [dbo].[tblICInventoryShipmentItem] ([intInventoryShipmentItemId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICInventoryShipmentCharge_intInventoryShipmentChargeId] FOREIGN KEY ([intInventoryShipmentChargeId]) REFERENCES [dbo].[tblICInventoryShipmentCharge] ([intInventoryShipmentChargeId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSOSalesOrderDetail_intSalesOrderDetailId] FOREIGN KEY ([intSalesOrderDetailId]) REFERENCES [dbo].[tblSOSalesOrderDetail] ([intSalesOrderDetailId]),	
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),	
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTItemContractHeader_intItemContractHeaderId] FOREIGN KEY ([intItemContractHeaderId]) REFERENCES [dbo].[tblCTItemContractHeader] ([intItemContractHeaderId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTItemContractDetail_intItemContractDetailId] FOREIGN KEY ([intItemContractDetailId]) REFERENCES [dbo].[tblCTItemContractDetail] ([intItemContractDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTItemContractHeaderCategory_intItemCategoryId] FOREIGN KEY ([intItemCategoryId]) REFERENCES [dbo].[tblCTItemContractHeaderCategory] ([intItemCategoryId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblLGShipment_intShipmentId] FOREIGN KEY ([intShipmentId]) REFERENCES [dbo].[tblLGShipment] ([intShipmentId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblLGShipmentPurchaseSalesContract_intShipmentPurchaseSalesContractId] FOREIGN KEY ([intShipmentPurchaseSalesContractId]) REFERENCES [dbo].[tblLGShipmentPurchaseSalesContract] ([intShipmentPurchaseSalesContractId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSCTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES [dbo].[tblSCTicket] ([intTicketId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblHDTicketHoursWorked_intTicketHoursWorkedId] FOREIGN KEY ([intTicketHoursWorkedId]) REFERENCES [dbo].[tblHDTicketHoursWorked] ([intTicketHoursWorkedId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblTMSite_intSiteId] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblTMSite] ([intSiteID]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblARSalesperson_intEntitySalespersonId] FOREIGN KEY ([intEntitySalespersonId]) REFERENCES [dbo].[tblARSalesperson] ([intEntityId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMCompanyLocationSubLocation_intCompanyLocationSubLocationId] FOREIGN KEY ([intCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGRCustomerStorage_intCustomerStorageId] FOREIGN KEY ([intCustomerStorageId]) REFERENCES [tblGRCustomerStorage]([intCustomerStorageId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCCSiteDetail_intSiteDetailId] FOREIGN KEY ([intSiteDetailId]) REFERENCES [tblCCSiteDetail]([intSiteDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [tblLGLoadDetail]([intLoadDetailId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblICLot_intLotId] FOREIGN KEY ([intLotId]) REFERENCES [tblICLot]([intLotId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblMFRecipeItem_intRecipeItemId] FOREIGN KEY ([intRecipeItemId]) REFERENCES [tblMFRecipeItem]([intRecipeItemId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [tblGRStorageType]([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblSMCurrency_intSubCurrencyId] FOREIGN KEY ([intSubCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblARInvoiceDetail_tblCTWeightGrade_intDestinationGradeId] FOREIGN KEY ([intDestinationGradeId]) REFERENCES [tblCTWeightGrade]([intWeightGradeId]),
    CONSTRAINT [FK_tblARInvoiceDetail_tblCTWeightGrade_intDestinationWeightId] FOREIGN KEY ([intDestinationWeightId]) REFERENCES [tblCTWeightGrade]([intWeightGradeId])
);
--INDEXES
GO
CREATE NONCLUSTERED INDEX [PIndex]
    ON [dbo].[tblARInvoiceDetail]([intInvoiceId] ASC, [intItemId] ASC, [strItemDescription] ASC, [dblQtyOrdered] ASC, [dblQtyShipped] ASC, [dblPrice] ASC, [dblTotal] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_strDocumentNumber]
	ON [dbo].[tblARInvoiceDetail] ([strDocumentNumber],[intInventoryShipmentItemId])
INCLUDE ([intInvoiceId])
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_intInventoryShipmentItemId]
	ON [dbo].[tblARInvoiceDetail] ([intInventoryShipmentItemId])
INCLUDE ([intInvoiceId])
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_intCustomerStorageId]
	ON [dbo].[tblARInvoiceDetail] ([intCustomerStorageId])
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_forStockRebuild]
	ON [dbo].[tblARInvoiceDetail] (intInvoiceDetailId, intItemId)
INCLUDE ([intInvoiceId])
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_intInventoryShipmentChargeId]
	ON [dbo].[tblARInvoiceDetail] ([intInventoryShipmentChargeId])
	INCLUDE ([intInvoiceId])
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_intOriginalInvoiceDetailId]
	ON [dbo].[tblARInvoiceDetail] ([intOriginalInvoiceDetailId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_intInvoiceId] 
	ON [dbo].[tblARInvoiceDetail] ([intInvoiceId])
INCLUDE ([intItemId], [dblQtyShipped], [intItemUOMId], [intInventoryShipmentItemId], [intSalesOrderDetailId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_intTicketId]
	ON [dbo].[tblARInvoiceDetail] ([intTicketId])
INCLUDE ([intInvoiceId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_intSalesOrderDetailId]
	ON [dbo].[tblARInvoiceDetail] ([intSalesOrderDetailId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_intItemId]
	ON [dbo].[tblARInvoiceDetail] ([intSalesOrderDetailId])
INCLUDE ([intInvoiceId], [dblQtyShipped], [intSiteId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_strPricing_intContractHeaderId] 
	ON [dbo].[tblARInvoiceDetail] ([strPricing],[intContractHeaderId]) 
INCLUDE ([intInvoiceId], [dblQtyShipped], [intItemUOMId], [intContractDetailId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_intAccountId]
	ON [dbo].[tblARInvoiceDetail] ([intAccountId])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_intContractHeaderId_intContractDetailId_intItemContractHeaderId_intItemContractDetailId]
	ON [dbo].[tblARInvoiceDetail] ([intContractHeaderId], [intContractDetailId], [intItemContractHeaderId], [intItemContractDetailId])
INCLUDE ([intInvoiceId], [intItemId], [intItemUOMId], [dblQtyShipped], [dblPrice])
GO
CREATE NONCLUSTERED INDEX [IDX_tblARInvoiceDetail_intLoadDetailId_intSiteDetailId]
	ON [dbo].[tblARInvoiceDetail] ([intLoadDetailId])
INCLUDE ([intInvoiceId], [intItemId], [intItemUOMId], [dblQtyShipped], [dblPrice])
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_intContractDetailId]
	ON [dbo].[tblARInvoiceDetail] ([intContractDetailId])
INCLUDE ([intInvoiceId])
GO
CREATE NONCLUSTERED INDEX [IX_tblARInvoiceDetail_intSCInvoiceId]
	ON [dbo].[tblARInvoiceDetail] ([intSCInvoiceId])
INCLUDE ([intInvoiceId])
GO