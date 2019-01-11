CREATE VIEW [dbo].[vyuSMAuditLogPanel]
AS
SELECT 
intAuditLogId,
en.strName,
[dbo].[fnSMAddSpaceToTitleCase](right(strTransactionType, CHARINDEX('.', REVERSE(strTransactionType)) - 1), 0) COLLATE Latin1_General_CI_AS as strTransactionType,
strActionType + ' a record' COLLATE Latin1_General_CI_AS as strActionType,
strRecordNo
strDescription,
strRoute,
dtmDate,
strRecordNo,
auditLog.intEntityId
FROM tblSMAuditLog auditLog
inner join tblEMEntity en on en.intEntityId = auditLog.intEntityId