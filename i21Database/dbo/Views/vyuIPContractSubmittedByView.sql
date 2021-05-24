CREATE VIEW [dbo].[vyuIPContractSubmittedByView]
AS
SELECT intContractHeaderId
	,strName
	,strUserName
	,strScreenName
	,strContractNumber
FROM (
	SELECT DISTINCT A.intTransactionId AS intContractHeaderId
		,E.strName
		,US.strUserName AS strUserName
		,S.strScreenName
		,B.strTransactionNo AS strContractNumber
		,Rank() OVER (
			PARTITION BY A.intTransactionId ORDER BY intApprovalId DESC
			) intRowId
	FROM tblSMApproval A
	JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId
	JOIN tblSMScreen S ON S.intScreenId = A.intScreenId
	JOIN tblEMEntity E ON E.intEntityId = A.intSubmittedById
	JOIN tblSMUserSecurity US ON US.intEntityId = E.intEntityId
	WHERE S.strNamespace IN (
			'ContractManagement.view.Contract'
			,'ContractManagement.view.Amendments'
			)
		AND A.strStatus IN (
			'Submitted'
			,'Resubmitted'
			)
	) AS DT
WHERE DT.intRowId = 1
