CREATE TABLE tblMFScheduleRuleType (
	intScheduleRuleTypeId INT NOT NULL
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,CONSTRAINT PK_tblMFScheduleRuleType_intScheduleRuleId PRIMARY KEY (intScheduleRuleTypeId)
	,CONSTRAINT FK_tblMFScheduleRuleType_strName UNIQUE (strName)
	)