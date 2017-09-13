﻿CREATE VIEW [dbo].[vyuSMContactScreen]
AS
SELECT intScreenId
,strScreenId
,strScreenName
,strNamespace
,strModule
,strTableName
,ysnApproval
,ysnActivity
,ysnCustomTab
,ysnDocumentSource
,strApprovalMessage
,sc.intConcurrencyId
FROM tblSMScreen sc
INNER JOIN tblSMMasterMenu mm ON sc.strNamespace = LEFT(mm.strCommand, (CASE WHEN (CHARINDEX('?', mm.strCommand) - 1) < 0 THEN 0 ELSE (CHARINDEX('?', mm.strCommand) - 1) END))
INNER JOIN tblSMContactMenu cm ON mm.intMenuID = cm.intMasterMenuId