/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICStorageLocation]
	(
		[intStorageLocationId] INT NOT NULL IDENTITY, 
		[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[intStorageUnitTypeId] INT NULL, 
		[intLocationId] INT NULL, 
		[intSubLocationId] INT NULL, 
		[intParentStorageLocationId] INT NULL, 
		[ysnAllowConsume] BIT NULL DEFAULT ((0)), 
		[ysnAllowMultipleItem] BIT NULL DEFAULT ((0)), 
		[ysnAllowMultipleLot] BIT NULL DEFAULT ((0)), 
		[ysnMergeOnMove] BIT NULL DEFAULT ((0)), 
		[ysnCycleCounted] BIT NULL DEFAULT ((0)), 
		[ysnDefaultWHStagingUnit] BIT NULL DEFAULT ((0)), 
		[intRestrictionId] INT NULL, 
		[strUnitGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dblMinBatchSize] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblBatchSize] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intBatchSizeUOMId] INT NULL, 
		[intSequence] INT NULL DEFAULT ((0)), 
		[ysnActive] BIT NULL DEFAULT ((0)), 
		[intRelativeX] INT NULL DEFAULT ((0)), 
		[intRelativeY] INT NULL DEFAULT ((0)), 
		[intRelativeZ] INT NULL DEFAULT ((0)), 
		[intCommodityId] INT NULL, 
		[dblPackFactor] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblUnitPerFoot] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblResidualUnit] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICStorageLocation] PRIMARY KEY ([intStorageLocationId]), 
		CONSTRAINT [AK_tblICStorageLocation_strName] UNIQUE ([strName]), 
		CONSTRAINT [FK_tblICStorageLocation_tblICStorageUnitType] FOREIGN KEY ([intStorageUnitTypeId]) REFERENCES [tblICStorageUnitType]([intStorageUnitTypeId]), 
		CONSTRAINT [FK_tblICStorageLocation_tblICRestriction] FOREIGN KEY ([intRestrictionId]) REFERENCES [tblICRestriction]([intRestrictionId]), 
		CONSTRAINT [FK_tblICStorageLocation_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
		CONSTRAINT [FK_tblICStorageLocation_tblICUnitMeasure] FOREIGN KEY ([intBatchSizeUOMId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]), 
		CONSTRAINT [FK_tblICStorageLocation_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intStorageLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Storage Location Name',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'strName'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Storage Unit Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intStorageUnitTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sub Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intSubLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Parent Storage Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intParentStorageLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Allow Consume',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnAllowConsume'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Allow Multiple Items',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnAllowMultipleItem'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Merge on Move',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnMergeOnMove'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Cycle Counted',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnCycleCounted'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default WH Staging Unit',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnDefaultWHStagingUnit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Restriction Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intRestrictionId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Group',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'strUnitGroup'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Minimum Batch Size',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblMinBatchSize'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Batch Size',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblBatchSize'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Batch Size Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intBatchSizeUOMId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sequence',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intSequence'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Active',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'ysnActive'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Relative X',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intRelativeX'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Relative Y',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intRelativeY'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Relative Z',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intRelativeZ'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pack Factor',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblPackFactor'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Units per Foot',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblUnitPerFoot'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Residual Unit',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'dblResidualUnit'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocation',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'