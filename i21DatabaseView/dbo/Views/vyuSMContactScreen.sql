CREATE VIEW [dbo].[vyuSMContactScreen]
AS
SELECT intScreenId
,strScreenId
,REPLACE(mm.strMenuName, '(Portal)', '' )AS strScreenName
,RTRIM(ISNULL(sc.strGroupName,mm.strCategory)) COLLATE Latin1_General_CI_AS AS strModule 
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
INNER JOIN tblSMMasterMenu mm ON sc.strNamespace = LEFT(mm.strCommand, (CASE WHEN (CHARINDEX('?', mm.strCommand) - 1) < 0 THEN LEN(strCommand) ELSE (CHARINDEX('?', mm.strCommand) - 1) END))
INNER JOIN tblSMContactMenu cm ON mm.intMenuID = cm.intMasterMenuId