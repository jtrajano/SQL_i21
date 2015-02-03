/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemAccount]
	(
		[intItemAccountId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intAccountCategoryId] INT NULL, 
		[intAccountId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemAccount] PRIMARY KEY ([intItemAccountId]), 
		CONSTRAINT [FK_tblICItemAccount_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemAccount_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
		CONSTRAINT [AK_tblICItemAccount] UNIQUE ([intAccountCategoryId], [intItemId]), 
		CONSTRAINT [FK_tblICItemAccount_tblGLAccountCategory] FOREIGN KEY ([intAccountCategoryId]) REFERENCES [tblGLAccountCategory]([intAccountCategoryId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemAccount',
		@level2type = N'COLUMN',
		@level2name = N'intItemAccountId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemAccount',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO

	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Account Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemAccount',
		@level2type = N'COLUMN',
		@level2name = N'intAccountId'
	GO

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemAccount',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemAccount',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemAccount',
    @level2type = N'COLUMN',
    @level2name = N'intAccountCategoryId'