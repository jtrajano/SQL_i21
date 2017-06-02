CREATE TABLE dbo.tblMFOrderManifestLabel (
	intOrderManifestLabelId INT NOT NULL IDENTITY
	,intConcurrencyId INT CONSTRAINT [DF_tblMFOrderManifestLabel_intConcurrencyId] DEFAULT 0
	,intOrderManifestId INT NOT NULL
	,intCustomerLabelTypeId INT NOT NULL
	,strSSCCNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
	,ysnPrinted BIT NOT NULL CONSTRAINT [DF_tblMFOrderManifestLabel_ysnActive] DEFAULT 0

	,CONSTRAINT PK_tblMFOrderManifestLabel PRIMARY KEY (intOrderManifestLabelId)
	,CONSTRAINT FK_tblMFOrderManifestLabel_tblMFOrderManifest FOREIGN KEY (intOrderManifestId) REFERENCES tblMFOrderManifest(intOrderManifestId) ON DELETE CASCADE
	,CONSTRAINT FK_tblMFOrderManifestLabel_tblMFCustomerLabelType FOREIGN KEY (intCustomerLabelTypeId) REFERENCES tblMFCustomerLabelType(intCustomerLabelTypeId)
	)
