CREATE TABLE [dbo].[tblICCatalog]
(
	[intCatalogId] INT NOT NULL IDENTITY , 
    [intParentCatalogId] INT NULL, 
    [strCatalogName] NVARCHAR(50) NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCatalog] PRIMARY KEY ([intCatalogId])
)
