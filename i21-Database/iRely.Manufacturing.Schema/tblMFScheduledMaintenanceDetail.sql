CREATE TABLE dbo.tblMFScheduledMaintenanceDetail (
	intScheduledMaintenanceDetailId INT identity(1, 1)NOT NULL
	,intScheduledMaintenanceId INT NOT NULL
	,dtmCalendarDate DATETIME NOT NULL
	,intShiftId INT NOT NULL
	,dtmStartTime DATETIME NOT NULL
	,dtmEndTime DATETIME NOT NULL
	,intDuration INT NOT NULL
	,CONSTRAINT PK_tblMFScheduledMaintenanceDetail_intScheduledMaintenanceDetailId PRIMARY KEY (intScheduledMaintenanceDetailId)
	,CONSTRAINT FK_tblMFScheduledMaintenanceDetail_tblMFScheduledMaintenance_intScheduledMaintenanceId FOREIGN KEY (intScheduledMaintenanceId) REFERENCES tblMFScheduledMaintenance(intScheduledMaintenanceId) ON DELETE CASCADE
	)