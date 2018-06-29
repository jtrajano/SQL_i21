CREATE TABLE [dbo].[tblMFRecipeCategory]
(
	[intRecipeCategoryId] INT NOT NULL  IDENTITY(1,1),
	[intRecipeId] INT NOT NULL,
	[intCategoryId] INT NOT NULL,
	[intRecipeItemTypeId] INT NOT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFRecipeCategory_intConcurrencyId] DEFAULT 0,
	CONSTRAINT [PK_tblMFRecipeCategory_intRecipeCategoryId] PRIMARY KEY ([intRecipeCategoryId]), 
	CONSTRAINT [FK_tblMFRecipeCategory_tblMFRecipe_intRecipeId] FOREIGN KEY ([intRecipeId]) REFERENCES [tblMFRecipe]([intRecipeId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblMFRecipeCategory_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [FK_tblMFRecipeCategory_tblMFRecipeItemType_intRecipeItemTypeId] FOREIGN KEY ([intRecipeItemTypeId]) REFERENCES [tblMFRecipeItemType]([intRecipeItemTypeId])
)
