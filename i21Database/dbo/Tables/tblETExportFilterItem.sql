CREATE TABLE tblETExportFilterItem(
	[intExportFilterItemId] int IDENTITY(1,1) NOT NULL,
	[intItemId] int NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportFilterItem] PRIMARY KEY CLUSTERED
(
	[intExportFilterItemId] ASC
))