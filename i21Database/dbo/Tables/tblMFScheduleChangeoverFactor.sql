
CREATE TABLE tblMFScheduleChangeoverFactor (
	intChangeoverFactorId INT NOT NULL
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intManufacturingCellId INT
	,intLocationId INT NOT NULL
	,ysnApplicableWithinGroup BIT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFScheduleChangeoverFactor_intChangeoverFactorId PRIMARY KEY (intChangeoverFactorId)
	,CONSTRAINT UQ_tblMFScheduleChangeoverFactor_strName_intManufacturingCellId_intLocationId UNIQUE (
		strName
		,intManufacturingCellId
		,intLocationId
		)
	,CONSTRAINT [FK_tblMFScheduleChangeoverFactor_tblMFManufacturingCell_intManufacturingCell] FOREIGN KEY (intManufacturingCellId) REFERENCES tblMFManufacturingCell(intManufacturingCellId)
	,CONSTRAINT FK_tblMFScheduleChangeoverFactor_tblSMCompanyLocation_intLocationId FOREIGN KEY (intLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId)
	)