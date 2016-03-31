CREATE TABLE [dbo].[tblEMEntitySplitExceptionCategory]
(
	[intEntitySplitExceptionCategoryId]		INT IDENTITY(1,1) NOT NULL, 
	[intSplitId]							INT NOT NULL,
    [intCategoryId]							INT NOT NULL,	
	[intConcurrencyId]						INT             CONSTRAINT [DF_tblEMEntitySplitExceptionCategory_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblEMEntitySplitExceptionCategory] PRIMARY KEY CLUSTERED ([intEntitySplitExceptionCategoryId] ASC),
    CONSTRAINT [FK_tblEMEntitySplitExceptionCategory_tblEMEntitySplit] FOREIGN KEY ([intSplitId]) REFERENCES [dbo].[tblEMEntitySplit] ([intSplitId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_dbo_tblEMEntitySplitExceptionCategory_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])
)
