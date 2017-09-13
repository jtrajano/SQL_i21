CREATE VIEW [dbo].[vyuSMContactControl]
AS 
SELECT intControlId
,cl.intScreenId
,strControlId
,strControlName
,strContainer
,strControlType
,cl.intConcurrencyId
FROM tblSMControl cl
INNER JOIN tblSMScreen sc ON cl.intScreenId = sc.intScreenId
INNER JOIN tblSMMasterMenu mm ON sc.strNamespace = LEFT(mm.strCommand, (CASE WHEN (CHARINDEX('?', mm.strCommand) - 1) < 0 THEN 0 ELSE (CHARINDEX('?', mm.strCommand) - 1) END))
INNER JOIN tblSMContactMenu cm ON mm.intMenuID = cm.intMasterMenuId
