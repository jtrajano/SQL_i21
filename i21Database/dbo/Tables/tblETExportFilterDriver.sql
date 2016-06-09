CREATE TABLE tblETExportFilterDriver(  
    [intExportFilterDriverId] int IDENTITY(1,1) NOT NULL,
	[intEntitySalesPersonId] int NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
CONSTRAINT [PK_tblETExportFilterDriver] PRIMARY KEY CLUSTERED 
(
	[intExportFilterDriverId] ASC
))