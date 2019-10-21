CREATE TABLE [dbo].[tblSTSubcategory]
(
	[intSubcategoryId] INT NOT NULL IDENTITY, 
    [strSubcategoryType] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubcategoryId] NVARCHAR(8) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubcategoryDesc] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [strSubCategoryComment] NVARCHAR(90) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTSubcategory] PRIMARY KEY CLUSTERED ([intSubcategoryId] ASC), 
    CONSTRAINT [AK_tblSTSubcategory_strSubcategoryType_strSubcategoryId] UNIQUE NONCLUSTERED ([strSubcategoryType],[strSubcategoryId] ASC)
);
