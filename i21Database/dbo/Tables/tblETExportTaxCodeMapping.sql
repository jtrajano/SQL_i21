CREATE TABLE tblETExportTaxCodeMapping(
	[intExportTaxCodeMappingId] int IDENTITY(1,1) NOT NULL,
	[intTaxGroupId] int NOT NULL,
	[strTaxCodeReference] NVARCHAR (50) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportTaxCodeMapping] PRIMARY KEY CLUSTERED([intExportTaxCodeMappingId] ASC), 
CONSTRAINT [FK_tblETExportTaxCodeMapping_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId]) ON DELETE CASCADE)
