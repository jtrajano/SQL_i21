﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCommodity]
	(
		[intCommodityId] INT NOT NULL IDENTITY, 
		[strCommodityCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnExchangeTraded] BIT NULL DEFAULT ((0)), 
		[intFutureMarketId] INT NULL,
		[intDecimalDPR] INT NULL DEFAULT ((2)), 
		[dblConsolidateFactor] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnFXExposure] BIT NULL, 
		[dblPriceCheckMin] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblPriceCheckMax] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strCheckoffTaxDesc] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strCheckoffAllState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strInsuranceTaxDesc] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strInsuranceAllState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmCropEndDateCurrent] DATETIME NULL, 
		[dtmCropEndDateNew] DATETIME NULL, 
		[strEDICode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intScheduleStoreId] INT NULL,
		[intScheduleDiscountId] INT NULL,
		[intScaleAutoDistId] INT NULL,
		[ysn1099Box3] BIT NULL DEFAULT((0)),
		[ysnAllowLoadContracts] BIT NULL, 
		[dblMaxUnder] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblMaxOver] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intAdjustInventorySales] INT NULL,
		[intAdjustInventoryTransfer] INT NULL,
		[intCompanyId] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		[dtmDateCreated] DATETIME NULL,
		[dtmDateModified] DATETIME NULL,
		[intCreatedByUserId] INT NULL,
		[intModifiedByUserId] INT NULL,
		CONSTRAINT [PK_tblICCommodity] PRIMARY KEY ([intCommodityId]), 
		CONSTRAINT [FK_tblICCommodity_tblRKFutureMarket] FOREIGN KEY ([intFutureMarketId]) REFERENCES [tblRKFutureMarket]([intFutureMarketId]), 
		CONSTRAINT [FK_tblICCommodity_tblGRDiscount] FOREIGN KEY ([intScheduleDiscountId]) REFERENCES [tblGRDiscountId]([intDiscountId]), 
		CONSTRAINT [FK_tblICCommodity_tblGRStorageSchedule] FOREIGN KEY ([intScheduleStoreId]) REFERENCES [tblGRStorageScheduleRule]([intStorageScheduleRuleId]), 
		CONSTRAINT [FK_tblICCommodity_tblICAdjustInventoryTerms1] FOREIGN KEY ([intAdjustInventorySales]) REFERENCES [tblICAdjustInventoryTerms]([intAdjustInventoryTermsId]), 
		CONSTRAINT [FK_tblICCommodity_tblICAdjustInventoryTerms2] FOREIGN KEY ([intAdjustInventoryTransfer]) REFERENCES [tblICAdjustInventoryTerms]([intAdjustInventoryTermsId]), 
		CONSTRAINT [AK_tblICCommodity_strCommodityCode] UNIQUE ([strCommodityCode]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'strCommodityCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Decimals on DPR',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intDecimalDPR'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Consolidate Factor',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dblConsolidateFactor'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'FX Exposure',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'ysnFXExposure'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Price Checks - Minimum',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dblPriceCheckMin'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Price Checks - Maximum',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dblPriceCheckMax'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Checkoff Tax Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'strCheckoffTaxDesc'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Checkoff All States',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'strCheckoffAllState'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Insurance Tax Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'strInsuranceTaxDesc'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Insurance All States',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'strInsuranceAllState'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Crop End Date Current',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dtmCropEndDateCurrent'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Crop End Date New',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dtmCropEndDateNew'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'EDI Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'strEDICode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Allow Load Contracts',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'ysnAllowLoadContracts'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Maximum Under',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dblMaxUnder'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Maximum Over',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dblMaxOver'
	GO
	
	GO
	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Exchange Traded',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodity',
		@level2type = N'COLUMN',
		@level2name = N'ysnExchangeTraded'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Default Futures Market',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodity',
    @level2type = N'COLUMN',
    @level2name = N'intFutureMarketId'