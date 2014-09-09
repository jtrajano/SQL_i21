CREATE TABLE [dbo].[tblICCategory]
(
	[intCategoryId] INT NOT NULL IDENTITY , 
    [strCategoryCode] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(50) NULL, 
	[strLineBusiness] NVARCHAR(50) NULL, 
    [intCatalogGroupId] INT NULL, 
    [strCostingMethod] NVARCHAR(50) NULL, 
    [strInventoryTracking] NVARCHAR(50) NULL, 
    [dblStandardQty] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intUOMId] INT NULL, 
    [strGLDivisionNumber] NVARCHAR(50) NULL, 
    [ysnSalesAnalysisByTon] BIT NULL DEFAULT ((0)), 
    [strMaterialFee] NVARCHAR(50) NULL, 
	[intMaterialItemId] INT NULL, 
    [ysnAutoCalculateFreight] BIT NULL DEFAULT ((0)), 
	[intFreightItemId] INT NULL, 
	[ysnNonRetailUseDepartment] BIT NULL, 
	[ysnReportNetGross] BIT NULL DEFAULT ((0)), 
	[ysnDepartmentPumps] BIT NULL DEFAULT ((0)), 

    [intConvertPaidOutId] INT NULL, 
    [ysnDeleteRegister] BIT NULL DEFAULT ((0)), 
    [ysnDepartmentKeyTaxed] BIT NULL DEFAULT ((0)), 
    [intProductCodeId] INT NULL, 
    [intFamilyId] INT NULL, 
    [intClassId] INT NULL, 
    [ysnFoodStampable] BIT NULL DEFAULT ((0)), 
    [ysnReturnable] BIT NULL DEFAULT ((0)), 
    [ysnSaleable] BIT NULL DEFAULT ((0)), 
    [ysnPrepriced] BIT NULL DEFAULT ((0)), 
    [ysnIdRequiredLiquor] BIT NULL DEFAULT ((0)), 
    [ysnIdRequiredCigarette] BIT NULL DEFAULT ((0)), 
    [intMinimumAge] INT NULL DEFAULT ((0)), 
    [strERPItemClass] NVARCHAR(50) NULL, 
    [dblfeTime] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblBOMItemShrinkage] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblBOMItemUpperTolerance] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblBOMItemLowerTolerance] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [ysnScaled] BIT NULL DEFAULT ((0)), 
    [ysnOutputItemMandatory] BIT NULL DEFAULT ((0)), 
    [strConsumptionMethod] NVARCHAR(50) NULL, 
    [strBOMItemType] NVARCHAR(50) NULL, 
    [strShortName] NVARCHAR(50) NULL, 
    [imgReceiptImage] IMAGE NULL, 
    [imgWIPImage] IMAGE NULL, 
    [imgFGImage] IMAGE NULL, 
    [imgShipImage] IMAGE NULL, 
    [dblLaborCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblOverHead] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [dblPercentage] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strCostDistributionMethod] NVARCHAR(50) NULL, 
    [ysnSellable] BIT NULL DEFAULT ((0)), 
    [ysnYieldAdjustment] BIT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCategory] PRIMARY KEY ([intCategoryId]), 
    CONSTRAINT [AK_tblICCategory_strCategoryCode] UNIQUE ([strCategoryCode]) 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intCategoryId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Category Code',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strCategoryCode'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Description',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line Of Business',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = 'strLineBusiness'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalog Group Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intCatalogGroupId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Costing Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strCostingMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Inventory Tracking',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strInventoryTracking'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Standard Quantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblStandardQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'GL Division Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strGLDivisionNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sales Analysis By Ton',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnSalesAnalysisByTon'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Fee',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strMaterialFee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Material Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intMaterialItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Auto Calculate Freight',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnAutoCalculateFreight'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intFreightItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Non Retail Use Department',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnNonRetailUseDepartment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Report in Net or Gross',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnReportNetGross'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Department for Pumps',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnDepartmentPumps'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Convert to PaidOut Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intConvertPaidOutId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delete from Register',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnDeleteRegister'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Department Key Taxed',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnDepartmentKeyTaxed'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Product Code Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intProductCodeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Family Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intFamilyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Class Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intClassId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Food Stampable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnFoodStampable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Returnable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnReturnable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Salesable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnSaleable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Pre-priced',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnPrepriced'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Id Required (Liquor)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnIdRequiredLiquor'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Id Required (Cigarette)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnIdRequiredCigarette'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Minimum Age',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intMinimumAge'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ERP Item Class',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strERPItemClass'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Life Time (Minutes)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblfeTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BOM Item Shrinkage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblBOMItemShrinkage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BOM Item Upper Tolerance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblBOMItemUpperTolerance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BOM Item Lower Tolerance',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblBOMItemLowerTolerance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Scaled',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnScaled'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Output Item Mandatory',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnOutputItemMandatory'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Consumption Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strConsumptionMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BOM Item Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strBOMItemType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Short Name',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strShortName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Receipt Image',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'imgReceiptImage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'WIP Image',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'imgWIPImage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'FG Image',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'imgFGImage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship Image',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'imgShipImage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Labor Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblLaborCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Over Head',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblOverHead'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Percentage',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'dblPercentage'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cost Distribution Method',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'strCostDistributionMethod'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sellable',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnSellable'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Yield Adjustment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'ysnYieldAdjustment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategory',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'