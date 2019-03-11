CREATE VIEW [dbo].[vyuSMAuditLogPanel]
AS
--SELECT 
--intAuditLogId,
--en.strName,
--[dbo].[fnSMAddSpaceToTitleCase](right(strTransactionType, CHARINDEX('.', REVERSE(strTransactionType)) - 1), 0) COLLATE Latin1_General_CI_AS as strTransactionType,
--strActionType + ' a record' COLLATE Latin1_General_CI_AS as strActionType,
--strRecordNo
--strDescription,
--strRoute,
--dtmDate,
--strRecordNo,
--auditLog.intEntityId
--FROM tblSMAuditLog auditLog
--inner join tblEMEntity en on en.intEntityId = auditLog.intEntityId
SELECT 
tblSMAudit.intAuditId as 'intAuditLogId',
tblSMLog.strName,
tblSMScreen.strNamespace as strScreenNamespace,
tblSMScreen.strScreenName as strTransactionType,
tblSMAudit.strAction + ' a record' COLLATE Latin1_General_CI_AS as strActionType,
CAST(tblSMTransaction.intRecordId AS NVARCHAR(MAX))
strDescription,
strRoute,
tblSMLog.dtmDate,
CAST(tblSMTransaction.intRecordId AS NVARCHAR(MAX)) as strRecordNo,
tblSMLog.intEntityId,
case when tblSMTransaction.strTransactionNo is null then CAST(tblSMTransaction.intRecordId AS NVARCHAR(MAX))
else tblSMTransaction.strTransactionNo end as 'strReference',
tblSMTransaction.dtmDate as 'dtmTransactionDate',
strEntityType
FROM (select 
		intLogId, 
		dtmDate, 
		e.intEntityId, 
		e.intTransactionId, 
		e.strRoute,
		strName, 
		strEntityType  = case when b.intEntityContactId is null then 'User' else 'Portal User' end 
		from tblSMLog e with(nolock) 
		join ( select intEntityId, strName from tblEMEntity with(nolock) ) a 
				on e.intEntityId = a.intEntityId
				left join (select intEntityContactId from tblEMEntityToContact with(nolock)) b 
					on intEntityContactId = a.intEntityId
	)	 tblSMLog
inner join tblSMAudit tblSMAudit on tblSMAudit.intLogId = tblSMLog.intLogId
inner join tblSMTransaction tblSMTransaction on tblSMTransaction.intTransactionId = tblSMLog.intTransactionId
inner join tblSMScreen on tblSMScreen.intScreenId = tblSMTransaction.intScreenId
where tblSMAudit.intParentAuditId IS NULL  --parent only 