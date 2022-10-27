CREATE TABLE [dbo].[tblQMCatalogueImportDefaults]
(
	[intCatalogueImportDefaultId] INT NOT NULL IDENTITY,
    [intConcurrencyId] INT NOT NULL DEFAULT(0),
    [intDefaultItemId] INT NULL,
    [intDefaultSampleUOMId] INT NULL,
    [intDefaultRepresentingUOMId] INT NULL,
	CONSTRAINT [PK_tblQMImportLogCatalogue_intCatalogueImportDefaultId] PRIMARY KEY CLUSTERED ([intCatalogueImportDefaultId] ASC)
)
GO