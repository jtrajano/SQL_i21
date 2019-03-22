CREATE TABLE tblMFScheduleRule (
	intScheduleRuleId INT NOT NULL identity(1, 1)
	,strName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intScheduleRuleTypeId INT NOT NULL
	,ysnActive BIT NOT NULL
	,intPriorityNo INT NOT NULL
	,strBackColorName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strComments NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intLocationId INT NOT NULL
	,intScheduleAttributeId INT
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFScheduleRule_intScheduleRuleId PRIMARY KEY (intScheduleRuleId)
	,CONSTRAINT UQ_tblMFScheduleAttribute_strName_intLocationId UNIQUE (
		strName
		,intLocationId
		)
	,CONSTRAINT FK_tblMFScheduleRule_tblMFScheduleAttribute_intScheduleAttributeId FOREIGN KEY (intScheduleAttributeId) REFERENCES tblMFScheduleAttribute(intScheduleAttributeId)
	,CONSTRAINT FK_tblMFScheduleRule_tblMFScheduleRuleType_intScheduleRuleTypeId FOREIGN KEY (intScheduleRuleTypeId) REFERENCES tblMFScheduleRuleType(intScheduleRuleTypeId)
	)