CREATE TABLE [dbo].[tblICCatalog]
(
	[intCatalogId] INT NOT NULL IDENTITY , 
    [intParentCatalogId] INT NULL, 
    [strCatalogName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[ysnLeaf] BIT NULL DEFAULT ((1)), 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICCatalog] PRIMARY KEY ([intCatalogId])
)
