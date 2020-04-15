CREATE VIEW [dbo].[vyuIPContractSubmittedByView]
AS
SELECT DISTINCT A.intTransactionId AS intContractHeaderId
	,E.strName
	,US.strUserName AS strUserName
	,S.strScreenName
	,B.strTransactionNo AS strContractNumber
FROM tblSMApproval A
JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId
JOIN tblSMScreen S ON S.intScreenId = A.intScreenId
JOIN tblEMEntity E ON E.intEntityId = A.intSubmittedById
JOIN tblSMUserSecurity US ON US.intEntityId = E.intEntityId
WHERE S.strNamespace = 'ContractManagement.view.Contract'

