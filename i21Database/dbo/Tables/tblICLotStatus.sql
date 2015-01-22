/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICLotStatus]
	(
		[intLotStatusId] INT NOT NULL IDENTITY, 
		[strSecondaryStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strPrimaryStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICLotStatus] PRIMARY KEY ([intLotStatusId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLotStatus',
		@level2type = N'COLUMN',
		@level2name = N'intLotStatusId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Secondary Status',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLotStatus',
		@level2type = N'COLUMN',
		@level2name = N'strSecondaryStatus'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLotStatus',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Primary Status',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLotStatus',
		@level2type = N'COLUMN',
		@level2name = N'strPrimaryStatus'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLotStatus',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLotStatus',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'