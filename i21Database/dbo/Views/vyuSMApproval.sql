CREATE VIEW [dbo].[vyuSMApproval]
AS
SELECT Approval.intApprovalId, 
Approval.intApproverId, 
Screen.strScreenName as strType, 
Approval.dtmDate, 
Approval.strTransactionNumber, 
Entity.strName as strSubmittedBy, 
Approval.dblAmount, 
Approval.dtmDueDate, 
Approval.strStatus, 
Approval.strComment
FROM tblSMApproval Approval 
INNER JOIN tblSMTransaction Transactions ON Approval.intTransactionId = Transactions.intTransactionId
INNER JOIN tblSMScreen Screen ON Transactions.intScreenId = Screen.intScreenId
INNER JOIN tblEMEntity Entity ON Approval.intSubmittedById = Entity.intEntityId
WHERE Approval.dtmDate = (SELECT MAX(dtmDate) FROM tblSMApproval WHERE intTransactionId = Transactions.intTransactionId)
GO
