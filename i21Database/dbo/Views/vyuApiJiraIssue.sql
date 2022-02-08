CREATE VIEW [dbo].[vyuApiJiraIssue]
AS
SELECT i.intJiraIssueId, i.strJiraKey, i.intTransactionId, t.intActivityId
FROM tblCRMJiraIssue i
OUTER APPLY (
	SELECT TOP 1 a.intActivityId
	FROM tblSMTransaction xt
	JOIN tblSMActivity a ON a.intActivityId = xt.intRecordId
	WHERE xt.intScreenId = (SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.Activity')
		AND xt.intTransactionId = i.intTransactionId
) t