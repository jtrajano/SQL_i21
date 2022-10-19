CREATE TABLE [dbo].[tblQMCatalogueType]
(
	[intCatalogueTypeId] INT IDENTITY(1,1) NOT NULL,
	[strCatalogueType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT 0, 
	CONSTRAINT [PK_tblQMCatalogueType] PRIMARY KEY ([intCatalogueTypeId])
)
