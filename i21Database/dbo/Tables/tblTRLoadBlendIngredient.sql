CREATE TABLE [dbo].[tblTRLoadBlendIngredient]
(
	[intLoadBlendIngredientId] INT NOT NULL, 
    [intLoadDistributionDetailId] INT NOT NULL, 
	[intRecipeItemId] INT NOT NULL,
    [dblQuantity] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [intConcurrencyId] INT NOT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTRLoadBlendIngredient] PRIMARY KEY ([intLoadBlendIngredientId]), 
    CONSTRAINT [FK_tblTRLoadBlendIngredient_tblTRLoadDistributionDetail] FOREIGN KEY ([intLoadDistributionDetailId]) REFERENCES [tblTRLoadDistributionDetail]([intLoadDistributionDetailId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTRLoadBlendIngredient_tblMFRecipeItem] FOREIGN KEY ([intRecipeItemId]) REFERENCES [tblMFRecipeItem]([intRecipeItemId])
)
