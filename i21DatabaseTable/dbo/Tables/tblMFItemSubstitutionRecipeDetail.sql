CREATE TABLE [dbo].[tblMFItemSubstitutionRecipeDetail]
(
	[intItemSubstitutionRecipeDetailId] INT NOT NULL IDENTITY(1,1),
	[intItemSubstitutionId] INT NOT NULL, 
    [intItemSubstitutionDetailId] INT NOT NULL, 
    [intItemSubstitutionRecipeId] INT NOT NULL, 
    [intRecipeItemId] INT NULL,
	CONSTRAINT [PK_tblMFItemSubstitutionRecipeDetail_intItemSubstitutionDetailRecipeId] PRIMARY KEY ([intItemSubstitutionRecipeDetailId]), 
	CONSTRAINT [FK_tblMFItemSubstitutionRecipeDetail_tblMFItemSubstitution_intItemSubstitutionId] FOREIGN KEY ([intItemSubstitutionId]) REFERENCES [tblMFItemSubstitution]([intItemSubstitutionId]), 
	CONSTRAINT [FK_tblMFItemSubstitutionRecipeDetail_tblMFItemSubstitutionDetail_intItemSubstitutionDetailId] FOREIGN KEY ([intItemSubstitutionDetailId]) REFERENCES [tblMFItemSubstitutionDetail]([intItemSubstitutionDetailId]), 
	CONSTRAINT [FK_tblMFItemSubstitutionRecipeDetail_tblMFItemSubstitutionRecipe_intItemSubstitutionRecipeId] FOREIGN KEY ([intItemSubstitutionRecipeId]) REFERENCES [tblMFItemSubstitutionRecipe]([intItemSubstitutionRecipeId]), 
)
