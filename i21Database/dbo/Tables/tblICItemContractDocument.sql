/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemContractDocument]
	(
		[intItemContractDocumentId] INT NOT NULL IDENTITY , 
		[intItemContractId] INT NOT NULL, 
		[intDocumentId] INT NOT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemContractDocument] PRIMARY KEY ([intItemContractDocumentId]), 
		CONSTRAINT [FK_tblICItemContractDocument_tblICItemContract] FOREIGN KEY ([intItemContractId]) REFERENCES [tblICItemContract]([intItemContractId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemContractDocument_tblICDocument] FOREIGN KEY ([intDocumentId]) REFERENCES [tblICDocument]([intDocumentId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemContractDocument',
		@level2type = N'COLUMN',
		@level2name = 'intItemContractDocumentId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemContractDocument',
		@level2type = N'COLUMN',
		@level2name = N'intItemContractId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Document Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemContractDocument',
		@level2type = N'COLUMN',
		@level2name = N'intDocumentId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemContractDocument',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemContractDocument',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'