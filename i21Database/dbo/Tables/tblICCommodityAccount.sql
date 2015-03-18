/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCommodityAccount]
	(
		[intCommodityAccountId] INT NOT NULL IDENTITY, 
		[intCommodityId] INT NOT NULL, 
		[intLocationId] INT NOT NULL,
		[intAccountCategoryId] INT NOT NULL,
		[intAccountId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCommodityAccount] PRIMARY KEY ([intCommodityAccountId]), 
		CONSTRAINT [FK_tblICCommodityAccount_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
		CONSTRAINT [FK_tblICCommodityAccount_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
		CONSTRAINT [AK_tblICCommodityAccount] UNIQUE ([intAccountCategoryId], [intLocationId], [intCommodityId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAccount',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityAccountId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAccount',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Account Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAccount',
		@level2type = N'COLUMN',
		@level2name = N'intAccountId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAccount',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAccount',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'intLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCommodityAccount',
    @level2type = N'COLUMN',
    @level2name = N'intAccountCategoryId'