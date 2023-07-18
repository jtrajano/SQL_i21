CREATE VIEW [dbo].[vyuMFScheduleRule]
AS 
/****************************************************************
	Title: Schedule Rule View
	Description: 23.1 Merging of Old Codes
	JIRA: MFG-4651
	Created By: Jonathan Valenzuela
	Date: 07/07/2023
*****************************************************************/
SELECT ScheduleRule.intScheduleRuleId
	 , ScheduleRule.strName					AS strScheduleRuleName
	 , ScheduleRule.intScheduleRuleTypeId
	 , RuleType.strName						AS strScheduleRuleTypeName
	 , ScheduleRule.ysnActive
	 , ScheduleRule.intPriorityNo
	 , ScheduleRule.strComments
	 , CONVERT(BIT, CASE WHEN ScheduleConstraint.intScheduleConstraintId IS NULL THEN 0
						 ELSE 1
					END)					AS ysnSelect
	 , ScheduleRule.intConcurrencyId
	 , ScheduleRule.intLocationId
	 , ScheduleConstraint.intScheduleId
FROM dbo.tblMFScheduleRule AS ScheduleRule
JOIN dbo.tblMFScheduleRuleType AS RuleType ON RuleType.intScheduleRuleTypeId = ScheduleRule.intScheduleRuleTypeId
LEFT JOIN dbo.tblMFScheduleConstraint AS ScheduleConstraint ON ScheduleConstraint.intScheduleRuleId = ScheduleRule.intScheduleRuleId