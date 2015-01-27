/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICContainer]
	(
		[intContainerId] INT NOT NULL IDENTITY, 
		[intExternalSystemId] INT NULL, 
		[strContainerId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intContainerTypeId] INT NOT NULL, 
		[intStorageLocationId] INT NOT NULL, 
		[strLastUpdateBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dtmLastUpdateOn] DATETIME NOT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICContainer] PRIMARY KEY ([intContainerId]), 
		CONSTRAINT [FK_tblICContainer_tblICContainerType] FOREIGN KEY ([intContainerTypeId]) REFERENCES [tblICContainerType]([intContainerTypeId]), 
		CONSTRAINT [FK_tblICContainer_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'intContainerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'External System Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'intExternalSystemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Container Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'strContainerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Container Type Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'intContainerTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Storage Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = 'intStorageLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update By',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'strLastUpdateBy'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update On',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'dtmLastUpdateOn'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICContainer',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'