CREATE VIEW [dbo].[vyuCTContractApproverView]
AS
SELECT intTransactionId AS intContractHeaderId
	,E.strName
	,E.strName AS strUserName
	,S.strScreenName
FROM tblSMApproval A
JOIN tblSMScreen S ON S.intScreenId = A.intScreenId
JOIN tblEMEntity E ON E.intEntityId = A.intApproverId
WHERE A.strStatus = 'Approved'
	AND S.strNamespace = 'ContractManagement.view.Contract'
