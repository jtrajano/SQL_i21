CREATE VIEW vyuMFGetChangeOverGroup
AS
SELECT SG.intScheduleGroupId
	,SG.strGroupName
	,SG.strDescription
	,SR.strName AS strScheduleRuleName
FROM dbo.tblMFScheduleGroup SG
JOIN dbo.tblMFScheduleRule SR ON SR.intScheduleRuleId = SG.intScheduleRuleId
