/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICManufacturingCellPackType]
	(
		[intManufacturingCellPackTypeId] INT NOT NULL IDENTITY, 
		[intManufacturingCellId] INT NOT NULL, 
		[intPackTypeId] INT NOT NULL, 
		[dblLineCapacity] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intLineCapacityUnitMeasureId] INT NULL, 
		[intLineCapacityRateUnitMeasureId] INT NULL, 
		[dblLineEfficiencyRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICManufacturingCellPackType] PRIMARY KEY ([intManufacturingCellPackTypeId]), 
		CONSTRAINT [FK_tblICManufacturingCellPackType_tblICManufacturingCell] FOREIGN KEY ([intManufacturingCellId]) REFERENCES [tblICManufacturingCell]([intManufacturingCellId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICManufacturingCellPackType_CapacityUnitMeasure] FOREIGN KEY ([intLineCapacityUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICManufacturingCellPackType_CapacityRateUnitMeasure] FOREIGN KEY ([intLineCapacityRateUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'intManufacturingCellPackTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Manufacturing Cell Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'intManufacturingCellId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pack Type Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'intPackTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Line Capacity',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'dblLineCapacity'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Line Capacity Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'intLineCapacityUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Line Capacity Rate Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'intLineCapacityRateUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Line Efficiency Rate',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'dblLineEfficiencyRate'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Cocnurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICManufacturingCellPackType',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'