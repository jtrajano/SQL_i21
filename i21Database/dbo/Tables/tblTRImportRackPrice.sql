CREATE TABLE [dbo].[tblTRImportRackPrice]
(
	[intImportRackPriceId] INT NOT NULL IDENTITY, 
    [dtmImportDate] DATETIME NULL DEFAULT (GETDATE()), 
	[intFieldMappingId] INT NOT NULL,
    [strFilename] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblTRImportRackPrice] PRIMARY KEY ([intImportRackPriceId]), 
    CONSTRAINT [FK_tblTRImportRackPrice_tblSMImportFileHeader] FOREIGN KEY ([intFieldMappingId]) REFERENCES [tblSMImportFileHeader]([intImportFileHeaderId])
)