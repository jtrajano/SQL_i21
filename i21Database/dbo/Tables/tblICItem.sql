/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItem] (
		[intItemId]                 INT             IDENTITY (1, 1) NOT NULL,
		[strItemNo]                 NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
		[strShortName]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strType]					NVARCHAR(50)    COLLATE Latin1_General_CI_AS NOT NULL,
		[strDescription]            NVARCHAR (250)  COLLATE Latin1_General_CI_AS NULL,
		[intManufacturerId]         INT             NULL,
		[intBrandId]                INT             NULL,
		[intCategoryId]				INT				NULL,
		[strStatus]					NVARCHAR(50)    COLLATE Latin1_General_CI_AS NULL,
		[strModelNo]                NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
		[strInventoryTracking]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strLotTracking] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnRequireCustomerApproval] BIT NULL DEFAULT ((0)), 
		[intRecipeId] INT NULL, 
		[ysnSanitationRequired] BIT NULL DEFAULT ((0)), 
		[intLifeTime] INT NOT NULL, 
		[strLifeTimeType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intReceiveLife] INT NULL, 
		[strGTIN] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strRotationType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intNMFCId] INT NULL, 
		[ysnStrictFIFO] BIT NULL DEFAULT ((0)), 
		[intDimensionUOMId] INT NULL, 
		[dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblDepth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intWeightUOMId] INT NULL, 
		[dblWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intMaterialPackTypeId] INT NULL,
		[strMaterialSizeCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intInnerUnits] INT NULL, 
		[intLayerPerPallet] INT NULL, 
		[intUnitPerLayer] INT NULL, 
		[dblStandardPalletRatio] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strMask1] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strMask2] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strMask3] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dblMaxWeightPerPack] NUMERIC(18, 6) NULL DEFAULT((0)),
		[intPatronageCategoryId] INT NULL,
		[intPatronageCategoryDirectId] INT NULL,
		[ysnStockedItem] BIT NULL DEFAULT ((0)), 
		[ysnDyedFuel] BIT NULL DEFAULT ((0)), 
		[strBarcodePrint] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnMSDSRequired] BIT NULL DEFAULT ((0)), 
		[strEPANumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnInboundTax] BIT NULL DEFAULT ((0)), 
		[ysnOutboundTax] BIT NULL DEFAULT ((0)), 
		[ysnRestrictedChemical] BIT NULL DEFAULT ((0)), 
		[ysnFuelItem] BIT NULL DEFAULT ((0)),
		[ysnTankRequired] BIT NULL DEFAULT ((0)), 
		[ysnAvailableTM] BIT NULL DEFAULT ((0)), 
		[dblDefaultFull] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strFuelInspectFee] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strRINRequired] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intRINFuelTypeId] INT NULL, 
		[dblDenaturantPercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnTonnageTax] BIT NULL DEFAULT ((0)), 
		[ysnLoadTracking] BIT NULL DEFAULT ((0)), 
		[dblMixOrder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnHandAddIngredient] BIT NULL DEFAULT ((0)), 
		[intMedicationTag] INT NULL, 
		[intIngredientTag] INT NULL, 
		[strVolumeRebateGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intPhysicalItem] INT NULL, 
		[ysnExtendPickTicket] BIT NULL DEFAULT ((0)), 
		[ysnExportEDI] BIT NULL DEFAULT ((0)), 
		[ysnHazardMaterial] BIT NULL DEFAULT ((0)), 
		[ysnMaterialFee] BIT NULL DEFAULT ((0)), 
		[ysnAutoBlend] BIT NULL DEFAULT ((0)),
		[dblUserGroupFee] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[dblWeightTolerance] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[dblOverReceiveTolerance] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[strMaintenanceCalculationMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[dblMaintenanceRate] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[ysnListBundleSeparately] BIT NULL DEFAULT ((1)),
		[intModuleId] INT NULL,
		[strNACSCategory] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strWICCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intAGCategory] INT NULL, 
		[ysnReceiptCommentRequired] BIT NULL DEFAULT ((0)), 
		[strCountCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnLandedCost] BIT NOT NULL DEFAULT ((0)), 
		[strLeadTime] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnTaxable] BIT NOT NULL DEFAULT ((0)), 
		[strKeywords] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[dblCaseQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dtmDateShip] DATETIME NULL, 
		[dblTaxExempt] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnDropShip] BIT NOT NULL DEFAULT ((0)), 
		[ysnCommisionable] BIT NOT NULL DEFAULT ((0)), 
		[ysnSpecialCommission] BIT NOT NULL DEFAULT ((0)), 
		[intCommodityId] INT NULL,
		[intCommodityHierarchyId] INT NULL, 
		[dblGAShrinkFactor] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intOriginId] INT NULL, 
		[intProductTypeId] INT NULL, 
		[intRegionId] INT NULL, 
		[intSeasonId] INT NULL, 
		[intClassVarietyId] INT NULL, 
		[intProductLineId] INT NULL, 
		[intGradeId] INT NULL,
		[strMarketValuation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnInventoryCost] BIT NULL DEFAULT ((1)),
		[ysnAccrue] BIT NULL DEFAULT ((1)),
		[ysnMTM] BIT NULL DEFAULT ((1)),
		[ysnPrice] BIT NULL DEFAULT ((1)),
		[strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit'),
		[strCostType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Other Charges'),
		[intOnCostTypeId] INT NULL,
		[dblAmount] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[intCostUOMId] INT NULL,
		[intPackTypeId] INT NULL, 
		[strWeightControlCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dblBlendWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblNetWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblUnitPerCase] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblQuarantineDuration] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intOwnerId] INT NULL,
		[intCustomerId] INT NULL,
		[dblCaseWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strWarehouseStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[ysnKosherCertified] BIT NULL DEFAULT ((0)),
		[ysnFairTradeCompliant] BIT NULL DEFAULT ((0)),
		[ysnOrganic] BIT NULL DEFAULT ((0)),
		[ysnRainForestCertified] BIT NULL DEFAULT ((0)),
		[dblRiskScore] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblDensity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dtmDateAvailable] DATETIME NULL DEFAULT (GETDATE()),
		[ysnMinorIngredient] BIT NULL DEFAULT ((0)),
		[ysnExternalItem] BIT NULL DEFAULT ((0)),
		[strExternalGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[ysnSellableItem] BIT NULL DEFAULT ((0)),
		[dblMinStockWeeks] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblFullContainerSize] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnHasMFTImplication] BIT NULL DEFAULT ((0)),
		[intBuyingGroupId] INT NULL,
		[intAccountManagerId] INT NULL,
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		[ysnItemUsedInDiscountCode] BIT NULL, 
		[ysnUsedForEnergyTracExport] BIT NULL , 
		[strInvoiceComments] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
		[strPickListComments] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, 
        [intLotStatusId] INT NULL, 
		[strRequired] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnBasisContract] BIT NULL, 
		[intM2MComputationId] INT NULL DEFAULT ((1)),
		[intTonnageTaxUOMId] INT NULL, 
    CONSTRAINT [AK_tblICItem_strItemNo] UNIQUE ([strItemNo]), 
		CONSTRAINT [PK_tblICItem] PRIMARY KEY ([intItemId]), 
		CONSTRAINT [FK_tblICItem_tblICManufacturer] FOREIGN KEY ([intManufacturerId]) REFERENCES [tblICManufacturer]([intManufacturerId]), 
		CONSTRAINT [FK_tblICItem_tblICBrand] FOREIGN KEY ([intBrandId]) REFERENCES [tblICBrand]([intBrandId]), 
		CONSTRAINT [FK_tblICItem_DimensionUOM] FOREIGN KEY ([intDimensionUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICItem_WeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [FK_tblICItem_tblICPatronageCategory] FOREIGN KEY ([intPatronageCategoryId]) REFERENCES [tblPATPatronageCategory]([intPatronageCategoryId]),
		CONSTRAINT [FK_tblICItem_tblICRinFuelCategory] FOREIGN KEY ([intRINFuelTypeId]) REFERENCES [tblICRinFuelCategory]([intRinFuelCategoryId]), 
		CONSTRAINT [FK_tblICItem_MedicationTag] FOREIGN KEY ([intMedicationTag]) REFERENCES [tblICTag]([intTagId]),
		CONSTRAINT [FK_tblICItem_IngredientTag] FOREIGN KEY ([intIngredientTag]) REFERENCES [tblICTag]([intTagId]), 
		CONSTRAINT [FK_tblICItem_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
		CONSTRAINT [FK_tblICItem_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]), 
		CONSTRAINT [FK_tblICItem_tblICCommodityAttribute] FOREIGN KEY ([intOriginId]) REFERENCES [tblICCommodityAttribute]([intCommodityAttributeId]), 
		CONSTRAINT [FK_tblICItem_MaterialPackType] FOREIGN KEY ([intMaterialPackTypeId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [FK_tblICItem_Owner] FOREIGN KEY ([intOwnerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]),
		CONSTRAINT [FK_tblICItem_Customer] FOREIGN KEY ([intCustomerId]) REFERENCES [tblARCustomer]([intEntityCustomerId]), 
		CONSTRAINT [FK_tblICItem_tblSMModule] FOREIGN KEY ([intModuleId]) REFERENCES [tblSMModule]([intModuleId]),		
		CONSTRAINT [FK_tblICItem_tblMFBuyingGroup] FOREIGN KEY ([intBuyingGroupId]) REFERENCES [tblMFBuyingGroup]([intBuyingGroupId]), 
		CONSTRAINT [FK_tblICItem_tblEMEntity] FOREIGN KEY ([intAccountManagerId]) REFERENCES tblEMEntity([intEntityId]),
		CONSTRAINT [FK_tblICItem_tblICLotStatus] FOREIGN KEY (intLotStatusId) REFERENCES tblICLotStatus([intLotStatusId]),
		CONSTRAINT [FK_tblICItem_tblICM2MComputation] FOREIGN KEY ([intM2MComputationId]) REFERENCES [tblICM2MComputation]([intM2MComputationId]), 
		CONSTRAINT [FK_tblICItem_tblICUnitMeasure] FOREIGN KEY ([intTonnageTaxUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	);
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICItem_intItemId]
		ON [dbo].[tblICItem]([intItemId] ASC)
		INCLUDE ([strItemNo], [strDescription], [intCategoryId])
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICItem_strType]
		ON [dbo].[tblICItem]([strType] ASC)
	GO

	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Unique key that corresponds to the item number. Origin: agitm-no ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strItemNo';
	GO
	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inventory type (e.g. 1=Inventory Item, 2=Service Item, 3=Finished Goods, 4=Bulk, 5=Pre-Mixes, 6=Raw Materials)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = 'strType';
	GO
	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Item Description. Origin: agitm-desc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strDescription';
	GO
	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a manufacturer. Origin: agitm-mfg-id', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intManufacturerId';
	GO
	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FK. An item may belong to a brand. Origin: stpbk_brand_name ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intBrandId';
	GO
	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status of an item (e.g. 1=Active, 2=Phased Out, 3=Discontinued)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = 'strStatus';
	GO
	EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Model number of an item. ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'strModelNo';
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Patronage Category Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intPatronageCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Stocked Item',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnStockedItem'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Dyed Fuel',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnDyedFuel'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Barcode Print',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strBarcodePrint'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'MSDS Required',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnMSDSRequired'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'EPA Number',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strEPANumber'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Inbound Tax',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnInboundTax'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Outbound Tax',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnOutboundTax'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Restricted Chemical',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnRestrictedChemical'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tank Required',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnTankRequired'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Available for TM',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnAvailableTM'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Percentage Full',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblDefaultFull'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Fuel Inspect Fee',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strFuelInspectFee'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Required',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strRINRequired'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Fuel Type Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intRINFuelTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Denaturant Percent',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblDenaturantPercent'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tonnage Tax',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnTonnageTax'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Load Tracking',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnLoadTracking'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Mix Order',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblMixOrder'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Hand Add Ingredients',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnHandAddIngredient'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Medication Tag',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intMedicationTag'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Ingredient Tag',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intIngredientTag'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Volume Rebate Group',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strVolumeRebateGroup'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Physical Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intPhysicalItem'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Extend Pick Ticket',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnExtendPickTicket'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Export EDI',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnExportEDI'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Hazard Material',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnHazardMaterial'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Material Fee',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnMaterialFee'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Require Customer Approval',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnRequireCustomerApproval'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Recipe Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intRecipeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sanitation Required',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnSanitationRequired'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Life Time',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intLifeTime'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Life Time Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strLifeTimeType'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Receive Life',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intReceiveLife'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'GTIN',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strGTIN'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Rotation Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strRotationType'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'NMFC Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intNMFCId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Strict FIFO',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnStrictFIFO'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Dimension Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intDimensionUOMId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Height',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblHeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Width',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblWidth'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Depth',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblDepth'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Weight Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intWeightUOMId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblWeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Material Size Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strMaterialSizeCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Inner Units',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intInnerUnits'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Layer Per Pallet',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intLayerPerPallet'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Per Layer',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intUnitPerLayer'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Standard Pallet Ratio',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblStandardPalletRatio'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Mask 1',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strMask1'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Mask 2',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strMask2'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Mask 3',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strMask3'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tracking Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = 'strInventoryTracking'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Lot Tracking',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strLotTracking'
	GO

	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'NACS Category',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strNACSCategory'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'WIC Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strWICCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'AG Category',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intAGCategory'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Receipt Comment Required',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnReceiptCommentRequired'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Count Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strCountCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Landed Cost',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnLandedCost'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Lead Time',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strLeadTime'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Taxable',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnTaxable'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Keywords',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strKeywords'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Case Quantity',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblCaseQty'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Date Ship',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dtmDateShip'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tax Exempt',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblTaxExempt'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Drop Ship',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnDropShip'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commisionable',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'ysnCommisionable'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Special Commission',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = 'ysnSpecialCommission'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Hierarchy Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityHierarchyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'GA Shrink Factor',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'dblGAShrinkFactor'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Origin Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intOriginId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Product Type Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intProductTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Region Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intRegionId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Season Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intSeasonId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Class/Variety Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intClassVarietyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Product Line Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'intProductLineId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Market Valuation',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItem',
		@level2type = N'COLUMN',
		@level2name = N'strMarketValuation'

		GO
		EXECUTE sp_addextendedproperty @name = N'iMake Mapping', @value = N'Identity Field', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'tblICItem', @level2type = N'COLUMN', @level2name = N'intItemId';
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Auto Blend',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnAutoBlend'
GO

GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'User Group Fee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'dblUserGroupFee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fuel Item',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItem',
    @level2type = N'COLUMN',
    @level2name = N'ysnFuelItem'