CREATE TABLE [dbo].[tblSTStoreDepartments]
(
	[intStoreDepartmentId] INT NOT NULL IDENTITY, 
	[intStoreId] INT NOT NULL, 
    [intCategoryId] INT NULL, 
	[intSubcategoriesId] INT NULL,
    [strRegisterCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblSTStoreDepartments] PRIMARY KEY ([intStoreDepartmentId]),
	CONSTRAINT [FK_tblSTStoreDepartments_tblSTStore] FOREIGN KEY ([intStoreId]) REFERENCES [tblSTStore]([intStoreId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSTStoreDepartments_tblICCategory_intCategoryId] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId]),
	CONSTRAINT [FK_tblSTStoreDepartments_tblSTSubCategories_intSubcategoriesId] FOREIGN KEY ([intSubcategoriesId]) REFERENCES [dbo].[tblSTSubCategories] ([intSubcategoriesId])
)