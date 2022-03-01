CREATE VIEW [dbo].[vyuApiRecordAuditPivot]
AS

SELECT a.intRecordId, a.intScreenId, a.intTransactionId, a.strModule, a.strNamespace, a.strScreenName
	, MAX(CASE WHEN a.strAction = 'Created' THEN a.dtmDate ELSE NULL END) dtmDateCreated
	, MAX(CASE WHEN a.strAction = 'Deleted' THEN a.dtmDate ELSE NULL END) dtmDateDeleted
	, MAX(CASE WHEN a.strAction = 'Updated' THEN a.dtmDate ELSE NULL END) dtmDateModified
FROM vyuApiRecordAudit a
GROUP BY a.intRecordId, a.intScreenId, a.intTransactionId, a.strModule, a.strNamespace, a.strScreenName