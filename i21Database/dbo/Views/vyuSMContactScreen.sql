CREATE VIEW [dbo].[vyuSMContactScreen]
AS
SELECT intScreenId
,strScreenId
--,strScreenName
--,strModule
,REPLACE(mm.strMenuName, '(Portal)', '' )AS strScreenName
,sc.strGroupName AS strModule
,strNamespace
,strTableName
,ysnApproval
,ysnActivity
,ysnCustomTab
,ysnDocumentSource
,strApprovalMessage
,sc.intConcurrencyId
,sc.ysnAvailable
FROM tblSMScreen sc
INNER JOIN tblSMMasterMenu mm ON sc.strNamespace = LEFT(mm.strCommand, (CASE WHEN (CHARINDEX('?', mm.strCommand) - 1) < 0 THEN 0 ELSE (CHARINDEX('?', mm.strCommand) - 1) END))
INNER JOIN tblSMContactMenu cm ON mm.intMenuID = cm.intMasterMenuId