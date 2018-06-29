CREATE TABLE tblETExportFilterTerm(
	[intExportFilterTermId] int IDENTITY(1,1) NOT NULL,
	[intTermId] int NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportFilterTerm] PRIMARY KEY CLUSTERED
(
	[intExportFilterTermId] ASC
), CONSTRAINT [FK_tblETExportFilterTerm_tblSMTerm] FOREIGN KEY ([intTermId]) REFERENCES tblSMTerm([intTermID]) ON DELETE CASCADE)