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
FROM tblSMApproval a
LEFT JOIN tblSMApproverGroup g ON g.intApproverGroupId = a.intApproverGroupId
LEFT JOIN tblEMEntity e ON e.intEntityId = a.intApproverId
