CREATE VIEW [dbo].[vyuICGetImportSetup]
AS 

SELECT 
	s.intImportSetupId
	,s.strName
	,s.strFolder
	,s.strArchiveFolder
	,strSchedule = schedule.strDescription
	,strTemplate = template.strName
	,s.intEdiMapTemplateId
	,s.intScheduleId 
	,strCronExpression = 
		/*
			CRON Expression
			-------------------------------------------------------------
			Field			Description
			------------	-----------------------------------------------------
			Seconds			0-59
			Minutes			0-59
			Hours			0-23
			Day of Month	1-31 
			Month			1-12 or JAN-DEC
			Day of Week		0-6 or SUN-SAT
		*/
		dbo.fnFormatMessage(
			'0 %s %s %s * %s'
			,ISNULL(CAST(DATEPART(MINUTE, schedule.dtmRunTime) AS NVARCHAR(3)), '*') -- Minute
			,ISNULL(CAST(DATEPART(HOUR, schedule.dtmRunTime) AS NVARCHAR(3)), '*') -- Hour
			,ISNULL(CAST(NULLIF(schedule.intDayOfMonth, 0) AS NVARCHAR(3)), '?') -- Day of Month
			,dbo.fnCronDayOfWeek(
				schedule.ysnSunday
				,schedule.ysnMonday
				,schedule.ysnTuesday
				,schedule.ysnWednesday
				,schedule.ysnThursday
				,schedule.ysnFriday
				,schedule.ysnSaturday
			) -- Day of Week
			,DEFAULT 
			,DEFAULT 
			,DEFAULT 
			,DEFAULT 
			,DEFAULT 
			,DEFAULT 
		) 
FROM
	tblICImportSetup s LEFT JOIN tblSCHSchedule schedule 
		ON s.intScheduleId = schedule.intScheduleId
	LEFT JOIN tblICEdiMapTemplate template
		ON s.intEdiMapTemplateId = template.intEdiMapTemplateId

GO 