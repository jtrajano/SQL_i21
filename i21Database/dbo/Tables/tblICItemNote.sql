/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemNote]
	(
		[intItemNoteId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intLocationId] INT NOT NULL, 
		[strCommentType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemNote] PRIMARY KEY ([intItemNoteId]), 
		CONSTRAINT [FK_tblICItemNote_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemNote_tblICItemLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemNote',
		@level2type = N'COLUMN',
		@level2name = N'intItemNoteId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemNote',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemNote',
		@level2type = N'COLUMN',
		@level2name = N'intLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Comment Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemNote',
		@level2type = N'COLUMN',
		@level2name = N'strCommentType'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Comments',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemNote',
		@level2type = N'COLUMN',
		@level2name = N'strComments'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemNote',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemNote',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'