
CREATE TABLE tblMFScheduleGroup (
	intScheduleGroupId INT NOT NULL
	,strGroupName NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,strDescription NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,intScheduleRuleId INT NOT NULL
	,intLocationId INT NOT NULL
	,dtmCreated DATETIME NOT NULL
	,intCreatedUserId INT NOT NULL
	,dtmLastModified DATETIME NOT NULL
	,intLastModifiedUserId INT NOT NULL
	,intConcurrencyId INT
	,CONSTRAINT PK_tblMFScheduleGroup_intScheduleGroupId PRIMARY KEY (intScheduleGroupId)
	,CONSTRAINT UQ_tblMFScheduleGroup_strGroupName_intLocationId UNIQUE (
		strGroupName
		,intLocationId
		)
	,CONSTRAINT FK_tblMFScheduleGroup_tblSMCompanyLocation_intLocationId FOREIGN KEY (intLocationId) REFERENCES tblSMCompanyLocation(intCompanyLocationId)
	,CONSTRAINT FK_tblMFScheduleGroup_tblMFScheduleRule_intScheduleRuleId FOREIGN KEY (intScheduleRuleId) REFERENCES tblMFScheduleRule(intScheduleRuleId)
	)
