CREATE VIEW [dbo].[vyuIPPriceContractSubmittedByView]
AS
SELECT Distinct B.intRecordId AS intPriceContractId
	,E.strName
	,US.strUserName AS strUserName
	,S.strScreenName
	,B.strTransactionNo As strContractNumber
FROM tblSMApproval A
JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId
JOIN tblSMScreen S ON S.intScreenId = A.intScreenId
JOIN tblEMEntity E ON E.intEntityId = A.intSubmittedById
JOIN tblSMUserSecurity US on US.intEntityId =E.intEntityId 
WHERE S.strNamespace = 'ContractManagement.view.PriceContracts'
