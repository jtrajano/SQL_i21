CREATE TABLE [dbo].[tblSTSubCategories]
(
	[intSubcategoriesId] INT NOT NULL IDENTITY, 
    [intCategoryId] INT NOT NULL, 
    [strSubCategoryCode] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubCategory] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTSubCategories] PRIMARY KEY CLUSTERED ([intSubcategoriesId] ASC), 
    CONSTRAINT [AK_tblSTSubCategories_intCategoryId_strSubCategoryCode] UNIQUE NONCLUSTERED ([intCategoryId], [strSubCategoryCode] ASC), 
    CONSTRAINT [AK_tblSTSubCategories_intCategoryId_strSubCategory] UNIQUE NONCLUSTERED ([intCategoryId], [strSubCategory] ASC),
    CONSTRAINT [FK_tblSTSubCategories_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [tblICCategory]([intCategoryId]), 
);