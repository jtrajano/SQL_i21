/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICRestriction]
	(
		[intRestrictionId] INT NOT NULL IDENTITY, 
		[strInternalCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strDisplayMember] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[ysnDefault] BIT NULL DEFAULT ((0)), 
		[ysnLocked] BIT NULL DEFAULT ((1)), 
		[strLastUpdateBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dtmLastUpdateOn] DATETIME NOT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICRestriction] PRIMARY KEY ([intRestrictionId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'intRestrictionId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Internal Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'strInternalCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Display Member',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'strDisplayMember'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Default',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'ysnDefault'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Locked',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'ysnLocked'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update By',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'strLastUpdateBy'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Last Update On',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'dtmLastUpdateOn'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICRestriction',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'