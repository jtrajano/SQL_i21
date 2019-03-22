CREATE TABLE tblETExportFilterTaxGroup(
	[intExportFilterTaxGroupId] int IDENTITY(1,1) NOT NULL,
	[intTaxGroupId] int NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportFilterTaxGroup] PRIMARY KEY CLUSTERED
(
	[intExportFilterTaxGroupId] ASC
), CONSTRAINT [FK_tblETExportFilterTaxGroup_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId]) ON DELETE CASCADE)