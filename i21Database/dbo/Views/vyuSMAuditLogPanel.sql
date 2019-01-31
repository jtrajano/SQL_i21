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
en.strName,
[dbo].[fnSMAddSpaceToTitleCase](right(tblSMScreen.strNamespace, CHARINDEX('.', REVERSE(tblSMScreen.strNamespace)) - 1), 0) as strTransactionType,
tblSMAudit.strAction + ' a record' COLLATE Latin1_General_CI_AS as strActionType,
CAST(tblSMTransaction.intRecordId AS NVARCHAR(MAX))
strDescription,
strRoute,
tblSMLog.dtmDate,
CAST(tblSMTransaction.intRecordId AS NVARCHAR(MAX)) as strRecordNo,
tblSMLog.intEntityId
FROM tblSMLog tblSMLog
INNER JOIN tblSMAudit tblSMAudit on tblSMAudit.intLogId = tblSMLog.intLogId
INNER JOIN tblEMEntity en on en.intEntityId = tblSMLog.intEntityId
INNER JOIN tblSMTransaction tblSMTransaction on tblSMTransaction.intTransactionId = tblSMLog.intTransactionId
INNER JOIN tblSMScreen on tblSMScreen.intScreenId = tblSMTransaction.intScreenId
WHERE tblSMAudit.intParentAuditId IS NULL  --parent only 
