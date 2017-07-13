CREATE TABLE [dbo].[tblCFExportTaxMapping] (
    [intExportTaxMappingId] INT            IDENTITY (1, 1) NOT NULL,
    [strExportTaxMapping]   NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intImportFileHeaderId] INT            NOT NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblCFExportTaxMapping_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFExportTaxMapping] PRIMARY KEY CLUSTERED ([intExportTaxMappingId] ASC),
    CONSTRAINT [FK_tblCFExportTaxMapping_tblSMImportFileHeader] FOREIGN KEY ([intImportFileHeaderId]) REFERENCES [dbo].[tblSMImportFileHeader] ([intImportFileHeaderId])
);



