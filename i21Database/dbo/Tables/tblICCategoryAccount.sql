﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICCategoryAccount]
	(
		[intCategoryAccountId] INT NOT NULL IDENTITY, 
		[intCategoryId] INT NOT NULL, 
		[intAccountCategoryId] INT NULL, 
		[intAccountId] INT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCategoryAccount] PRIMARY KEY ([intCategoryAccountId]), 
		CONSTRAINT [FK_tblICCategoryAccount_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICCategoryAccount_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]), 
		CONSTRAINT [AK_tblICCategoryAccount] UNIQUE ([intAccountCategoryId], [intCategoryId]), 
		CONSTRAINT [FK_tblICCategoryAccount_tblGLAccountCategory] FOREIGN KEY ([intAccountCategoryId]) REFERENCES [tblGLAccountCategory]([intAccountCategoryId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICCategoryAccount_intCategoryId]
		ON [dbo].[tblICCategoryAccount]([intCategoryId] ASC);
	GO

	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryAccount',
		@level2type = N'COLUMN',
		@level2name = N'intCategoryAccountId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Category Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryAccount',
		@level2type = N'COLUMN',
		@level2name = N'intCategoryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Account Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryAccount',
		@level2type = N'COLUMN',
		@level2name = N'intAccountId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCategoryAccount',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	
	GO

EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Account Category Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICCategoryAccount',
    @level2type = N'COLUMN',
    @level2name = N'intAccountCategoryId'