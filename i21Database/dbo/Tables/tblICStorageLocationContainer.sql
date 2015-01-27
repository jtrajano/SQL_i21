/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICStorageLocationContainer]
	(
		[intStorageLocationContainerId] INT NOT NULL IDENTITY, 
		[intStorageLocationId] INT NOT NULL, 
		[intContainerId] INT NOT NULL, 
		[intExternalSystemId] INT NULL, 
		[intContainerTypeId] INT NULL, 
		[strLastUpdatedBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmLastUpdatedOn] DATETIME NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICStorageLocationContainer] PRIMARY KEY ([intStorageLocationContainerId]), 
		CONSTRAINT [FK_tblICStorageLocationContainer_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
		CONSTRAINT [FK_tblICStorageLocationContainer_tblICContainer] FOREIGN KEY ([intContainerId]) REFERENCES [tblICContainer]([intContainerId]), 
		CONSTRAINT [FK_tblICStorageLocationContainer_tblICContainerType] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblICContainerType]([intContainerTypeId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'intStorageLocationContainerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Storage Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'intStorageLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Container Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'intContainerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Extrernal System Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'intExternalSystemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Container Type Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'intContainerTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Updated By',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'strLastUpdatedBy'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Updated On',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'dtmLastUpdatedOn'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICStorageLocationContainer',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'