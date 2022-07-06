CREATE TABLE [dbo].[tblQMQualityCriteria]
(
	intQualityCriteriaId INT NOT NULL IDENTITY, 
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblQMQualityCriteria_intConcurrencyId] DEFAULT 0, 

	intItemId INT NOT NULL,
	intSampleTypeId INT,

	CONSTRAINT [PK_tblQMQualityCriteria] PRIMARY KEY (intQualityCriteriaId), 
	CONSTRAINT [AK_tblQMQualityCriteria_intItemId] UNIQUE (intItemId), 
	CONSTRAINT [FK_tblQMQualityCriteria_tblICItem] FOREIGN KEY (intItemId) REFERENCES [tblICItem](intItemId), 
	CONSTRAINT [FK_tblQMQualityCriteria_tblQMSampleType] FOREIGN KEY (intSampleTypeId) REFERENCES [tblQMSampleType](intSampleTypeId)
)