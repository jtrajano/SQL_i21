CREATE VIEW [dbo].[vyuSMAuditDetail]  
AS  
  
SELECT 
	CASE WHEN 
		(CASE WHEN ISNULL(strAlias, '') = '' THEN strChange ELSE strAlias END) Like '%Password'  
	THEN '***' ELSE strFrom END		[from],
	CASE WHEN 
		(CASE WHEN ISNULL(strAlias, '') = '' THEN strChange ELSE strAlias END) Like '%Password'  
	THEN '***'ELSE strTo END		[to],
	strAction						[action],
	strAlias						[alias],
	(CASE WHEN ISNULL(strAlias, '') = '' THEN strChange ELSE strAlias END) [change],
	tblSMLog.dtmDate				[changeDate],
	ysnHidden						[hidden],
	tblEMEntity.strName				[user],
	ysnField						[isField],
	''								[iconCls],
	tblSMAudit.intAuditId			[intAuditId],
	tblSMAudit.intLogId				[intLogId],
	tblSMAudit.intParentAuditId		[intParentAuditId]
FROM tblSMAudit 
INNER JOIN tblSMLog ON tblSMAudit.intLogId = tblSMLog.intLogId 
LEFT JOIN tblEMEntity ON tblSMLog.intEntityId = tblEMEntity.intEntityId 