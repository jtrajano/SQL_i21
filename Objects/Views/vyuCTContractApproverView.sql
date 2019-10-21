CREATE VIEW [dbo].[vyuCTContractApproverView]
AS
SELECT Distinct intTransactionId AS intContractHeaderId
	,E.strName
	,US.strUserName AS strUserName
	,S.strScreenName
	,A.strTransactionNumber As strContractNumber
FROM tblSMApproval A
JOIN tblSMScreen S ON S.intScreenId = A.intScreenId
JOIN tblEMEntity E ON E.intEntityId = A.intApproverId
JOIN tblSMUserSecurity US on US.intEntityId =E.intEntityId 
WHERE A.strStatus = 'Approved'
	AND S.strNamespace = 'ContractManagement.view.Contract'
