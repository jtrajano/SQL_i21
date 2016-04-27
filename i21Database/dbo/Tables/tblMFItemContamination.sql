
CREATE TABLE dbo.tblMFItemContamination (
	intItemContaminationId INT IDENTITY(1, 1) NOT NULL
	,intItemId INT NOT NULL
	,intItemGroupId INT NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFItemContamination_intItemContaminationId PRIMARY KEY (intItemContaminationId)
	,CONSTRAINT UQ_tblMFItemContamination_intItemId UNIQUE (
		intItemId
		)
	,CONSTRAINT FK_tblMFItemContamination_tblICItem_intItemId FOREIGN KEY (intItemId) REFERENCES tblICItem(intItemId)
	,CONSTRAINT FK_tblMFItemContamination_tblMFItemGroup_intItemGroupId FOREIGN KEY (intItemGroupId) REFERENCES tblMFItemGroup(intItemGroupId)
	)