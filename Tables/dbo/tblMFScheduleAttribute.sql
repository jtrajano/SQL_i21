CREATE TABLE tblMFScheduleAttribute (
	intScheduleAttributeId INT NOT NULL
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strTableName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strColumnName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFScheduleAttribute_intScheduleAttributeId PRIMARY KEY (intScheduleAttributeId)
	,CONSTRAINT UQ_tblMFScheduleAttribute_strName UNIQUE (strName)
	)
