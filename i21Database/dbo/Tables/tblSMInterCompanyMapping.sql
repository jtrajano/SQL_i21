  CREATE TABLE  tblSMInterCompanyMapping
  (
	[intInterCompanyMappingId] INT IDENTITY(1,1),
	[intSourceTransactionId] INT NULL,
	[intDestinationCompanyId] INT NULL,
	[intDestinationTransactionId] INT NULL,
	[intConcurrencyId] int default(0),
	constraint [PK_dbo.tblSMInterCompanyMapping] PRIMARY KEY CLUSTERED ([intInterCompanyMappingId] ASC)
  )