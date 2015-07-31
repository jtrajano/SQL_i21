CREATE TABLE tblMFSchedule (
	intScheduleId INT NOT NULL identity(1, 1)
	,strScheduleNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,dtmScheduleDate DATETIME NOT NULL
	,intCalendarId INT NOT NULL
	,intManufacturingCellId INT NOT NULL
	,ysnStandard BIT NOT NULL
	,intLocationId INT NOT NULL
	,intConcurrencyId INT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,CONSTRAINT PK_tblMFSchedule_intScheduleId PRIMARY KEY (intScheduleId)
	,CONSTRAINT UQ_tblMFSchedule_intScheduleNo_intLocationId UNIQUE (
		strScheduleNo
		,intLocationId
		)
	,CONSTRAINT [FK_tblMFSchedule_tblMFScheduleCalendar_intCalendarId] FOREIGN KEY (intCalendarId) REFERENCES tblMFScheduleCalendar(intCalendarId)
	,CONSTRAINT [FK_tblMFSchedule_tblMFManufacturingCell_intManufacturingCellId] FOREIGN KEY (intManufacturingCellId) REFERENCES tblMFManufacturingCell(intManufacturingCellId)
	,CONSTRAINT [FK_tblMFSchedule_tblSMCompanyLocation_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	)