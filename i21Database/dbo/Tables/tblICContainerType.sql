/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICContainerType]
	(
		[intContainerTypeId] INT NOT NULL IDENTITY, 
		[intExternalSystemId] INT NULL, 
		[strInternalCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDisplayMember] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intDimensionUnitMeasureId] INT NULL, 
		[dblHeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblWidth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblDepth] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[intWeightUnitMeasureId] INT NULL, 
		[dblMaxWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnLocked] BIT NOT NULL DEFAULT ((1)), 
		[ysnDefault] BIT NOT NULL DEFAULT ((0)), 
		[dblPalletWeight] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[strLastUpdateBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dtmLastUpdateOn] DATETIME NOT NULL, 
		[strContainerDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[ysnReusable] BIT NULL DEFAULT ((0)), 
		[ysnAllowMultipleItems] BIT NULL DEFAULT ((0)), 
		[ysnAllowMultipleLots] BIT NULL DEFAULT ((0)), 
		[ysnMergeOnMove] BIT NULL DEFAULT ((0)), 
		[intTareUnitMeasureId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICContainerType] PRIMARY KEY ([intContainerTypeId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'intContainerTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'External System Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'intExternalSystemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Internal Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'strInternalCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Display Member',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'strDisplayMember'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Dimension Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'intDimensionUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Height',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'dblHeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Width',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'dblWidth'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Depth',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'dblDepth'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Weight Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'intWeightUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Maximum Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'dblMaxWeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Locked',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'ysnLocked'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'ysnDefault'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pallet Weight',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'dblPalletWeight'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update By',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'strLastUpdateBy'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update On',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'dtmLastUpdateOn'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Container Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'strContainerDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Reusable',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'ysnReusable'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Allow Multiple Items',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'ysnAllowMultipleItems'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Allow Multiple Lots',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'ysnAllowMultipleLots'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Merge on Move',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'ysnMergeOnMove'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tare Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'intTareUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainerType',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'