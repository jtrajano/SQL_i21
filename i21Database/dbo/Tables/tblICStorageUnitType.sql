﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICStorageUnitType]
	(
		[intStorageUnitTypeId] INT NOT NULL IDENTITY, 
		[strStorageUnitType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strInternalCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intCapacityUnitMeasureId] INT NULL, 
		[dblMaxWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnAllowPick] BIT NULL DEFAULT ((0)), 
		[intDimensionUnitMeasureId] INT NULL, 
		[dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblDepth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intPalletStack] INT NULL DEFAULT ((0)), 
		[intPalletColumn] INT NULL DEFAULT ((0)), 
		[intPalletRow] INT NULL DEFAULT ((0)), 
		[intCompanyId] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICStorageUnitType] PRIMARY KEY ([intStorageUnitTypeId]), 
		CONSTRAINT [FK_tblICStorageUnitType_CapacityUnitMeasure] FOREIGN KEY ([intCapacityUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
		CONSTRAINT [FK_tblICStorageUnitType_DimensionUnitMeasure] FOREIGN KEY ([intDimensionUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'intStorageUnitTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Storage Unit Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = 'strStorageUnitType'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Internal Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = 'strInternalCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Capacity Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'intCapacityUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Maximum Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'dblMaxWeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Allow Picking',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'ysnAllowPick'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Dimension Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'intDimensionUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Height',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'dblHeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Depth',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'dblDepth'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Width',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'dblWidth'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pallet Stack',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'intPalletStack'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pallet Column',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'intPalletColumn'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pallet Row',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'intPalletRow'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageUnitType',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
GO

CREATE UNIQUE INDEX [UX_tblICStorageUnitType_strStorageUnitType] ON [dbo].[tblICStorageUnitType] ([strStorageUnitType])
