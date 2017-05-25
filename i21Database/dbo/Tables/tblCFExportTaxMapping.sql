CREATE TABLE [dbo].[tblCFExportTaxMapping] (
    [intExportTaxMappingId] INT           IDENTITY (1, 1) NOT NULL,
    [strExportTaxMapping]   NVARCHAR (50) NOT NULL,
    [intImportFileHeaderId] INT           NOT NULL,
    [intConcurrencyId]      INT           CONSTRAINT [DF_tblCFExportTaxMapping_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFExportTaxMapping] PRIMARY KEY CLUSTERED ([intExportTaxMappingId] ASC),
    CONSTRAINT [FK_tblCFExportTaxMapping_tblSMImportFileHeader] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId])
);

GO
CREATE UNIQUE NONCLUSTERED INDEX tblCFExportTaxMapping_UniqueExportTaxMapping
	ON tblCFExportTaxMapping (strExportTaxMapping);