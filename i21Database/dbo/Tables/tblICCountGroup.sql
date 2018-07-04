/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCountGroup]
	(
		[intCountGroupId] INT NOT NULL IDENTITY, 
		[strCountGroup] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intCountsPerYear] INT NOT NULL DEFAULT ((1)),
		[ysnIncludeOnHand] BIT NOT NULL DEFAULT ((0)),
		[ysnScannedCountEntry] BIT NOT NULL DEFAULT ((0)),
		[ysnCountByLots] BIT NOT NULL DEFAULT ((0)),
		[ysnCountByPallets] BIT NOT NULL DEFAULT ((0)),
		[ysnRecountMismatch] BIT NOT NULL DEFAULT ((0)),
		[ysnExternal] BIT NOT NULL DEFAULT ((0)),
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		[dtmDateCreated] DATETIME NULL,
		[dtmDateModified] DATETIME NULL,
		[intCreatedByUserId] INT NULL,
		[intModifiedByUserId] INT NULL,
		CONSTRAINT [PK_tblICCountGroup] PRIMARY KEY ([intCountGroupId]), 
		CONSTRAINT [AK_tblICCountGroup_strCountGroup] UNIQUE ([strCountGroup])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCountGroup',
		@level2type = N'COLUMN',
		@level2name = N'intCountGroupId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Count Group',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCountGroup',
		@level2type = N'COLUMN',
		@level2name = N'strCountGroup'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCountGroup',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCountGroup',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'