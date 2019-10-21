CREATE TYPE [dbo].[ScheduleConstraintTable] AS TABLE (
	intScheduleConstraintId INT identity(1, 1)
	,intScheduleRuleId INT
	,intPriorityNo INT
	)
