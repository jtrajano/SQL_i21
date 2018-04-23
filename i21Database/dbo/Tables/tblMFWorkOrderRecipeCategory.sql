CREATE TABLE [dbo].[tblMFWorkOrderRecipeCategory]
(
	[intWorkOrderId] INT NOT NULL,
	[intRecipeCategoryId] INT NOT NULL,
	[intRecipeId] INT NOT NULL,
	[intCategoryId] INT NOT NULL,
	[intRecipeItemTypeId] INT NOT NULL,
	CONSTRAINT [PK_tblMFWorkOrderRecipeCategory_intRecipeCategoryId] PRIMARY KEY ([intRecipeCategoryId],[intWorkOrderId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeCategory_tblMFWorkOrder_intWorkOrderId] FOREIGN KEY ([intWorkOrderId]) REFERENCES [tblMFWorkOrder]([intWorkOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblMFWorkOrderRecipeCategory_tblMFRecipe_intRecipeId] FOREIGN KEY ([intRecipeId]) REFERENCES [tblMFRecipe]([intRecipeId]), 
	CONSTRAINT [FK_tblMFWorkOrderRecipeCategory_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	CONSTRAINT [FK_tblMFWorkOrderRecipeCategory_tblMFRecipeItemType_intRecipeItemTypeId] FOREIGN KEY ([intRecipeItemTypeId]) REFERENCES [tblMFRecipeItemType]([intRecipeItemTypeId])
)
