﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICFuelType]
	(
		[intFuelTypeId] INT NOT NULL IDENTITY, 
		[intRinFuelCategoryId] INT NULL, 
		[intRinFeedStockId] INT NULL, 
		[intBatchNumber] INT NULL DEFAULT ((0)), 
		[intEndingRinGallons] INT NULL DEFAULT ((0)), 
		[strEquivalenceValue] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intRinFuelId] INT NULL, 
		[intRinProcessId] INT NULL, 
		[intRinFeedStockUOMId] INT NULL, 
		[dblFeedStockFactor] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnRenewableBiomass] BIT NULL, 
		[dblPercentDenaturant] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnDeductDenaturant] BIT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICFuelType] PRIMARY KEY ([intFuelTypeId]), 
		CONSTRAINT [FK_tblICFuelType_tblICRinFuelType] FOREIGN KEY ([intRinFuelCategoryId]) REFERENCES [tblICRinFuelCategory]([intRinFuelCategoryId]),
		CONSTRAINT [FK_tblICFuelType_tblICRinFeedStock] FOREIGN KEY ([intRinFeedStockId]) REFERENCES [tblICRinFeedStock]([intRinFeedStockId]),
		CONSTRAINT [FK_tblICFuelType_tblICRinFuel] FOREIGN KEY ([intRinFuelId]) REFERENCES [tblICRinFuel]([intRinFuelId]),
		CONSTRAINT [FK_tblICFuelType_tblICRinProcess] FOREIGN KEY ([intRinProcessId]) REFERENCES [tblICRinProcess]([intRinProcessId]),
		CONSTRAINT [FK_tblICFuelType_tblICRinFeedStockUOM] FOREIGN KEY ([intRinFeedStockUOMId]) REFERENCES [tblICRinFeedStockUOM]([intRinFeedStockUOMId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intFuelTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Fuel Category Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = 'intRinFuelCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Feed Stock Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intRinFeedStockId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Batch Number',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intBatchNumber'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Ending RIN Gallons for Batch',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intEndingRinGallons'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Equivalence Value',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = 'strEquivalenceValue'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Fuel Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intRinFuelId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Process Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intRinProcessId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'RIN Feed Stock Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intRinFeedStockUOMId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Feed Stock Factor',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'dblFeedStockFactor'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Renewable Biomass',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'ysnRenewableBiomass'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Percent of Denaturant',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'dblPercentDenaturant'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Deduct Denaturant from RIN',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'ysnDeductDenaturant'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelType',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
GO

CREATE UNIQUE INDEX [IX_tblICFuelType_Unique] ON [dbo].[tblICFuelType] ([intRinFeedStockId], [intRinProcessId], [intRinFeedStockUOMId], [intRinFuelCategoryId], [intRinFuelId])
