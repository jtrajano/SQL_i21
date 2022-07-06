
CREATE TABLE [dbo].[tblAGWorkOrderDetail]
(
	[intWorkOrderDetailId] INT IDENTITY(1,1) NOT NULL,
	[intWorkOrderId] INT NULL,
	[intItemId] INT NULL,
	[strItemDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strEPARegNo] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[strLineNo] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intItemUOMId] INT NULL,
	[intPriceUOMId] INT NULL,
	[dblRate] NUMERIC(18,6) NULL,
	[dblQtyOrdered] NUMERIC(18,6) NULL,
	[dblQtyAllocated] NUMERIC(18,6) NULL,
	[dblQtyShipped] NUMERIC(18,6) NULL,
	[dblDiscount] NUMERIC(18,6) NULL,
	[dblDiscountValue] NUMERIC(18,6) NULL,
	[dblItemTermDiscount] NUMERIC(18,6) NULL,
	[strItemTermDiscountBy] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intTaxId] INT NULL,
	[dblPrice] NUMERIC(18,6) NULL,
	[dblBasePrice] NUMERIC(18,6) NULL,
	[dblUnitPrice] NUMERIC(18,6) NULL,
	[dblBaseUnitPrice] NUMERIC(18,6) NULL,
	[dblUnitQuantity] NUMERIC(18,6) NULL,
	[strPricing] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[dblTotalTax] NUMERIC(18,6) NULL,
	[dblBaseTotalTax] NUMERIC(18,6) NULL,
	[dblTotal] NUMERIC(18,6) NULL,
	[dblBaseTotal] NUMERIC(18,6) NULL,
	[strComments] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intAccountId] INT NULL, --fk
	[intCOGSAccountId] INT NULL,--fk
	[intSalesAccountId] INT NULL, --fk
	[intInventoryAccountId] INT NULL,--fk
	[intLicenseAccountId] INT NULL,--fk
	[intMaintenanceAccountId] INT NULL, --fk
	[intStorageLocationId] INT NULL, --fk
	[strMaintenanceType] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[strFrequency] NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL,
	[dtmMaintenanceDate] DATETIME NULL,
	[dblMaintenanceAmount] NUMERIC(18,6) NULL,
	[dblBaseMaintenanceAmount] NUMERIC(18,6) NULL,
	[dblLicenseAmount] NUMERIC(18,6) NULL,
	[dblBaseLicenseAmount] NUMERIC(18,6) NULL,
	[strVFDDocumentNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intContractHeaderId] INT NULL, --fk
	[intContractDetailId] INT NULL, --fk
	[intItemContractHeaderId] INT NULL, --fk
	[intItemContractDetailId] INT NULL, --fk
	[dblContractBalance] NUMERIC(18,6) NULL,
	[dblContractAvailable] NUMERIC(18,6) NULL,
	[intTaxGroupId] INT NULL, --fk
	[intRecipeId] INT NULL, --fk
	[intSubLocationId] INT NULL,
	[ysnBlended] BIT NULL,
	[dblItemWeight] NUMERIC(18,6),
	[dblOriginalItemWeight] NUMERIC(18,6) NULL,
	[intCostTypeId] INT NULL,
	[intMarginById] INT NULL,
	[intCommentTypeId] INT NULL,
	[intRecipeItemId] INT NULL,
	[dblMargin] NUMERIC(18,6) NULL,
	[dblRecipeQuantity] NUMERIC(18,6) NULL,
	[intCustomerStorageId] INT NULL,
	[intStorageScheduleTypeId] INT NULL,--fk
	[intSubCurrencyId] INT NULL, --fk
	[dblSubCurrencyRate] NUMERIC(18,6) NULL,
	[intCurrencyExchangeRateTypeId] INT NULL, --fk
	[intCurrencyExchangeRateId] INT NULL,
	[dblCurrencyExchangeRate] NUMERIC(18,6) NULL,
	[strAddonDetailKey] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblAddOnQuantity] NUMERIC(18,6) NULL,
	[intItemWeightUOMId] INT NULL,
	[ysnAddonParent] BIT NULL,
	[ysnItemContract] BIT NULL,
	[intAGQtyUOMId] INT NULL,
	[intAGAreaUOMId] INT NULL,
	[intConcurrencyId] INT NULL,
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblAGWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [dbo].[tblAGWorkOrder] ([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblGLAccount_intAccountId] FOREIGN KEY([intAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),

	CONSTRAINT [FK_tblAGWorkOrderDetail_tblGLAccount_intCOGSAccountId] FOREIGN KEY ([intCOGSAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblGLAccount_intSalesAccountId] FOREIGN KEY ([intSalesAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblGLAccount_intInventoryAccountId] FOREIGN KEY ([intInventoryAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblGLAccount_intLicenseAccountId] FOREIGN KEY ([intLicenseAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblGLAccount_intMaintenanceAccountId] FOREIGN KEY ([intMaintenanceAccountId]) REFERENCES [dbo].[tblGLAccount] ([intAccountId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblICStorageLocation_intStorageLocationId] FOREIGN KEY ([intStorageLocationId]) REFERENCES [dbo].[tblICStorageLocation] ([intStorageLocationId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblSMCompanyLocationSubLocation_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [dbo].[tblSMCompanyLocationSubLocation] ([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblMFRecipe_intRecipeId] FOREIGN KEY ([intRecipeId]) REFERENCES [dbo].[tblMFRecipe] ([intRecipeId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblCTItemContractHeader_intItemContractHeaderId] FOREIGN KEY ([intItemContractHeaderId]) REFERENCES [dbo].[tblCTItemContractHeader] ([intItemContractHeaderId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblCTItemContractDetail_intItemContractDetailId] FOREIGN KEY ([intItemContractDetailId]) REFERENCES [dbo].[tblCTItemContractDetail] ([intItemContractDetailId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblSMTaxGroup_intTaxGroupId] FOREIGN KEY ([intTaxGroupId]) REFERENCES [dbo].[tblSMTaxGroup] ([intTaxGroupId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblGRStorageType_intStorageScheduleTypeId] FOREIGN KEY ([intStorageScheduleTypeId]) REFERENCES [dbo].[tblGRStorageType] ([intStorageScheduleTypeId]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblSMCurrency_intSubCurrencyId] FOREIGN KEY ([intSubCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblAGWorkOrderDetail_tblSMCurrencyExchangeRateType_intCurrencyExchangeRateTypeId] FOREIGN KEY ([intCurrencyExchangeRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]),
 	CONSTRAINT [FK_tblAGWorkOrderDetail_tblAGUnitMeasure_intAGQtyUOMId] FOREIGN KEY ([intAGQtyUOMId]) REFERENCES [dbo].[tblAGUnitMeasure] ([intAGUnitMeasureId]),
 	CONSTRAINT [FK_tblAGWorkOrderDetail_tblAGUnitMeasure_intAGAreaUOMId] FOREIGN KEY ([intAGAreaUOMId]) REFERENCES [dbo].[tblAGUnitMeasure] ([intAGUnitMeasureId]),
	CONSTRAINT [PK_dbo.tblAGWorkOrderDetail_intWorkOrderDetailId] PRIMARY KEY CLUSTERED ([intWorkOrderDetailId] ASC) 
	
	
)