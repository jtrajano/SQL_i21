CREATE TABLE tblMFHolidayCalendar (
	intHolidayId INT NOT NULL identity(1, 1)
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intHolidayTypeId INT NOT NULL
	,dtmFromDate DATETIME NOT NULL
	,dtmToDate DATETIME NOT NULL
	,strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intLocationId INT NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFHolidayCalendar_intHolidayId PRIMARY KEY (intHolidayId)
	,CONSTRAINT UQ_tblMFHolidayCalendar_strName_dtmFromDate_dtmToDate_intLocationId UNIQUE (
		strName
		,dtmFromDate
		,dtmToDate
		,intLocationId
		)
	,CONSTRAINT FK_tblMFHolidayCalendar_tblSMCompanyLocation_intLocationId FOREIGN KEY (intLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId)
	,CONSTRAINT FK_tblMFHolidayCalendar_tblMFHolidayType_intHolidayTypeId FOREIGN KEY (intHolidayTypeId) REFERENCES tblMFHolidayType(intHolidayTypeId)
	)