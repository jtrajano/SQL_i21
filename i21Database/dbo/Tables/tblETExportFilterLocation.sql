CREATE TABLE tblETExportFilterLocation(
	[intExportFilterLocationId] int IDENTITY(1,1) NOT NULL,
	[intCompanyLocationId] int NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportFilterLocation] PRIMARY KEY CLUSTERED
(
	[intExportFilterLocationId] ASC
))