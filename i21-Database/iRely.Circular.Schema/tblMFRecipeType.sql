CREATE TABLE [dbo].[tblMFRecipeType]
(
	[intRecipeTypeId] INT NOT NULL , 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    CONSTRAINT [PK_tblMFRecipeType_intRecipeTypeId] PRIMARY KEY ([intRecipeTypeId]), 
    CONSTRAINT [UQ_tblMFRecipeType_strName] UNIQUE ([strName]) 
)
