/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICDocument]
	(
		[intDocumentId] INT NOT NULL IDENTITY , 
		[strDocumentName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intCommodityId] INT NOT NULL, 
		[ysnStandard] BIT NOT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [AK_tblICDocument_strDocumentName] UNIQUE ([strDocumentName]), 
		CONSTRAINT [PK_tblICDocument] PRIMARY KEY ([intDocumentId]), 
		CONSTRAINT [FK_tblICDocument_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICDocument',
		@level2type = N'COLUMN',
		@level2name = N'intDocumentId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Document Name',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICDocument',
		@level2type = N'COLUMN',
		@level2name = N'strDocumentName'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICDocument',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICDocument',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Standard',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICDocument',
		@level2type = N'COLUMN',
		@level2name = N'ysnStandard'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICDocument',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'