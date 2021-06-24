CREATE VIEW [dbo].[vyuICGetImportSetup]
AS 

SELECT 
	s.intImportSetupId
	,s.strName
	,s.strFolder
	,s.strArchiveFolder
	,strSchedule = schedule.strDescription
	,strTemplate = template.strName
FROM
	tblICImportSetup s LEFT JOIN tblSCHSchedule schedule 
		ON s.intScheduleId = schedule.intScheduleId
	LEFT JOIN tblICEdiMapTemplate template
		ON s.intEdiMapTemplateId = template.intEdiMapTemplateId

GO 