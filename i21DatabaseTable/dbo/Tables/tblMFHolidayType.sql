CREATE TABLE tblMFHolidayType (
	intHolidayTypeId INT NOT NULL
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFHolidayType_intHolidayTypeId PRIMARY KEY (intHolidayTypeId)
	,CONSTRAINT UQ_tblMFHolidayType_strName UNIQUE (strName)
	)