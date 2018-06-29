CREATE TABLE dbo.tblMFScheduledMaintenance (
	intScheduledMaintenanceId INT IDENTITY(1, 1) NOT NULL
	,intManufacturingCellId INT NULL
	,dtmStartDate DATETIME NOT NULL
	,dtmStartTime DATETIME NOT NULL
	,dtmEndDate DATETIME NOT NULL
	,dtmEndTime DATETIME NOT NULL
	,strReason NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intLocationId int Not NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,intCompanyId INT NULL
	,CONSTRAINT PK_tblMFScheduledMaintenance_intScheduledMaintenanceId PRIMARY KEY (intScheduledMaintenanceId)
	,CONSTRAINT [FK_tblMFScheduledMaintenance_tblMFManufacturingCellId_intManufacturingCellId] FOREIGN KEY (intManufacturingCellId) REFERENCES tblMFManufacturingCell(intManufacturingCellId)
	)