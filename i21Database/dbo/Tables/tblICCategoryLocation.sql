/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICCategoryLocation]
	(
		[intCategoryLocationId] INT NOT NULL IDENTITY, 
		[intCategoryId] INT NOT NULL, 
		[intLocationId] INT NOT NULL, 
		[intRegisterDepartmentId] INT NULL, 
		[ysnUpdatePrices] BIT NULL DEFAULT ((0)), 
		[ysnUseTaxFlag1] BIT NULL DEFAULT ((0)), 
		[ysnUseTaxFlag2] BIT NULL DEFAULT ((0)), 
		[ysnUseTaxFlag3] BIT NULL DEFAULT ((0)), 
		[ysnUseTaxFlag4] BIT NULL DEFAULT ((0)), 
		[ysnBlueLaw1] BIT NULL DEFAULT ((0)), 
		[ysnBlueLaw2] BIT NULL DEFAULT ((0)), 
		[intNucleusGroupId] INT NULL, 
		[dblTargetGrossProfit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblTargetInventoryCost] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblCostInventoryBOM] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblLowGrossMarginAlert] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblHighGrossMarginAlert] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dtmLastInventoryLevelEntry] DATETIME NULL, 
		[ysnNonRetailUseDepartment] BIT NULL DEFAULT ((0)), 
		[ysnReportNetGross] BIT NULL DEFAULT ((0)), 
		[ysnDepartmentForPumps] BIT NULL DEFAULT ((0)), 
		[intConvertPaidOutId] INT NULL, 
		[ysnDeleteFromRegister] BIT NULL DEFAULT ((0)), 
		[ysnDeptKeyTaxed] BIT NULL DEFAULT ((0)), 
		[intProductCodeId] INT NULL, 
		[intFamilyId] INT NULL, 
		[intClassId] INT NULL, 
		[ysnFoodStampable] BIT NULL DEFAULT ((0)), 
		[ysnReturnable] BIT NULL DEFAULT ((0)), 
		[ysnSaleable] BIT NULL DEFAULT ((0)), 
		[ysnPrePriced] BIT NULL DEFAULT ((0)), 
		[ysnIdRequiredLiquor] BIT NULL DEFAULT ((0)), 
		[ysnIdRequiredCigarette] BIT NULL DEFAULT ((0)), 
		[intMinimumAge] INT NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCategoryLocation] PRIMARY KEY ([intCategoryLocationId]), 
		CONSTRAINT [FK_tblICCategoryLocation_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICCategoryLocation_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intCategoryLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Category Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Register Department Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intRegisterDepartmentId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Update Prices on Pricebook imports',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnUpdatePrices'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Use Tax Flag 1',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnUseTaxFlag1'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Use Tax Flag 2',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnUseTaxFlag2'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Use Tax Flag 3',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnUseTaxFlag3'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Use Tax Flag 4',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnUseTaxFlag4'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Blue Law 1',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnBlueLaw1'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Blue Law 2',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnBlueLaw2'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Nucleus Group Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intNucleusGroupId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Target Gross Profit Percentage',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblTargetGrossProfit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Target Inventory at Cost',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblTargetInventoryCost'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Cost of Inventory at BOM',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblCostInventoryBOM'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Low Gross Margin % Alert',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblLowGrossMarginAlert'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'High Gross Margin % Alert',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblHighGrossMarginAlert'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Inventory Level Entry Date',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'dtmLastInventoryLevelEntry'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Non Retail Use Department',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnNonRetailUseDepartment'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Report in net or gross',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnReportNetGross'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Department is for Pumps',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnDepartmentForPumps'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Convert to Paid Outs Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intConvertPaidOutId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Delete From Register',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnDeleteFromRegister'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Department Key Taxed',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnDeptKeyTaxed'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Product Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intProductCodeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Family',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intFamilyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Class',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intClassId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Food Stampable',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnFoodStampable'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Returnable',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnReturnable'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Saleable',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnSaleable'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Prepriced',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnPrePriced'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Id Required for Liquor',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnIdRequiredLiquor'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Id Required for Cigarette',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnIdRequiredCigarette'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default Minimum Age',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intMinimumAge'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryLocation',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'