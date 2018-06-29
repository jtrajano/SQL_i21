CREATE TABLE dbo.tblQMSampleImportSampleType (
	intSampleImportSampleTypeId INT IDENTITY(1,1) NOT NULL
	,intSampleTypeId INT NOT NULL
	,intConcurrencyId INT NULL CONSTRAINT DF_tblQMSampleImportSampleType_intConcurrencyId DEFAULT 0

	,CONSTRAINT [PK_tblQMSampleImportSampleType] PRIMARY KEY ([intSampleImportSampleTypeId])
	,CONSTRAINT FK_tblQMSampleImportSampleType_tblQMSampleType FOREIGN KEY ([intSampleTypeId]) REFERENCES [tblQMSampleType]([intSampleTypeId])
	)
