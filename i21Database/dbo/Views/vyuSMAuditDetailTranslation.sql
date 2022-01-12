CREATE VIEW [dbo].[vyuSMAuditDetailTranslation]  
AS  
  
SELECT 
	CASE WHEN 
		(CASE WHEN ISNULL(strAlias, '') = '' 
			THEN strChange 
			ELSE strAlias END) Like '%Password'  
	THEN '***' ELSE strFrom END				[from],
	CASE WHEN 
		(CASE WHEN ISNULL(strAlias, '') = '' 
			THEN strChange 
			ELSE strAlias END) Like '%Password'  
	THEN '***'ELSE strTo END				[to],
	strAction								[action],
	strAlias								[alias],
	CASE WHEN ISNULL(tblSMLanguageTranslation.strTranslation, '') <> '' 
		THEN tblSMLanguageTranslation.strTranslation 
		ELSE 
			CASE WHEN ISNULL(strAlias, '') = '' 
			THEN strChange 
			ELSE strAlias END 
		END	[change],
	tblSMLog.dtmDate						[changeDate],
	ysnHidden								[hidden],
	tblEMEntity.strName						[user],
	ysnField								[isField],
	''										[iconCls],
	tblSMAudit.intAuditId					[intAuditId],
	tblSMAudit.intLogId						[intLogId],
	tblSMAudit.intParentAuditId				[intParentAuditId],
	tblSMLanguageTranslation.intLanguageId	[intLanguageId]
FROM tblSMAudit 
INNER JOIN tblSMLog ON tblSMAudit.intLogId = tblSMLog.intLogId 
LEFT JOIN tblEMEntity ON tblSMLog.intEntityId = tblEMEntity.intEntityId 
LEFT JOIN tblSMLanguageTranslation ON tblSMLanguageTranslation.strLabel = (CASE WHEN ISNULL(strAlias, '') = '' THEN strChange ELSE strAlias END)