CREATE TABLE [dbo].[tblEntitySplitExceptionCategory]
(
	[intEntitySplitExceptionCategoryId]		INT IDENTITY(1,1) NOT NULL, 
	[intSplitId]							INT NOT NULL,
    [intCategoryId]							INT NOT NULL,	
	[intConcurrencyId]						INT             CONSTRAINT [DF_tblEntitySplitExceptionCategory_intConcurrencyId] DEFAULT ((0)) NOT NULL,
	CONSTRAINT [PK_tblEntitySplitExceptionCategory] PRIMARY KEY CLUSTERED ([intEntitySplitExceptionCategoryId] ASC),
    CONSTRAINT [FK_tblEntitySplitExceptionCategory_tblEntitySplit] FOREIGN KEY ([intSplitId]) REFERENCES [dbo].[tblEntitySplit] ([intSplitId]) ON DELETE CASCADE,	
	CONSTRAINT [FK_dbo_tblEntitySplitExceptionCategory_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])
)
