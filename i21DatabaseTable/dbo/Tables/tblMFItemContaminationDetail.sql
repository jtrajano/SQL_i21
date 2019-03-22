CREATE TABLE dbo.tblMFItemContaminationDetail (
	intItemContaminationDetailId INT IDENTITY(1, 1) NOT NULL
	,intItemContaminationId INT NOT NULL
	,intItemGroupId INT NOT NULL
	,intNoOfFlushes INT NOT NULL CONSTRAINT DF_tblMFItemContaminationDetail_intNoOfFlushes DEFAULT(0)
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFItemContaminationDetail_intItemContaminationDetailId PRIMARY KEY (intItemContaminationDetailId)
	,CONSTRAINT UQ_tblMFItemContaminationDetail_intItemContaminationId_intItemGroupId UNIQUE (
		intItemContaminationId
		,intItemGroupId
		)
	,CONSTRAINT FK_tblMFItemContaminationDetail_tblMFItemContamination_intItemContaminationId FOREIGN KEY (intItemContaminationId) REFERENCES tblMFItemContamination(intItemContaminationId) ON DELETE CASCADE
	,CONSTRAINT FK_tblMFItemContaminationDetail_tblMFItemGroup_intItemGroupId FOREIGN KEY (intItemGroupId) REFERENCES tblMFItemGroup(intItemGroupId)
	)