CREATE TABLE [dbo].[tblMFRecipeItemType]
(
	[intRecipeItemTypeId] INT NOT NULL, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblMFRecipeItemType_intRecipeItemTypeId] PRIMARY KEY ([intRecipeItemTypeId]), 
    CONSTRAINT [UQ_tblMFRecipeItemType_strName] UNIQUE ([strName]) 
)
