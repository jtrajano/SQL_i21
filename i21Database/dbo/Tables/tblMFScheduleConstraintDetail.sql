﻿CREATE TABLE tblMFScheduleConstraintDetail (
	intScheduleConstraintDetailId INT NOT NULL identity(1, 1)
	,intScheduleLineId INT NOT NULL
	,intScheduleRuleId INT NOT NULL
	,dtmChangeoverStartDate DATETIME NOT NULL
	,dtmChangeoverEndDate DATETIME NOT NULL
	,intDuration INT NOT NULL
	,CONSTRAINT PK_tblMFScheduleConstraintDetail_intScheduleConstraintDetailId PRIMARY KEY (intScheduleConstraintDetailId)
	,CONSTRAINT [FK_tblMFScheduleConstraintDetail_tblMFScheduleLine_intScheduleLineId] FOREIGN KEY (intScheduleLineId) REFERENCES tblMFScheduleWorkOrder(intScheduleWorkOrderId)
	,CONSTRAINT [FK_tblMFScheduleConstraintDetail_tblMFScheduleRule_intScheduleRuleId] FOREIGN KEY (intScheduleRuleId) REFERENCES tblMFScheduleRule(intScheduleRuleId)
	)
