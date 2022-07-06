CREATE VIEW [dbo].[vyuApiApproval]
AS

SELECT
	  a.dtmDate
	, a.strStatus
    , a.intApprovalId
	, a.intTransactionId
	, a.strComment
	, g.strApproverGroup
	, e.strName strApprover
	, a.ysnVisible
	, a.intOrder
	, s.strNamespace
FROM tblSMApproval a
INNER JOIN tblSMTransaction t ON t.intTransactionId = a.intTransactionId
INNER JOIN tblSMScreen s ON s.intScreenId = t.intScreenId
LEFT JOIN tblSMApproverGroup g ON g.intApproverGroupId = a.intApproverGroupId
LEFT JOIN tblEMEntity e ON e.intEntityId = a.intApproverId
