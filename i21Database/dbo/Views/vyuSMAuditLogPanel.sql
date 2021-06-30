CREATE VIEW [dbo].[vyuSMAuditLogPanel]
AS

SELECT 
	tblSMAudit.intAuditId as intAuditLogId,
	tblSMLog.strName,
	ISNULL(B.strNamespace, tblSMScreen.strNamespace) as strScreenNamespace,
	ISNULL(B.strScreenName, tblSMScreen.strScreenName) as strTransactionType,
	tblSMAudit.strAction + ' a record' COLLATE Latin1_General_CI_AS as strActionType,
	CAST(tblSMTransaction.intRecordId AS NVARCHAR(MAX))
	strDescription,
	strRoute,
	tblSMLog.dtmDate,
	CAST(tblSMTransaction.intRecordId AS NVARCHAR(MAX)) as strRecordNo,
	tblSMLog.intEntityId,
	ISNULL(tblSMTransaction.strTransactionNo, '') as strTransactionNo,
	tblSMTransaction.dtmDate as dtmTransactionDate,
	tblSMTransaction.strName as strAuditName,
	tblSMTransaction.strDescription as strAuditDescription,
	strEntityType
FROM (SELECT 
		intLogId, 
		intOriginalScreenId,
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
left join tblSMScreen B on B.intScreenId = tblSMLog.intOriginalScreenId
where tblSMAudit.intParentAuditId IS NULL  --parent only 