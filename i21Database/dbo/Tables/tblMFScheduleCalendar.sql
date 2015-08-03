CREATE TABLE tblMFScheduleCalendar (
	intCalendarId INT NOT NULL identity(1, 1)
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intManufacturingCellId INT
	,dtmFromDate DATETIME NOT NULL
	,dtmToDate DATETIME NOT NULL
	,ysnStandard BIT NOT NULL
	,intLocationId INT NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFScheduleCalendar_intCalendarId PRIMARY KEY (intCalendarId)
	,CONSTRAINT UQ_tblMFScheduleCalendar_strName_intLocationId UNIQUE (
		strName
		,intLocationId
		)
	,CONSTRAINT [FK_tblMFScheduleCalendar_tblSMCompanyLocation_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	,CONSTRAINT [FK_tblMFScheduleCalendar_tblMFManufacturingCellId_intManufacturingCellId] FOREIGN KEY (intManufacturingCellId) REFERENCES tblMFManufacturingCell(intManufacturingCellId)
	)
