CREATE TABLE tblETExportTaxCodeMapping(
	[intExportTaxCodeMappingId] int IDENTITY(1,1) NOT NULL,
	[intTaxCodeId] int NOT NULL,
	[strTaxCodeReference] NVARCHAR (50) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportTaxCodeMapping] PRIMARY KEY CLUSTERED([intExportTaxCodeMappingId] ASC), 
CONSTRAINT [FK_tblETExportTaxCodeMapping_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [tblSMTaxCode]([intTaxCodeId]) ON DELETE CASCADE)
