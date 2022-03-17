CREATE VIEW [dbo].[vyuApiRecordAudit]
AS

SELECT
      t.intRecordId
    , s.strModule
    , s.strScreenName
    , s.intScreenId
	, s.strNamespace
    , t.intTransactionId
    , a.strAction
    , MAX(l.dtmDate) dtmDate
FROM tblSMAudit a
INNER JOIN tblSMLog l ON l.intLogId = a.intLogId
INNER JOIN tblSMTransaction t ON t.intTransactionId = l.intTransactionId
	AND t.intRecordId = a.intKeyValue
INNER JOIN tblSMScreen s ON s.intScreenId = t.intScreenId
WHERE l.strType = 'Audit'
	AND ISNULL(a.ysnHidden, 0) = 0
	AND ISNULL(a.ysnField, 0) = 0
	AND a.strAction IN ('Created', 'Updated', 'Deleted')
GROUP BY a.strAction, t.intRecordId, s.strModule, s.strScreenName, s.intScreenId, s.strNamespace, t.intTransactionId