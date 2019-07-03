  CREATE TABLE  tblSMInterCompanyMapping
  (
	[intInterCompanyMappingId] INT IDENTITY(1,1),
	[intCurrentTransactionId] INT NULL,
	[intReferenceTransactionId] INT NULL,
	[intReferenceCompanyId] INT NULL,
	[intConcurrencyId] int default(0),
	constraint [PK_dbo.tblSMInterCompanyMapping] PRIMARY KEY CLUSTERED ([intInterCompanyMappingId] ASC)
  )