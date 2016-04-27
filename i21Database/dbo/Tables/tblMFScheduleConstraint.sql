CREATE TABLE tblMFScheduleConstraint (
	intScheduleConstraintId INT NOT NULL identity(1, 1)
	,intScheduleId INT NOT NULL
	,intScheduleRuleId INT NOT NULL
	,CONSTRAINT PK_tblMFScheduleConstraint_intScheduleConstraintId PRIMARY KEY (intScheduleConstraintId)
	,CONSTRAINT [FK_tblMFScheduleConstraint_tblMFScheduleRule_intScheduleRuleId] FOREIGN KEY (intScheduleRuleId) REFERENCES tblMFScheduleRule(intScheduleRuleId)
	,CONSTRAINT [FK_tblMFScheduleConstraint_tblMFSchedule_intScheduleId] FOREIGN KEY (intScheduleId) REFERENCES [dbo].[tblMFSchedule](intScheduleId) ON DELETE CASCADE
	)
