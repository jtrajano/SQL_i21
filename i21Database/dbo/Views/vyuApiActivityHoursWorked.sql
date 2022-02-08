CREATE VIEW [dbo].[vyuApiActivityHoursWorked]
AS
SELECT h.*, t.intRecordId
FROM vyuCRMHoursWorkedSearch h
OUTER APPLY (
	SELECT TOP 1 xt.intRecordId
	FROM tblSMTransaction xt
	JOIN tblSMActivity a ON a.intActivityId = xt.intRecordId
	WHERE xt.intScreenId = (SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strNamespace = 'GlobalComponentEngine.view.Activity')
		AND xt.intTransactionId = h.intTransactionId
) t